import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../services/app_state.dart';
import 'share_helper.dart';

/// Cartão de um versículo, com ações de favoritar, copiar e compartilhar.
class VerseTile extends StatelessWidget {
  const VerseTile({super.key, required this.verse});

  final Verse verse;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final fav = state.isFavorite(verse.id);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 6, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(verse.text,
                style: GoogleFonts.lora(fontSize: 16, height: 1.5)),
            if (verse.reference.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(verse.reference,
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: scheme.primary)),
            ],
            Row(
              children: [
                IconButton(
                  tooltip: 'Favoritar',
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                      color: fav ? const Color(0xFFE11D48) : null),
                  onPressed: () =>
                      context.read<AppState>().toggleFavorite(verse.id),
                ),
                IconButton(
                  tooltip: 'Copiar',
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () async {
                    await ShareHelper.copy(verse.shareText);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Frase copiada!')),
                      );
                    }
                  },
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Compartilhar',
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => ShareHelper.share(verse.shareText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
