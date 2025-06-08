import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/gerador_provider.dart';
import '../models/gerador_model.dart';
import 'gerador_detalhe.dart';

class DashboardGeradoresScreen extends ConsumerStatefulWidget {
  const DashboardGeradoresScreen({super.key});

  @override
  ConsumerState<DashboardGeradoresScreen> createState() =>
      _DashboardGeradoresScreenState();
}

class _DashboardGeradoresScreenState
    extends ConsumerState<DashboardGeradoresScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(geradorProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final geradoresAsync = ref.watch(geradorProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF5F5F5);
    final cardColor = isDarkMode
        ? const Color(0xFF1E1E1E)
        : CupertinoColors.systemBackground;
    final rotuloColor = isDarkMode
        ? CupertinoColors.white
        : const Color(0xFF114474);
    final shadowColor = isDarkMode
        ? const Color(0x66000000)
        : const Color(0x33000000);

    Future<void> onRefresh() async {
      ref.invalidate(geradorProvider);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 10,
            ),
            color: const Color(0xFF114474),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    CupertinoIcons.back,
                    color: CupertinoColors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "TSIGO Geradores",
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    CupertinoIcons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    ref.invalidate(geradorProvider);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(onRefresh: onRefresh),
                geradoresAsync.when(
                  data: (geradores) {
                    if (geradores.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: const Center(
                          child: Text("Nenhum gerador encontrado"),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final Gerador gerador = geradores[index];
                        final bateriaStatus = getBateriaStatus(gerador.tensao);

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      GeradorDetalheScreen(gerador: gerador),
                                ),
                              );
                              ref.invalidate(geradorProvider);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.power,
                                        size: 24,
                                        color: gerador.ignicao
                                            ? CupertinoColors.activeGreen
                                            : CupertinoColors.secondaryLabel,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          gerador.rotulo,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: rotuloColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      _infoItem(
                                        CupertinoIcons.calendar,
                                        gerador.dataHora,
                                      ),
                                      _infoItem(
                                        CupertinoIcons.gauge,
                                        "${gerador.horimetro} h",
                                      ),
                                      _infoItem(
                                        bateriaStatus['icon'],
                                        "${gerador.tensao.toStringAsFixed(1)} V",
                                        bateriaStatus['color'],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 8,
                                    children: [
                                      _statusItem(
                                        "Status de Rede",
                                        gerador.statusRede
                                            ? CupertinoIcons.bolt_fill
                                            : CupertinoIcons.bolt_slash_fill,
                                        gerador.statusRede,
                                      ),
                                      _statusItem(
                                        "Teste sem Carga",
                                        gerador.testeSemCarga
                                            ? Icons.toggle_on
                                            : Icons.toggle_off,
                                        gerador.testeSemCarga,
                                      ),
                                      _statusSvgItem(
                                        "Status de Gerador",
                                        'assets/icon/stts_gerador.svg',
                                        gerador.statusGerador,
                                      ),
                                      _statusItem(
                                        "Teste com Carga",
                                        gerador.testeComCarga
                                            ? Icons.toggle_on
                                            : Icons.toggle_off,
                                        gerador.testeComCarga,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }, childCount: geradores.length),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text("Erro ao carregar geradores: $err"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, [Color? iconColor]) {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color:
              iconColor ??
              (isDarkMode
                  ? CupertinoColors.white
                  : CupertinoColors.secondaryLabel),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
      ],
    );
  }

  Widget _statusItem(String title, IconData icon, bool status) {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: status
              ? CupertinoColors.activeGreen
              : CupertinoColors.secondaryLabel,
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
      ],
    );
  }

  Widget _statusSvgItem(String title, String assetPath, bool status) {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          assetPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            status
                ? CupertinoColors.activeGreen
                : (isDarkMode
                      ? CupertinoColors.systemGrey2
                      : CupertinoColors.systemGrey),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> getBateriaStatus(double tensao) {
    if (tensao >= 10) {
      return {
        'icon': CupertinoIcons.battery_100,
        'color': CupertinoColors.activeGreen,
      };
    } else if (tensao >= 8) {
      return {
        'icon': CupertinoIcons.battery_25,
        'color': CupertinoColors.systemYellow,
      };
    } else {
      return {
        'icon': CupertinoIcons.battery_0,
        'color': CupertinoColors.destructiveRed,
      };
    }
  }
}
