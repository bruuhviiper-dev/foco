import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:provider/provider.dart';

import '../services/ads_service.dart';
import '../services/app_state.dart';

/// Banner real do AdMob. Some quando o usuário comprou "remover anúncios"
/// / premium. Mantém o nome BannerPlaceholder por compatibilidade.
class BannerPlaceholder extends StatefulWidget {
  const BannerPlaceholder({super.key});

  @override
  State<BannerPlaceholder> createState() => _BannerPlaceholderState();
}

class _BannerPlaceholderState extends State<BannerPlaceholder> {
  BannerAd? _ad;
  bool _loaded = false;

  bool get _supported => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (!_supported) return;
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: AdsService.instance.bannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    );
    ad.load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final removed = context.watch<AppState>().adsRemoved;
    AdsService.instance.adsRemoved = removed;
    if (removed) return const SizedBox.shrink();
    if (_ad == null || !_loaded) return const SizedBox(height: 50);
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
