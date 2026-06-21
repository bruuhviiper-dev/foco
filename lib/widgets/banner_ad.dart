import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

/// Espaço de anúncio (placeholder na fase 1). Some quando o usuário compra
/// "remover anúncios" / premium. Na fase 2 vira um banner real do AdMob.
class BannerPlaceholder extends StatelessWidget {
  const BannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().adsRemoved) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        height: 54,
        width: double.infinity,
        alignment: Alignment.center,
        color: scheme.surfaceContainerHighest,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined,
                size: 15, color: scheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Text('Espaço de anúncio (preview)',
                style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}
