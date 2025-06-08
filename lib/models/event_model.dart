class Evento {
  final String rotulo;
  final String nomeTipo;
  final String dataHora;

  Evento({
    required this.rotulo,
    required this.nomeTipo,
    required this.dataHora,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      rotulo: json['rotulo'] ?? 'Sem nome',
      nomeTipo: json['nome_tipo'] ?? 'Evento',
      dataHora: _formatarData(json['data_hora']),
    );
  }

  static String _formatarData(String? dataUtc) {
    if (dataUtc == null || dataUtc.isEmpty) return "Data inválida";
    try {
      final dateTime = DateTime.parse("${dataUtc}Z").toLocal();
      return "${dateTime.day.toString().padLeft(2, '0')}/"
          "${dateTime.month.toString().padLeft(2, '0')}/"
          "${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}:"
          "${dateTime.second.toString().padLeft(2, '0')}";
    } catch (_) {
      return "Data inválida";
    }
  }
}
