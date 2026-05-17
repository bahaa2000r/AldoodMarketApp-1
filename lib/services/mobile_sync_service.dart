import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/local_database.dart';
import '../models/item_model.dart';
import '../models/person_model.dart';
import '../models/bank_operation_model.dart';

class MobileSyncResult {
  final int imported;
  final int skipped;
  final int conflicts;
  final String message;

  const MobileSyncResult({
    required this.imported,
    required this.skipped,
    required this.conflicts,
    required this.message,
  });
}

class MobileSyncService {
  static const _deviceIdKey = 'mobile_sync_device_id';
  static const _lastExportKey = 'mobile_sync_last_export_at';

  static Future<String> deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id == null || id.isEmpty) {
      id = 'mobile-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_deviceIdKey, id);
    }
    return id;
  }

  static String _now() => DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' ');

  static Future<String> exportPackage({String kind = 'full'}) async {
    final db = LocalDatabase.instance;
    final device = await deviceId();
    final createdAt = _now();
    final packageId = '$device-${DateTime.now().millisecondsSinceEpoch}';

    final payload = <String, dynamic>{
      'package_version': 1,
      'package_id': packageId,
      'package_kind': kind,
      'created_at': createdAt,
      'source_device': device,
      'source_device_name': 'هاتف الدود ماركت',
      'tables': {
        'items': {
          'columns': [
            'id', 'name', 'quantity', 'supplier_id', 'purchase_price',
            'wholesale_price', 'retail_price', 'warehouse_location', 'notes',
            'created_at', 'updated_at', 'sync_uuid', 'source_device', 'deleted_at'
          ],
          'rows': [
            for (final i in db.items)
              {
                'id': i.id,
                'name': i.name,
                'quantity': i.quantity,
                'supplier_id': null,
                'purchase_price': i.purchasePrice,
                'wholesale_price': i.wholesalePrice,
                'retail_price': i.retailPrice,
                'warehouse_location': i.storagePlace,
                'notes': '',
                'created_at': createdAt,
                'updated_at': createdAt,
                'sync_uuid': '$device-items-${i.id}',
                'source_device': device,
                'deleted_at': null,
              }
          ],
        },
        'customers': {
          'columns': ['id', 'name', 'phone', 'address', 'notes', 'created_at', 'updated_at', 'sync_uuid', 'source_device', 'deleted_at'],
          'rows': [
            for (final c in db.customers)
              {
                'id': c.id,
                'name': c.name,
                'phone': c.phone,
                'address': '',
                'notes': c.notes,
                'created_at': createdAt,
                'updated_at': createdAt,
                'sync_uuid': '$device-customers-${c.id}',
                'source_device': device,
                'deleted_at': null,
              }
          ],
        },
        'suppliers': {
          'columns': ['id', 'name', 'phone', 'address', 'notes', 'created_at', 'updated_at', 'sync_uuid', 'source_device', 'deleted_at'],
          'rows': [
            for (final s in db.suppliers)
              {
                'id': s.id,
                'name': s.name,
                'phone': s.phone,
                'address': '',
                'notes': s.notes,
                'created_at': createdAt,
                'updated_at': createdAt,
                'sync_uuid': '$device-suppliers-${s.id}',
                'source_device': device,
                'deleted_at': null,
              }
          ],
        },
        'bank_account_audit': {
          'columns': [
            'id', 'person_name', 'phone', 'account_name', 'operation_type',
            'expected_amount', 'received_amount', 'remaining_amount',
            'payment_method', 'tx_date', 'status', 'notes', 'created_by',
            'created_at', 'updated_at', 'sync_uuid', 'source_device', 'deleted_at'
          ],
          'rows': [
            for (final b in db.bankOperations)
              {
                'id': b.id,
                'person_name': b.name,
                'phone': '',
                'account_name': b.account,
                'operation_type': b.type,
                'expected_amount': b.originalAmount,
                'received_amount': b.transferredAmount,
                'remaining_amount': b.remaining,
                'payment_method': '',
                'tx_date': b.date.toIso8601String().substring(0, 19).replaceAll('T', ' '),
                'status': b.status,
                'notes': b.notes,
                'created_by': 'mobile',
                'created_at': createdAt,
                'updated_at': createdAt,
                'sync_uuid': '$device-bank-${b.id}',
                'source_device': device,
                'deleted_at': null,
              }
          ],
        },
      },
    };

    final data = utf8.encode(const JsonEncoder.withIndent('  ').convert(payload));
    final archive = Archive();
    archive.addFile(ArchiveFile('sync_data.json', data.length, data));
    final zipBytes = ZipEncoder().encode(archive)!;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/aldood_${kind}_sync_${DateTime.now().millisecondsSinceEpoch}.adsync');
    await file.writeAsBytes(zipBytes, flush: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastExportKey, createdAt);
    return file.path;
  }

  static Future<MobileSyncResult> importPackage() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['adsync', 'zip'],
      allowMultiple: false,
    );
    if (picked == null || picked.files.single.path == null) {
      return const MobileSyncResult(imported: 0, skipped: 0, conflicts: 0, message: 'لم يتم اختيار ملف.');
    }

    final bytes = await File(picked.files.single.path!).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final syncFile = archive.files.where((f) => f.name == 'sync_data.json').firstOrNull;
    if (syncFile == null) {
      return const MobileSyncResult(imported: 0, skipped: 0, conflicts: 1, message: 'الملف لا يحتوي على sync_data.json');
    }
    final payload = jsonDecode(utf8.decode(syncFile.content as List<int>)) as Map<String, dynamic>;
    final tables = (payload['tables'] as Map?) ?? {};
    final db = LocalDatabase.instance;
    int imported = 0;
    int skipped = 0;
    int conflicts = 0;

    try {
      final itemsRows = ((tables['items'] as Map?)?['rows'] as List?) ?? [];
      for (final raw in itemsRows) {
        final r = Map<String, dynamic>.from(raw as Map);
        final name = '${r['name'] ?? ''}'.trim();
        if (name.isEmpty) {
          skipped++;
          continue;
        }
        final exists = db.items.indexWhere((e) => e.name == name || e.id == (r['id'] as num?)?.toInt());
        final item = ItemModel(
          id: (r['id'] as num?)?.toInt() ?? (db.items.length + 1),
          name: name,
          quantity: (r['quantity'] as num?)?.toDouble() ?? 0,
          purchasePrice: (r['purchase_price'] as num?)?.toDouble() ?? 0,
          wholesalePrice: (r['wholesale_price'] as num?)?.toDouble() ?? 0,
          retailPrice: (r['retail_price'] as num?)?.toDouble() ?? 0,
          storagePlace: '${r['warehouse_location'] ?? ''}',
          supplier: '',
        );
        if (exists >= 0) {
          db.items[exists] = item;
        } else {
          db.items.add(item);
        }
        imported++;
      }

      for (final entry in [
        {'table': 'customers', 'list': db.customers},
        {'table': 'suppliers', 'list': db.suppliers},
      ]) {
        final tableName = entry['table'] as String;
        final list = entry['list'] as List<PersonModel>;
        final rows = ((tables[tableName] as Map?)?['rows'] as List?) ?? [];
        for (final raw in rows) {
          final r = Map<String, dynamic>.from(raw as Map);
          final name = '${r['name'] ?? ''}'.trim();
          if (name.isEmpty) {
            skipped++;
            continue;
          }
          final person = PersonModel(
            id: (r['id'] as num?)?.toInt() ?? (list.length + 1),
            name: name,
            phone: '${r['phone'] ?? ''}',
            notes: '${r['notes'] ?? ''}',
          );
          final exists = list.indexWhere((e) => e.name == person.name || e.id == person.id);
          if (exists >= 0) {
            list[exists] = person;
          } else {
            list.add(person);
          }
          imported++;
        }
      }

      final bankRows = ((tables['bank_account_audit'] as Map?)?['rows'] as List?) ?? [];
      for (final raw in bankRows) {
        final r = Map<String, dynamic>.from(raw as Map);
        final op = BankOperationModel(
          id: (r['id'] as num?)?.toInt() ?? (db.bankOperations.length + 1),
          name: '${r['person_name'] ?? ''}',
          account: '${r['account_name'] ?? ''}',
          type: '${r['operation_type'] ?? 'حوالة'}',
          originalAmount: (r['expected_amount'] as num?)?.toDouble() ?? 0,
          transferredAmount: (r['received_amount'] as num?)?.toDouble() ?? 0,
          date: DateTime.tryParse('${r['tx_date'] ?? ''}') ?? DateTime.now(),
          notes: '${r['notes'] ?? ''}',
        );
        final exists = db.bankOperations.indexWhere((e) => e.id == op.id && e.name == op.name);
        if (exists >= 0) {
          db.bankOperations[exists] = op;
        } else {
          db.bankOperations.add(op);
        }
        imported++;
      }
    } catch (_) {
      conflicts++;
    }

    return MobileSyncResult(
      imported: imported,
      skipped: skipped,
      conflicts: conflicts,
      message: 'تم استقبال ملف المزامنة.',
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
