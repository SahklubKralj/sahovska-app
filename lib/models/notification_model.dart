enum NotificationType {
  general,
  tournament,
  camp,
  training,
}

class NotificationModel {
  final String id;
  final String title;
  final String content;
  final NotificationType type;
  final DateTime createdAt;
  final String createdBy;
  final List<String>? imageUrls;
  final bool isActive;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.createdBy,
    this.imageUrls,
    this.isActive = true,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['type'] ?? 'general'),
        orElse: () => NotificationType.general,
      ),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      createdBy: data['createdBy'] ?? '',
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from(data['imageUrls']) 
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'imageUrls': imageUrls,
      'isActive': isActive,
    };
  }

  String get typeDisplayName {
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

  NotificationModel copyWith({
    String? id,
    String? title,
    String? content,
    NotificationType? type,
    DateTime? createdAt,
    String? createdBy,
    List<String>? imageUrls,
    bool? isActive,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
    );
  }
}