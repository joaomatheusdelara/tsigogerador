import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import 'api_constants.dart';

class EventoService {
  Future<List<Evento>> listarEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) throw Exception("Token não encontrado.");

    final response = await http.post(
      Uri.parse(ApiConstants.listarEventos),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "token": token,
        "numero_registros": "100",
        "busca": "",
        "pagina": "",
        "filtro": "",
        "data_hora_inicio": "",
        "data_hora_fim": "",
      }),
    );
    final data = jsonDecode(response.body);

    if (data["mensagem"]?.toLowerCase()?.contains("token") == true &&
        (data["mensagem"]?.toLowerCase()?.contains("inválido") == true ||
            data["mensagem"]?.toLowerCase()?.contains("expirado") == true)) {
      throw Exception("Token inválido ou expirado");
    }

    if (data["codigo"] != 0) throw Exception(data["mensagem"]);

    return (data["data"][0] as List).map((e) => Evento.fromJson(e)).toList();
  }
}
