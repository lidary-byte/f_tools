/*
 * @Description: 
 * @Author: lidary-byte lidaryl@163.com
 * @Date: 2025-01-16 14:46:56
 * @LastEditors: lidary-byte lidaryl@163.com
 * @LastEditTime: 2025-01-16 15:56:40
 */
import 'dart:io';

import 'package:f_tools/models/app_info_model.dart';

import 'darwin_app_search.dart';
import 'linux_app_search.dart';

abstract class AppSearch {
  Future<List<AppInfoModel>> getApps();

  factory AppSearch() {
    if (Platform.isMacOS) {
      return DarwinAppSearch();
    } else if (Platform.isWindows) {
      // return WindowsAppSearch();
    } else if (Platform.isLinux) {
      return LinuxAppSearch();
    }
    throw UnsupportedError('当前平台不支持应用搜索');
  }
}
