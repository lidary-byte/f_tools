/*
 * @Description: 
 * @Author: lidary-byte lidaryl@163.com
 * @Date: 2025-01-16 13:41:29
 * @LastEditors: lidary-byte lidaryl@163.com
 * @LastEditTime: 2025-01-16 16:51:58
 */
import 'dart:io';

import 'package:f_tools/main.dart';
import 'package:f_tools/models/app_info_model.dart';
import 'package:f_tools/utils/app_search/app_search.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final focusNode = FocusNode();
  final searchFocusNode = FocusNode();
  List<AppInfoModel> apps = [];
  List<AppInfoModel> filteredApps = [];
  int selectedIndex = 0;

  @override
  void onInit() {
    super.onInit();
    loadApps();
    // 确保搜索框获得焦点
    searchFocusNode.requestFocus();
  }

  @override
  void onClose() {
    searchController.dispose();
    focusNode.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void handleKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // ESC 键清空搜索
      clearSearch();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // 向下键选择下一个
      if (selectedIndex < filteredApps.length - 1) {
        selectedIndex++;
        update();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      // 向上键选择上一个
      if (selectedIndex > 0) {
        selectedIndex--;
        update();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      // 回车键打开选中的应用
      if (filteredApps.isNotEmpty) {
        openApp(filteredApps[selectedIndex]);
      }
    }
  }

  Future<void> loadApps() async {
    try {
      final appSearch = AppSearch();
      apps = await appSearch.getApps();
      filteredApps = apps;
      update();
    } catch (e) {
      logger.e('加载应用失败: $e');
    }
  }

  void onSearchChanged(String value) {
    selectedIndex = 0; // 重置选中项
    if (value.isEmpty) {
      filteredApps = apps;
    } else {
      filteredApps = apps.where((app) {
        return app.name.toLowerCase().contains(value.toLowerCase()) ||
            app.path.toLowerCase().contains(value.toLowerCase());
      }).toList();
    }
    update();
  }

  void clearSearch() {
    searchController.clear();
    filteredApps = apps;
    selectedIndex = 0;
    update();
  }

  void openApp(AppInfoModel app) async {
    try {
      await Process.run('open', [app.path]);
    } catch (e) {
      logger.e('打开应用失败: $e');
    }
  }
}
