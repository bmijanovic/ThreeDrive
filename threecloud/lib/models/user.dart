
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

import '../helper.dart';


class User {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String password;
  final DateTime birthdate;

  User(this.id, this.email, this.password, this.birthdate, this.name, this.surname);

  static Future<String> register(String name, String surname, String email, String password, String birthdate, String username) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse('https://kf8dco6sv9.execute-api.eu-north-1.amazonaws.com/test/registration'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: json.encode(
        {
          'name': name,
          'surname': surname,
          'email': email,
          'password': password,
          'birthdate': birthdate,
          'username': username,
        },
      ),
    );
    var res = jsonDecode(response.body);
    if (res['statusCode'] == 200) {
      // var userData = jsonDecode(response.body);
      // user = User(userData['id'], userData['firstName'], userData['lastName'],
      //     userData['email'], userData['password'], 0.0);
      // return jsonDecode(response.body)['id'];
      return "1";
    } else {
      throw StateError(res['body']);
    }
  }
}