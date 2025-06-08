import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';
import '../services/parametro_comando_service.dart';
import '../models/parametro_comando_model.dart';
import '../models/parametros_comando_params.dart'; // <--- IMPORTANTE

final parametrosComandoProvider =
    FutureProvider.autoDispose.family<List<ParametroComando>, ParametrosComandoParams>((ref, params) async {
  final prefs = ref.watch(sharedPrefsProvider);
  final token = prefs.getString("token") ?? "";
  final service = ParametroComandoService(token);

  return service.listarParametros(
    idVeiculo: params.idVeiculo,
    idComando: params.idComando,
    modeloEquipamento: params.modeloEquipamento,
  );
});
