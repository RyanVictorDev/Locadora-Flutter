class RenterModel {
  final int id;
  final String name;
  final String email;
  final String telephone;
  final String address;
  final String cpf;

  RenterModel({
    required this.id,
    required this.name,
    required this.email,
    required this.telephone,
    required this.address,
    required this.cpf,
  });

  factory RenterModel.fromJson(Map<String, dynamic> json){
    return RenterModel(
      id: json['id'] as int, 
      name: json['name'] as String, 
      email: json['email'] as String, 
      telephone: json['telephone'] as String, 
      address: json['address'] as String, 
      cpf: json['cpf'] as String
    );
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['telephone'] = this.telephone;
    data['address'] = this.address;
    data['cpf'] = this.cpf;
    return data;
  }
}