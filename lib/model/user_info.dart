class UserInfoDetails{
  late String email;
 late String password;
  late String name;
 late String uID;

  UserInfoDetails({required this.email, required this.password, required this.name, required this.uID});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'uID': uID,
    };
  }

  UserInfoDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    password = json['password'];
    uID = json['uID'];
  }

}