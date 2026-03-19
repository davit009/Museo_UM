class ProfanityFilter {
  static final List<String> _badWords = [
    // Español (MX)
    'puto', 'puta', 'pendejo', 'pendeja', 'mierda', 'cabron', 'cabrón',
    'pinche', 'verga', 'culo', 'culero', 'joto', 'maricon', 'maricón',
    'chingar', 'chinga', 'chingado', 'chingada', 'chingatumadre',
    'idiota',
    'estupido',
    'estupida',
    'estúpido',
    'estúpida',
    'imbecil',
    'imbécil',
    'zorra',
    'perra',
    'bastardo',
    'ramera',
    'putita',
    'chinga tu madre',
    'puto el que lo lea',
    'gay',
    'lesbiana',
    'homosexual',
    'homosexuales',
    'puñetas',

    // Inglés (US)
    'fuck', 'shit', 'bitch', 'ass', 'asshole', 'dick', 'pussy',
    'bastard', 'slut', 'whore', 'motherfucker', 'cunt', 'fuk', 'fck',
  ];

  /// Normaliza texto (leet + símbolos comunes)
  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('@', 'a')
        .replaceAll('\$', 's')
        .replaceAll('!', 'i');
  }

  /// Convierte una palabra en regex flexible (permite espacios/símbolos entre letras)
  static RegExp _buildFlexibleRegex(String word) {
    final buffer = StringBuffer();

    for (int i = 0; i < word.length; i++) {
      final char = RegExp.escape(word[i]);
      buffer.write(char);

      // Permite separadores entre letras (espacios, símbolos, etc.)
      if (i != word.length - 1) {
        buffer.write(r'[\W_]*');
      }
    }

    return RegExp(buffer.toString(), caseSensitive: false);
  }

  /// Devuelve `true` si encuentra alguna palabra ofensiva
  static bool hasProfanity(String text) {
    if (text.trim().isEmpty) return false;

    final normalizedText = _normalize(text);

    for (String badWord in _badWords) {
      // 1. Match exacto con límites de palabra
      final exactRegex = RegExp(r'\b' + badWord + r'\b', caseSensitive: false);
      if (exactRegex.hasMatch(normalizedText)) {
        return true;
      }

      // 2. Match flexible (evasiones tipo p*to, p u t o, etc.)
      final flexibleRegex = _buildFlexibleRegex(badWord);
      if (flexibleRegex.hasMatch(normalizedText)) {
        return true;
      }
    }

    return false;
  }
}
