/*
 * @Description: 
 * @Author: lidary-byte lidaryl@163.com
 * @Date: 2025-01-16 13:47:37
 * @LastEditors: lidary-byte lidaryl@163.com
 * @LastEditTime: 2025-01-16 14:31:11
 */
import 'package:f_tools/pages/home/home_controller.dart';
import 'package:f_tools/pages/home/home_page.dart';
import 'package:get/get.dart';

abstract class AppRoutes {
  AppRoutes._();

  static final routes = [
    GetPage(
      name: AppRoutePath.home,
      page: () => const HomePage(),
      binding: GenericBinding(() => HomeController()),
    )
  ];
}

abstract class AppRoutePath {
  AppRoutePath._();

  static const home = '/';
}

/// 通用 Binding 生成器
class GenericBinding<T> extends Binding {
  final T Function() create;

  GenericBinding(this.create);

  @override
  List<Bind> dependencies() => [Bind.lazyPut(create)];
}
