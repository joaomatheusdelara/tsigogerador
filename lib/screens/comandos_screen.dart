import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsigo_gerador/screens/parametros_comando_screen.dart';
import '../providers/comando_provider.dart';

class ComandosScreen extends ConsumerWidget {
  final String idVeiculo;
  final String rotulo;
  final String modeloEquipamentoNome;

  const ComandosScreen({
    super.key,
    required this.idVeiculo,
    required this.rotulo,
    required this.modeloEquipamentoNome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comandosAsync = ref.watch(comandosProvider(idVeiculo));
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : CupertinoColors.white;
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          // BARRA AZUL FIXA (como nas outras telas)
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
                      'Comandos - $rotulo',
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

          // LISTAGEM DOS COMANDOS
          Expanded(
            child: comandosAsync.when(
              data: (comandos) {
                if (comandos.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum comando disponível.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: comandos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comando = comandos[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark
                            ? [] // sem sombra no modo escuro
                            : [
                                BoxShadow(
                                  color: CupertinoColors.systemGrey2
                                      .withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 10),
                        borderRadius: BorderRadius.circular(16),
                        color: CupertinoColors.transparent,
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => ParametrosComandoScreen(
                                idVeiculo: idVeiculo,
                                idComando: comando.id,
                                comandoNome: comando.nome,
                                modeloEquipamentoNome: modeloEquipamentoNome,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.arrow_right_circle,
                                color: CupertinoColors.systemBlue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                comando.nome,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (e, _) => Center(
                child: Text('Erro: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
