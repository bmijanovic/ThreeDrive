
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
      Uri.parse(url + "upload"),
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

  static Future<dynamic> getMyResources(String name) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.get(
      Uri.parse(
          url+"getMyResources"+"?path="+name),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<dynamic> directories=[];
      if (res['data'][0]['directories'] !=null){
        directories.addAll(res['data'][0]['directories']);
      }
      List<dynamic> resources=[];
      if (res['data'][0]['items'] !=null){
        directories.addAll(res['data'][0]['items']);
      }
      DirectoryDTO return_value= DirectoryDTO((directories)?.map((item) => item as String)?.toList(),(resources)?.map((item) => item as String)?.toList());
      return return_value ;
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