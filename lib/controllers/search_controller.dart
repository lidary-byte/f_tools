import 'package:get/get.dart';

class SearchController extends GetxController {
  final searchText = ''.obs;
  final searchResults = <String>[].obs;

  void updateSearch(String value) {
    searchText.value = value;
    // TODO: 实现实际的搜索逻辑
    searchResults.value = ['结果 1', '结果 2', '结果 3']; // 示例数据
  }
}
