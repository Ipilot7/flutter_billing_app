// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Billing App';

  @override
  String get openShift => 'Открыть смену';

  @override
  String get closeShift => 'Закрыть смену';

  @override
  String get salesHistory => 'История продаж';

  @override
  String get productUnit => 'Единица измерения';

  @override
  String get add => 'Добавить';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get products => 'Товары';

  @override
  String get settings => 'Настройки';

  @override
  String get shop => 'Магазин';

  @override
  String get checkout => 'Оплата';

  @override
  String get total => 'Итого';

  @override
  String get cash => 'Наличные';

  @override
  String get card => 'Карта';

  @override
  String get terminal => 'Терминал';

  @override
  String get returnSale => 'Возврат';

  @override
  String get language => 'Язык';

  @override
  String get startBalance => 'Начальный остаток';

  @override
  String get endBalance => 'Конечный остаток';

  @override
  String get unitName => 'Название';

  @override
  String get unitShortName => 'Короткое название';

  @override
  String get noProducts => 'Нет товаров';

  @override
  String get noSales => 'Нет продаж';

  @override
  String get noUnits => 'Нет единиц измерения';

  @override
  String get shiftOpened => 'Смена открыта';

  @override
  String get shiftClosed => 'Смена закрыта';

  @override
  String get confirmReturn => 'Вы уверены, что хотите вернуть эту продажу?';

  @override
  String get deleteUnit => 'Удалить единицу';

  @override
  String deleteUnitConfirm(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get saleDetails => 'Детали продажи';

  @override
  String get items => 'Товары';

  @override
  String get quantity => 'Количество';

  @override
  String get price => 'Цена';

  @override
  String get measurementUnits => 'Единицы измерения';

  @override
  String get currency => 'сум';

  @override
  String get barcode => 'Штрих-код';

  @override
  String get productName => 'Название товара';

  @override
  String get addProduct => 'Добавить товар';

  @override
  String get editProduct => 'Редактировать товар';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get completeSale => 'Завершить продажу';

  @override
  String get printReceipt => 'Печать чека';

  @override
  String get printReceiptOnly => 'Только печать чека';

  @override
  String get paymentMethod => 'Выберите способ оплаты';

  @override
  String get saleCompleted => 'Продажа успешно завершена!';

  @override
  String get printSuccess => 'Чек успешно напечатан';

  @override
  String barcodeExists(Object barcode) {
    return 'Товар со штрих-кодом \"$barcode\" уже существует!';
  }

  @override
  String get addUnit => 'Добавить единицу измерения';

  @override
  String get unitNameLabel => 'Название (напр. Килограмм)';

  @override
  String get unitShortNameLabel => 'Короткое название (напр. кг)';

  @override
  String get scanBarcode => 'Сканировать штрих-код';

  @override
  String get totalAmount => 'Итог';

  @override
  String get listIsEmpty => 'Список пуст';

  @override
  String get scannedItemsAppear => 'Отсканированные товары появятся здесь';

  @override
  String get reviewOrder => 'Проверить заказ';

  @override
  String get search => 'Поиск';

  @override
  String get searchProducts => 'Поиск товаров';

  @override
  String get statusOpen => 'Открыта';

  @override
  String get statusClosed => 'Закрыта';

  @override
  String get scannedItems => 'Отсканированные товары';

  @override
  String totalItems(int count) {
    return 'Всего товаров: $count';
  }

  @override
  String get cameraOff => 'Камера выключена';

  @override
  String get cameraOffDescription =>
      'Включите камеру, чтобы начать автоматическое сканирование штрих-кодов.';

  @override
  String get turnOnCamera => 'Включить камеру';

  @override
  String get enterEndBalance => 'Введите конечный остаток';

  @override
  String get openedBy => 'Открыто:';

  @override
  String get cashier => 'Кассир';

  @override
  String get history => 'История';

  @override
  String get salesHistoryShort => 'История';

  @override
  String get totalSales => 'Всего продаж';

  @override
  String get saleDate => 'Дата продажи';

  @override
  String get returnCompleted => 'Возврат успешно завершен';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get open => 'Открыть';

  @override
  String get close => 'Закрыть';

  @override
  String get scanOrEnterBarcode => 'Отсканируйте или введите штрих-код';

  @override
  String get scanIconHint => 'Нажмите на иконку, чтобы открыть сканер';

  @override
  String get noProductsMatch =>
      'Товары, соответствующие вашему запросу, не найдены';

  @override
  String deleteProductConfirm(String name) {
    return 'Вы уверены, что хотите удалить $name?';
  }

  @override
  String get enterBarcode => 'Введите штрих-код';

  @override
  String get namePlaceholder => 'напр. Рис Басмати';

  @override
  String get pricePlaceholder => '0.00';

  @override
  String get measurementUnit => 'Единица измерения';

  @override
  String get pleaseEnterName => 'Пожалуйста, введите название';

  @override
  String get pleaseEnterPrice => 'Пожалуйста, введите цену';

  @override
  String get unitDefault => 'шт';

  @override
  String get dateLabel => 'Дата';

  @override
  String get totalLabel => 'Итого';

  @override
  String get enterStartBalance => 'Введите начальный баланс';

  @override
  String get invalidNumber => 'Введите корректное число';

  @override
  String get management => 'Управление';

  @override
  String get shopDetails => 'Детали магазина';

  @override
  String get shopDetailsSubtitle => 'Редактировать бизнес-инфо и адрес';

  @override
  String get hardware => 'Оборудование';

  @override
  String get printDevice => 'Принтер';

  @override
  String get printerConnected => 'Принтер подключен';

  @override
  String get noPrinterConnected => 'Принтер не подключен';

  @override
  String get connected => 'ПОДКЛЮЧЕНО';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get reinitializingPrinter => 'Инициализация принтера';

  @override
  String get printerRefreshHint =>
      'Чтобы подключить новое устройство, нажмите на значок настроек, чтобы выполнить сопряжение в настройках Bluetooth телефона, затем вернитесь и нажмите Обновить.';

  @override
  String get generalInformation => 'Общая информация';

  @override
  String get receiptHint =>
      'Эти данные будут отображаться в ваших цифровых и бумажных чеках.';

  @override
  String get addressLine1 => 'Адресная строка 1';

  @override
  String get addressLine2 => 'Адресная строка 2 (необязательно)';

  @override
  String get upiId => 'UPI ID';

  @override
  String get footerText => 'Текст внизу чека';

  @override
  String get maxChars => 'Макс. 150 симв.';

  @override
  String get shopSaved => 'Данные магазина сохранены!';

  @override
  String get requiredLabel => 'Обязательно';

  @override
  String get phone => 'Номер телефона';

  @override
  String get alignBarcode => 'Поместите штрих-код в рамку';

  @override
  String get noUnitsFound => 'Единицы измерения не найдены';

  @override
  String get editUnit => 'Редактировать единицу';

  @override
  String get saveDetails => 'Сохранить данные';

  @override
  String get scanToPay => 'Сканируйте для оплаты';

  @override
  String get grandTotal => 'ОБЩИЙ ИТОГ';

  @override
  String get shopDetailsNotLoaded => 'Данные магазина не загружены';

  @override
  String get pleaseOpenShift => 'Пожалуйста, сначала откройте смену!';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get categories => 'Категории';

  @override
  String get addCategory => 'Добавить категорию';

  @override
  String get editCategory => 'Редактировать категорию';

  @override
  String get categoryName => 'Название категории';

  @override
  String get noCategories => 'Категории не найдены';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Вы уверены, что хотите удалить $name?';
  }

  @override
  String get subtotal => 'Промежуточный итог';

  @override
  String get discount => 'Скидка';

  @override
  String get apply => 'Применить';

  @override
  String get payment => 'Оплата';

  @override
  String get all => 'Все';

  @override
  String get analytics => 'Аналитика';

  @override
  String get revenue => 'Выручка';

  @override
  String get profit => 'Прибыль';

  @override
  String get today => 'Сегодня';

  @override
  String get thisWeek => 'Эта неделя';

  @override
  String get thisMonth => 'Этот месяц';

  @override
  String get topProducts => 'Популярные товары';

  @override
  String get salesByPayment => 'Продажи по способам оплаты';

  @override
  String get costPrice => 'Себестоимость';

  @override
  String get stock => 'Запас';

  @override
  String get filterByDate => 'Фильтр по дате';

  @override
  String get dailyRevenue => 'Выручка по дням';

  @override
  String get change => 'Сдача';

  @override
  String get received => 'Получено';

  @override
  String get transactions => 'Транзакции';

  @override
  String salesCount(int count) {
    return '$count продаж';
  }

  @override
  String productAddedToCart(String name) {
    return '$name добавлен в корзину';
  }

  @override
  String get stockManagement => 'Управление запасами';

  @override
  String get updateStock => 'Обновить запас';

  @override
  String get currentStock => 'Текущий запас';

  @override
  String get newStock => 'Новый запас';

  @override
  String get lowStock => 'Мало товара';

  @override
  String get stockUpdated => 'Запас успешно обновлен!';

  @override
  String get exportCSV => 'Экспорт CSV';

  @override
  String get share => 'Поделиться';

  @override
  String get salesReport => 'Отчет о продажах';

  @override
  String get amountReceived => 'Получено';

  @override
  String get dataBackup => 'Данные и бэкап';

  @override
  String get backupDatabase => 'Бэкап базы данных';

  @override
  String get backupDatabaseSubtitle => 'Экспорт данных в файл';

  @override
  String get restoreDatabase => 'Восстановление базы';

  @override
  String get restoreDatabaseSubtitle => 'Импорт данных из файла бэкапа';

  @override
  String get backupSuccess => 'Бэкап успешно создан!';

  @override
  String get restoreSuccess =>
      'База данных успешно восстановлена! Пожалуйста, перезапустите приложение.';

  @override
  String get restoreConfirm =>
      'Вы уверены, что хотите восстановить базу данных? Текущие данные будут перезаписаны.';
}
