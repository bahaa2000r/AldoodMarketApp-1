import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/item_model.dart';
import '../services/telegram_service.dart';
import '../widgets/smart_item_search.dart';
import '../widgets/section_box.dart';
import '../widgets/action_bar.dart';

enum InvoiceType { sales, purchases }

class InvoiceScreen extends StatefulWidget {
  final InvoiceType type;
  const InvoiceScreen({super.key, required this.type});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  ItemModel? selectedItem;
  final qtyController = TextEditingController(text: '1');
  final priceController = TextEditingController(text: '0');
  final List<Map<String, dynamic>> rows = [];

  bool get isSales => widget.type == InvoiceType.sales;

  void addRow() {
    if (selectedItem == null) return;
    final qty = double.tryParse(qtyController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;
    if (qty <= 0 || price < 0) return;
    setState(() {
      rows.add({'item': selectedItem!, 'qty': qty, 'price': price});
    });
  }

  Future<void> saveInvoice() async {
    final invoiceName = isSales ? 'فاتورة مبيعات' : 'فاتورة مشتريات';
    final result = await TelegramService.sendMessage(
      '🧾 $invoiceName\n'
      'عدد الأصناف: ${rows.length}\n'
      'الإجمالي: $total',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  double get total => rows.fold(0, (s, r) => s + (r['qty'] as double) * (r['price'] as double));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionBox(
            title: isSales ? 'إدخال فاتورة مبيعات' : 'إدخال فاتورة مشتريات',
            child: Column(
              children: [
                SmartItemSearch(
                  onSelected: (item) {
                    setState(() {
                      selectedItem = item;
                      priceController.text = isSales ? '${item.retailPrice}' : '${item.purchasePrice}';
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: qtyController, keyboardType: TextInputType.number, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'الكمية'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'السعر'))),
                  ],
                ),
                const SizedBox(height: 12),
                ActionBar(children: [
                  FilledButton.icon(onPressed: addRow, icon: const Icon(Icons.add), label: const Text('إضافة السطر')),
                  OutlinedButton.icon(onPressed: saveInvoice, icon: const Icon(Icons.save), label: const Text('حفظ الفاتورة')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.print), label: const Text('طباعة')),
                ]),
              ],
            ),
          ),
          SectionBox(
            title: 'جدول الفاتورة',
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.bgCard),
                    columns: const [
                      DataColumn(label: Text('الصنف')),
                      DataColumn(label: Text('الكمية')),
                      DataColumn(label: Text('السعر')),
                      DataColumn(label: Text('الإجمالي')),
                    ],
                    rows: [
                      for (final r in rows)
                        DataRow(cells: [
                          DataCell(Text((r['item'] as ItemModel).name)),
                          DataCell(Text('${r['qty']}')),
                          DataCell(Text('${r['price']}')),
                          DataCell(Text('${(r['qty'] as double) * (r['price'] as double)}')),
                        ]),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.bgCard, border: Border.all(color: AppColors.accent)),
                  child: Text('الإجمالي: $total', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
