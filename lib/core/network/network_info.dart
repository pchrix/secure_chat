/// 🌐 Utilitaires de gestion réseau
///
/// Fournit des fonctionnalités pour vérifier la connectivité réseau
/// et gérer les états de connexion.

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Interface pour les informations réseau
abstract class NetworkInfo {
  /// Vérifie si l'appareil est connecté à internet
  Future<bool> get isConnected;

  /// Stream des changements de connectivité
  Stream<List<ConnectivityResult>> get connectivityStream;

  /// Vérifie la connectivité avec un ping vers un serveur
  Future<bool> hasInternetAccess();

  /// Obtient le type de connexion actuel
  Future<List<ConnectivityResult>> get connectionType;

  /// Vérifie si la connexion est sur WiFi
  Future<bool> get isWiFiConnected;

  /// Vérifie si la connexion est sur données mobiles
  Future<bool> get isMobileConnected;
}

/// Implémentation concrète de NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  @override
  Stream<List<ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  @override
  Future<bool> hasInternetAccess() async {
    try {
      // Vérifier d'abord la connectivité de base
      if (!await isConnected) {
        return false;
      }

      // Tenter un ping vers des serveurs fiables
      final results = await Future.wait([
        _pingHost('8.8.8.8'), // Google DNS
        _pingHost('1.1.1.1'), // Cloudflare DNS
        _pingHost('208.67.222.222'), // OpenDNS
      ]);

      // Si au moins un ping réussit, on a accès à internet
      return results.any((result) => result);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ConnectivityResult>> get connectionType async {
    return await _connectivity.checkConnectivity();
  }

  @override
  Future<bool> get isWiFiConnected async {
    final results = await connectionType;
    return results.contains(ConnectivityResult.wifi);
  }

  @override
  Future<bool> get isMobileConnected async {
    final results = await connectionType;
    return results.contains(ConnectivityResult.mobile);
  }

  /// Ping un host spécifique pour vérifier la connectivité internet
  Future<bool> _pingHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Gestionnaire de connectivité réseau avec cache et retry
class NetworkManager {
  final NetworkInfo _networkInfo;
  final Duration _cacheTimeout;

  bool? _lastKnownStatus;
  DateTime? _lastCheck;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  NetworkManager({
    NetworkInfo? networkInfo,
    Duration cacheTimeout = const Duration(seconds: 30),
  })  : _networkInfo = networkInfo ?? NetworkInfoImpl(),
        _cacheTimeout = cacheTimeout {
    _initializeConnectivityListener();
  }

  /// Stream des changements de statut de connexion
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Obtient le statut de connexion (avec cache)
  Future<bool> get isConnected async {
    final now = DateTime.now();

    // Utiliser le cache si disponible et récent
    if (_lastKnownStatus != null &&
        _lastCheck != null &&
        now.difference(_lastCheck!) < _cacheTimeout) {
      return _lastKnownStatus!;
    }

    // Vérifier la connectivité
    final isConnected = await _networkInfo.hasInternetAccess();

    // Mettre à jour le cache
    _lastKnownStatus = isConnected;
    _lastCheck = now;

    return isConnected;
  }

  /// Force une vérification de la connectivité (ignore le cache)
  Future<bool> forceCheck() async {
    _lastKnownStatus = null;
    _lastCheck = null;
    return await isConnected;
  }

  /// Obtient des informations détaillées sur la connexion
  Future<ConnectionInfo> getConnectionInfo() async {
    final isConnected = await this.isConnected;
    final connectionTypes = await _networkInfo.connectionType;
    final isWiFi = await _networkInfo.isWiFiConnected;
    final isMobile = await _networkInfo.isMobileConnected;

    return ConnectionInfo(
      isConnected: isConnected,
      connectionTypes: connectionTypes,
      isWiFi: isWiFi,
      isMobile: isMobile,
      timestamp: DateTime.now(),
    );
  }

  /// Attend qu'une connexion soit disponible
  Future<void> waitForConnection({
    Duration timeout = const Duration(minutes: 2),
    Duration checkInterval = const Duration(seconds: 5),
  }) async {
    final completer = Completer<void>();
    Timer? timeoutTimer;
    Timer? checkTimer;

    // Timer de timeout
    timeoutTimer = Timer(timeout, () {
      checkTimer?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('Timeout waiting for connection', timeout),
        );
      }
    });

    // Vérification périodique
    checkTimer = Timer.periodic(checkInterval, (timer) async {
      if (await forceCheck()) {
        timer.cancel();
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    // Vérification immédiate
    if (await forceCheck()) {
      checkTimer.cancel();
      timeoutTimer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    return completer.future;
  }

  /// Initialise l'écoute des changements de connectivité
  void _initializeConnectivityListener() {
    _connectivitySubscription = _networkInfo.connectivityStream.listen(
      (List<ConnectivityResult> results) async {
        // Attendre un peu pour que la connexion se stabilise
        await Future.delayed(const Duration(seconds: 2));

        final isConnected = await forceCheck();
        _connectionStatusController.add(isConnected);
      },
    );
  }

  /// Nettoie les ressources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}

/// Informations détaillées sur la connexion
class ConnectionInfo {
  final bool isConnected;
  final List<ConnectivityResult> connectionTypes;
  final bool isWiFi;
  final bool isMobile;
  final DateTime timestamp;

  const ConnectionInfo({
    required this.isConnected,
    required this.connectionTypes,
    required this.isWiFi,
    required this.isMobile,
    required this.timestamp,
  });

  /// Obtient le type de connexion principal
  ConnectivityResult get primaryConnectionType {
    if (connectionTypes.isEmpty) return ConnectivityResult.none;
    return connectionTypes.first;
  }

  /// Obtient une description lisible du type de connexion
  String get connectionDescription {
    if (!isConnected) return 'Aucune connexion';

    switch (primaryConnectionType) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Données mobiles';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Autre';
      case ConnectivityResult.none:
        return 'Aucune connexion';
    }
  }

  /// Vérifie si la connexion est considérée comme rapide
  bool get isFastConnection {
    return isWiFi || connectionTypes.contains(ConnectivityResult.ethernet);
  }

  /// Vérifie si la connexion est considérée comme lente
  bool get isSlowConnection {
    return isMobile || connectionTypes.contains(ConnectivityResult.bluetooth);
  }

  @override
  String toString() {
    return 'ConnectionInfo('
        'isConnected: $isConnected, '
        'type: $connectionDescription, '
        'timestamp: $timestamp'
        ')';
  }
}
