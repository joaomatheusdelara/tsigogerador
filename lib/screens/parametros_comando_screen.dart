import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parametros_comando_params.dart';
import '../models/parametro_comando_model.dart';
import '../providers/parametro_comando_provider.dart';
import '../services/enviar_comando_service.dart';

class ParametrosComandoScreen extends ConsumerStatefulWidget {
  final String idVeiculo;
  final String idComando;
  final String modeloEquipamentoNome;
  final String comandoNome;

  const ParametrosComandoScreen({
    super.key,
    required this.idVeiculo,
    required this.idComando,
    required this.modeloEquipamentoNome,
    required this.comandoNome,
  });

  @override
  ConsumerState<ParametrosComandoScreen> createState() =>
      _ParametrosComandoScreenState();
}

class _ParametrosComandoScreenState
    extends ConsumerState<ParametrosComandoScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _controllersInitialized = false;
  late final ParametrosComandoParams _providerParams;

  @override
  void initState() {
    super.initState();
    _providerParams = ParametrosComandoParams(
      idVeiculo: widget.idVeiculo,
      idComando: widget.idComando,
      modeloEquipamento: widget.modeloEquipamentoNome,
    );
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _mostrarAlerta({
    required String titulo,
    required String mensagem,
    required bool sucesso,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        content: Column(
          children: [
            Icon(
              sucesso
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.xmark_circle_fill,
              size: 60,
              color: sucesso ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(mensagem, style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "OK, continuar",
              style: TextStyle(
                color: Color(0xFF114474),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _mostrarConfirmacao() async {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            content: Column(
              children: const [
                Icon(CupertinoIcons.question_circle_fill,
                    size: 60, color: Colors.orange),
                SizedBox(height: 12),
                Text(
                  "Confirmar envio",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text("Tem certeza que deseja enviar este comando?"),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Enviar",
                  style: TextStyle(
                    color: Color(0xFF114474),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // imports e demais blocos iguais...

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF121212)
        : CupertinoColors.systemGroupedBackground;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : CupertinoColors.white;
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;

    final parametrosAsync =
        ref.watch(parametrosComandoProvider(_providerParams));

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: Column(
        children: [
          // BARRA AZUL CUSTOM COMO NA OUTRA TELA
          Container(
            color: const Color(0xFF114474),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      widget.comandoNome,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(10),
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(
                        CupertinoIcons.back,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: parametrosAsync.when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (err, _) => Center(child: Text("Erro: $err")),
              data: (parametros) {
                if (!_controllersInitialized && parametros.isNotEmpty) {
                  _controllers.clear();
                  for (var p in parametros) {
                    _controllers[p.identificador] =
                        TextEditingController(text: p.valorPadrao ?? "");
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _controllersInitialized = true);
                    }
                  });
                  return const Center(child: CupertinoActivityIndicator());
                }

                if (parametros.isEmpty || !_controllersInitialized) {
                  return const Center(
                      child: Text("Nenhum parâmetro disponível."));
                }

                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      ...parametros.map((p) {
                        final controller = _controllers[p.identificador];
                        if (controller == null) return const SizedBox.shrink();

                        final isBoolean = p.valores == "0;1" ||
                            p.nome.toLowerCase().contains("saida") ||
                            p.inputType == InputType.booleanSwitch;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (!isDark)
                                const BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.rotulo,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              isBoolean
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: CupertinoSwitch(
                                        value: controller.text == "1",
                                        activeTrackColor: Colors.orange,
                                        onChanged: (bool value) {
                                          setState(() {
                                            controller.text = value ? "1" : "0";
                                          });
                                        },
                                      ),
                                    )
                                  : CupertinoTextField(
                                      controller: controller,
                                      placeholder: p.rotulo,
                                      style: TextStyle(color: textColor),
                                      placeholderStyle: const TextStyle(
                                          color: CupertinoColors.systemGrey),
                                    ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
                      CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        onPressed: () async {
                          final confirm = await _mostrarConfirmacao();
                          if (!confirm) return;

                          final parametrosEnvio = <String, String>{};
                          for (var entry in _controllers.entries) {
                            final val = entry.value.text.trim();
                            if (val.isNotEmpty) {
                              parametrosEnvio[entry.key] = val;
                            }
                          }

                          final idModelo = parametros.first.idModeloEquipamento;
                          final result =
                              await EnviarComandoService.enviarComandoStatic(
                            idVeiculo: widget.idVeiculo,
                            idComando: widget.idComando,
                            idModeloEquipamento: idModelo,
                            parametros: parametrosEnvio,
                          );

                          _mostrarAlerta(
                            titulo: result['codigo'] == 0
                                ? "Comando enviado"
                                : "Erro",
                            mensagem: result['mensagem'] ?? "",
                            sucesso: result['codigo'] == 0,
                          );
                        },
                        child: const Text(
                          "Enviar comando",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
