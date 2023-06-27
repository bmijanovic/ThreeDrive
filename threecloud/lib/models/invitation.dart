

import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../urls.dart';

class Invitation {
  static Future<bool> create(String email) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse("${url}familyInvitation"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "Bearer ${(await SharedPreferences.getInstance()).getString("token")}"
      },
      body: json.encode(
        {
          'family_member_email': email,
        },
      ),
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw StateError(res['data']);
    }
  }
}