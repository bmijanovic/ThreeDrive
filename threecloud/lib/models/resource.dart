import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threecloud/urls.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';


class Resource {
  static Future<String> upload(String name, String image,List<Map<String,String>> tags,String current_path) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse("${url}resource"),
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

  static Future<bool> delete(String name, String currentPath) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.delete(
      Uri.parse("${url}resource?path=$name"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
      },
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
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

  static Future<dynamic> getResource(String path) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.get(
      Uri.parse(
          "${url}resource/metadata?path=$path"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
      },
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return res['data'][0];
    } else {
      throw StateError(res['body']);
    }
  }

  static Future<void> downloadResource(String path,{String downloadPath='/storage/emulated/0/Download'}) async
    {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.get(
      Uri.parse("${url}resource?path=$path"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
      },
    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<int> bytes = base64.decode(res['data']);
      String downloadsDirPath = downloadPath;
      String fileName = path.split("/").last;
      String filePath = '$downloadsDirPath/$fileName';

      File file = File(await generateUniqueFileName(filePath));
      await file.writeAsBytes(bytes);
    }
    else {
      throw StateError(res['data']);
    }
  }

  static Future<String> generateUniqueFileName(String originalFilePath) async {
    String originalFileName = originalFilePath.split('/').last;
    String originalFileExtension = originalFileName.split('.').last;

    Directory downloadsDirPath = Directory('/storage/emulated/0/Download');
    int count = 1;
    String newFilePath = originalFilePath;
    String newFileName = originalFileName;

    while (await File(newFilePath).exists()) {
      newFileName = '${originalFileName}_($count)';
      newFilePath = '${downloadsDirPath.path}/$newFileName.$originalFileExtension';
      count++;
    }

    return newFilePath;
  }
  
  static Future<List<dynamic>> getSharedUsernames(String action, String path) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.get(
      Uri.parse(
          "${url}share?path=$path&type=$action"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
      },

    );
    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print(res['data']);
      return res['data'];
    } else {
      throw StateError(res['body']);
    }
  }

  static Future<bool> addPermission(String type, String path, String username, String action) async
  {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.put(
      Uri.parse("${url}share"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
      },
      body: json.encode(
        {
          'path': path,
          'type': type,
          'username':username,
          'action': action
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

  static Future<bool> move(String content, String currentPath)
  async {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(
      Uri.parse("${url}move"),
      headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer ${(await SharedPreferences.getInstance()).getString("token")}'
    },
      body: json.encode(
        {
          'path': content,
          'new_path': currentPath
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


class DirectoryDTO{
  late List<String> directories;
  late List<String> files;
  DirectoryDTO(List<String>? directories,List<String>? files){
    this.directories=directories!;
    this.files=files!;
  }
}