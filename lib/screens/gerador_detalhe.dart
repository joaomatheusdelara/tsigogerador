import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/gerador_model.dart';
import '../providers/gerador_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'comandos_screen.dart';



final logger = Logger();

class GeradorDetalheScreen extends ConsumerStatefulWidget {
  final Gerador gerador;

  const GeradorDetalheScreen({super.key, required this.gerador});

  @override
  ConsumerState<GeradorDetalheScreen> createState() =>
      _GeradorDetalheScreenState();
}

class _GeradorDetalheScreenState extends ConsumerState<GeradorDetalheScreen> {
  @override
  void initState() {
    super.initState();
    // ignore: unused_result
    ref.refresh(geradorDetalheProvider(widget.gerador.id));
  }

  Color getTensaoColor(double tensao) {
    if (tensao >= 10) return CupertinoColors.activeGreen;
    if (tensao >= 8) return CupertinoColors.systemYellow;
    return CupertinoColors.destructiveRed;
  }

  @override
  Widget build(BuildContext context) {
    final geradorAsync = ref.watch(geradorDetalheProvider(widget.gerador.id));
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

    Future<void> onRefresh() async {
      ref.invalidate(geradorDetalheProvider(widget.gerador.id));
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
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
                      widget.gerador.rotulo,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Positioned(
  right: 0,
  child: Row(
    children: [
      CupertinoButton(
        padding: const EdgeInsets.all(10),
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => ComandosScreen(
                idVeiculo: widget.gerador.idVeiculo,
                rotulo: widget.gerador.rotulo,
                modeloEquipamentoNome: widget.gerador.nomeModelo,
              ),
            ),
          );
        },
        child: const Icon(
          CupertinoIcons.settings,
          color: CupertinoColors.white,
          size: 22,
        ),
      ),
    ],
  ),
),

                ],
              ),
            ),
          ),
          Expanded(
            child: geradorAsync.when(
              data: (geradorAtualizado) {
                logger.i("Dados atualizados: ${geradorAtualizado.rotulo}");

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(onRefresh: onRefresh),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        delegate: SliverChildListDelegate([
                          _infoBox(
                            "Ignição",
                            CupertinoIcons.power,
                            geradorAtualizado.ignicao
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.destructiveRed,
                          ),
                          _infoBox(
                            "Bateria",
                            CupertinoIcons.battery_100,
                            getTensaoColor(geradorAtualizado.tensao),
                            "${geradorAtualizado.tensao.toStringAsFixed(1)} V",
                          ),
                          _svgBox(
                            "Status do Gerador",
                            'assets/icon/stts_gerador.svg',
                            geradorAtualizado.statusGerador,
                            geradorAtualizado.statusGerador
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.destructiveRed,
                          ),
                          _infoBox(
                            "Status da Rede",
                            geradorAtualizado.statusRede
                                ? CupertinoIcons.bolt_fill
                                : CupertinoIcons.bolt_slash_fill,
                            geradorAtualizado.statusRede
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.destructiveRed,
                          ),
                          _infoBox(
                            "Teste com Carga",
                            geradorAtualizado.testeComCarga
                                ? Icons.toggle_on
                                : Icons.toggle_off,
                            geradorAtualizado.testeComCarga
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.destructiveRed,
                          ),
                          _infoBox(
                            "Teste sem Carga",
                            geradorAtualizado.testeSemCarga
                                ? Icons.toggle_on
                                : Icons.toggle_off,
                            geradorAtualizado.testeSemCarga
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.destructiveRed,
                          ),
                          _infoBox(
                            "Horímetro",
                            CupertinoIcons.gauge,
                            CupertinoColors.systemGrey,
                            "${geradorAtualizado.horimetro} h",
                          ),
                          _infoBox(
                            "Última Atualização",
                            CupertinoIcons.calendar,
                            CupertinoColors.systemGrey,
                            geradorAtualizado.dataHora,
                          ),
                        ]),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (err, stack) =>
                  Center(child: Text("Erro ao carregar: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String title, IconData icon, Color iconColor,
      [String? value]) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? const Color(0xFF1E1E1E) : CupertinoColors.white;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _svgBox(String title, String assetPath, bool ativo, Color cor,
      [String? value]) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? const Color(0xFF1E1E1E) : CupertinoColors.white;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              width: 36,
              height: 36,
              colorFilter: ColorFilter.mode(cor, BlendMode.srcIn),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
