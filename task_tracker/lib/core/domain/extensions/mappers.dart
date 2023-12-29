extension DateTimeMapper on DateTime {
  String toJson() => toIso8601String();
  static DateTime? fromJson(dynamic json) => json == null ? null : DateTime.parse(json);
}

extension DurationMapper on Duration {
  String toJson() => inSeconds.toString();
  static Duration? fromJson(dynamic json) => json is! int ? null : Duration(seconds: json);
}