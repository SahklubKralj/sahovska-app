import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(List<XFile>) onImagesSelected;
  final List<XFile>? initialImages;
  final bool allowMultiple;
  final int maxImages;
  final String? helpText;

  const ImagePickerWidget({
    Key? key,
    required this.onImagesSelected,
    this.initialImages,
    this.allowMultiple = true,
    this.maxImages = 5,
    this.helpText,
  }) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final StorageService _storageService = StorageService();
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _selectedImages = widget.initialImages ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Slike (opciono)',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_selectedImages.isNotEmpty) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedImages.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (widget.helpText != null) ...[
          SizedBox(height: 4),
          Text(
            widget.helpText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        SizedBox(height: 12),
        
        // Add Images Button
        if (_selectedImages.length < widget.maxImages)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: Icon(Icons.add_photo_alternate),
              label: Text(_selectedImages.isEmpty ? 'Dodaj slike' : 'Dodaj još slika'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        
        // Selected Images Grid
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Izabrane slike (${_selectedImages.length}/${widget.maxImages})',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return _buildImageTile(_selectedImages[index], index);
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageTile(XFile imageFile, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(imageFile.path),
              fit: BoxFit.cover,
            ),
            
            // Overlay with actions
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            
            // Remove button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            
            // View button
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _viewImage(imageFile),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            
            // Image index
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Izaberite izvor slike',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            
            // Gallery option
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('Galerija'),
              subtitle: Text('Izaberite ${widget.allowMultiple ? "slike" : "sliku"} iz galerije'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            
            // Camera option
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('Kamera'),
              subtitle: Text('Fotografišite ${widget.allowMultiple ? "slike" : "sliku"}'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      if (widget.allowMultiple) {
        final List<XFile>? images = await _storageService.pickMultipleImages();
        if (images != null && images.isNotEmpty) {
          _addImages(images);
        }
      } else {
        final XFile? image = await _storageService.pickImageFromGallery();
        if (image != null) {
          _addImages([image]);
        }
      }
    } catch (e) {
      _showError('Greška pri izboru slika iz galerije');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _storageService.pickImageFromCamera();
      if (image != null) {
        _addImages([image]);
      }
    } catch (e) {
      _showError('Greška pri fotografisanju');
    }
  }

  void _addImages(List<XFile> newImages) {
    setState(() {
      final int remainingSlots = widget.maxImages - _selectedImages.length;
      final List<XFile> imagesToAdd = newImages.take(remainingSlots).toList();
      _selectedImages.addAll(imagesToAdd);
    });
    
    widget.onImagesSelected(_selectedImages);
    
    if (newImages.length > (widget.maxImages - (_selectedImages.length - newImages.length))) {
      _showInfo('Dodano je ${widget.maxImages - (_selectedImages.length - newImages.length)} slika. Maksimalno je ${widget.maxImages}.');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }

  void _viewImage(XFile imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewScreen(imageFile: imageFile),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

class _ImageViewScreen extends StatelessWidget {
  final XFile imageFile;

  const _ImageViewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Pregled slike',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(imageFile.path),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/// Widget za prikaz uploaded slika sa URL-ovima
class UploadedImagesWidget extends StatelessWidget {
  final List<String> imageUrls;
  final Function(String)? onImageTap;
  final Function(String)? onImageDelete;
  final bool showDeleteButton;

  const UploadedImagesWidget({
    Key? key,
    required this.imageUrls,
    this.onImageTap,
    this.onImageDelete,
    this.showDeleteButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Slike (${imageUrls.length})',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                child: _buildNetworkImageTile(imageUrls[index], context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImageTile(String imageUrl, BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.error,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
            
            // Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            
            // Delete button
            if (showDeleteButton && onImageDelete != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onImageDelete!(imageUrl),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            
            // Tap to view
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (onImageTap != null) {
                      onImageTap!(imageUrl);
                    } else {
                      _viewNetworkImage(context, imageUrl);
                    }
                  },
                  child: Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewNetworkImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _NetworkImageViewScreen(imageUrl: imageUrl),
      ),
    );
  }
}

class _NetworkImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const _NetworkImageViewScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Pregled slike',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Greška pri učitavanju slike',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}