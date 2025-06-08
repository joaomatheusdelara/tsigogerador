import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/network_service.dart';

final networkServiceProvider = Provider((ref) => NetworkService());

final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return networkService.onConnectivityChanged;
});
