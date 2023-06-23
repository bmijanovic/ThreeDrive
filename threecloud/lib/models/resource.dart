
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threecloud/urls.dart';

class Resource {
  static Future<String> upload(String name, String image,List<Map<String,String>> tags,String current_path) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse(url + "upload"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
      },
      body: json.encode(
        {
          'name': name,
          'image': image,
          'tags':tags,
          'path':current_path.substring(0,current_path.length-1)
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

  static Future<dynamic> getMyResources(String name) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.get(
      Uri.parse(
          "${url}getMyResources?path=$name"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
      },
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<dynamic> directories=[];
      List<dynamic> resources = [];
      if (res['data'].length>0) {
        if (res['data'][0]['directories'] != null) {
          directories.addAll(res['data'][0]['directories']);
        }
        if (res['data'][0]['items'] != null) {
          resources.addAll(res['data'][0]['items']);
        }
      }
      DirectoryDTO returnValue= DirectoryDTO((directories)?.map((item) => item as String)?.toList(),(resources)?.map((item) => item as String)?.toList());
      return returnValue ;
    } else {
      throw StateError(res['body']);
    }
  }
}
class DirectoryDTO{
  late List<String> directories;
  late List<String> files;
  DirectoryDTO(List<String>? directories,List<String>? files){
    this.directories=directories!;
    this.files=files!;
  }
}