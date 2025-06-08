import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/suporte_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/suporte_model.dart';

final suporteProvider = FutureProvider<Suporte>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final service = SuporteService(token);
  return service.buscarSuporte();
});
