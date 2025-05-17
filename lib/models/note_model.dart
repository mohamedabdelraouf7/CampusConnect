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
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateCreated: dateCreated,
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
    // Handle isPinned as int or String
    dynamic isPinnedValue = json['isPinned'];
    bool isPinnedBool;
    if (isPinnedValue is int) {
      isPinnedBool = isPinnedValue == 1;
    } else if (isPinnedValue is String) {
      isPinnedBool = isPinnedValue == '1' || isPinnedValue.toLowerCase() == 'true';
    } else {
      isPinnedBool = false;
    }

    // Handle color as int or String
    dynamic colorValue = json['color'];
    int colorInt;
    if (colorValue is int) {
      colorInt = colorValue;
    } else if (colorValue is String) {
      colorInt = int.tryParse(colorValue) ?? Colors.white.value;
    } else {
      colorInt = Colors.white.value;
    }

    // Handle dateCreated as int (milliseconds) or String (ISO format)
    DateTime dateCreated;
    dynamic dateCreatedValue = json['dateCreated'];
    if (dateCreatedValue is int) {
      dateCreated = DateTime.fromMillisecondsSinceEpoch(dateCreatedValue);
    } else if (dateCreatedValue is String) {
      try {
        dateCreated = DateTime.parse(dateCreatedValue);
      } catch (e) {
        dateCreated = DateTime.now();
      }
    } else {
      dateCreated = DateTime.now();
    }

    // Handle dateModified as int (milliseconds) or String (ISO format)
    DateTime dateModified;
    dynamic dateModifiedValue = json['dateModified'];
    if (dateModifiedValue is int) {
      dateModified = DateTime.fromMillisecondsSinceEpoch(dateModifiedValue);
    } else if (dateModifiedValue is String) {
      try {
        dateModified = DateTime.parse(dateModifiedValue);
      } catch (e) {
        dateModified = DateTime.now();
      }
    } else {
      dateModified = DateTime.now();
    }

    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      dateCreated: dateCreated,
      dateModified: dateModified,
      color: Color(colorInt),
      isPinned: isPinnedBool,
    );
  }
}