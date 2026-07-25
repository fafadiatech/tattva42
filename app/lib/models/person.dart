import 'package:flutter/material.dart';

class Person {
  final String id;
  final String name;
  final String? role;
  final String? org;
  final Color avatarColor;
  final bool voiceprintEnrolled;

  const Person({
    required this.id,
    required this.name,
    this.role,
    this.org,
    required this.avatarColor,
    required this.voiceprintEnrolled,
  });
}
