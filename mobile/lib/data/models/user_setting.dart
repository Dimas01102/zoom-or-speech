/// Representasi baris tabel user_setting dari response API Laravel.
class UserSetting {
  const UserSetting({required this.bahasa, required this.kecepatanSuara});

  final String bahasa; // 'id' | 'en'
  final double kecepatanSuara;

  static const defaultValue = UserSetting(bahasa: 'id', kecepatanSuara: 0.5);

  factory UserSetting.fromJson(Map<String, dynamic> json) {
    return UserSetting(
      bahasa: json['bahasa'] as String? ?? defaultValue.bahasa,
      kecepatanSuara: (json['kecepatan_suara'] as num?)?.toDouble() ?? defaultValue.kecepatanSuara,
    );
  }

  UserSetting copyWith({String? bahasa, double? kecepatanSuara}) {
    return UserSetting(
      bahasa: bahasa ?? this.bahasa,
      kecepatanSuara: kecepatanSuara ?? this.kecepatanSuara,
    );
  }
}