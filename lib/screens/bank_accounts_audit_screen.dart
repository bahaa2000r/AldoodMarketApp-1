import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../database/local_database.dart';
import '../widgets/section_box.dart';
import '../widgets/action_bar.dart';

class BankAccountsAuditScreen extends StatelessWidget {
  const BankAccountsAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ops = LocalDatabase.instance.bankOperations;
    final totalOriginal = ops.fold<double>(0, (s, o) => s + o.originalAmount);
    final totalTransferred = ops.fold<double>(0, (s, o) => s + o.transferredAmount);
    final totalRemaining = ops.fold<double>(0, (s, o) => s + o.remaining);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionBox(
            title: 'التحكم بجرد الحسابات البنكية',
            child: Column(
              children: [
                ActionBar(children: [
                  FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('إضافة عملية')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.table_view), label: const Text('فتح جدول جميع العمليات')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.today), label: const Text('اليوم')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.view_week), label: const Text('الأسبوع')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_month), label: const Text('الشهر')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.file_download), label: const Text('تصدير Excel')),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.bgCard, border: Border.all(color: AppColors.accent)),
                  child: Text(
                    'الأصل: $totalOriginal | المحول: $totalTransferred | المتبقي: $totalRemaining',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SectionBox(
            title: 'جدول العمليات',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.bgCard),
                columns: const [
                  DataColumn(label: Text('الاسم')),
                  DataColumn(label: Text('الحساب')),
                  DataColumn(label: Text('النوع')),
                  DataColumn(label: Text('الأصل')),
                  DataColumn(label: Text('المحول')),
                  DataColumn(label: Text('المتبقي')),
                  DataColumn(label: Text('الحالة')),
                  DataColumn(label: Text('ملاحظات')),
                ],
                rows: [
                  for (final o in ops)
                    DataRow(cells: [
                      DataCell(Text(o.name)),
                      DataCell(Text(o.account)),
                      DataCell(Text(o.type)),
                      DataCell(Text('${o.originalAmount}')),
                      DataCell(Text('${o.transferredAmount}')),
                      DataCell(Text('${o.remaining}')),
                      DataCell(Text(o.status)),
                      DataCell(Text(o.notes)),
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
