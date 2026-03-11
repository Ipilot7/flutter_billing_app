import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Billing App'**
  String get appTitle;

  /// No description provided for @openShift.
  ///
  /// In ru, this message translates to:
  /// **'Открыть смену'**
  String get openShift;

  /// No description provided for @closeShift.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть смену'**
  String get closeShift;

  /// No description provided for @salesHistory.
  ///
  /// In ru, this message translates to:
  /// **'История продаж'**
  String get salesHistory;

  /// No description provided for @productUnit.
  ///
  /// In ru, this message translates to:
  /// **'Единица измерения'**
  String get productUnit;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @products.
  ///
  /// In ru, this message translates to:
  /// **'Товары'**
  String get products;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @shop.
  ///
  /// In ru, this message translates to:
  /// **'Магазин'**
  String get shop;

  /// No description provided for @checkout.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get checkout;

  /// No description provided for @total.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get total;

  /// No description provided for @cash.
  ///
  /// In ru, this message translates to:
  /// **'Наличные'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get card;

  /// No description provided for @terminal.
  ///
  /// In ru, this message translates to:
  /// **'Терминал'**
  String get terminal;

  /// No description provided for @returnSale.
  ///
  /// In ru, this message translates to:
  /// **'Возврат'**
  String get returnSale;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @startBalance.
  ///
  /// In ru, this message translates to:
  /// **'Начальный остаток'**
  String get startBalance;

  /// No description provided for @endBalance.
  ///
  /// In ru, this message translates to:
  /// **'Конечный остаток'**
  String get endBalance;

  /// No description provided for @unitName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get unitName;

  /// No description provided for @unitShortName.
  ///
  /// In ru, this message translates to:
  /// **'Короткое название'**
  String get unitShortName;

  /// No description provided for @noProducts.
  ///
  /// In ru, this message translates to:
  /// **'Нет товаров'**
  String get noProducts;

  /// No description provided for @noSales.
  ///
  /// In ru, this message translates to:
  /// **'Нет продаж'**
  String get noSales;

  /// No description provided for @noUnits.
  ///
  /// In ru, this message translates to:
  /// **'Нет единиц измерения'**
  String get noUnits;

  /// No description provided for @shiftOpened.
  ///
  /// In ru, this message translates to:
  /// **'Смена открыта'**
  String get shiftOpened;

  /// No description provided for @shiftClosed.
  ///
  /// In ru, this message translates to:
  /// **'Смена закрыта'**
  String get shiftClosed;

  /// No description provided for @confirmReturn.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите вернуть эту продажу?'**
  String get confirmReturn;

  /// No description provided for @deleteUnit.
  ///
  /// In ru, this message translates to:
  /// **'Удалить единицу'**
  String get deleteUnit;

  /// No description provided for @deleteUnitConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить \"{name}\"?'**
  String deleteUnitConfirm(String name);

  /// No description provided for @saleDetails.
  ///
  /// In ru, this message translates to:
  /// **'Детали продажи'**
  String get saleDetails;

  /// No description provided for @items.
  ///
  /// In ru, this message translates to:
  /// **'Товары'**
  String get items;

  /// No description provided for @quantity.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get price;

  /// No description provided for @measurementUnits.
  ///
  /// In ru, this message translates to:
  /// **'Единицы измерения'**
  String get measurementUnits;

  /// No description provided for @currency.
  ///
  /// In ru, this message translates to:
  /// **'сум'**
  String get currency;

  /// No description provided for @barcode.
  ///
  /// In ru, this message translates to:
  /// **'Штрих-код'**
  String get barcode;

  /// No description provided for @productName.
  ///
  /// In ru, this message translates to:
  /// **'Название товара'**
  String get productName;

  /// No description provided for @addProduct.
  ///
  /// In ru, this message translates to:
  /// **'Добавить товар'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать товар'**
  String get editProduct;

  /// No description provided for @saveChanges.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить изменения'**
  String get saveChanges;

  /// No description provided for @completeSale.
  ///
  /// In ru, this message translates to:
  /// **'Завершить продажу'**
  String get completeSale;

  /// No description provided for @printReceipt.
  ///
  /// In ru, this message translates to:
  /// **'Печать чека'**
  String get printReceipt;

  /// No description provided for @printReceiptOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только печать чека'**
  String get printReceiptOnly;

  /// No description provided for @paymentMethod.
  ///
  /// In ru, this message translates to:
  /// **'Выберите способ оплаты'**
  String get paymentMethod;

  /// No description provided for @saleCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Продажа успешно завершена!'**
  String get saleCompleted;

  /// No description provided for @printSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Чек успешно напечатан'**
  String get printSuccess;

  /// No description provided for @barcodeExists.
  ///
  /// In ru, this message translates to:
  /// **'Товар со штрих-кодом \"{barcode}\" уже существует!'**
  String barcodeExists(Object barcode);

  /// No description provided for @addUnit.
  ///
  /// In ru, this message translates to:
  /// **'Добавить единицу измерения'**
  String get addUnit;

  /// No description provided for @unitNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название (напр. Килограмм)'**
  String get unitNameLabel;

  /// No description provided for @unitShortNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Короткое название (напр. кг)'**
  String get unitShortNameLabel;

  /// No description provided for @scanBarcode.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать штрих-код'**
  String get scanBarcode;

  /// No description provided for @totalAmount.
  ///
  /// In ru, this message translates to:
  /// **'Итог'**
  String get totalAmount;

  /// No description provided for @listIsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Список пуст'**
  String get listIsEmpty;

  /// No description provided for @scannedItemsAppear.
  ///
  /// In ru, this message translates to:
  /// **'Отсканированные товары появятся здесь'**
  String get scannedItemsAppear;

  /// No description provided for @reviewOrder.
  ///
  /// In ru, this message translates to:
  /// **'Проверить заказ'**
  String get reviewOrder;

  /// No description provided for @searchProducts.
  ///
  /// In ru, this message translates to:
  /// **'Поиск товаров'**
  String get searchProducts;

  /// No description provided for @statusOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыта'**
  String get statusOpen;

  /// No description provided for @statusClosed.
  ///
  /// In ru, this message translates to:
  /// **'Закрыта'**
  String get statusClosed;

  /// No description provided for @scannedItems.
  ///
  /// In ru, this message translates to:
  /// **'Отсканированные товары'**
  String get scannedItems;

  /// No description provided for @totalItems.
  ///
  /// In ru, this message translates to:
  /// **'Всего товаров: {count}'**
  String totalItems(int count);

  /// No description provided for @cameraOff.
  ///
  /// In ru, this message translates to:
  /// **'Камера выключена'**
  String get cameraOff;

  /// No description provided for @cameraOffDescription.
  ///
  /// In ru, this message translates to:
  /// **'Включите камеру, чтобы начать автоматическое сканирование штрих-кодов.'**
  String get cameraOffDescription;

  /// No description provided for @turnOnCamera.
  ///
  /// In ru, this message translates to:
  /// **'Включить камеру'**
  String get turnOnCamera;

  /// No description provided for @enterEndBalance.
  ///
  /// In ru, this message translates to:
  /// **'Введите конечный остаток'**
  String get enterEndBalance;

  /// No description provided for @openedBy.
  ///
  /// In ru, this message translates to:
  /// **'Открыто:'**
  String get openedBy;

  /// No description provided for @cashier.
  ///
  /// In ru, this message translates to:
  /// **'Кассир'**
  String get cashier;

  /// No description provided for @history.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get history;

  /// No description provided for @totalSales.
  ///
  /// In ru, this message translates to:
  /// **'Всего продаж'**
  String get totalSales;

  /// No description provided for @saleDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата продажи'**
  String get saleDate;

  /// No description provided for @returnCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Возврат успешно завершен'**
  String get returnCompleted;

  /// No description provided for @errorOccurred.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка'**
  String get errorOccurred;

  /// No description provided for @open.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get open;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @scanOrEnterBarcode.
  ///
  /// In ru, this message translates to:
  /// **'Отсканируйте или введите штрих-код'**
  String get scanOrEnterBarcode;

  /// No description provided for @scanIconHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите на иконку, чтобы открыть сканер'**
  String get scanIconHint;

  /// No description provided for @noProductsMatch.
  ///
  /// In ru, this message translates to:
  /// **'Товары, соответствующие вашему запросу, не найдены'**
  String get noProductsMatch;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить {name}?'**
  String deleteProductConfirm(String name);

  /// No description provided for @enterBarcode.
  ///
  /// In ru, this message translates to:
  /// **'Введите штрих-код'**
  String get enterBarcode;

  /// No description provided for @namePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'напр. Рис Басмати'**
  String get namePlaceholder;

  /// No description provided for @pricePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'0.00'**
  String get pricePlaceholder;

  /// No description provided for @measurementUnit.
  ///
  /// In ru, this message translates to:
  /// **'Единица измерения'**
  String get measurementUnit;

  /// No description provided for @pleaseEnterName.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, введите название'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterPrice.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, введите цену'**
  String get pleaseEnterPrice;

  /// No description provided for @unitDefault.
  ///
  /// In ru, this message translates to:
  /// **'шт'**
  String get unitDefault;

  /// No description provided for @dateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get dateLabel;

  /// No description provided for @totalLabel.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get totalLabel;

  /// No description provided for @enterStartBalance.
  ///
  /// In ru, this message translates to:
  /// **'Введите начальный баланс'**
  String get enterStartBalance;

  /// No description provided for @invalidNumber.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректное число'**
  String get invalidNumber;

  /// No description provided for @management.
  ///
  /// In ru, this message translates to:
  /// **'Управление'**
  String get management;

  /// No description provided for @shopDetails.
  ///
  /// In ru, this message translates to:
  /// **'Детали магазина'**
  String get shopDetails;

  /// No description provided for @shopDetailsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать бизнес-инфо и адрес'**
  String get shopDetailsSubtitle;

  /// No description provided for @hardware.
  ///
  /// In ru, this message translates to:
  /// **'Оборудование'**
  String get hardware;

  /// No description provided for @printDevice.
  ///
  /// In ru, this message translates to:
  /// **'Принтер'**
  String get printDevice;

  /// No description provided for @printerConnected.
  ///
  /// In ru, this message translates to:
  /// **'Принтер подключен'**
  String get printerConnected;

  /// No description provided for @noPrinterConnected.
  ///
  /// In ru, this message translates to:
  /// **'Принтер не подключен'**
  String get noPrinterConnected;

  /// No description provided for @connected.
  ///
  /// In ru, this message translates to:
  /// **'ПОДКЛЮЧЕНО'**
  String get connected;

  /// No description provided for @selectLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Выберите язык'**
  String get selectLanguage;

  /// No description provided for @reinitializingPrinter.
  ///
  /// In ru, this message translates to:
  /// **'Инициализация принтера'**
  String get reinitializingPrinter;

  /// No description provided for @printerRefreshHint.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы подключить новое устройство, нажмите на значок настроек, чтобы выполнить сопряжение в настройках Bluetooth телефона, затем вернитесь и нажмите Обновить.'**
  String get printerRefreshHint;

  /// No description provided for @generalInformation.
  ///
  /// In ru, this message translates to:
  /// **'Общая информация'**
  String get generalInformation;

  /// No description provided for @receiptHint.
  ///
  /// In ru, this message translates to:
  /// **'Эти данные будут отображаться в ваших цифровых и бумажных чеках.'**
  String get receiptHint;

  /// No description provided for @addressLine1.
  ///
  /// In ru, this message translates to:
  /// **'Адресная строка 1'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In ru, this message translates to:
  /// **'Адресная строка 2 (необязательно)'**
  String get addressLine2;

  /// No description provided for @upiId.
  ///
  /// In ru, this message translates to:
  /// **'UPI ID'**
  String get upiId;

  /// No description provided for @footerText.
  ///
  /// In ru, this message translates to:
  /// **'Текст внизу чека'**
  String get footerText;

  /// No description provided for @maxChars.
  ///
  /// In ru, this message translates to:
  /// **'Макс. 150 симв.'**
  String get maxChars;

  /// No description provided for @shopSaved.
  ///
  /// In ru, this message translates to:
  /// **'Данные магазина сохранены!'**
  String get shopSaved;

  /// No description provided for @requiredLabel.
  ///
  /// In ru, this message translates to:
  /// **'Обязательно'**
  String get requiredLabel;

  /// No description provided for @phone.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phone;

  /// No description provided for @alignBarcode.
  ///
  /// In ru, this message translates to:
  /// **'Поместите штрих-код в рамку'**
  String get alignBarcode;

  /// No description provided for @noUnitsFound.
  ///
  /// In ru, this message translates to:
  /// **'Единицы измерения не найдены'**
  String get noUnitsFound;

  /// No description provided for @editUnit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать единицу'**
  String get editUnit;

  /// No description provided for @saveDetails.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить данные'**
  String get saveDetails;

  /// No description provided for @scanToPay.
  ///
  /// In ru, this message translates to:
  /// **'Сканируйте для оплаты'**
  String get scanToPay;

  /// No description provided for @grandTotal.
  ///
  /// In ru, this message translates to:
  /// **'ОБЩИЙ ИТОГ'**
  String get grandTotal;

  /// No description provided for @shopDetailsNotLoaded.
  ///
  /// In ru, this message translates to:
  /// **'Данные магазина не загружены'**
  String get shopDetailsNotLoaded;

  /// No description provided for @pleaseOpenShift.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, сначала откройте смену!'**
  String get pleaseOpenShift;

  /// No description provided for @unknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get unknown;

  /// No description provided for @categories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get categories;

  /// No description provided for @addCategory.
  ///
  /// In ru, this message translates to:
  /// **'Добавить категорию'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать категорию'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In ru, this message translates to:
  /// **'Название категории'**
  String get categoryName;

  /// No description provided for @noCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории не найдены'**
  String get noCategories;

  /// No description provided for @selectCategory.
  ///
  /// In ru, this message translates to:
  /// **'Выберите категорию'**
  String get selectCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить {name}?'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @subtotal.
  ///
  /// In ru, this message translates to:
  /// **'Промежуточный итог'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In ru, this message translates to:
  /// **'Скидка'**
  String get discount;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @payment.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get payment;

  /// No description provided for @all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// No description provided for @analytics.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get analytics;

  /// No description provided for @revenue.
  ///
  /// In ru, this message translates to:
  /// **'Выручка'**
  String get revenue;

  /// No description provided for @profit.
  ///
  /// In ru, this message translates to:
  /// **'Прибыль'**
  String get profit;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In ru, this message translates to:
  /// **'Эта неделя'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In ru, this message translates to:
  /// **'Этот месяц'**
  String get thisMonth;

  /// No description provided for @topProducts.
  ///
  /// In ru, this message translates to:
  /// **'Популярные товары'**
  String get topProducts;

  /// No description provided for @salesByPayment.
  ///
  /// In ru, this message translates to:
  /// **'Продажи по способам оплаты'**
  String get salesByPayment;

  /// No description provided for @costPrice.
  ///
  /// In ru, this message translates to:
  /// **'Себестоимость'**
  String get costPrice;

  /// No description provided for @stock.
  ///
  /// In ru, this message translates to:
  /// **'Запас'**
  String get stock;

  /// No description provided for @filterByDate.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр по дате'**
  String get filterByDate;

  /// No description provided for @dailyRevenue.
  ///
  /// In ru, this message translates to:
  /// **'Выручка по дням'**
  String get dailyRevenue;

  /// No description provided for @change.
  ///
  /// In ru, this message translates to:
  /// **'Сдача'**
  String get change;

  /// No description provided for @received.
  ///
  /// In ru, this message translates to:
  /// **'Получено'**
  String get received;

  /// No description provided for @transactions.
  ///
  /// In ru, this message translates to:
  /// **'Транзакции'**
  String get transactions;

  /// No description provided for @salesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} продаж'**
  String salesCount(int count);

  /// No description provided for @productAddedToCart.
  ///
  /// In ru, this message translates to:
  /// **'{name} добавлен в корзину'**
  String productAddedToCart(String name);

  /// No description provided for @stockManagement.
  ///
  /// In ru, this message translates to:
  /// **'Управление запасами'**
  String get stockManagement;

  /// No description provided for @updateStock.
  ///
  /// In ru, this message translates to:
  /// **'Обновить запас'**
  String get updateStock;

  /// No description provided for @currentStock.
  ///
  /// In ru, this message translates to:
  /// **'Текущий запас'**
  String get currentStock;

  /// No description provided for @newStock.
  ///
  /// In ru, this message translates to:
  /// **'Новый запас'**
  String get newStock;

  /// No description provided for @lowStock.
  ///
  /// In ru, this message translates to:
  /// **'Мало товара'**
  String get lowStock;

  /// No description provided for @stockUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Запас успешно обновлен!'**
  String get stockUpdated;

  /// No description provided for @exportCSV.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт CSV'**
  String get exportCSV;

  /// No description provided for @share.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get share;

  /// No description provided for @salesReport.
  ///
  /// In ru, this message translates to:
  /// **'Отчет о продажах'**
  String get salesReport;

  /// No description provided for @amountReceived.
  ///
  /// In ru, this message translates to:
  /// **'Получено'**
  String get amountReceived;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
