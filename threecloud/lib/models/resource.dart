
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

class Resource {
  static Future<String> upload(String name, String image) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse(
          'https://kf8dco6sv9.execute-api.eu-north-1.amazonaws.com/test/upload'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: json.encode(
        {
          'name': name,
          'image': image,
          'tags':[]
        },
      ),
    );
    var res = jsonDecode(response.body);
    if (res['statusCode'] == 200) {
      return "1";
    } else {
      throw StateError(res['body']);
    }
  }
}