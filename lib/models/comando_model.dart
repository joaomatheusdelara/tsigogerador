
class Comando {
  final String id;
  final String nome;
  

  Comando({required this.id, required this.nome});

  factory Comando.fromJson(Map<String, dynamic> json) {
    return Comando(
      id: json['id'].toString(),
      nome: json['nome'] ?? '',
    );
  }
}
