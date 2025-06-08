import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/suporte_provider.dart';

class SuporteScreen extends ConsumerWidget {
  const SuporteScreen({super.key});

  void _ligar(String numero) {
    final uri = Uri.parse('tel:$numero');
    launchUrl(uri);
  }

  void _whatsapp(String numero) {
    final telefoneLimpo = numero.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/55$telefoneLimpo');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _email(String email) {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Suporte TSIGO',
    );
    launchUrl(uri);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suporteAsync = ref.watch(suporteProvider);
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : CupertinoColors.systemGroupedBackground;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : CupertinoColors.white;
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;
    final subTextColor = CupertinoColors.systemGrey;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              bottom: 12,
              left: 10,
              right: 16,
            ),
            color: const Color(0xFF114474),
            child: Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.back,
                    color: CupertinoColors.white,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Suporte",
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          Expanded(
            child: suporteAsync.when(
              data: (suporte) => ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  const SizedBox(height: 15),
                  Center(
                    child: Image.asset('assets/logo_ativos.png', height: 55),
                  ),
                  const SizedBox(height: 15),

                  _buildCard(
                    title: "Responsável",
                    value: suporte.responsavel,
                    icon: CupertinoIcons.person,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Telefone",
                    value: suporte.telefone ?? "Não informado",
                    icon: CupertinoIcons.phone,
                    isDark: isDark,
                    onTap: () {
                      if ((suporte.telefone ?? '').isNotEmpty) {
                        _ligar(suporte.telefone!);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "WhatsApp",
                    value: suporte.celular ?? "Não informado",
                    icon: CupertinoIcons.chat_bubble_2_fill,
                    isDark: isDark,
                    onTap: () {
                      if ((suporte.celular ?? '').isNotEmpty) {
                        _whatsapp(suporte.celular!);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "E-mail",
                    value: suporte.email ?? "Não informado",
                    icon: CupertinoIcons.mail,
                    isDark: isDark,
                    onTap: () {
                      if ((suporte.email ?? '').isNotEmpty) {
                        _email(suporte.email!);
                      }
                    },
                  ),

                  const SizedBox(height: 30),

                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(CupertinoIcons.calendar, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Horário de Atendimento",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ..._horario().map(
                          (linha) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  linha['dia']!,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  linha['hora']!,
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (err, _) => Center(
                child: Text("Erro: $err", style: TextStyle(color: textColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final Color cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : CupertinoColors.white;
    final Color titleColor = CupertinoColors.systemGrey;
    final Color valueColor = isDark
        ? CupertinoColors.white
        : CupertinoColors.black;

    final bool isClickable = onTap != null && value != "Não informado";

    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: CupertinoColors.systemBlue),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isClickable)
              const Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: CupertinoColors.systemGrey,
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _horario() {
    return [
      {'dia': 'Domingo', 'hora': 'Fechado'},
      {'dia': 'Segunda-feira', 'hora': '08:00 – 18:00'},
      {'dia': 'Terça-feira', 'hora': '08:00 – 18:00'},
      {'dia': 'Quarta-feira', 'hora': '08:00 – 18:00'},
      {'dia': 'Quinta-feira', 'hora': '08:00 – 18:00'},
      {'dia': 'Sexta-feira', 'hora': '08:00 – 18:00'},
      {'dia': 'Sábado', 'hora': 'Fechado'},
    ];
  }
}
