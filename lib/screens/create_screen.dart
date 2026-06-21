import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_theme.dart';
import '../data/story_backgrounds.dart';
import '../services/app_state.dart';
import 'store_screen.dart';

/// Cria uma mensagem própria e gera uma IMAGEM (formato story) pra compartilhar.
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _controller = TextEditingController();
  final _cardKey = GlobalKey();
  int _bg = 0;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _canUse(StoryBg bg, AppState state) =>
      !bg.premium || state.isPremium || state.ownsExclusivePack;

  Future<void> _shareImage() async {
    if (_busy) return;
    final noWatermark = context.read<AppState>().canRemoveWatermark;
    setState(() => _busy = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/mensagem_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      await Share.shareXFiles([XFile(file.path)],
          text: noWatermark
              ? ''
              : 'Feito no app Foco em Foco 🎯');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bg = StoryBg.all[_bg];
    final text = _controller.text.trim().isEmpty
        ? 'Escreva a sua frase aqui...'
        : _controller.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Criar frase')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // Pré-visualização (formato story 9:16) — é o que vira imagem.
          Center(
            child: SizedBox(
              width: 270,
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradient(bg.colors),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                color: Colors.white,
                                fontSize: 22,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 2)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!state.canRemoveWatermark)
                          const Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Text('🎯 Foco em Foco',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Escreva a sua mensagem...',
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Fundos', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (!state.isPremium && !state.ownsExclusivePack)
                Text('🔒 premium',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: StoryBg.all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final b = StoryBg.all[i];
                final usable = _canUse(b, state);
                return GestureDetector(
                  onTap: () {
                    if (usable) {
                      setState(() => _bg = i);
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const StoreScreen()));
                    }
                  },
                  child: Container(
                    width: 52,
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradient(b.colors),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _bg == i
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: usable
                        ? null
                        : const Icon(Icons.lock_rounded,
                            color: Colors.white, size: 18),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : _shareImage,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.image_rounded),
            label: const Text('Compartilhar imagem (Story)'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              final t = _controller.text.trim();
              if (t.isNotEmpty) {
                Share.share('$t\n\n🌅 Bom Dia, Boa Tarde e Boa Noite');
              }
            },
            icon: const Icon(Icons.share_rounded),
            label: const Text('Compartilhar texto'),
          ),
        ],
      ),
    );
  }
}
