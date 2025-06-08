import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class EnviarComandoService {
  static Future<Map<String, dynamic>> enviarComandoStatic({
    required String idVeiculo,
    required String idComando,
    required String idModeloEquipamento,
    required Map<String, String> parametros,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final body = {
      "token": token,
      "id_veiculo": idVeiculo,
      "id_comando": idComando,
      "id_modelo_equipamento": idModeloEquipamento,
      idModeloEquipamento: parametros,
    };

    logger.i("==== ENVIANDO COMANDO ====");
    logger.i(jsonEncode(body));

    final response = await http.post(
      Uri.parse(ApiConstants.enviarComando),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    logger.i("==== RESPOSTA COMANDO ====");
    logger.i(response.body);
    final data = jsonDecode(response.body);

    if (data['mensagem']?.toLowerCase()?.contains("token") == true &&
        (data['mensagem']?.toLowerCase()?.contains("inválido") == true ||
            data['mensagem']?.toLowerCase()?.contains("expirado") == true)) {
      throw Exception("Token inválido ou expirado");
    }

    return data;
  }
}
