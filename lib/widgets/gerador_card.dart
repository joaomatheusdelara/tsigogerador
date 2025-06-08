import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/gerador_model.dart';

class GeradorCard extends StatelessWidget {
  final Gerador gerador;

  const GeradorCard({super.key, required this.gerador});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: (gerador.icone.isNotEmpty) // ✅ Apenas verifica se está vazio
            ? Image.network(
                "https://api.getsec.com.br/${gerador.icone}",
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(CupertinoIcons.gear_solid, size: 50);
                },
              )
            : const Icon(CupertinoIcons.gear_solid, size: 50), // Ícone padrão caso não tenha imagem

        title: Text(
          gerador.rotulo, // ✅ Agora usando o campo correto da API
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Horímetro: ${gerador.horimetro} h"),

            Row(
              children: [
                Icon(
                  gerador.statusRede ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt_slash_fill,
                  color: gerador.statusRede ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                ),
                const SizedBox(width: 8),
                Text(gerador.statusRede ? "Rede Ativa" : "Rede Inativa"),
              ],
            ),

            Row(
              children: [
                Icon(
                  gerador.statusGerador ? CupertinoIcons.battery_full : CupertinoIcons.battery_empty,
                  color: gerador.statusGerador ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                ),
                const SizedBox(width: 8),
                Text(gerador.statusGerador ? "Gerador Ativo" : "Gerador Inativo"),
              ],
            ),

            Row(
              children: [
                Icon(
                  gerador.testeSemCarga ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash,
                  color: gerador.testeSemCarga ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                ),
                const SizedBox(width: 8),
                Text(gerador.testeSemCarga ? "Teste Sem Carga Ativo" : "Teste Sem Carga Inativo"),
              ],
            ),

            Row(
              children: [
                Icon(
                  gerador.testeComCarga ? CupertinoIcons.cloud_bolt_fill : CupertinoIcons.cloud_bolt,
                  color: gerador.testeComCarga ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                ),
                const SizedBox(width: 8),
                Text(gerador.testeComCarga ? "Teste Com Carga Ativo" : "Teste Com Carga Inativo"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
