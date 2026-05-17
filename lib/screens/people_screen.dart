import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../database/local_database.dart';
import '../models/person_model.dart';
import '../widgets/action_bar.dart';
import '../widgets/section_box.dart';

enum PeopleKind { customers, suppliers }

class PeopleScreen extends StatelessWidget {
  final PeopleKind kind;
  const PeopleScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final List<PersonModel> data = kind == PeopleKind.customers
        ? LocalDatabase.instance.customers
        : LocalDatabase.instance.suppliers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionBox(
            title: kind == PeopleKind.customers ? 'بيانات العميل' : 'بيانات المورد',
            child: Column(
              children: [
                TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: kind == PeopleKind.customers ? 'اسم العميل' : 'اسم المورد')),
                const SizedBox(height: 10),
                const TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'الجوال')),
                const SizedBox(height: 10),
                const TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'ملاحظات')),
                const SizedBox(height: 12),
                ActionBar(children: [
                  FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('إضافة')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('تعديل')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.delete), label: const Text('حذف')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file), label: const Text('استقبال Excel')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.file_download), label: const Text('تصدير Excel')),
                ]),
              ],
            ),
          ),
          SectionBox(
            title: kind == PeopleKind.customers ? 'جدول العملاء' : 'جدول الموردين',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.bgCard),
                columns: const [
                  DataColumn(label: Text('الرقم')),
                  DataColumn(label: Text('الاسم')),
                  DataColumn(label: Text('الجوال')),
                  DataColumn(label: Text('ملاحظات')),
                ],
                rows: [
                  for (final p in data)
                    DataRow(cells: [
                      DataCell(Text('${p.id}')),
                      DataCell(Text(p.name)),
                      DataCell(Text(p.phone)),
                      DataCell(Text(p.notes)),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
