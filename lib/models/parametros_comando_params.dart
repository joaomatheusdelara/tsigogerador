import 'package:flutter/foundation.dart';

@immutable
class ParametrosComandoParams {
  final String idVeiculo;
  final String idComando;
  final String modeloEquipamento;

  const ParametrosComandoParams({
    required this.idVeiculo,
    required this.idComando,
    required this.modeloEquipamento,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParametrosComandoParams &&
          runtimeType == other.runtimeType &&
          idVeiculo == other.idVeiculo &&
          idComando == other.idComando &&
          modeloEquipamento == other.modeloEquipamento;

  @override
  int get hashCode =>
      idVeiculo.hashCode ^ idComando.hashCode ^ modeloEquipamento.hashCode;
}
