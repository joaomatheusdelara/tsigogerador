import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gerador_model.dart';
import 'api_constants.dart';

class PosicaoService {
  Future<List<Gerador>> getUltimasPosicoes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) throw Exception("Token não encontrado.");

    final response = await http.post(
      Uri.parse(ApiConstants.ultimasPosicoes),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "token": token,
        "busca": "",
        "pagina": "",
        "filtro": "",
        "data_hora_inicio": "",
        "data_hora_fim": "",
        "numero_registros": "10000",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro HTTP ${response.statusCode}");
    }

    final data = jsonDecode(response.body);

    if (data["mensagem"]?.toLowerCase()?.contains("token") == true &&
        (data["mensagem"]?.toLowerCase()?.contains("inválido") == true ||
            data["mensagem"]?.toLowerCase()?.contains("expirado") == true)) {
      throw Exception("Token inválido ou expirado");
    }

    if (data["codigo"] != 0) throw Exception(data["mensagem"]);

    return (data["data"][0] as List)
        .map((item) => Gerador.fromJson(item))
        .toList();
  }
}
