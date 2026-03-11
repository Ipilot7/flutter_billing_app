import 'package:fpdart/fpdart.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final AppDatabase _db;

  ShopRepositoryImpl(this._db);

  @override
  Future<Either<Failure, Shop>> getShop() async {
    try {
      final rows = await _db.select(_db.shopDetails).get();
      if (rows.isNotEmpty) {
        return Right(_mapToEntity(rows.first));
      } else {
        // Return default shop if not found
        return const Right(Shop(
            name: 'Dinesh Shop',
            addressLine1: 'Samrajpet, Mecheri',
            addressLine2: 'Salem - 636453',
            phoneNumber: '+917010674588',
            upiId: 'dineshsowndar@oksbi',
            footerText: 'Thank you, Visit again!!!'));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async {
    try {
      // Clear existing and insert new (simple single row management)
      await _db.delete(_db.shopDetails).go();
      await _db.into(_db.shopDetails).insert(_mapToTable(shop));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Shop _mapToEntity(ShopTable table) {
    return Shop(
      name: table.name,
      addressLine1: table.addressLine1,
      addressLine2: table.addressLine2,
      phoneNumber: table.phoneNumber,
      upiId: table.upiId,
      footerText: table.footerText,
    );
  }

  ShopTable _mapToTable(Shop shop) {
    return ShopTable(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      upiId: shop.upiId,
      footerText: shop.footerText,
    );
  }
}
