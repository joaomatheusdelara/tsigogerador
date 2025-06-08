class Suporte {
  final String responsavel;
  final String? telefone;
  final String? celular;
  final String? email;

  Suporte({
    required this.responsavel,
    this.telefone,
    this.celular,
    this.email,
  });

  factory Suporte.fromJson(Map<String, dynamic> json) {
    return Suporte(
      responsavel: json['responsavel'] ?? 'Não informado',
      telefone: json['telefone'],
      celular: json['celular'],
      email: json['email'],
    );
  }
}
