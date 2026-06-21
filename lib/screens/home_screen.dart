import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/app_theme.dart';
import '../data/greeting_generator.dart';
import '../data/models.dart';
import '../data/verses.dart';
import '../services/app_state.dart';
import '../widgets/share_helper.dart';
import 'category_screen.dart';
import 'messages_screen.dart';
import 'settings_screen.dart';
import 'store_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯  Foco em Foco'),
        actions: [
          IconButton(
            tooltip: 'Lembrete diário',
            icon: Icon(state.reminderOn
                ? Icons.notifications_active_rounded
                : Icons.notifications_none_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Loja Premium',
            icon: Icon(Icons.workspace_premium_rounded,
                color: state.isPremium ? const Color(0xFFD9A406) : null),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StoreScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Tema',
            icon: Icon(state.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () => context.read<AppState>().toggleTheme(),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: _MessageOfDay(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child:
                Text('Categorias', style: Theme.of(context).textTheme.titleLarge),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: [
              for (final c in VerseData.categories)
                _CategoryTile(
                    category: c, locked: state.isCategoryLocked(c.premium)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageOfDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final grad = context.watch<AppState>().palette.gradient;
    final text = GreetingGenerator.ofNow();
    final share = '$text\n\n🎯 Foco em Foco';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 12, 6),
      decoration: BoxDecoration(
        gradient: AppTheme.gradient(grad),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: grad.last.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 6),
              const Text('FRASE DO DIA',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(text,
              style: GoogleFonts.lora(
                  color: Colors.white,
                  fontSize: 19,
                  height: 1.5,
                  fontWeight: FontWeight.w500)),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MessagesScreen()),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.forum_rounded, size: 18),
                label: const Text('Ver mais'),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.white),
                onPressed: () async {
                  await ShareHelper.copy(share);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copiado!')),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () => ShareHelper.share(share),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, this.locked = false});
  final VerseCategory category;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient(category.gradient),
          borderRadius: BorderRadius.circular(22),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => locked
                  ? const StoreScreen()
                  : CategoryScreen(category: category),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(category.emoji, style: const TextStyle(fontSize: 30)),
                    const Spacer(),
                    if (locked)
                      const Icon(Icons.lock_rounded,
                          color: Colors.white, size: 20),
                  ],
                ),
                const Spacer(),
                Text(category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(locked ? 'Exclusivo' : '${category.verses.length} frases',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
