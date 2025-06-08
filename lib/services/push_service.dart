import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import '../utils/logger.dart';

class PushService {
  Future<void> enviarTokenPush(String tokenPush) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      logger.e("❌ Token do usuário não encontrado.");
      throw Exception("Token não encontrado.");
    }

    logger.i("📤Enviando tokenPush para Servidor: $tokenPush");

    final response = await http.post(
      Uri.parse(ApiConstants.pushToken),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "token": token,
        "token_push": tokenPush,
      }),
    );

    logger.d("🔄 RESPOSTA PUSH: ${response.body}");

    final data = jsonDecode(response.body);

    if ((data["mensagem"]?.toLowerCase()?.contains("token") ?? false) &&
        (data["mensagem"]?.toLowerCase()?.contains("inválido") ?? false ||
         data["mensagem"]?.toLowerCase()?.contains("expirado") ?? false)) {
      logger.e("❌ Token inválido ou expirado.");
      throw Exception("Token inválido ou expirado");
    }

    if (data["codigo"] != 0) {
      logger.e("❌ Erro ao enviar tokenPush: ${data["mensagem"]}");
      throw Exception(data["mensagem"]);
    }

    logger.i("✅ Token push enviado com sucesso!");
  }
}
