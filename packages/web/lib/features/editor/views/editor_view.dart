import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_colors_ext.dart';
import '../../auth/controllers/auth_controller.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final titleCtrl = TextEditingController();
  final subtitleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  bool memberOnly = false;
  final _auth = Get.find<AuthController>();

  @override
  void dispose() {
    titleCtrl.dispose();
    subtitleCtrl.dispose();
    contentCtrl.dispose();
    tagsCtrl.dispose();
    super.dispose();
  }

  void _saveDraft() {
    Get.snackbar('Taslak kaydedildi', 'Yazın taslaklara eklendi.');
  }

  void _publish() {
    Get.snackbar('Yayınlandı', 'Yazın okuyucularla buluştu.');
    Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_auth.isAuthenticated.value) {
        return Scaffold(
          appBar: AppBar(title: const Text('Giriş gerekli')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Yazı yayınlama işlemi için hesabınızla giriş yapmanız gerekiyor.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Get.toNamed('/login'),
                    child: const Text('Giriş Yap'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Get.toNamed('/register'),
                    child: const Text('Kayıt Ol'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Yeni Yazı'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _saveDraft,
              tooltip: 'Taslak kaydet',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: _publish,
                icon: const Icon(Icons.publish_outlined, size: 18),
                label: const Text('Yayınla'),
              ),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                TextField(
                  controller: titleCtrl,
                  style: Theme.of(context).textTheme.headlineMedium,
                  decoration: const InputDecoration(
                    hintText: 'Başlık',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                TextField(
                  controller: subtitleCtrl,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: const InputDecoration(
                    hintText: 'Kısa özet',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ToolButton(icon: Icons.format_bold, label: 'Bold'),
                    _ToolButton(icon: Icons.format_italic, label: 'Italic'),
                    _ToolButton(icon: Icons.format_quote, label: 'Quote'),
                    _ToolButton(icon: Icons.link, label: 'Link'),
                    _ToolButton(icon: Icons.code, label: 'Code'),
                    _ToolButton(icon: Icons.image_outlined, label: 'Görsel'),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentCtrl,
                  minLines: 14,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(hintText: 'Yazmaya başla...'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Etiketler',
                    hintText: 'flutter, dart, backend',
                    prefixIcon: Icon(Icons.tag_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: memberOnly,
                  onChanged: (value) => setState(() => memberOnly = value),
                  title: const Text('Üyelere özel'),
                  secondary: Icon(
                    Icons.star_rounded,
                    color: context.appColors.textSub,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: IconButton.outlined(icon: Icon(icon, size: 18), onPressed: () {}),
    );
  }
}
