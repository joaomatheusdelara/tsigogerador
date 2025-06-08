class ApiConstants {
  static const baseUrl = 'https://api.getsec.com.br';
  static const login = '$baseUrl/login/entrar/';
  static const validarToken = '$baseUrl/validar_token/';
  static const ultimasPosicoes = '$baseUrl/ultimas/listar/';
  static const historicoPosicao = '$baseUrl/posicao/listar/';
  static const pushToken = '$baseUrl/usuario_push_token/adicionar/';
  static const listarEventos = '$baseUrl/evento/listar/';
  static const recuperarSenha = '$baseUrl/login/recuperar_senha/';
  static const suporte = '$baseUrl/empresas/suporte/';
  static const String listarComandos = '$baseUrl/atuacao/comandos/';
  static const String parametrosComando =
      '$baseUrl/atuacao/parametros_comando/';
  static const String enviarComando = '$baseUrl/atuacao/adicionar_atuacao/';
}
