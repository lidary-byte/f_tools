/*
 * @Description: 
 * @Author: lidary-byte lidaryl@163.com
 * @Date: 2025-01-16 11:26:52
 * @LastEditors: lidary-byte lidaryl@163.com
 * @LastEditTime: 2025-01-16 17:03:51
 */
import 'dart:io';

import 'package:f_tools/pages/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: controller.focusNode,
      autofocus: true,
      onKeyEvent: controller.handleKeyEvent,
      // onKey: controller.handleKeyEvent,
      child: Scaffold(
        body: GetBuilder<HomeController>(
          // init: HomeController(),
          builder: (c) => Column(
            children: [
              // Raycast 风格的搜索框
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  focusNode: controller.searchFocusNode,
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '搜索应用...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: controller.clearSearch,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              // 应用列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final app = controller.filteredApps[index];
                    final isSelected = index == controller.selectedIndex;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                      ),
                      child: ListTile(
                        leading: Image.file(
                          File(app.icon),
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.apps, size: 40),
                        ),
                        title: Text(
                          app.name,
                          style: TextStyle(
                            color: isSelected ? Colors.blue : null,
                          ),
                        ),
                        subtitle: Text(
                          app.path,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => controller.openApp(app),
                      ),
                    );
                  },
                  itemCount: controller.filteredApps.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
