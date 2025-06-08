import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import '../utils/logger.dart';

class AuthService {
  Future<Map<String, dynamic>> login(
      String email, String senha, bool lembrarMe) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': email, 'senha': senha}),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro HTTP ${response.statusCode}");
    }

    final data = jsonDecode(response.body);
    if (data["codigo"] != 0) {
      throw Exception(data["mensagem"]);
    }

    final prefs = await SharedPreferences.getInstance();

    if (lembrarMe) {
      await prefs.setString("token", data["token"]);
      await prefs.setString("nome", data["data"]["nome"] ?? "");
      await prefs.setString("nome_tipo", data["data"]["nome_tipo"] ?? "");
      await prefs.setBool("lembrar_me", true);
    } else {
      await prefs.remove("token");
      await prefs.remove("nome");
      await prefs.remove("nome_tipo");
      await prefs.setBool("lembrar_me", false);
    }

    logger.i("🔐 TOKEN GERADO: ${data["token"]}");
    return data;
  }

  Future<bool> validarToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.validarToken),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      return data["status"] == "verdadeiro";
    } catch (_) {
      return false;
    }
  }

  Future<void> limparSeNaoLembrar() async {
    final prefs = await SharedPreferences.getInstance();
    final lembrar = prefs.getBool("lembrar_me") ?? false;

    if (!lembrar) {
      await prefs.remove("token");
      await prefs.remove("nome");
      await prefs.remove("nome_tipo");
    }
  }

  Future<Map<String, dynamic>> recuperarSenha(String email) async {
    final response = await http.post(
      Uri.parse(ApiConstants.recuperarSenha),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body);
    return {
      "mensagem": data["mensagem"] ?? "Erro ao recuperar senha",
      "codigo": data["codigo"] ?? -1,
    };
  }
}