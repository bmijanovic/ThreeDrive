import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threecloud/urls.dart';

class Directory {
  static Future<bool> create(String name, String path) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse(url + "directory"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "Bearer ${(await SharedPreferences.getInstance()).getString("token")}"
      },
      body: json.encode(
        {
          'name': name,
          'path': path,
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
  static Future<bool> delete(String path) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.delete(
      Uri.parse(url + "directory"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "Bearer ${(await SharedPreferences.getInstance()).getString("token")}"
      },
      body: json.encode(
        {
          'path': path,
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