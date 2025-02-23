class Contact {
  int? id;
  String name;
  String phone;

  Contact({this.id, required this.name, required this.phone});

  // Converter um objeto Contact para um mapa (usado para inserir no banco)
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone};
  }

  // Criar um objeto Contact a partir de um mapa (usado para leitura do banco)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(id: map['id'], name: map['name'], phone: map['phone']);
  }
}
