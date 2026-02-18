class Validators {
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email requis';
    final re = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!re.hasMatch(v)) return 'Email invalide';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Mot de passe requis';
    if (v.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nom requis';
    if (v.trim().length < 2) return 'Trop court';
    return null;
  }

  static String? required(String? v, [String label = 'Ce champ']) {
    if (v == null || v.trim().isEmpty) return '$label est requis';
    return null;
  }

  static String? price(String? v) {
    if (v == null || v.isEmpty) return 'Prix requis';
    if (double.tryParse(v) == null) return 'Prix invalide';
    if (double.parse(v) <= 0) return 'Prix doit être positif';
    return null;
  }
}