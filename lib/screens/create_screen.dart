import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_theme.dart';
import '../data/story_backgrounds.dart';
import '../services/app_state.dart';
import 'store_screen.dart';

/// Editor PRO: cria uma frase como imagem (formatos, fontes, cores, sua foto,
/// assinatura e salvar na galeria). Recursos PRO liberados no premium.
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _Format {
  const _Format(this.label, this.ratio);
  final String label;
  final double ratio;
}

class _CreateScreenState extends State<CreateScreen> {
  final _controller = TextEditingController();
  final _cardKey = GlobalKey();

  int _bg = 0;
  int _format = 0;
  int _font = 0;
  int _color = 0;
  String? _photoPath;
  bool _busy = false;

  static const _formats = [
    _Format('Story', 9 / 16),
    _Format('Quadrado', 1),
    _Format('Retrato', 4 / 5),
  ];

  // 1ª fonte/cor são grátis; o resto é PRO.
  static const _fonts = [
    'Lora',
    'Montserrat',
    'Poppins',
    'Pacifico',
    'Oswald',
    'Dancing Script',
    'Bebas Neue',
    'Playfair Display',
  ];
  static const _colors = [
    Colors.white,
    Colors.black,
    Color(0xFFFFE066),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFC026D3),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _pro(AppState s) =>
      s.isPremium || s.ownsExclusivePack || s.hasTemporaryPro;

  /// Recurso PRO: oferece comprar OU assistir anúncio (libera 24h).
  void _unlock(AppState s) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 2),
              child: Text('Recurso PRO 💎',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                  'Desbloqueie com o Premium ou assista a um anúncio e use por 24h.',
                  textAlign: TextAlign.center),
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_fill_rounded,
                  color: Color(0xFF16A34A)),
              title: const Text('Assistir anúncio e liberar 24h'),
              onTap: () {
                Navigator.pop(ctx);
                s.grantTemporaryPro(const Duration(hours: 24));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('PRO liberado por 24h! Aproveite 🎉')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium_rounded,
                  color: Color(0xFFD9A406)),
              title: const Text('Comprar Premium'),
              subtitle: const Text('Desbloqueia pra sempre'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StoreScreen()));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _capture() async {
    final boundary =
        _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await boundary.toImage(pixelRatio: 3.5);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  Future<void> _shareImage(bool noWatermark) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file =
          File('${dir.path}/frase_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: noWatermark ? '' : 'Feito no app Foco em Foco 🎯');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveGallery() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) return;
      await Gal.putImageBytes(bytes, album: 'Foco em Foco');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagem salva na galeria! 📥')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível salvar.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (x != null) setState(() => _photoPath = x.path);
  }

  Future<void> _editSignature(AppState s) async {
    final c = TextEditingController(text: s.customSignature);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sua assinatura'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: '@seu_perfil ou seu nome'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (v != null) s.setCustomSignature(v);
  }

  TextStyle _font_(Color color) => GoogleFonts.getFont(
        _fonts[_font],
        color: color,
        fontSize: 22,
        height: 1.4,
        fontWeight: FontWeight.w600,
        shadows: const [
          Shadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 2)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pro = _pro(state);
    final bg = StoryBg.all[_bg];
    final color = _colors[_color];
    final text = _controller.text.trim().isEmpty
        ? 'Escreva a sua frase aqui...'
        : _controller.text.trim();

    // Regra: assinatura personalizada (PRO) sempre aparece quando preenchida;
    // premium sem assinatura = imagem limpa; grátis = marca d'água do app.
    final sig = state.customSignature.isNotEmpty
        ? state.customSignature
        : (state.canRemoveWatermark ? '' : '🎯 Foco em Foco');

    return Scaffold(
      appBar: AppBar(title: const Text('Criar (Editor PRO)')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // ---- Pré-visualização (vira a imagem) ----
          Center(
            child: SizedBox(
              width: 280,
              child: AspectRatio(
                aspectRatio: _formats[_format].ratio,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:
                          _photoPath == null ? AppTheme.gradient(bg.colors) : null,
                      image: _photoPath != null
                          ? DecorationImage(
                              image: FileImage(File(_photoPath!)),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (_photoPath != null)
                          Container(color: Colors.black.withValues(alpha: 0.28)),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child:
                                Text(text, textAlign: TextAlign.center, style: _font_(color)),
                          ),
                        ),
                        if (sig.isNotEmpty)
                          Positioned(
                            bottom: 14,
                            left: 0,
                            right: 0,
                            child: Text(sig,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: color.withValues(alpha: 0.85),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            maxLines: 4,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Escreva a sua frase...',
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          _proLabel(context, 'Formato', pro),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < _formats.length; i++)
                ChoiceChip(
                  avatar: (i > 0 && !pro)
                      ? const Icon(Icons.lock_rounded, size: 14)
                      : null,
                  label: Text(_formats[i].label),
                  selected: _format == i,
                  onSelected: (_) =>
                      (i > 0 && !pro) ? _unlock(state) : setState(() => _format = i),
                ),
            ],
          ),
          const SizedBox(height: 14),

          _proLabel(context, 'Fontes', pro),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _fonts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final locked = i > 0 && !pro;
                final sel = _font == i;
                return ActionChip(
                  label: Text('Aa',
                      style: GoogleFonts.getFont(_fonts[i],
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w500)),
                  avatar: locked
                      ? const Icon(Icons.lock_rounded, size: 14)
                      : null,
                  backgroundColor: sel
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  onPressed: () =>
                      locked ? _unlock(state) : setState(() => _font = i),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          _proLabel(context, 'Cor do texto', pro),
          Row(
            children: [
              for (var i = 0; i < _colors.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => (i > 1 && !pro)
                        ? _unlock(state)
                        : setState(() => _color = i),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _colors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _color == i
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black26,
                            width: _color == i ? 3 : 1),
                      ),
                      child: (i > 1 && !pro)
                          ? const Icon(Icons.lock_rounded,
                              size: 14, color: Colors.black54)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          _proLabel(context, 'Fundo', pro),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: StoryBg.all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final b = StoryBg.all[i];
                final locked = b.premium && !pro;
                return GestureDetector(
                  onTap: () => locked
                      ? _unlock(state)
                      : setState(() {
                          _bg = i;
                          _photoPath = null;
                        }),
                  child: Container(
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradient(b.colors),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: (_photoPath == null && _bg == i)
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 3),
                    ),
                    child: locked
                        ? const Icon(Icons.lock_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ---- Ações PRO ----
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => pro ? _pickPhoto() : _unlock(state),
                  icon: Icon(pro
                      ? Icons.add_photo_alternate_rounded
                      : Icons.lock_rounded),
                  label: const Text('Sua foto'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => pro ? _editSignature(state) : _unlock(state),
                  icon: Icon(pro ? Icons.draw_rounded : Icons.lock_rounded),
                  label: const Text('Assinatura'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : () => _shareImage(state.canRemoveWatermark),
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.share_rounded),
            label: const Text('Compartilhar imagem'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => pro ? _saveGallery() : _unlock(state),
            icon: Icon(pro ? Icons.download_rounded : Icons.lock_rounded),
            label: const Text('Salvar na galeria (HD)'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              final t = _controller.text.trim();
              if (t.isNotEmpty) {
                Share.share('$t\n\n🎯 Foco em Foco');
              }
            },
            icon: const Icon(Icons.text_fields_rounded),
            label: const Text('Compartilhar texto'),
          ),
        ],
      ),
    );
  }

  Widget _proLabel(BuildContext context, String t, bool pro) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(t, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 8),
            if (!pro)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('PRO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ),
          ],
        ),
      );
}
