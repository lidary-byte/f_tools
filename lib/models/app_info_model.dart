/*
 * @Description: 
 * @Author: lidary-byte lidaryl@163.com
 * @Date: 2025-01-15 16:21:59
 * @LastEditors: lidary-byte lidaryl@163.com
 * @LastEditTime: 2025-01-16 16:07:51
 */

class AppInfoModel {
  final String name;
  final String path;
  final String icon;
  final List<String> keywords;
  final String description;

  AppInfoModel({
    required this.name,
    required this.path,
    required this.icon,
    required this.keywords,
    required this.description,
  });
}

// // @JsonCodable()
// class AppModel {
//   //final List<MacAppModel> macApp;
//   final String? name;
//   final String? archKind;
//   final String? lastModified;
//   final String? obtainedFrom;
//   final String? path;
//   // final List<String>? signedBy;
//   final String? version;
//   String? iconPath;

//   AppModel(
//       {this.name,
//       this.archKind,
//       this.lastModified,
//       this.obtainedFrom,
//       this.path,
//       // this.signedBy,
//       this.version,
//       this.iconPath});
// }

// @JsonCodable()
// class MacAppModel {
//   final String name;
//   final String archKind;
//   final String lastModified;
//   final String obtainedFrom;
//   final String path;
//   final List<String> signedBy;
//   final String version;
// }

// // 状态模型
// class SearchStateModel {
//   final List<AppModel> apps;
//   final List<AppModel> filteredApps;
//   final int selectedIndex;
//   final String searchText;

//   SearchStateModel({
//     required this.apps,
//     required this.filteredApps,
//     required this.selectedIndex,
//     required this.searchText,
//   });

//   SearchStateModel copyWith({
//     List<AppModel>? apps,
//     List<AppModel>? filteredApps,
//     int? selectedIndex,
//     String? searchText,
//   }) {
//     return SearchStateModel(
//       apps: apps ?? this.apps,
//       filteredApps: filteredApps ?? this.filteredApps,
//       selectedIndex: selectedIndex ?? this.selectedIndex,
//       searchText: searchText ?? this.searchText,
//     );
//   }
// }
