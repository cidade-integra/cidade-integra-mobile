String mapAuthError(String code) {
  const errors = {
    'user-not-found': 'Usuário não encontrado. Verifique o email.',
    'invalid-credential': 'Credenciais inválidas. Verifique email e senha.',
    'wrong-password': 'Senha incorreta. Tente novamente.',
    'email-already-in-use': 'Este email já está em uso por outra conta.',
    'invalid-email': 'O email informado não é válido.',
    'weak-password': 'A senha deve ter pelo menos 6 caracteres.',
    'popup-closed-by-user': 'Login cancelado pelo usuário.',
    'popup-blocked': 'O popup de login foi bloqueado pelo navegador.',
    'cancelled-popup-request': 'Operação de login cancelada.',
    'account-exists-with-different-credential':
        'Já existe uma conta com este email usando outro método de login.',
    'operation-not-allowed': 'Este método de login não está habilitado.',
    'network-request-failed':
        'Erro de conexão. Verifique sua internet e tente novamente.',
    'too-many-requests':
        'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
    'user-disabled': 'Esta conta foi desativada.',
  };

  return errors[code] ?? 'Erro desconhecido ($code). Tente novamente.';
}
