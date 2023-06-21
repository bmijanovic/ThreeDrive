
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:threecloud/urls.dart';

class Resource {
  static Future<String> upload(String name, String image,List<Map<String,String>> tags) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse(
          url+"upload"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: json.encode(
        {
          'name': name,
          'image': image,
          'tags':tags,
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