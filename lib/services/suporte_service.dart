import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/suporte_model.dart';
import '../services/api_constants.dart';

class SuporteService {
  final String token;

  SuporteService(this.token);

  Future<Suporte> buscarSuporte() async {
    final response = await http.post(
      Uri.parse(ApiConstants.suporte),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["mensagem"]?.toLowerCase()?.contains("token") == true &&
          (data["mensagem"]?.toLowerCase()?.contains("inválido") == true ||
              data["mensagem"]?.toLowerCase()?.contains("expirado") == true)) {
        throw Exception("Token inválido ou expirado");
      }

      return Suporte.fromJson(data['data']);
    } else {
      throw Exception('Erro ao carregar suporte');
    }
  }
}
