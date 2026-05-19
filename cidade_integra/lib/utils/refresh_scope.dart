/// Registro global de callback de pull-to-refresh.
///
/// As telas registram seu próprio handler no `initState` e o `BaseLayout`
/// executa esse handler quando o usuário arrasta para baixo.
class RefreshScope {
  RefreshScope._();

  static Future<void> Function()? _handler;

  static void register(Future<void> Function()? handler) {
    _handler = handler;
  }

  static Future<void> trigger() async {
    final h = _handler;
    if (h != null) await h();
  }
}
