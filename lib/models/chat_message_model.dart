import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String studyGroupId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;
  final String? fileUrl;
  final String? fileName;
  final bool isRead;
  final Map<String, bool> readBy;
  final bool isEdited;
  final DateTime? editedAt;

  ChatMessage({
    required this.id,
    required this.studyGroupId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
    this.isRead = false,
    required this.readBy,
    this.isEdited = false,
    this.editedAt,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      studyGroupId: data['studyGroupId'] as String,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] as String?,
      fileUrl: data['fileUrl'] as String?,
      fileName: data['fileName'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      readBy: Map<String, bool>.from(data['readBy'] as Map),
      isEdited: data['isEdited'] as bool? ?? false,
      editedAt: data['editedAt'] != null 
          ? (data['editedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studyGroupId': studyGroupId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'isRead': isRead,
      'readBy': readBy,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? studyGroupId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    bool? isRead,
    Map<String, bool>? readBy,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      studyGroupId: studyGroupId ?? this.studyGroupId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      isRead: isRead ?? this.isRead,
      readBy: readBy ?? this.readBy,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
} 