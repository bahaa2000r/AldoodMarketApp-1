import '../models/item_model.dart';
import '../models/person_model.dart';
import '../models/bank_operation_model.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._();
  LocalDatabase._();

  final List<ItemModel> items = [
    const ItemModel(
      id: 1,
      name: 'بيبسي 250 مل',
      quantity: 24,
      purchasePrice: 2.0,
      wholesalePrice: 2.5,
      retailPrice: 3.0,
      storagePlace: 'المخزن الرئيسي',
      supplier: 'مورد تجريبي',
    ),
    const ItemModel(
      id: 2,
      name: 'سكر 1 كيلو',
      quantity: 12,
      purchasePrice: 4.0,
      wholesalePrice: 4.5,
      retailPrice: 5.0,
      storagePlace: 'رف 1',
      supplier: 'مورد تجريبي',
    ),
    const ItemModel(
      id: 3,
      name: 'زيت 1 لتر',
      quantity: 18,
      purchasePrice: 8.0,
      wholesalePrice: 9.0,
      retailPrice: 10.0,
      storagePlace: 'رف 2',
      supplier: 'مورد تجريبي',
    ),
  ];

  final List<PersonModel> customers = [
    const PersonModel(id: 1, name: 'أحمد', phone: '0590000000', notes: 'عميل دائم'),
    const PersonModel(id: 2, name: 'خالد', phone: '0591111111', notes: 'حوالات بنكية'),
  ];

  final List<PersonModel> suppliers = [
    const PersonModel(id: 1, name: 'مورد تجريبي', phone: '0592222222', notes: 'توريد مواد غذائية'),
  ];

  final List<BankOperationModel> bankOperations = [
    BankOperationModel(
      id: 1,
      name: 'أحمد',
      account: 'بنك فلسطين',
      type: 'بيع يومي',
      originalAmount: 150,
      transferredAmount: 100,
      date: DateTime.now(),
      notes: 'متبقي 50',
    ),
    BankOperationModel(
      id: 2,
      name: 'خالد',
      account: 'كاش',
      type: 'حوالة',
      originalAmount: 100,
      transferredAmount: 100,
      date: DateTime.now(),
      notes: 'مسدد بالكامل',
    ),
    BankOperationModel(
      id: 3,
      name: 'أحمد',
      account: 'بنك فلسطين',
      type: 'تسديد دين',
      originalAmount: 50,
      transferredAmount: 50,
      date: DateTime.now(),
      notes: 'سدد دين سابق',
    ),
  ];

  double get inventoryPurchaseValue =>
      items.fold(0, (sum, i) => sum + i.quantity * i.purchasePrice);

  double get inventoryWholesaleValue =>
      items.fold(0, (sum, i) => sum + i.quantity * i.wholesalePrice);

  double get inventoryRetailValue =>
      items.fold(0, (sum, i) => sum + i.quantity * i.retailPrice);

  double get expectedStockProfit =>
      inventoryWholesaleValue - inventoryPurchaseValue;
}
