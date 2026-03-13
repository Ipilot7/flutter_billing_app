import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';
import 'package:billing_app/features/sales/domain/usecases/sales_usecases.dart';
import 'package:billing_app/features/settings/domain/repositories/printer_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class _FakeProductRepository implements ProductRepository {
  final Map<String, Product> byBarcode = {};
  final List<Product> updatedProducts = [];

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    byBarcode[product.barcode] = product;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    byBarcode.removeWhere((_, value) => value.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    final product = byBarcode[barcode];
    if (product == null) {
      return const Left(CacheFailure('not found'));
    }
    return Right(product);
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    return Right(byBarcode.values.toList());
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    updatedProducts.add(product);
    byBarcode[product.barcode] = product;
    return const Right(null);
  }
}

class _FakeSalesRepository implements SalesRepository {
  final List<Sale> createdSales = [];

  @override
  Future<Either<Failure, Sale>> createSale(Sale sale) async {
    createdSales.add(sale);
    return Right(sale);
  }

  @override
  Future<Either<Failure, Sale>> getSaleById(String id) async {
    Sale? sale;
    for (final item in createdSales) {
      if (item.id == id) {
        sale = item;
        break;
      }
    }
    if (sale == null) {
      return const Left(CacheFailure('sale not found'));
    }
    return Right(sale);
  }

  @override
  Future<Either<Failure, List<Sale>>> getSalesHistory({
    DateTime? from,
    DateTime? to,
    String? shiftId,
  }) async {
    return Right(createdSales);
  }

  @override
  Future<Either<Failure, Sale>> returnSale(String saleId) async {
    return const Left(CacheFailure('not used in this test'));
  }
}

class _FakePrinterRepository implements PrinterRepository {
  String? savedMac;

  @override
  Future<void> clearPrinterData() async {}

  @override
  Future<bool> connect(String macAddress) async => true;

  @override
  Future<bool> disconnect() async => true;

  @override
  Future<String?> getSavedPrinterMac() async => savedMac;

  @override
  Future<String?> getSavedPrinterName() async => null;

  @override
  Future<void> savePrinterData(String mac, String name) async {
    savedMac = mac;
  }

  @override
  Future<List<BluetoothInfo>> scanDevices() async => [];

  @override
  Future<void> testPrint(String shopName) async {}
}

void main() {
  group('BillingBloc POS flow', () {
    late _FakeProductRepository productRepo;
    late _FakeSalesRepository salesRepo;
    late BillingBloc bloc;
    late Product tea;

    setUp(() {
      productRepo = _FakeProductRepository();
      salesRepo = _FakeSalesRepository();

      tea = const Product(
        id: 'p-1',
        name: 'Tea',
        barcode: '111',
        price: 50,
        costPrice: 20,
        stock: 10,
      );
      productRepo.byBarcode[tea.barcode] = tea;

      bloc = BillingBloc(
        getProductByBarcodeUseCase: GetProductByBarcodeUseCase(productRepo),
        createSaleUseCase: CreateSaleUseCase(salesRepo),
        updateProductUseCase: UpdateProductUseCase(productRepo),
        printerRepository: _FakePrinterRepository(),
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test('adds same product twice and increments quantity', () async {
      bloc.add(AddProductToCartEvent(tea));
      await Future<void>.delayed(Duration.zero);
      bloc.add(AddProductToCartEvent(tea));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.cartItems.length, 1);
      expect(bloc.state.cartItems.first.quantity, 2);
      expect(bloc.state.totalAmount, 100);
    });

    test('completes sale, clears cart, and updates stock', () async {
      bloc.add(AddProductToCartEvent(tea));
      await Future<void>.delayed(Duration.zero);
      bloc.add(UpdateQuantityEvent(tea.id, 3));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const CompleteSaleEvent(
        shiftId: 'shift-1',
        openedBy: 'cashier',
        paymentType: 0,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(salesRepo.createdSales.length, 1);
      expect(salesRepo.createdSales.first.totalAmount, 150);

      expect(productRepo.updatedProducts.isNotEmpty, true);
      final updated = productRepo.updatedProducts.last;
      expect(updated.id, tea.id);
      expect(updated.stock, 7);

      expect(bloc.state.cartItems, isEmpty);
    });
  });
}
