import 'package:intl/intl.dart';

class Gerador {
  final String id;
  final String idVeiculo;
  final String nomeModelo;
  final String idModeloEquipamento;
  final String dataHora;
  final String horimetro;
  final bool statusRede;
  final bool statusGerador;
  final bool testeSemCarga;
  final bool testeComCarga;
  final bool ignicao;
  final String rotulo;
  final String icone;
  final double tensao;

  Gerador({
    required this.id,
    required this.idVeiculo,
    required this.nomeModelo,
    required this.idModeloEquipamento,
    required this.dataHora,
    required this.horimetro,
    required this.statusRede,
    required this.statusGerador,
    required this.testeSemCarga,
    required this.testeComCarga,
    required this.ignicao,
    required this.rotulo,
    required this.icone,
    required this.tensao,
  });

  ///  Converte a data UTC para horário de Brasília (GMT-3)
  static String converterFusoHorario(String? dataUtc) {
    try {
      if (dataUtc == null || dataUtc.isEmpty) return "Data inválida";

      DateTime parsedDate = DateTime.parse('${dataUtc}Z');
      DateTime brasiliaTime = parsedDate.toLocal();

      return DateFormat("dd/MM/yyyy HH:mm:ss").format(brasiliaTime);
    } catch (e) {
      return "Data inválida";
    }
  }

  /// Converte segundos para horas com 2 casas decimais
  static String converterHorimetro(String? segundos) {
    try {
      int segundosInt = int.tryParse(segundos ?? '0') ?? 0;
      double horas = segundosInt / 3600;
      return horas.toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  factory Gerador.fromJson(Map<String, dynamic> json) {
    int entradas = int.tryParse(json['entradas']?.toString() ?? '0') ?? 0;
    int saidas = int.tryParse(json['saidas']?.toString() ?? '0') ?? 0;
    bool ignicaoStatus = (json['ignicao']?.toString() == "1");

    return Gerador(
      id: json['id'].toString(),
      idVeiculo: json['id_veiculo'].toString(),
      nomeModelo: json['nome_modelo'] ?? '',
      idModeloEquipamento: json['id_equipamento']?.toString() ?? '',
      dataHora: converterFusoHorario(json['data_hora']),
      horimetro: converterHorimetro(json['horimetro']),
      statusRede: (entradas & 32) != 0,
      statusGerador: (entradas & 64) != 0,
      testeSemCarga: (saidas & 128) != 0,
      testeComCarga: (saidas & 64) != 0,
      ignicao: ignicaoStatus,
      rotulo: json['rotulo'] ?? 'Sem Nome',
      icone: json['icone'] ?? '',
      tensao: double.tryParse(json['tensao']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}
