import 'package:cloud_firestore/cloud_firestore.dart';

/// Representasi dokumen koleksi `user_setting`. ID dokumen = id_user.
class UserSetting {
  const UserSetting({required this.bahasa, required this.kecepatanSuara});

  final String bahasa; // 'id' | 'en'
  final double kecepatanSuara; // 0.0 - 1.0

  static const defaultValue = UserSetting(bahasa: 'id', kecepatanSuara: 0.5);

  Map<String, dynamic> toMap() => {
        'bahasa': bahasa,
        'kecepatan_suara': kecepatanSuara,
      };

  factory UserSetting.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return defaultValue;
    return UserSetting(
      bahasa: data['bahasa'] as String? ?? defaultValue.bahasa,
      kecepatanSuara:
          (data['kecepatan_suara'] as num?)?.toDouble() ?? defaultValue.kecepatanSuara,
    );
  }

  UserSetting copyWith({String? bahasa, double? kecepatanSuara}) {
    return UserSetting(
      bahasa: bahasa ?? this.bahasa,
      kecepatanSuara: kecepatanSuara ?? this.kecepatanSuara,
    );
  }
}