import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  /// Upload sliku za obaveštenje
  Future<String?> uploadNotificationImage({
    required String notificationId,
    required XFile imageFile,
  }) async {
    try {
      final String fileName = '${notificationId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final String uploadPath = 'notifications/$fileName';
      
      final Reference ref = _storage.ref().child(uploadPath);
      
      // Upload file
      final Uint8List imageData = await imageFile.readAsBytes();
      final UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(
          contentType: 'image/${path.extension(imageFile.path).substring(1)}',
          customMetadata: {
            'notificationId': notificationId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload avatar sliku za korisnika
  Future<String?> uploadUserAvatar({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      final String fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final String uploadPath = 'avatars/$fileName';
      
      final Reference ref = _storage.ref().child(uploadPath);
      
      final Uint8List imageData = await imageFile.readAsBytes();
      final UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(
          contentType: 'image/${path.extension(imageFile.path).substring(1)}',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      print('Avatar uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  /// Obriši sliku iz Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Image deleted successfully: $imageUrl');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Izaberi sliku iz galerije
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Izaberi sliku iz kamere
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Izaberi više slika odjednom
  Future<List<XFile>?> pickMultipleImages() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return images;
    } catch (e) {
      print('Error picking multiple images: $e');
      return null;
    }
  }

  /// Pokaži dialog za izbor izvora slike
  Future<XFile?> showImageSourceDialog() async {
    // Ova metoda će biti implementirana u UI komponenti
    // Ovde vraćamo null kao placeholder
    return null;
  }

  /// Upload više slika za jedno obaveštenje
  Future<List<String>> uploadMultipleNotificationImages({
    required String notificationId,
    required List<XFile> imageFiles,
    Function(int, int)? onProgress,
  }) async {
    final List<String> uploadedUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final String? url = await uploadNotificationImage(
        notificationId: notificationId,
        imageFile: imageFiles[i],
      );
      
      if (url != null) {
        uploadedUrls.add(url);
      }
      
      // Pozovi progress callback
      onProgress?.call(i + 1, imageFiles.length);
    }
    
    return uploadedUrls;
  }

  /// Dobij metadata o slici
  Future<FullMetadata?> getImageMetadata(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      final FullMetadata metadata = await ref.getMetadata();
      return metadata;
    } catch (e) {
      print('Error getting image metadata: $e');
      return null;
    }
  }

  /// Dobij listu svih slika za određeno obaveštenje
  Future<List<String>> getNotificationImages(String notificationId) async {
    try {
      final Reference ref = _storage.ref().child('notifications/');
      final ListResult result = await ref.listAll();
      
      final List<String> imageUrls = [];
      for (final Reference imageRef in result.items) {
        final FullMetadata metadata = await imageRef.getMetadata();
        final String? refNotificationId = metadata.customMetadata?['notificationId'];
        
        if (refNotificationId == notificationId) {
          final String downloadUrl = await imageRef.getDownloadURL();
          imageUrls.add(downloadUrl);
        }
      }
      
      return imageUrls;
    } catch (e) {
      print('Error getting notification images: $e');
      return [];
    }
  }

  /// Obriši sve slike za određeno obaveštenje
  Future<bool> deleteNotificationImages(String notificationId) async {
    try {
      final List<String> imageUrls = await getNotificationImages(notificationId);
      
      for (final String imageUrl in imageUrls) {
        await deleteImage(imageUrl);
      }
      
      print('All images deleted for notification: $notificationId');
      return true;
    } catch (e) {
      print('Error deleting notification images: $e');
      return false;
    }
  }

  /// Kompresuj sliku pre upload-a
  Future<Uint8List?> compressImage(XFile imageFile, {int quality = 80}) async {
    try {
      // Za naprednu kompresiju, dodajte flutter_image_compress package
      // Ovo je osnovna implementacija
      return await imageFile.readAsBytes();
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Dobij storage usage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final Reference notificationsRef = _storage.ref().child('notifications/');
      final Reference avatarsRef = _storage.ref().child('avatars/');
      
      final ListResult notificationsResult = await notificationsRef.listAll();
      final ListResult avatarsResult = await avatarsRef.listAll();
      
      int totalNotificationImages = notificationsResult.items.length;
      int totalAvatarImages = avatarsResult.items.length;
      
      // Aproksimativna kalkulacija storage size
      // U realnom scenariju bi trebalo sumirati actual file sizes
      
      return {
        'notificationImages': totalNotificationImages,
        'avatarImages': totalAvatarImages,
        'totalImages': totalNotificationImages + totalAvatarImages,
        'estimatedSize': '${(totalNotificationImages + totalAvatarImages) * 2}MB', // rough estimate
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {
        'notificationImages': 0,
        'avatarImages': 0,
        'totalImages': 0,
        'estimatedSize': '0MB',
      };
    }
  }
}