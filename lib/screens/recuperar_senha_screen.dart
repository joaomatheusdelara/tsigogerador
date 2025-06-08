import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? erroEmail;
  bool carregando = false;

  Future<void> _enviarEmail() async {
    final email = _emailController.text.trim();

    setState(() {
      erroEmail = email.isEmpty ? "Preencha o e-mail" : null;
    });

    if (erroEmail != null) return;

    setState(() => carregando = true);

    final resposta = await AuthService().recuperarSenha(email);

    setState(() => carregando = false);

    _mostrarDialogo(
      sucesso: resposta["codigo"] == 0,
      mensagem: resposta["mensagem"],
    );
  }

  void _mostrarDialogo({required bool sucesso, required String mensagem}) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Column(
          children: [
            Icon(
              sucesso
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.clear_circled_solid,
              size: 48,
              color: sucesso
                  ? CupertinoColors.activeGreen
                  : CupertinoColors.systemRed,
            ),
            const SizedBox(height: 10),
            Text(
              sucesso ? "Sucesso" : "Erro",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Fecha o alerta
                if (sucesso) Navigator.of(context).pop(); // Volta p/ login
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF114474),
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
    final fieldColor =
        isDarkMode ? const Color(0xFF1E1E1E) : CupertinoColors.white;
    final borderColor =
        isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey3;
    final placeholderColor = isDarkMode
        ? CupertinoColors.systemGrey2
        : CupertinoColors.placeholderText;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Recuperar Senha'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Digite seu e-mail para recuperar sua senha.',
                style: TextStyle(fontSize: 16, color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: "E-mail",
                    placeholderStyle: TextStyle(color: placeholderColor),
                    style: TextStyle(color: textColor),
                    keyboardType: TextInputType.emailAddress,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child:
                          Icon(CupertinoIcons.mail, color: Color(0xFF114474)),
                    ),
                  ),
                  if (erroEmail != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        erroEmail!,
                        style: const TextStyle(
                            color: CupertinoColors.systemRed, fontSize: 13),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: carregando ? null : _enviarEmail,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: carregando
                      ? const CupertinoActivityIndicator()
                      : const Text("Enviar", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
