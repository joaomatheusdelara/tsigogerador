import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/push_service.dart';
import 'dashboard.dart';
import '../theme/app_theme.dart';
import 'recuperar_senha_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode senhaFocusNode = FocusNode();

  bool isLoading = false;
  bool lembrarSenha = false;
  bool senhaVisivel = false;

  String? erroEmail;
  String? erroSenha;

  @override
  void initState() {
    super.initState();
    carregarCredenciais();
  }

  Future<void> carregarCredenciais() async {
    final prefs = await SharedPreferences.getInstance();
    lembrarSenha = prefs.getBool("lembrar_me") ?? false;
    if (lembrarSenha) {
      emailController.text = prefs.getString("email_lembrado") ?? "";
      senhaController.text = prefs.getString("senha_lembrada") ?? "";
    }
    setState(() {});
  }

  Future<void> loginUser() async {
    setState(() {
      erroEmail = emailController.text.isEmpty ? "Preencha o e-mail" : null;
      erroSenha = senhaController.text.isEmpty ? "Preencha a senha" : null;
    });

    if (erroEmail != null || erroSenha != null) return;

    setState(() => isLoading = true);

    try {
      final auth = AuthService();
      await auth.login(
        emailController.text.trim(),
        senhaController.text.trim(),
        lembrarSenha,
      );

      final prefs = await SharedPreferences.getInstance();
      if (lembrarSenha) {
        await prefs.setString("email_lembrado", emailController.text.trim());
        await prefs.setString("senha_lembrada", senhaController.text.trim());
      } else {
        await prefs.remove("email_lembrado");
        await prefs.remove("senha_lembrada");
      }

      await Future.delayed(const Duration(milliseconds: 400));

      final token = prefs.getString("token");
      if (token != null && token.isNotEmpty && mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const DashboardScreen()),
        );
        _registrarTokenPush().catchError((error) {
          logger.e("Erro ao registrar token push após login: $error");
        });
      } else {
        setState(() => isLoading = false);
        _mostrarMensagem("Erro ao salvar login. Tente novamente.");
        return;
      }
      _registrarTokenPush().catchError((error) {
        logger.e("Erro ao registrar token push após login: $error");
      });
    } on Exception catch (e) {
      _mostrarMensagem(e.toString().replaceFirst("Exception: ", ""));
      setState(() => isLoading = false);
    } catch (e) {
      logger.e("Erro inesperado no login: $e");
      _mostrarMensagem("Ocorreu um erro inesperado. Tente novamente.");
      setState(() => isLoading = false);
    }
  }

  Future<void> _registrarTokenPush() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        logger.w("Permissão de push negada pelo usuário.");
        return;
      }

      final tokenPush = await FirebaseMessaging.instance.getToken();

      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      logger.i("📱 APNs Token (iOS): $apnsToken");

      if (tokenPush != null) {
        final push = PushService();
        await push.enviarTokenPush(tokenPush);
        logger.i("✅ Token push enviado com sucesso: $tokenPush");
      } else {
        throw Exception("Token de push do Firebase não encontrado.");
      }
    } catch (e) {
      throw Exception("Falha ao registrar/enviar token push: $e");
    }
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Column(
          children: const [
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 48,
              color: Color(0xFFFF7500),
            ),
            SizedBox(height: 10),
            Text(
              "Atenção",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Color(0xFF114474),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "OK, continuar",
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? const Color(0xFF1C1C1E)
        : CupertinoColors.systemGroupedBackground;
    final fieldColor = isDarkMode
        ? const Color(0xFF1E1E1E)
        : CupertinoColors.white;
    final borderColor = isDarkMode
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemGrey3;
    final textColor = isDarkMode
        ? CupertinoColors.white
        : CupertinoColors.black;
    final placeholderColor = isDarkMode
        ? CupertinoColors.systemGrey2
        : CupertinoColors.placeholderText;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo_ativos.png', height: 130, width: 280),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CupertinoTextField(
                            controller: emailController,
                            focusNode: emailFocusNode,
                            placeholder: "E-mail",
                            keyboardType: TextInputType.emailAddress,
                            placeholderStyle: TextStyle(
                              color: placeholderColor,
                            ),
                            onSubmitted: (_) => senhaFocusNode.requestFocus(),
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Icon(
                                CupertinoIcons.mail,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            style: TextStyle(color: textColor),
                            decoration: BoxDecoration(
                              color: fieldColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor),
                            ),
                          ),
                          if (erroEmail != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                erroEmail!,
                                style: TextStyle(
                                  color: CupertinoColors.systemRed,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CupertinoTextField(
                            controller: senhaController,
                            focusNode: senhaFocusNode,
                            placeholder: "Senha",
                            obscureText: !senhaVisivel,
                            placeholderStyle: TextStyle(
                              color: placeholderColor,
                            ),
                            onSubmitted: (_) => loginUser(),
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Icon(
                                CupertinoIcons.lock,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            suffix: GestureDetector(
                              onTap: () =>
                                  setState(() => senhaVisivel = !senhaVisivel),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  senhaVisivel
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            style: TextStyle(color: textColor),
                            decoration: BoxDecoration(
                              color: fieldColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor),
                            ),
                          ),
                          if (erroSenha != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                erroSenha!,
                                style: TextStyle(
                                  color: CupertinoColors.systemRed,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                setState(() => lembrarSenha = !lembrarSenha),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: CupertinoColors.systemGrey,
                                      width: 2,
                                    ),
                                    color: lembrarSenha
                                        ? const Color(0xFFFF7500)
                                        : CupertinoColors.transparent,
                                  ),
                                  child: lembrarSenha
                                      ? Center(
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: CupertinoColors.white,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Lembrar-me',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => const RecuperarSenhaScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Esqueceu a senha?",
                              style: TextStyle(
                                fontSize: 15,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: isLoading ? null : loginUser,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: isLoading
                              ? const CupertinoActivityIndicator(
                                  color: CupertinoColors.black,
                                )
                              : const Text(
                                  "Entrar",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
