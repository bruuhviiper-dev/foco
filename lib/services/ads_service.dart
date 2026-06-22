import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Serviço de anúncios (AdMob). Usa os IDs de TESTE do Google — na publicação,
/// troque `_rewardedUnit` (e o APPLICATION_ID no AndroidManifest) pelos seus.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  // Unidade de anúncio PREMIADO de TESTE (oficial do Google).
  static const String _rewardedTestUnit =
      'ca-app-pub-3940256099942544/5224354917';

  RewardedAd? _rewarded;
  bool _loading = false;
  bool _ready = false;

  void init() {
    MobileAds.instance.initialize();
    _load();
  }

  void _load() {
    if (_loading || _rewarded != null) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: _rewardedTestUnit,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _ready = true;
          _loading = false;
        },
        onAdFailedToLoad: (err) {
          _rewarded = null;
          _ready = false;
          _loading = false;
        },
      ),
    );
  }

  bool get isReady => _ready && _rewarded != null;

  /// Mostra o anúncio premiado. Chama [onReward] SÓ quando o usuário
  /// realmente assistir e ganhar a recompensa. Retorna false se não havia
  /// anúncio carregado (e dispara um novo carregamento).
  Future<bool> showRewarded(void Function() onReward) async {
    final ad = _rewarded;
    if (ad == null) {
      _load();
      return false;
    }
    _rewarded = null;
    _ready = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _load();
      },
    );
    await ad.show(onUserEarnedReward: (ad, reward) => onReward());
    return true;
  }
}
