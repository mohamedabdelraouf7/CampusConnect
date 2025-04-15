import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime dateCreated;
  final DateTime dateModified;
  final Color color;
  final bool isPinned;
  
  NoteModel({
    String? id,
    required this.title,
    required this.content,
    DateTime? dateCreated,
    DateTime? dateModified,
    this.color = Colors.white,
    this.isPinned = false,
  }) : 
    id = id ?? const Uuid().v4(),
    dateCreated = dateCreated ?? DateTime.now(),
    dateModified = dateModified ?? DateTime.now();
  
  NoteModel copyWith({
    String? title,
    String? content,
    DateTime? dateModified,
    Color? color,
    bool? isPinned,
  }) {
    return NoteModel(
      id: this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateCreated: this.dateCreated,
      dateModified: dateModified ?? DateTime.now(),
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'dateModified': dateModified.millisecondsSinceEpoch,
      'color': color.value,
      'isPinned': isPinned ? 1 : 0,
    };
  }
  
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(json['dateCreated']),
      dateModified: DateTime.fromMillisecondsSinceEpoch(json['dateModified']),
      color: Color(json['color']),
      isPinned: json['isPinned'] == 1,
    );
  }
}