import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/evento_service.dart';

final eventosProvider = FutureProvider<List<Evento>>((ref) async {
  final service = EventoService();
  return await service.listarEventos();
});
