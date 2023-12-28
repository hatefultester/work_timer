enum TaskPriorityEnum {
  minor,
  major,
  critical;

  String toStringFormatted() => switch (this) {
        minor => 'Minor',
        major => 'Major',
        critical => 'Critical',
      };

  String toJson() => switch (this) {
        minor => 'minor',
        major => 'major',
        critical => 'critical',
      };

  static TaskPriorityEnum fromJson(dynamic json) => switch (json) {
        'minor' => minor,
        'major' => major,
        'critical' => critical,
        _ => major,
      };
}
