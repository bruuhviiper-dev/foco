import 'package:flutter/foundation.dart';

import 'store_products.dart';

/// Compras SIMULADAS (fase 1, sem plugin de billing). A compra é concedida
/// na hora, para você ver a loja e o premium funcionando. Na fase 2, troca-se
/// por Google Play Billing (in_app_purchase), reaproveitando esta mesma API.
class PurchaseService extends ChangeNotifier {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  void Function(String productId)? _onGrant;
  void Function(String productId)? _onSubGrant;

  void onEntitlement(void Function(String productId) cb) => _onGrant = cb;
  void onSubscriptionGranted(void Function(String productId) cb) =>
      _onSubGrant = cb;

  bool get isAvailable => true;

  String priceOf(String productId) =>
      StoreProducts.byId(productId)?.fallbackPrice ?? '';

  Future<PurchaseResult> buy(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (StoreProducts.subscriptionIds.contains(productId)) {
      _onSubGrant?.call(productId);
    } else {
      _onGrant?.call(productId);
    }
    return PurchaseResult.success;
  }

  Future<void> restore() async {}
  Future<void> init() async {}
}
