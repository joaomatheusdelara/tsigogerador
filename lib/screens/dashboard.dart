import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tsigo_gerador/providers/network_provider.dart';
import 'package:tsigo_gerador/screens/suporte_screen.dart';
import 'login_screen.dart';
import 'dashboard_geradores.dart';
import '../providers/gerador_provider.dart';
import '../providers/evento_provider.dart';
import 'eventos_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool _isDrawerOpen = false;
  late AnimationController _controller;
  late Animation<Offset> _drawerSlideAnimation;
  String userName = "Carregando...";
  String userProfile = "Perfil";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _drawerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.delayed(Duration.zero, () {
      ref.invalidate(geradorProvider);
      ref.invalidate(eventosProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(geradorProvider);
      ref.invalidate(eventosProvider);
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("nome") ?? "Usuário";
      userProfile = prefs.getString("nome_tipo") ?? "Perfil";
    });
  }

  void toggleDrawer() {
    if (ref.read(connectivityStreamProvider).value == ConnectivityResult.none) {
      // Não faz nada se estiver offline
      return;
    }
    if (_isDrawerOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final geradoresAsync = ref.watch(geradorProvider);
    final eventosAsync = ref.watch(eventosProvider);

    final statusAsync = ref.watch(connectivityStreamProvider);
    final isOffline = statusAsync.maybeWhen(
      data: (status) => status == ConnectivityResult.none,
      orElse: () => false,
    );

    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF5F5F5);
    final drawerBgColor = isDarkMode
        ? const Color(0xFF1E1E1E)
        : CupertinoColors.systemBackground;
    final eventCardBg = isDarkMode
        ? const Color(0xFF23272F)
        : CupertinoColors.systemGrey6;
    final eventTitleColor = isDarkMode
        ? CupertinoColors.white
        : Color(0xFF114474);

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Stack(
        children: [
          if (isOffline)
            Positioned.fill(
              child: Builder(
                builder: (context) {
                  final isDarkMode =
                      MediaQuery.of(context).platformBrightness ==
                      Brightness.dark;
                  final backgroundColor = isDarkMode
                      ? const Color(0xFF181B20).withOpacity(
                          0.98,
                        ) // Fundo dark night
                      : Colors.white.withOpacity(0.98);
                  final cardColor = isDarkMode
                      ? const Color(0xFF23272F)
                      : Colors.white;
                  final textColor = isDarkMode
                      ? Colors.white
                      : const Color(0xFF222B45);
                  final subTextColor = isDarkMode
                      ? CupertinoColors.systemGrey
                      : const Color(0xFF606060);

                  return Container(
                    color: backgroundColor,
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.83,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 26,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0x1Aff9800),
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(16),
                            child: Icon(
                              CupertinoIcons.wifi_exclamationmark,
                              color: Color(0xFFFF9800),
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            "Sem conexão com a internet",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Por favor, verifique sua conexão\ne tente novamente.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subTextColor, fontSize: 16),
                          ),
                          const SizedBox(height: 28),
                          CupertinoButton.filled(
                            borderRadius: BorderRadius.circular(18),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.refresh,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  "Tentar novamente",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                            onPressed: () {
                              // Tenta recarregar providers (se a internet voltou, já fecha)
                              ref.invalidate(geradorProvider);
                              ref.invalidate(eventosProvider);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra azul top
              Container(
                width: double.infinity,
                color: const Color(0xFF114474),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 6,
                  bottom: 12,
                  left: 0,
                  right: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.all(10),
                      onPressed: toggleDrawer,
                      child: const Icon(
                        CupertinoIcons.bars,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const Text(
                      "TSIGO Geradores",
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        CupertinoIcons.refresh,
                        color: CupertinoColors.white,
                      ),
                      onPressed: () {
                        ref.invalidate(geradorProvider);
                        ref.invalidate(eventosProvider);
                      },
                    ),
                  ],
                ),
              ),
              // Olá, João!
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Text(
                  'Olá, $userName!',
                  style: TextStyle(
                    color: isDarkMode
                        ? CupertinoColors.white
                        : Color(0xFF114474),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Cards e eventos
              Expanded(
                child: SafeArea(
                  top: false,
                  child: geradoresAsync.when(
                    data: (geradores) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: ListView(
                          children: [
                            // Grid de cards
                            GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.07,
                              children: [
                                _buildStatusCard(
                                  "Ativos",
                                  "Total de Ativos",
                                  geradores.length,
                                  Colors.blue,
                                  CupertinoIcons.globe,
                                ),
                                _buildStatusCard(
                                  "Eventos",
                                  "Eventos ativos",
                                  eventosAsync.asData?.value.length ?? 0,
                                  Colors.orange,
                                  CupertinoIcons.bell_fill,
                                ),
                                _buildStatusCard(
                                  "Desligado",
                                  "Ativos desligados",
                                  geradores.where((g) => !g.ignicao).length,
                                  Colors.red,
                                  CupertinoIcons.clock,
                                ),
                                _buildStatusCard(
                                  "Ligado",
                                  "Ativos ligados",
                                  geradores.where((g) => g.ignicao).length,
                                  Colors.green,
                                  CupertinoIcons.info_circle_fill,
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            // Últimos eventos (notificação)
                            Text(
                              'Últimos eventos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? CupertinoColors.white
                                    : Color(0xFF114474),
                              ),
                            ),

                            const SizedBox(height: 10),
                            eventosAsync.when(
                              data: (eventos) {
                                final ultimos = eventos.take(5).toList();
                                return Column(
                                  children: ultimos.map((evento) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: eventCardBg,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(
                                              ((isDarkMode ? 0.10 : 0.08) * 255)
                                                  .toInt(),
                                            ),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Color(0x1A114474),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              CupertinoIcons.bell_fill,
                                              color: const Color(0xFF114474),
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  evento.rotulo,
                                                  style: TextStyle(
                                                    color: eventTitleColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  evento.nomeTipo,
                                                  style: TextStyle(
                                                    color: isDarkMode
                                                        ? CupertinoColors
                                                              .systemGrey2
                                                        : CupertinoColors
                                                              .systemGrey,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  evento.dataHora,
                                                  style: TextStyle(
                                                    color: CupertinoColors
                                                        .systemGrey2,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const CupertinoActivityIndicator(),
                              error: (e, s) =>
                                  const Text('Erro ao carregar eventos'),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CupertinoActivityIndicator()),
                    error: (err, stack) {
                      if (isOffline) {
                        // Não mostra erro de dados quando está offline!
                        return const SizedBox.shrink();
                      }
                      return Center(
                        child: Text(
                          "Erro ao carregar dados",
                          style: TextStyle(color: CupertinoColors.systemRed),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // DRAWER
          if (_isDrawerOpen)
            Positioned(
              left: 250,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: toggleDrawer,
                child: Container(color: const Color.fromRGBO(0, 0, 0, 0.8)),
              ),
            ),
          SlideTransition(
            position: _drawerSlideAnimation,
            child: SizedBox(
              width: 250,
              child: Material(
                elevation: 16,
                color: drawerBgColor,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF114474),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        bottom: 16,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: CupertinoColors.systemOrange,
                            child: Icon(
                              CupertinoIcons.person,
                              size: 30,
                              color: CupertinoColors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProfile,
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey2,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          _drawerItem(
                            icon: CupertinoIcons.doc_plaintext,
                            text: "Dashboard Geradores",
                            iconColor: const Color(0xFF007bff),
                            onTap: () {
                              toggleDrawer();
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const DashboardGeradoresScreen(),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                ),
                              );
                            },
                          ),
                          _drawerItem(
                            icon: CupertinoIcons.bell_fill,
                            text: "Eventos",
                            iconColor: const Color(0xFFfd7e14),
                            onTap: () {
                              toggleDrawer();
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const EventosScreen(),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                ),
                              );
                            },
                          ),
                          _drawerItem(
                            icon: CupertinoIcons.phone,
                            text: "Suporte",
                            iconColor: const Color(0xFF28a745),
                            onTap: () {
                              toggleDrawer();
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const SuporteScreen(),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                ),
                              );
                            },
                          ),
                          _drawerItem(
                            icon: CupertinoIcons.power,
                            text: "Sair",
                            iconColor: const Color(0xFFdc3545),
                            onTap: () {
                              toggleDrawer();
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const LoginScreen(),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final textColor = isDarkMode
        ? CupertinoColors.white
        : CupertinoColors.label;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  Widget _buildStatusCard(
    String title,
    String subtitle,
    int count,
    Color cardColor,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor.withAlpha(220),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: CupertinoColors.white),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
