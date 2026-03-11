part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final bool isPrinting;
  final bool printSuccess;
  final double globalDiscount; // Fixed amount discount for the whole sale

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.isPrinting = false,
    this.printSuccess = false,
    this.globalDiscount = 0.0,
  });

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item.total);
  double get totalAmount {
    final amount = subtotal - globalDiscount;
    return amount < 0 ? 0 : amount;
  }

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    bool? isPrinting,
    bool? printSuccess,
    double? globalDiscount,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      globalDiscount: globalDiscount ?? this.globalDiscount,
    );
  }

  @override
  List<Object?> get props =>
      [cartItems, error, isPrinting, printSuccess, globalDiscount];
}
