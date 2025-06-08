import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parametro_comando_model.dart';
import 'api_constants.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ParametroComandoService {
  final String token;

  ParametroComandoService(this.token);

  Future<List<ParametroComando>> listarParametros({
    required String idVeiculo,
    required String idComando,
    required String modeloEquipamento,
  }) async {
    logger.i("====== DEBUG PARAMETROS COMANDO ======");
    logger.i("idVeiculo: $idVeiculo");
    logger.i("idComando: $idComando");
    logger.i("modeloEquipamento: $modeloEquipamento");

    final response = await http.post(
      Uri.parse(ApiConstants.parametrosComando),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "token": token,
        "id_veiculo": idVeiculo,
        "id_comando": idComando,
        "modelo_rastreador":
            modeloEquipamento, 
      }),
    );

    logger.i("Status: $response.statusCode");
    logger.i("Response body: $response.body");

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar parâmetros do comando');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    logger.i("JSON Decoded: $data");

    if (data['mensagem']?.toLowerCase()?.contains("token") == true &&
        (data['mensagem']?.toLowerCase()?.contains("inválido") == true ||
            data['mensagem']?.toLowerCase()?.contains("expirado") == true)) {
      throw Exception("Token inválido ou expirado");
    }

    final lista =
        (data['dados'][modeloEquipamento] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    logger.i("Lista encontrada: $lista");

    return lista.map((e) => ParametroComando.fromJson(e)).toList();
  }
}
