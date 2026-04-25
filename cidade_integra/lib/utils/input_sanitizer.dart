class InputSanitizer {
  InputSanitizer._();

  static final _htmlTagRegex = RegExp(r'<[^>]*>');
  static final _scriptRegex = RegExp(
    r'(javascript|on\w+)\s*[:=]',
    caseSensitive: false,
  );
  static final _controlCharRegex = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]');
  static final _multiSpaceRegex = RegExp(r'\s{2,}');
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );
  static final _cepRegex = RegExp(r'^\d{5}-?\d{3}$');

  static const _allowedImageHosts = [
    'fyjefwpyesgedvfuewiw.supabase.co',
    'firebasestorage.googleapis.com',
  ];

  static const blockedWords = [
    'idiota', 'imbecil', 'burro', 'otario', 'otária', 'babaca',
    'retardado', 'retardada', 'vagabundo', 'vagabunda', 'lixo humano',
    'merda', 'porra', 'caralho', 'puta', 'fdp', 'vsf', 'vtnc',
  ];

  /// Remove HTML tags, script patterns, control chars and normalizes whitespace.
  static String sanitize(String input) {
    return input
        .replaceAll(_htmlTagRegex, '')
        .replaceAll(_scriptRegex, '')
        .replaceAll(_controlCharRegex, '')
        .replaceAll(_multiSpaceRegex, ' ')
        .trim();
  }

  /// Validates email format with a robust regex.
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Validates CEP format (00000-000 or 00000000).
  static bool isValidCep(String cep) {
    return _cepRegex.hasMatch(cep.trim());
  }

  /// Checks if text contains any blocked word.
  static bool containsBlockedWords(String text) {
    final lower = text.toLowerCase();
    return blockedWords.any((w) => lower.contains(w));
  }

  /// Returns the URL only if it belongs to an allowed host, otherwise null.
  static String? validateImageUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;
    if (_allowedImageHosts.any((host) => uri.host.contains(host))) return url;
    return null;
  }

  /// Sanitizes and validates an email field. Returns error message or null.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o email';
    if (!isValidEmail(value)) return 'Insira um email válido';
    return null;
  }

  /// Sanitizes and validates a name field. Returns error message or null.
  static String? validateName(String? value, {int min = 3, int max = 60}) {
    if (value == null || value.trim().isEmpty) return 'Preencha seu nome completo';
    final clean = sanitize(value);
    if (clean.length < min) return 'Mínimo $min caracteres';
    if (clean.length > max) return 'Máximo $max caracteres';
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(clean)) {
      return 'O nome deve conter apenas letras e espaços';
    }
    return null;
  }

  /// Validates a text field with min/max and blocked words check.
  static String? validateText(
    String? value, {
    required String fieldName,
    int min = 1,
    int? max,
    bool checkBlocked = false,
  }) {
    if (value == null || value.trim().isEmpty) return 'Informe $fieldName';
    final clean = sanitize(value);
    if (clean.length < min) return 'Mínimo $min caracteres';
    if (max != null && clean.length > max) return 'Máximo $max caracteres';
    if (checkBlocked && containsBlockedWords(clean)) {
      return 'O texto contém palavras inadequadas';
    }
    return null;
  }
}
