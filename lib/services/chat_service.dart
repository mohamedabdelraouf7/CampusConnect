import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection references
  CollectionReference get _messagesCollection => 
      _firestore.collection('study_group_messages');
  
  // Stream of messages for a study group
  Stream<List<ChatMessage>> getMessages(String studyGroupId) {
    return _firestore
        .collection('study_groups')
        .doc(studyGroupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }
  
  // Send a text message
  Future<void> sendMessage({
    required String studyGroupId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final message = ChatMessage(
      id: const Uuid().v4(),
      studyGroupId: studyGroupId,
      senderId: user.uid,
      senderName: user.displayName ?? user.email ?? 'Unknown',
      content: content,
      timestamp: DateTime.now(),
      readBy: {user.uid: true},
    );

    await _firestore
        .collection('study_groups')
        .doc(studyGroupId)
        .collection('messages')
        .doc(message.id)
        .set(message.toFirestore());
  }
  
  // Send an image message
  Future<void> sendImage({
    required String studyGroupId,
    required File imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Upload image to Firebase Storage
    final imageId = const Uuid().v4();
    final imageRef = _storage.ref().child('study_groups/$studyGroupId/images/$imageId');
    await imageRef.putFile(imageFile);
    final imageUrl = await imageRef.getDownloadURL();

    final message = ChatMessage(
      id: const Uuid().v4(),
      studyGroupId: studyGroupId,
      senderId: user.uid,
      senderName: user.displayName ?? user.email ?? 'Unknown',
      content: '📷 Image',
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      readBy: {user.uid: true},
    );

    await _firestore
        .collection('study_groups')
        .doc(studyGroupId)
        .collection('messages')
        .doc(message.id)
        .set(message.toFirestore());
  }
  
  // Send a file message
  Future<void> sendFile({
    required String studyGroupId,
    required File file,
    required String fileName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Upload file to Firebase Storage
    final fileId = const Uuid().v4();
    final fileRef = _storage.ref().child('study_groups/$studyGroupId/files/$fileId');
    await fileRef.putFile(file);
    final fileUrl = await fileRef.getDownloadURL();

    final message = ChatMessage(
      id: const Uuid().v4(),
      studyGroupId: studyGroupId,
      senderId: user.uid,
      senderName: user.displayName ?? user.email ?? 'Unknown',
      content: '📎 File: $fileName',
      timestamp: DateTime.now(),
      fileUrl: fileUrl,
      fileName: fileName,
      readBy: {user.uid: true},
    );

    await _firestore
        .collection('study_groups')
        .doc(studyGroupId)
        .collection('messages')
        .doc(message.id)
        .set(message.toFirestore());
  }
  
  // Delete a message
  Future<void> deleteMessage(String studyGroupId, String messageId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageRef = _firestore
        .collection('study_groups')
        .doc(studyGroupId)
        .collection('messages')
        .doc(messageId);

    final messageDoc = await messageRef.get();
    if (!messageDoc.exists) throw Exception('Message not found');

    final message = ChatMessage.fromFirestore(messageDoc);
    if (message.senderId != user.uid) {
      throw Exception('Cannot delete messages from other users');
    }

    // Delete attachments if they exist
    if (message.imageUrl != null) {
      final imageRef = _storage.refFromURL(message.imageUrl!);
      await imageRef.delete();
    }
    if (message.fileUrl != null) {
      final fileRef = _storage.refFromURL(message.fileUrl!);
      await fileRef.delete();
    }

    await messageRef.delete();
  }
  
  // Update a message
  Future<void> updateMessage({
    required String studyGroupId,
    required String messageId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    final messageRef = _firestore
        .collection('study_groups')
        .doc(studyGroupId)
        .collection('messages')
        .doc(messageId);
        
    final messageDoc = await messageRef.get();
    if (!messageDoc.exists) {
      throw Exception('Message not found');
    }
    
    final message = ChatMessage.fromFirestore(messageDoc);
    if (message.senderId != user.uid) {
      throw Exception('Not authorized to update this message');
    }
    
    await messageRef.update({
      'content': content,
      'isEdited': true,
      'editedAt': Timestamp.now(),
    });
  }
  
  // Mark messages as read
  Future<void> markMessagesAsRead(String studyGroupId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final messagesRef = _firestore
        .collection('study_groups')
        .doc(studyGroupId)
        .collection('messages')
        .where('readBy.${user.uid}', isEqualTo: false);

    final messages = await messagesRef.get();
    for (var doc in messages.docs) {
      final message = ChatMessage.fromFirestore(doc);
      final updatedReadBy = Map<String, bool>.from(message.readBy);
      updatedReadBy[user.uid] = true;

      batch.update(doc.reference, {
        'readBy': updatedReadBy,
        'isRead': updatedReadBy.values.every((read) => read),
      });
    }

    await batch.commit();
  }
  
  // Get unread message count
  Stream<int> getUnreadMessageCount(String studyGroupId) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    return _messagesCollection
        .where('studyGroupId', isEqualTo: studyGroupId)
        .where('readBy', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
} 