import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:loyalty_card_app/models/loyalty_card.dart';
import 'package:loyalty_card_app/services/card_service.dart';

class SyncService extends ChangeNotifier {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final CardService _cardService;
  bool _isOnline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  SyncService(this._cardService);
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  // Initialize the sync service
  void initialize() {
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
      // If we just came online, trigger a sync
      if (_isOnline) {
        sync();
      }
    });
    // Check initial connectivity
    _checkConnectivity();
  }
  // Check current connectivity
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }
  Future<void> sync() async {
    if (_isSyncing) return;
    try {
      _isSyncing = true;
      notifyListeners();
      // Simulate sync delay
      await Future.delayed(const Duration(seconds: 2));
      // Update last sync time
      _lastSyncTime = DateTime.now();
      // Notify listeners of sync completion
      notifyListeners();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  // Remove Firestore syncCards method for now
}
