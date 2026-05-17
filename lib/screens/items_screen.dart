import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../database/local_database.dart';
import '../widgets/action_bar.dart';
import '../widgets/section_box.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = LocalDatabase.instance.items;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionBox(
            title: 'بيانات الصنف',
            child: Column(
              children: [
                const TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'اسم الصنف')),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(child: TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'الكمية'), keyboardType: TextInputType.number)),
                    SizedBox(width: 8),
                    Expanded(child: TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'سعر الشراء'), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(child: TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'سعر البيع جملة'), keyboardType: TextInputType.number)),
                    SizedBox(width: 8),
                    Expanded(child: TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'سعر البيع مفرق'), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                const TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'مكان المخزون')),
                const SizedBox(height: 12),
                ActionBar(
                  children: [
                    FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('إضافة')),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('تعديل')),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.delete), label: const Text('حذف')),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.cleaning_services), label: const Text('تفريغ')),
                  ],
                ),
              ],
            ),
          ),
          SectionBox(
            title: 'جدول الأصناف',
            child: Column(
              children: [
                ActionBar(children: [
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.table_view), label: const Text('فتح الجدول')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file), label: const Text('استقبال Excel')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.file_download), label: const Text('تصدير Excel')),
                ]),
                const SizedBox(height: 10),
                const TextField(textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'بحث')),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.bgCard),
                    columns: const [
                      DataColumn(label: Text('الرقم')),
                      DataColumn(label: Text('الصنف')),
                      DataColumn(label: Text('الكمية')),
                      DataColumn(label: Text('شراء')),
                      DataColumn(label: Text('جملة')),
                      DataColumn(label: Text('مفرق')),
                      DataColumn(label: Text('المخزن')),
                      DataColumn(label: Text('المورد')),
                    ],
                    rows: [
                      for (final item in items)
                        DataRow(cells: [
                          DataCell(Text('${item.id}')),
                          DataCell(Text(item.name)),
                          DataCell(Text('${item.quantity}')),
                          DataCell(Text('${item.purchasePrice}')),
                          DataCell(Text('${item.wholesalePrice}')),
                          DataCell(Text('${item.retailPrice}')),
                          DataCell(Text(item.storagePlace)),
                          DataCell(Text(item.supplier)),
                        ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
