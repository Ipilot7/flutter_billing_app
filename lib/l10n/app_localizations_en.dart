// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Billing App';

  @override
  String get openShift => 'Open Shift';

  @override
  String get closeShift => 'Close Shift';

  @override
  String get salesHistory => 'Sales History';

  @override
  String get productUnit => 'Unit of Measure';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get products => 'Products';

  @override
  String get settings => 'Settings';

  @override
  String get shop => 'Shop';

  @override
  String get checkout => 'Checkout';

  @override
  String get total => 'Total';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get terminal => 'Terminal';

  @override
  String get returnSale => 'Return';

  @override
  String get language => 'Language';

  @override
  String get startBalance => 'Start Balance';

  @override
  String get endBalance => 'End Balance';

  @override
  String get unitName => 'Name';

  @override
  String get unitShortName => 'Short Name';

  @override
  String get noProducts => 'No products';

  @override
  String get noSales => 'No sales';

  @override
  String get noUnits => 'No units';

  @override
  String get shiftOpened => 'Shift opened';

  @override
  String get shiftClosed => 'Shift closed';

  @override
  String get confirmReturn => 'Are you sure you want to return this sale?';

  @override
  String get deleteUnit => 'Delete Unit';

  @override
  String deleteUnitConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get saleDetails => 'Sale Details';

  @override
  String get items => 'Items';

  @override
  String get quantity => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get measurementUnits => 'Measurement Units';

  @override
  String get currency => 'sum';

  @override
  String get barcode => 'Barcode';

  @override
  String get productName => 'Product Name';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get completeSale => 'Complete Sale';

  @override
  String get printReceipt => 'Print Receipt';

  @override
  String get printReceiptOnly => 'Print Receipt Only';

  @override
  String get paymentMethod => 'Select Payment Method';

  @override
  String get saleCompleted => 'Sale Completed Successfully!';

  @override
  String get printSuccess => 'Printed successfully';

  @override
  String barcodeExists(Object barcode) {
    return 'Product with barcode \"$barcode\" already exists!';
  }

  @override
  String get addUnit => 'Add Measurement Unit';

  @override
  String get unitNameLabel => 'Unit Name (e.g. Kilogram)';

  @override
  String get unitShortNameLabel => 'Short Name (e.g. kg)';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get listIsEmpty => 'List is empty';

  @override
  String get scannedItemsAppear => 'Scanned items will appear here';

  @override
  String get reviewOrder => 'Review Order';

  @override
  String get search => 'Search';

  @override
  String get searchProducts => 'Search Products';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusClosed => 'Closed';

  @override
  String get scannedItems => 'Scanned Items';

  @override
  String totalItems(int count) {
    return '$count items total';
  }

  @override
  String get cameraOff => 'Camera is turned off';

  @override
  String get cameraOffDescription =>
      'Turn on your camera to start scanning barcodes and items automatically.';

  @override
  String get turnOnCamera => 'Turn on Camera';

  @override
  String get enterEndBalance => 'Enter end balance';

  @override
  String get openedBy => 'Opened by';

  @override
  String get cashier => 'Cashier';

  @override
  String get history => 'History';

  @override
  String get salesHistoryShort => 'History';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get saleDate => 'Sale Date';

  @override
  String get returnCompleted => 'Return completed successfully';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get open => 'Open';

  @override
  String get close => 'Close';

  @override
  String get scanOrEnterBarcode => 'Scan or enter barcode';

  @override
  String get scanIconHint => 'Tap the icon to open camera scanner';

  @override
  String get noProductsMatch => 'No products match your search';

  @override
  String deleteProductConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get enterBarcode => 'Please enter a barcode';

  @override
  String get namePlaceholder => 'e.g. Basmati Rice';

  @override
  String get pricePlaceholder => '0.00';

  @override
  String get measurementUnit => 'Measurement Unit';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get pleaseEnterPrice => 'Please enter a price';

  @override
  String get unitDefault => 'pcs';

  @override
  String get dateLabel => 'Date';

  @override
  String get totalLabel => 'Total';

  @override
  String get enterStartBalance => 'Please enter start balance';

  @override
  String get invalidNumber => 'Please enter a valid number';

  @override
  String get management => 'Management';

  @override
  String get shopDetails => 'Shop Details';

  @override
  String get shopDetailsSubtitle => 'Edit business info & address';

  @override
  String get hardware => 'Hardware';

  @override
  String get printDevice => 'Print Device';

  @override
  String get printerConnected => 'Printer connected';

  @override
  String get noPrinterConnected => 'No printer connected';

  @override
  String get connected => 'CONNECTED';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get reinitializingPrinter => 'Re-initializing printer status';

  @override
  String get printerRefreshHint =>
      'To connect a new device, tap on the Settings gear to pair in phone\'s Bluetooth settings, then return and hit Refresh.';

  @override
  String get generalInformation => 'General Information';

  @override
  String get receiptHint =>
      'These details will appear on your digital and printed receipts.';

  @override
  String get addressLine1 => 'Address Line 1';

  @override
  String get addressLine2 => 'Address Line 2 (Optional)';

  @override
  String get upiId => 'UPI ID';

  @override
  String get footerText => 'Receipt Footer Text';

  @override
  String get maxChars => 'Max 150 chars';

  @override
  String get shopSaved => 'Shop details saved!';

  @override
  String get requiredLabel => 'Required';

  @override
  String get phone => 'Phone Number';

  @override
  String get alignBarcode => 'Align barcode within frame';

  @override
  String get noUnitsFound => 'No units found';

  @override
  String get editUnit => 'Edit Unit';

  @override
  String get saveDetails => 'Save Details';

  @override
  String get scanToPay => 'Scan to Pay';

  @override
  String get grandTotal => 'GRAND TOTAL';

  @override
  String get shopDetailsNotLoaded => 'Shop details not loaded';

  @override
  String get pleaseOpenShift => 'Please open a shift first!';

  @override
  String get unknown => 'Unknown';

  @override
  String get categories => 'Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get noCategories => 'No categories found';

  @override
  String get selectCategory => 'Select Category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get apply => 'Apply';

  @override
  String get payment => 'Payment';

  @override
  String get all => 'All';

  @override
  String get analytics => 'Analytics';

  @override
  String get revenue => 'Revenue';

  @override
  String get profit => 'Profit';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get topProducts => 'Top Products';

  @override
  String get salesByPayment => 'Sales by Payment Method';

  @override
  String get costPrice => 'Cost Price';

  @override
  String get stock => 'Stock';

  @override
  String get filterByDate => 'Filter by Date';

  @override
  String get dailyRevenue => 'Daily Revenue';

  @override
  String get change => 'Change';

  @override
  String get received => 'Received';

  @override
  String get transactions => 'Transactions';

  @override
  String salesCount(int count) {
    return '$count sales';
  }

  @override
  String productAddedToCart(String name) {
    return '$name added to cart';
  }

  @override
  String get stockManagement => 'Stock Management';

  @override
  String get updateStock => 'Update Stock';

  @override
  String get currentStock => 'Current Stock';

  @override
  String get newStock => 'New Stock';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get stockUpdated => 'Stock updated successfully!';

  @override
  String get exportCSV => 'Export CSV';

  @override
  String get share => 'Share';

  @override
  String get salesReport => 'Sales Report';

  @override
  String get amountReceived => 'Amount Received';
}
