import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'queue_models.dart';

class QueueProvider with ChangeNotifier {
  final List<ChargingGun> _guns = [
    ChargingGun(id: 'Gun 1'),
    ChargingGun(id: 'Gun 2'),
  ];

  final List<QueueUser> _waitingQueue = [];
  int _nextUserId = 1;

  List<ChargingGun> get guns => _guns;
  List<QueueUser> get waitingQueue => _waitingQueue;

  QueueProvider() {
    // Simulate some initial state
    _startCharging('Gun 1', QueueUser(id: 'user_a', name: 'Snehi'), const Duration(minutes: 5));
    _addToQueue(QueueUser(id: 'user_b', name: 'Alex'));

    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateStatuses();
    });
  }

  void _startCharging(String gunId, QueueUser user, Duration duration) {
    final gun = _guns.firstWhere((g) => g.id == gunId);
    gun.status = GunStatus.charging;
    gun.currentUser = user;
    gun.estimatedEndTime = DateTime.now().add(duration);
    notifyListeners();
  }

  void joinQueue() {
    final newUser = QueueUser(id: 'user_$_nextUserId', name: 'User $_nextUserId');
    _nextUserId++;
    _addToQueue(newUser);
  }

  void _addToQueue(QueueUser user) {
    _waitingQueue.add(user);
    notifyListeners();
  }

  void _updateStatuses() {
    bool changed = false;
    for (final gun in _guns) {
      if (gun.status == GunStatus.charging &&
          gun.estimatedEndTime != null &&
          DateTime.now().isAfter(gun.estimatedEndTime!)) {
        
        final previouslyChargingUser = gun.currentUser;
        
        gun.status = GunStatus.available;
        gun.currentUser = null;
        gun.estimatedEndTime = null;
        changed = true;

        if (previouslyChargingUser != null) {
          // You can implement a notification system here
          print("Notify ${previouslyChargingUser.name} that charging is complete!");
        }

        _promoteFromQueue(gun.id);
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void _promoteFromQueue(String gunId) {
    if (_waitingQueue.isNotEmpty) {
      final nextUser = _waitingQueue.removeAt(0);
      
      // Notify the user that it's their turn
      print("Notify ${nextUser.name}, it's your turn for ${gunId}!");

      // Simulate a random charging duration between 3 to 10 minutes
      final randomMinutes = Random().nextInt(8) + 3;
      _startCharging(gunId, nextUser, Duration(minutes: randomMinutes));
    }
  }

  Duration getEstimatedWaitTimeFor(String gunId) {
    final gun = _guns.firstWhere((g) => g.id == gunId);
    if (gun.status == GunStatus.available) return Duration.zero;
    if (gun.estimatedEndTime == null) return Duration.zero;

    final remaining = gun.estimatedEndTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Duration getEstimatedQueueWaitTime(int userIndexInQueue) {
    Duration totalWait = Duration.zero;

    // Sum of remaining times for all currently charging guns
    for (final gun in _guns) {
        if(gun.status == GunStatus.charging){
            totalWait += getEstimatedWaitTimeFor(gun.id);
        }
    }
    
    // Average out the wait time across available slots
    final availableGuns = _guns.where((g) => g.status == GunStatus.available).length;
    if(_guns.length > 0) {
        totalWait = Duration(seconds: totalWait.inSeconds ~/ _guns.length);
    }
    
    // Add estimated time for users ahead in the queue (e.g., 15 mins per user)
    // This is a simplification. A real system would be more complex.
    totalWait += Duration(minutes: 15 * (userIndexInQueue));
    
    return totalWait;
  }
} 