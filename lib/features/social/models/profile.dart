class Profile {
  final String id;
  final String? nombre;
  final String? biografia;
  final String? linkedinUrl;
  final String? emailPublico;
  final String? matricula;
  final String? carrera;
  final String? generacion;
  final String? avatarUrl;

  Profile({
    required this.id,
    this.nombre,
    this.biografia,
    this.linkedinUrl,
    this.emailPublico,
    this.matricula,
    this.carrera,
    this.generacion,
    this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      nombre: json['nombre'],
      biografia: json['biografia'],
      linkedinUrl: json['linkedin_url'],
      emailPublico: json['email_publico'],
      matricula: json['matricula'],
      carrera: json['carrera'],
      generacion: json['generacion'],
      avatarUrl: json['avatar_url'],
    );
  }
}
