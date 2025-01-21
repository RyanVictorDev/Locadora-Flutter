class PublisherModel {
  final int id;
  final String name;
  final String email;
  final String telephone;
  final String? site;

  PublisherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.telephone,
    this.site,
  });

  factory PublisherModel.fromJson(Map<String, dynamic> json) {
    return PublisherModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      site: json['site'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['telephone'] = this.telephone;
    data['site'] = this.site;
    return data;
  }
}
