import 'dart:io';

import 'package:flutter/material.dart';

class ImageGalleryPage extends StatefulWidget {
  const ImageGalleryPage({Key? key}) : super(key: key);

  @override
  State<ImageGalleryPage> createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    // TODO: Load images from local storage or app state
    setState(() {
      _images = [];
    });
  }

  void _viewImage(File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewScreen(imageFile: imageFile),
      ),
    );
  }

  void _deleteImage(int index) {
    // TODO: Delete image from storage and update list
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
      ),
      body: _images.isEmpty
          ? const Center(child: Text('No images found'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                return GestureDetector(
                  onTap: () => _viewImage(image),
                  onLongPress: () => _deleteImage(index),
                  child: Image.file(image, fit: BoxFit.cover),
                );
              },
            ),
    );
  }
}

class ImageViewScreen extends StatelessWidget {
  final File imageFile;

  const ImageViewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Image'),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
