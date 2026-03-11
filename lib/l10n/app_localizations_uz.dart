// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Billing App';

  @override
  String get openShift => 'Smena ochish';

  @override
  String get closeShift => 'Smena yopish';

  @override
  String get salesHistory => 'Sotuvlar tarixi';

  @override
  String get productUnit => 'O\'lchov birligi';

  @override
  String get add => 'Qo\'shish';

  @override
  String get edit => 'Tahrirlash';

  @override
  String get delete => 'O\'chirish';

  @override
  String get save => 'Saqlash';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get products => 'Mahsulotlar';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get shop => 'Do\'kon';

  @override
  String get checkout => 'To\'lov';

  @override
  String get total => 'Jami';

  @override
  String get cash => 'Naqd';

  @override
  String get card => 'Karta';

  @override
  String get terminal => 'Terminal';

  @override
  String get returnSale => 'Qaytarish';

  @override
  String get language => 'Til';

  @override
  String get startBalance => 'Boshlang\'ich qoldiq';

  @override
  String get endBalance => 'Yakuniy qoldiq';

  @override
  String get unitName => 'Nomi';

  @override
  String get unitShortName => 'Qisqa nomi';

  @override
  String get noProducts => 'Mahsulotlar yo\'q';

  @override
  String get noSales => 'Sotuvlar yo\'q';

  @override
  String get noUnits => 'Birliklar yo\'q';

  @override
  String get shiftOpened => 'Smena ochildi';

  @override
  String get shiftClosed => 'Smena yopildi';

  @override
  String get confirmReturn => 'Sotuvni qaytarishni xohlaysizmi?';

  @override
  String get deleteUnit => 'Birlikni o\'chirish';

  @override
  String deleteUnitConfirm(String name) {
    return '$name ni o\'chirishni xohlaysizmi?';
  }

  @override
  String get saleDetails => 'Sotuv tafsilotlari';

  @override
  String get items => 'Mahsulotlar';

  @override
  String get quantity => 'Miqdor';

  @override
  String get price => 'Narx';

  @override
  String get measurementUnits => 'O\'lchov birliklari';

  @override
  String get currency => 'sum';

  @override
  String get barcode => 'Shtrix-kod';

  @override
  String get productName => 'Mahsulot nomi';

  @override
  String get addProduct => 'Mahsulot qo\'shish';

  @override
  String get editProduct => 'Mahsulotni tahrirlash';

  @override
  String get saveChanges => 'O\'zgarishlarni saqlash';

  @override
  String get completeSale => 'Sotuvni yakunlash';

  @override
  String get printReceipt => 'Chekni chiqarish';

  @override
  String get printReceiptOnly => 'Faqat chekni chiqarish';

  @override
  String get paymentMethod => 'To\'lov turini tanlang';

  @override
  String get saleCompleted => 'Sotuv muvaffaqiyatli yakunlandi!';

  @override
  String get printSuccess => 'Chek muvaffaqiyatli chiqarildi';

  @override
  String barcodeExists(Object barcode) {
    return '\"$barcode\" shtrix-kodli mahsulot allaqachon mavjud!';
  }

  @override
  String get addUnit => 'O\'lchov birligini qo\'shish';

  @override
  String get unitNameLabel => 'Birlik nomi (masalan, Kilogram)';

  @override
  String get unitShortNameLabel => 'Qisqa nomi (masalan, kg)';

  @override
  String get scanBarcode => 'Shtrix-kodni skanerlash';

  @override
  String get totalAmount => 'Jami summa';

  @override
  String get listIsEmpty => 'Ro\'yxat bo\'sh';

  @override
  String get scannedItemsAppear =>
      'Skanerlangan mahsulotlar shu yerda paydo bo\'ladi';

  @override
  String get reviewOrder => 'Buyurtmani tekshirish';

  @override
  String get search => 'Qidirish';

  @override
  String get searchProducts => 'Mahsulotlarni qidirish';

  @override
  String get statusOpen => 'Ochiq';

  @override
  String get statusClosed => 'Yopiq';

  @override
  String get scannedItems => 'Skanerlangan mahsulotlar';

  @override
  String totalItems(int count) {
    return '$count ta mahsulot';
  }

  @override
  String get cameraOff => 'Kamera o\'chirilgan';

  @override
  String get cameraOffDescription =>
      'Shtrix-kodlarni avtomatik skanerlashni boshlash uchun kamerani yoqing.';

  @override
  String get turnOnCamera => 'Kamerani yoqish';

  @override
  String get enterEndBalance => 'Yakuniy qoldiqni kiriting';

  @override
  String get openedBy => 'Tomonidan ochilgan';

  @override
  String get cashier => 'Kassir';

  @override
  String get history => 'Tarix';

  @override
  String get salesHistoryShort => 'Tarix';

  @override
  String get totalSales => 'Jami sotuvlar';

  @override
  String get saleDate => 'Sotuv sanasi';

  @override
  String get returnCompleted => 'Qaytarish muvaffaqiyatli yakunlandi';

  @override
  String get errorOccurred => 'Xatolik yuz berdi';

  @override
  String get open => 'Ochish';

  @override
  String get close => 'Yopish';

  @override
  String get scanOrEnterBarcode => 'Shtrix-kodni skanerlang yoki kiriting';

  @override
  String get scanIconHint => 'Skanerni ochish uchun belgini bosing';

  @override
  String get noProductsMatch => 'Qidiruvga mos mahsulot topilmadi';

  @override
  String deleteProductConfirm(String name) {
    return '$name mahsulotini o\'chirmoqchimisiz?';
  }

  @override
  String get enterBarcode => 'Shtrix-kodni kiriting';

  @override
  String get namePlaceholder => 'masalan, Basmati Guruch';

  @override
  String get pricePlaceholder => '0.00';

  @override
  String get measurementUnit => 'O\'lchov birligi';

  @override
  String get pleaseEnterName => 'Iltimos, nomini kiriting';

  @override
  String get pleaseEnterPrice => 'Iltimos, narxni kiriting';

  @override
  String get unitDefault => 'dona';

  @override
  String get dateLabel => 'Sana';

  @override
  String get totalLabel => 'Jami';

  @override
  String get enterStartBalance => 'Boshlang\'ich qoldiqni kiriting';

  @override
  String get invalidNumber => 'Noto\'g\'ri son kiritildi';

  @override
  String get management => 'Boshqaruv';

  @override
  String get shopDetails => 'Do\'kon ma\'lumotlari';

  @override
  String get shopDetailsSubtitle =>
      'Biznes haqida ma\'lumot va manzilni tahrirlash';

  @override
  String get hardware => 'Qurilmalar';

  @override
  String get printDevice => 'Printer qurilmasi';

  @override
  String get printerConnected => 'Printer ulangan';

  @override
  String get noPrinterConnected => 'Printer ulanmagan';

  @override
  String get connected => 'ULANGAN';

  @override
  String get selectLanguage => 'Tilni tanlang';

  @override
  String get reinitializingPrinter => 'Printer holati yangilanmoqda';

  @override
  String get printerRefreshHint =>
      'Yangi qurilmani ulash uchun, telefondagi Bluetooth sozlamalarida juftlang, so\'ngra qaytib kelib Yangilash tugmasini bosing.';

  @override
  String get generalInformation => 'Umumiy ma\'lumotlar';

  @override
  String get receiptHint =>
      'Ushbu ma\'lumotlar raqamli va bosma cheklarda ko\'rinadi.';

  @override
  String get addressLine1 => 'Manzil 1';

  @override
  String get addressLine2 => 'Manzil 2 (ixtiyoriy)';

  @override
  String get upiId => 'UPI ID';

  @override
  String get footerText => 'Chek matni (futer)';

  @override
  String get maxChars => 'Maksimal 150 ta belgi';

  @override
  String get shopSaved => 'Do\'kon ma\'lumotlari saqlandi!';

  @override
  String get requiredLabel => 'Majburiy';

  @override
  String get phone => 'Telefon raqami';

  @override
  String get alignBarcode => 'Shtrix-kodni ramkaga tekislang';

  @override
  String get noUnitsFound => 'O\'lchov birliklari topilmadi';

  @override
  String get editUnit => 'Birlikni tahrirlash';

  @override
  String get saveDetails => 'Ma\'lumotlarni saqlash';

  @override
  String get scanToPay => 'To\'lash uchun skanerlang';

  @override
  String get grandTotal => 'BARCHASI';

  @override
  String get shopDetailsNotLoaded => 'Do\'kon ma\'lumotlari yuklanmadi';

  @override
  String get pleaseOpenShift => 'Iltimos, avval smenani oching!';

  @override
  String get unknown => 'Noma\'lum';

  @override
  String get categories => 'Kategoriyalar';

  @override
  String get addCategory => 'Kategoriya qo\'shish';

  @override
  String get editCategory => 'Kategoriyani tahrirlash';

  @override
  String get categoryName => 'Kategoriya nomi';

  @override
  String get noCategories => 'Kategoriyalar topilmadi';

  @override
  String get selectCategory => 'Kategoriyani tanlang';

  @override
  String deleteCategoryConfirm(String name) {
    return '$name ni o\'chirishni xohlaysizmi?';
  }

  @override
  String get subtotal => 'Oraliq jami';

  @override
  String get discount => 'Chegirma';

  @override
  String get apply => 'Qo\'llash';

  @override
  String get payment => 'To\'lov';

  @override
  String get all => 'Barchasi';

  @override
  String get analytics => 'Tahlil';

  @override
  String get revenue => 'Tushum';

  @override
  String get profit => 'Foyda';

  @override
  String get today => 'Bugun';

  @override
  String get thisWeek => 'Shu hafta';

  @override
  String get thisMonth => 'Shu oy';

  @override
  String get topProducts => 'Top mahsulotlar';

  @override
  String get salesByPayment => 'To\'lov turlari bo\'yicha';

  @override
  String get costPrice => 'Tannarx';

  @override
  String get stock => 'Invertar';

  @override
  String get filterByDate => 'Sana bo\'yicha filtrlash';

  @override
  String get dailyRevenue => 'Kunlik tushum';

  @override
  String get change => 'Qaytim';

  @override
  String get received => 'Qabul qilindi';

  @override
  String get transactions => 'Tranzaksiyalar';

  @override
  String salesCount(int count) {
    return '$count sotuv';
  }

  @override
  String productAddedToCart(String name) {
    return '$name savatga qo\'shildi';
  }

  @override
  String get stockManagement => 'Invertarni boshqarish';

  @override
  String get updateStock => 'Zaxirani yangilash';

  @override
  String get currentStock => 'Joriy zaxira';

  @override
  String get newStock => 'Yangi zaxira';

  @override
  String get lowStock => 'Kam qoldi';

  @override
  String get stockUpdated => 'Zaxira muvaffaqiyatli yangilandi!';

  @override
  String get exportCSV => 'CSV eksport';

  @override
  String get share => 'Ulashish';

  @override
  String get salesReport => 'Sotuv hisoboti';

  @override
  String get amountReceived => 'Qabul qilindi';
}
