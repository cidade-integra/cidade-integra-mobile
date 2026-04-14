import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_theme.dart';

class ImageUploadWidget extends StatefulWidget {
  final int maxImages;
  final ValueChanged<List<File>> onImagesChanged;

  const ImageUploadWidget({
    super.key,
    this.maxImages = 2,
    required this.onImagesChanged,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final _picker = ImagePicker();
  final List<File> _images = [];

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Máximo de ${widget.maxImages} imagens.'),
        ),
      );
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() => _images.add(File(picked.path)));
      widget.onImagesChanged(_images);
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
    widget.onImagesChanged(_images);
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagens (opcional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.azul,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Adicione até ${widget.maxImages} fotos do problema.',
          style: TextStyle(fontSize: 12, color: AppColors.textoSecundario),
        ),
        const SizedBox(height: 12),

        if (_images.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _ImagePreview(
                file: _images[index],
                onRemove: () => _removeImage(index),
              ),
            ),
          ),

        if (_images.isNotEmpty) const SizedBox(height: 12),

        if (_images.length < widget.maxImages)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showPickerOptions,
              icon: const Icon(Icons.add_a_photo_outlined, size: 20),
              label: Text(
                _images.isEmpty
                    ? 'Adicionar imagem'
                    : 'Adicionar outra imagem',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.bordas),
                foregroundColor: AppColors.textoSecundario,
              ),
            ),
          ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _ImagePreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            file,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
