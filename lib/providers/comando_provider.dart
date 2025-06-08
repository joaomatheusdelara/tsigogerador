import '../models/comando_model.dart';
import '../services/comando_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsigo_gerador/providers/shared_prefs_provider.dart';

final comandoServiceProvider = Provider<ComandoService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final token = prefs.getString("token") ?? "";
  return ComandoService(token);
});

final comandosProvider =
    FutureProvider.family<List<Comando>, String>((ref, idVeiculo) async {
  final service = ref.watch(comandoServiceProvider);
  return service.listarComandos(idVeiculo);
});
