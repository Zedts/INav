// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';

class AppDefinition {
  final String packageName;
  final List<String>? packageAliases;
  final String name;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final bool iconMatchTextDirection;
  final int colorARGB;
  final bool isDefault;

  Color get color => Color(colorARGB);

  const AppDefinition({
    required this.packageName,
    this.packageAliases,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
    this.iconMatchTextDirection = false,
    required this.colorARGB,
    this.isDefault = false,
  });

  bool matchesPackage(String candidate) {
    if (packageName == candidate) return true;
    if (packageAliases != null && packageAliases!.contains(candidate)) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    if (packageAliases != null) 'packageAliases': packageAliases,
    'name': name,
    'iconCodePoint': iconCodePoint,
    'iconFontFamily': iconFontFamily,
    'iconFontPackage': iconFontPackage,
    'iconMatchTextDirection': iconMatchTextDirection,
    'colorARGB': colorARGB,
    'isDefault': isDefault,
  };

  factory AppDefinition.fromJson(Map<String, dynamic> json) {
    final aliasesJson = json['packageAliases'];
    final List<String>? aliases = aliasesJson is List
        ? aliasesJson.map((e) => e as String).toList()
        : null;

    return AppDefinition(
      packageName: json['packageName'] as String,
      packageAliases: aliases,
      name: json['name'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      iconFontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
      iconFontPackage: json['iconFontPackage'] as String?,
      iconMatchTextDirection: json['iconMatchTextDirection'] as bool? ?? false,
      colorARGB: json['colorARGB'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  AppDefinition copyWith({
    String? packageName,
    List<String>? packageAliases,
    String? name,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    bool? iconMatchTextDirection,
    int? colorARGB,
    bool? isDefault,
  }) => AppDefinition(
    packageName: packageName ?? this.packageName,
    packageAliases: packageAliases ?? this.packageAliases,
    name: name ?? this.name,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    iconFontFamily: iconFontFamily ?? this.iconFontFamily,
    iconFontPackage: iconFontPackage ?? this.iconFontPackage,
    iconMatchTextDirection:
        iconMatchTextDirection ?? this.iconMatchTextDirection,
    colorARGB: colorARGB ?? this.colorARGB,
    isDefault: isDefault ?? this.isDefault,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppDefinition &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;
}
