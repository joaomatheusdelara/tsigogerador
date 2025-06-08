import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gerador_model.dart';
import '../services/posicao_service.dart';

final posicaoServiceProvider =
    Provider<PosicaoService>((ref) => PosicaoService());

final geradorProvider = FutureProvider<List<Gerador>>((ref) async {
  final service = ref.watch(posicaoServiceProvider);
  return await service.getUltimasPosicoes();
});

final geradorDetalheProvider =
    FutureProvider.family<Gerador, String>((ref, id) async {
  final service = ref.watch(posicaoServiceProvider);
  final geradores = await service.getUltimasPosicoes();
  return geradores.firstWhere((g) => g.id == id);
});
