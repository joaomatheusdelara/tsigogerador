class ParametroComando {
  final String identificador;
  final String rotulo;
  final String? valorPadrao;
  final String? valores;
  final String nome;
  final String idModeloEquipamento;
  final String modeloRastreador;

  ParametroComando({
    required this.identificador,
    required this.rotulo,
    this.valorPadrao,
    this.valores,
    required this.nome,
    required this.idModeloEquipamento,
    required this.modeloRastreador,
  });

  factory ParametroComando.fromJson(Map<String, dynamic> json) {
    return ParametroComando(
      identificador: json['identificador'] ?? '',
      rotulo: json['rotulo'] ?? '',
      valorPadrao: json['valor_padrao'],
      valores: json['valores'],
      nome: json['nome'] ?? '',
      idModeloEquipamento: json['id_modelo_equipamento'].toString(),
      modeloRastreador: json['modelo_rastreador'] ?? '',
    );
  }

  // Helper para determinar tipo de entrada no form
  InputType get inputType {
    final lowerNome = nome.toLowerCase();
    final hasValores = valores != null && valores!.isNotEmpty;
    final options = hasValores ? valores!.split(";") : [];

    if (lowerNome.contains("bool") ||
        (hasValores && options.length == 2 && options.contains("0") && options.contains("1")) ||
        valorPadrao?.toLowerCase() == "checked" ||
        valorPadrao?.toLowerCase() == "true" ||
        valorPadrao?.toLowerCase() == "false") {
      return InputType.booleanSwitch;
    }

    if (hasValores && options.length >= 2) {
      if (options.length <= 3 && options.every((o) => o.length < 15)) {
        return InputType.segmented;
      }
      return InputType.picker;
    }

    if (lowerNome.contains("int") || lowerNome.contains("dec")) {
      return InputType.number;
    }

    return InputType.text;
  }
}

enum InputType {
  text,
  number,
  booleanSwitch,
  segmented,
  picker
}
