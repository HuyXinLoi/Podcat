import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podcat/core/services/upload_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String) onImageUploaded;
  final String uploadButtonLabel;

  const ImageUploadWidget({
    Key? key,
    this.initialImageUrl,
    required this.onImageUploaded,
    required this.uploadButtonLabel,
  }) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final TextEditingController _imageUrlController = TextEditingController();
  final UploadService _uploadService = UploadService();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlController.text = widget.initialImageUrl ?? '';
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isUploading = true;
      });

      final imageUrl = await _uploadService.uploadImage(_selectedImage!);

      if (imageUrl != null) {
        setState(() {
          _imageUrlController.text = imageUrl;
          _isUploading = false;
        });

        widget.onImageUploaded(imageUrl);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Expanded(
            //   child: TextFormField(
            //     controller: _imageUrlController,
            //     decoration: InputDecoration(
            //       hintText: 'Image URL',
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //     readOnly: true,
            //   ),
            // ),
            // const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadImage,
              icon: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: Text(widget.uploadButtonLabel),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedImage != null ||
            (widget.initialImageUrl != null &&
                widget.initialImageUrl!.isNotEmpty))
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.initialImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
