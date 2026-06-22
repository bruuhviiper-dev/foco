import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_palettes.dart';
import '../data/app_theme.dart';
import '../services/ads_service.dart';
import '../services/app_state.dart';
import '../services/purchase_service.dart';
import '../services/store_products.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  Future<void> _buy(BuildContext context, String id) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Processando…')));
    final res = await PurchaseService.instance.buy(id);
    if (!context.mounted) return;
    final msg = res == PurchaseResult.success
        ? 'Tudo certo! Item liberado. 🎉'
        : 'Não foi possível concluir a compra.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Loja Premium')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          if (state.isPremium)
            _Badge()
          else ...[
            _BundleCard(
              price:
                  PurchaseService.instance.priceOf(StoreProducts.premiumBundle.id),
              onBuy: () => _buy(context, StoreProducts.premiumBundle.id),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.movie_filter_rounded, size: 30),
                title: const Text('Liberar tudo por 24h',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Assistindo um anúncio rápido (grátis)'),
                trailing: const Icon(Icons.play_circle_fill_rounded, size: 30),
                onTap: () async {
                  final shown = await AdsService.instance.showRewarded(() {
                    context
                        .read<AppState>()
                        .grantTemporaryPro(const Duration(hours: 24));
                  });
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(shown
                            ? 'Aproveite! Tudo liberado por 24h. 🎉'
                            : 'Anúncio carregando, tente de novo em instantes.')));
                },
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (!state.isSubscriber) ...[
            const _SectionTitle('Assinatura'),
            _ProductTile(
                product: StoreProducts.premiumMonthly,
                price: PurchaseService.instance
                    .priceOf(StoreProducts.premiumMonthly.id),
                owned: false,
                onBuy: () => _buy(context, StoreProducts.premiumMonthly.id)),
            const SizedBox(height: 10),
            _ProductTile(
                product: StoreProducts.premiumYearly,
                price: PurchaseService.instance
                    .priceOf(StoreProducts.premiumYearly.id),
                owned: false,
                onBuy: () => _buy(context, StoreProducts.premiumYearly.id)),
            const SizedBox(height: 18),
          ],
          if (!state.adsRemoved) ...[
            const _SectionTitle('Sem anúncios'),
            _ProductTile(
                product: StoreProducts.removeAds,
                price:
                    PurchaseService.instance.priceOf(StoreProducts.removeAds.id),
                owned: false,
                onBuy: () => _buy(context, StoreProducts.removeAds.id)),
            const SizedBox(height: 18),
          ],
          if (!state.canRemoveWatermark) ...[
            const _SectionTitle("Marca d'água"),
            _ProductTile(
                product: StoreProducts.removeWatermark,
                price: PurchaseService.instance
                    .priceOf(StoreProducts.removeWatermark.id),
                owned: false,
                onBuy: () => _buy(context, StoreProducts.removeWatermark.id)),
            const SizedBox(height: 18),
          ],
          if (!state.ownsExclusivePack) ...[
            const _SectionTitle('Conteúdo exclusivo'),
            _ProductTile(
                product: StoreProducts.packExclusivas,
                price: PurchaseService.instance
                    .priceOf(StoreProducts.packExclusivas.id),
                owned: false,
                onBuy: () => _buy(context, StoreProducts.packExclusivas.id)),
            const SizedBox(height: 18),
          ],
          const _SectionTitle('Temas'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              for (final p in AppPalettes.all)
                _ThemeCard(
                  palette: p,
                  owned: state.ownsPalette(p.id),
                  selected: state.palette.id == p.id,
                  price: p.productId == null
                      ? ''
                      : PurchaseService.instance.priceOf(p.productId!),
                  onUse: () => context.read<AppState>().setPalette(p.id),
                  onBuy:
                      p.productId == null ? null : () => _buy(context, p.productId!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.gradient(const [Color(0xFFFDC830), Color(0xFFF37335)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: const [
          Text('👑', style: TextStyle(fontSize: 32)),
          SizedBox(width: 14),
          Expanded(
            child: Text('Você é Premium!\nAproveite tudo sem anúncios.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  const _BundleCard({required this.price, required this.onBuy});
  final String price;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.gradient(const [Color(0xFFFDC830), Color(0xFFF37335)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👑 Premium',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Sem anúncios + todos os temas + conteúdo exclusivo.',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFC2410C)),
              onPressed: onBuy,
              child: Text('Comprar tudo  •  $price',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.price,
    required this.owned,
    required this.onBuy,
  });
  final StoreProduct product;
  final String price;
  final bool owned;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Text(product.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(product.description,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            owned
                ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                : FilledButton(onPressed: onBuy, child: Text(price)),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.palette,
    required this.owned,
    required this.selected,
    required this.price,
    required this.onUse,
    this.onBuy,
  });
  final AppPalette palette;
  final bool owned;
  final bool selected;
  final String price;
  final VoidCallback onUse;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: owned ? onUse : onBuy,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? palette.accent
                : scheme.onSurface.withValues(alpha: 0.08),
            width: selected ? 2.2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      gradient: AppTheme.gradient(palette.gradient),
                      shape: BoxShape.circle),
                ),
                const Spacer(),
                if (!owned)
                  Icon(Icons.lock_rounded,
                      size: 18, color: scheme.onSurface.withValues(alpha: 0.4)),
                if (selected)
                  Icon(Icons.check_circle_rounded,
                      size: 20, color: palette.accent),
              ],
            ),
            const Spacer(),
            Text(palette.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
                owned
                    ? (selected ? 'Em uso' : 'Tocar para usar')
                    : price,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: owned
                        ? scheme.onSurface.withValues(alpha: 0.6)
                        : palette.accent)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
          )),
    );
  }
}
