import 'dart:convert';
import 'dart:io';

import 'package:f_tools/models/app_info_model.dart';
import 'package:f_tools/utils/app_search/app_search.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DarwinAppSearch implements AppSearch {
  @override
  Future<List<AppInfoModel>> getApps() async {
    // final apps = <AppInfo>[];

    // 使用system_profiler获取应用列表
    final result = await Process.run('system_profiler',
        ['-json', '-detailLevel', 'mini', 'SPApplicationsDataType']);

    if (result.exitCode == 0) {
      return await _parseJson(
          jsonDecode(result.stdout)['SPApplicationsDataType']);
    }

    return [];
  }

  Future<List<AppInfoModel>> _parseJson(List<dynamic> resultJson) async {
    final apps = <AppInfoModel>[];

    for (final result in resultJson) {
      final appName = result['_name'];
      final appPath = result['path'];
      final icon = await _getAppIcon(appPath, appName);
      if (icon != null) {
        apps.add(AppInfoModel(
            name: appName,
            path: appPath,
            icon: icon,
            keywords: _generateKeywords(appName),
            description: appPath));
      }
    }
    // for (var e in resultJson) {
    //   String appName = e['_name'];
    //   String appPath = e['path'];

    //   apps.add(_MacApp(name: appName, path: appPath));
    // }
    return apps;
  }

  Future<String?> _getAppIcon(String appPath, String appName) async {
    final tempDir = await getApplicationCacheDirectory();
    final iconDir = Directory(path.join(tempDir.path, 'ProcessIcon'));

    if (!await iconDir.exists()) {
      await iconDir.create();
    }

    final iconPath = path.join(iconDir.path, '$appName.png');

    // 如果图标已存在则直接返回
    if (await File(iconPath).exists()) {
      return iconPath;
    }

    try {
      // 使用 sips 命令提取图标
      final sipsResult = await Process.run('sips', [
        '-s', 'format', 'png',
        '--getIcon', appPath, // 获取应用图标
        '--resampleHeightWidth', '256', '256',
        '--out', iconPath
      ]);

      if (sipsResult.exitCode == 0 && await File(iconPath).exists()) {
        return iconPath;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  List<String> _generateKeywords(String appName) {
    final keywords = <String>[appName];

    // 添加应用名称的小写形式
    keywords.add(appName.toLowerCase());

    // 如果应用名称包含空格,添加无空格版本
    if (appName.contains(' ')) {
      keywords.add(appName.replaceAll(' ', ''));
    }

    // 添加首字母缩写
    final initials = appName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0])
        .join()
        .toLowerCase();
    if (initials.length > 1) {
      keywords.add(initials);
    }

    // 如果包含中文字符,可以添加拼音支持
    if (_containsChinese(appName)) {
      // TODO: 添加拼音支持
      // 需要引入拼音转换库
    }

    return keywords;
  }

  bool _containsChinese(String text) {
    return RegExp(r'[\u4e00-\u9fa5]').hasMatch(text);
  }
}
