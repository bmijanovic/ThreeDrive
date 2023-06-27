
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
      return "1";
    } else {
      throw StateError(res['body']);
    }
  }

  static Future<String> registerWithInvite(String name, String surname, String email, String password, String birthdate, String username,String inviter) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse('${url}familyProcess'),
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
          'inviter': inviter
        },
      ),
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return "1";
    } else {
      throw StateError(res['body']);
    }
  }

  static Future<String> logIn(String username, String password) async
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
      return username;
    } else {
      throw StateError(res['data']);
    }
  }

  static rememberThatUserLoggedIn(String username, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("loggedIn", true);
    await prefs.setString("username", username);
    await prefs.setString("token", token);
  }

  static rememberThatUserLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("loggedIn");
    await prefs.remove("username");
    await prefs.remove("token");
  }
  static Future<dynamic> getInvitations() async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.get(
      Uri.parse("${url}invitation"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
      },
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return res['data'];
    } else {
      throw StateError(res['body']);
    }
  }
  static Future<String> answerInvite(String email,bool isAccepted) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse("${url}invitation"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
      },
      body: json.encode(
        {
          'email': email,
          'accept':isAccepted
        },
      ),
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return "1";
    } else {
      throw StateError(res['body']);
    }
  }

}