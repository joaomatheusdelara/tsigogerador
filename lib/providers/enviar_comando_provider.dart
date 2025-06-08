import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/enviar_comando_service.dart';

// Enum de status do envio
enum EnviarComandoStatus { idle, loading, success, error }

// Estado do envio
class EnviarComandoState {
  final EnviarComandoStatus status;
  final String? message;

  EnviarComandoState({required this.status, this.message});

  factory EnviarComandoState.idle() => EnviarComandoState(status: EnviarComandoStatus.idle);
  factory EnviarComandoState.loading() => EnviarComandoState(status: EnviarComandoStatus.loading);
  factory EnviarComandoState.success(String msg) => EnviarComandoState(status: EnviarComandoStatus.success, message: msg);
  factory EnviarComandoState.error(String msg) => EnviarComandoState(status: EnviarComandoStatus.error, message: msg);
}

// Notifier
class EnviarComandoNotifier extends StateNotifier<EnviarComandoState> {
  EnviarComandoNotifier() : super(EnviarComandoState.idle());

  Future<void> enviar({
    required String idVeiculo,
    required String idComando,
    required String idModeloEquipamento,
    required Map<String, String> parametros,
  }) async {
    state = EnviarComandoState.loading();
    try {
      final result = await EnviarComandoService.enviarComandoStatic(
        idVeiculo: idVeiculo,
        idComando: idComando,
        idModeloEquipamento: idModeloEquipamento,
        parametros: parametros,
      );
      if (result['codigo'] == 0) {
        state = EnviarComandoState.success(result['mensagem'] ?? 'Comando enviado!');
      } else {
        state = EnviarComandoState.error(result['mensagem'] ?? 'Erro ao enviar');
      }
    } catch (e) {
      state = EnviarComandoState.error(e.toString());
    }
  }

  void resetState() => state = EnviarComandoState.idle();
}

// Provider
final enviarComandoProvider = StateNotifierProvider<EnviarComandoNotifier, EnviarComandoState>(
  (ref) => EnviarComandoNotifier(),
);
