import 'package:flutter/material.dart';

enum GunStatus { available, charging, unavailable }

class ChargingGun {
  final String id;
  GunStatus status;
  QueueUser? currentUser;
  DateTime? estimatedEndTime;

  ChargingGun({
    required this.id,
    this.status = GunStatus.available,
    this.currentUser,
    this.estimatedEndTime,
  });
}

class QueueUser {
  final String id;
  final String name;

  QueueUser({required this.id, required this.name});
} 