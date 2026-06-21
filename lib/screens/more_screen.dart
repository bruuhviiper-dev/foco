import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_info.dart';

/// Aba "Mais": avaliar, compartilhar o app e cross-promoção (outros apps).
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.star_rounded, color: Color(0xFFFBBF24)),
            title: const Text('Avaliar na Play Store'),
            subtitle: const Text('Sua nota ajuda muito 💛'),
            onTap: () => _open(AppInfo.playUrl),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share_rounded),
            title: const Text('Compartilhar o app'),
            subtitle: const Text('Indique para os amigos'),
            onTap: () =>
                Share.share('Conheça o ${AppInfo.appName}! ${AppInfo.playUrl}'),
          ),
          const Divider(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text('OUTROS APPS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: scheme.primary)),
          ),
          for (final a in AppInfo.otherApps)
            ListTile(
              leading: const Icon(Icons.apps_rounded),
              title: Text(a.$1),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => _open(AppInfo.playUrlFor(a.$2)),
            ),
          const SizedBox(height: 20),
          Center(
            child: Text('By: ${AppInfo.developer}',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
