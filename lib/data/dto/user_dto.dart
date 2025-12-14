class UserDto {
  String? name;
  String? email;
  String? phone;
  String? address;

  UserDto({
    this.name,
    this.email,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    return data;
  }
}
