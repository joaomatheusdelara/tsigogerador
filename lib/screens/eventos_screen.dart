import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/evento_provider.dart';

class EventosScreen extends ConsumerWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(eventosProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final backgroundColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor =
        isDarkMode ? const Color(0xFF1E1E1E) : CupertinoColors.white;
    final textColor =
        isDarkMode ? CupertinoColors.white : const Color(0xFF114474);
    final shadowColor =
        isDarkMode ? const Color(0x66000000) : const Color(0x33000000);

    Future<void> onRefresh() async {
      ref.invalidate(eventosProvider);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          // Topo azul fixo
          Container(
            color: const Color(0xFF114474),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 12,
              left: 12,
              right: 12,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(CupertinoIcons.back,
                        color: CupertinoColors.white),
                  ),
                ),
                const Text(
                  'Eventos',
                  style: TextStyle(
                    fontSize: 20,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista de eventos
          Expanded(
            child: eventosAsync.when(
              data: (eventos) {
                if (eventos.isEmpty) {
                  return const Center(child: Text("Nenhum evento encontrado."));
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(onRefresh: onRefresh),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final evento = eventos[index];

                          final isAlerta =
                              evento.nomeTipo.contains('Desacionada');
                          final icon = isAlerta
                              ? CupertinoIcons.exclamationmark_triangle_fill
                              : evento.nomeTipo.contains('Ignição')
                                  ? CupertinoIcons.bolt_fill
                                  : CupertinoIcons.check_mark_circled_solid;

                          final iconColor = isAlerta
                              ? CupertinoColors.systemRed
                              : CupertinoColors.activeGreen;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(icon, size: 32, color: iconColor),
                                const SizedBox(height: 12),
                                Text(
                                  evento.rotulo,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: iconColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    evento.nomeTipo,
                                    style: TextStyle(
                                      color: iconColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.time,
                                        size: 14,
                                        color: isDarkMode
                                            ? CupertinoColors.systemGrey
                                            : CupertinoColors.systemGrey),
                                    const SizedBox(width: 6),
                                    Text(
                                      evento.dataHora,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: eventos.length,
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CupertinoActivityIndicator(radius: 16)),
              error: (err, stack) => Center(child: Text("Erro: $err")),
            ),
          ),
        ],
      ),
    );
  }
}
