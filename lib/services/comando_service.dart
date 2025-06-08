// lib/services/comando_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comando_model.dart';
import 'api_constants.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ComandoService {
  final String token;
  ComandoService(this.token);

  Future<List<Comando>> listarComandos(String idVeiculo) async {
    logger.i("TOKEN ENVIADO: $token");
    logger.i("ID_VEICULO ENVIADO: $idVeiculo");

    final response = await http.post(
      Uri.parse(ApiConstants.listarComandos),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "token": token,
        "id_veiculo": idVeiculo,
      }),
    );

    logger.i("RESPONSE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar comandos');
    }
final data = jsonDecode(response.body);

// 💡 Adicione este bloco ANTES de retornar!
if (data['mensagem']?.toLowerCase()?.contains("token") == true &&
    (data['mensagem']?.toLowerCase()?.contains("inválido") == true ||
     data['mensagem']?.toLowerCase()?.contains("expirado") == true)) {
  throw Exception("Token inválido ou expirado");
}

if (data['codigo'] != 0) {
  throw Exception(data['mensagem']);
}

    return (data['comandos'] as List)
        .map((json) => Comando.fromJson(json))
        .toList();
  }
}
