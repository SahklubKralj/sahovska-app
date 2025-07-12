import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../models/notification_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_picker_widget.dart';
import '../../services/storage_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final StorageService _storageService = StorageService();
  
  NotificationType _selectedType = NotificationType.general;
  List<XFile> _selectedImages = [];
  bool _isUploadingImages = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Pristup zabranjen'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block,
                    size: 80,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nemate dozvolu za pristup ovoj stranici',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: Text('Nazad na početnu'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Admin Panel'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.signOut();
                  context.go('/login');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo obaveštenje',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        label: 'Naslov',
                        prefixIcon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Molimo unesite naslov';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Kategorija',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: DropdownButton<NotificationType>(
                          value: _selectedType,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (NotificationType? newValue) {
                            setState(() {
                              _selectedType = newValue!;
                            });
                          },
                          items: NotificationType.values.map((type) {
                            return DropdownMenuItem<NotificationType>(
                              value: type,
                              child: Text(_getTypeDisplayName(type)),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _contentController,
                        label: 'Sadržaj',
                        prefixIcon: Icons.description,
                        maxLines: 6,
                        hintText: 'Unesite detaljne informacije o obaveštenju...',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Molimo unesite sadržaj';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      
                      // Image picker
                      ImagePickerWidget(
                        onImagesSelected: (images) {
                          setState(() {
                            _selectedImages = images;
                          });
                        },
                        initialImages: _selectedImages,
                        allowMultiple: true,
                        maxImages: 5,
                        helpText: 'Dodajte do 5 slika za obaveštenje',
                      ),
                      
                      SizedBox(height: 24),
                      Consumer<NotificationsProvider>(
                        builder: (context, notificationsProvider, child) {
                          if (notificationsProvider.error != null) {
                            return Container(
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                notificationsProvider.error!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                      Consumer<NotificationsProvider>(
                        builder: (context, notificationsProvider, child) {
                          return CustomButton(
                            text: _isUploadingImages ? 'Upload slika...' : 'Objavi obaveštenje',
                            isLoading: notificationsProvider.isLoading || _isUploadingImages,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                notificationsProvider.clearError();
                                await _createNotificationWithImages(notificationsProvider, authProvider);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Divider(),
                SizedBox(height: 16),
                Text(
                  'Poslednja obaveštenja',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 16),
                Consumer<NotificationsProvider>(
                  builder: (context, notificationsProvider, child) {
                    final notifications = notificationsProvider.notifications.take(5).toList();
                    
                    if (notifications.isEmpty) {
                      return Center(
                        child: Text(
                          'Nema objavljenih obaveštenja',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              notification.title,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${notification.typeDisplayName} • ${_formatDate(notification.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteDialog(context, notification);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Obriši'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return 'Opšte';
      case NotificationType.tournament:
        return 'Turnir';
      case NotificationType.camp:
        return 'Kamp';
      case NotificationType.training:
        return 'Trening';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _createNotificationWithImages(
    NotificationsProvider notificationsProvider,
    AuthProvider authProvider,
  ) async {
    List<String>? imageUrls;
    
    // Upload images if any are selected
    if (_selectedImages.isNotEmpty) {
      setState(() {
        _isUploadingImages = true;
      });
      
      try {
        // Generate a temporary notification ID for image upload
        final tempNotificationId = DateTime.now().millisecondsSinceEpoch.toString();
        
        imageUrls = await _storageService.uploadMultipleNotificationImages(
          notificationId: tempNotificationId,
          imageFiles: _selectedImages,
          onProgress: (current, total) {
            // You could show progress here if needed
            print('Uploading image $current of $total');
          },
        );
        
        if (imageUrls.isEmpty) {
          _showError('Greška pri upload-u slika');
          return;
        }
      } catch (e) {
        _showError('Greška pri upload-u slika: $e');
        return;
      } finally {
        setState(() {
          _isUploadingImages = false;
        });
      }
    }
    
    // Create notification with image URLs
    bool success = await notificationsProvider.createNotificationWithImages(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: _selectedType,
      createdBy: authProvider.user!.uid,
      imageUrls: imageUrls,
    );
    
    if (success) {
      _clearForm();
      _showSuccess('Obaveštenje je uspešno objavljeno');
    }
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedType = NotificationType.general;
      _selectedImages.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Obriši obaveštenje'),
        content: Text('Da li ste sigurni da želite da obrišete ovo obaveštenje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Otkaži'),
          ),
          Consumer<NotificationsProvider>(
            builder: (context, notificationsProvider, child) {
              return TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  bool success = await notificationsProvider.deleteNotification(notification.id);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Obaveštenje je obrisano'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Greška pri brisanju obaveštenja'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Obriši', style: TextStyle(color: Colors.red)),
              );
            },
          ),
        ],
      ),
    );
  }
}