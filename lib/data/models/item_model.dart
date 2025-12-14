import 'package:flutter/material.dart';

class ItemModel {
  ItemModel({
    this.id,
    this.path,
    this.subTitle,
    this.title,
    this.description,
    this.isSelected = false,
    this.icon,
    this.color,
    this.subId,
  });
  int? id;
  String? title;
  String? subTitle;
  String? path;
  String? description;
  bool isSelected;
  Widget? icon;
  Color? color;
  String? subId;

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json['id'] ?? 0,
    path: json['path'] ?? '',
    subTitle: json['subTitle'] ?? '',
    title: json['name'] ?? '',
    description: json['description'] ?? '',
    isSelected: json['isSelected'] ?? false,
    icon: json['icon'] ?? Icons.abc,
    subId: json['_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'subTitle': subTitle,
    'title': title,
    'description': description,
    'isSelected': isSelected,
    'icon': icon,
  };
  // CopyWith method
  ItemModel copyWith({
    int? id,
    String? title,
    String? subTitle,
    String? path,
    String? description,
    bool? isSelected,
    Widget? icon,
    Color? color,
    String? subId,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      path: path ?? this.path,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      subId: subId ?? this.subId,
    );
  }
}
