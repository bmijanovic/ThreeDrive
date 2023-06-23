
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threecloud/urls.dart';



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
      Uri.parse('${url}registration'),
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
    if (response.statusCode == 200) {
      // var userData = jsonDecode(response.body);
      // user = User(userData['id'], userData['firstName'], userData['lastName'],
      //     userData['email'], userData['password'], 0.0);
      // return jsonDecode(response.body)['id'];
      return "1";
    } else {
      throw StateError(res['body']);
    }
  }

  static Future<void> logIn(String username, String password) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse('${url}login'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: json.encode(
        {
          'username': username,
          'password': password,
        },
      ),
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await rememberThatUserLoggedIn(username, data['token']);
    } else {
      throw StateError(res['body']);
    }
  }

  static rememberThatUserLoggedIn(String username, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("loggedIn", true);
    await prefs.setString("username", username);
    await prefs.setString("token", token);
  }

}