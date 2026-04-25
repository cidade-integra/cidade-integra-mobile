#!/usr/bin/env bash
# ==============================================================================
# run.sh — wrapper para `flutter <subcomando>` injetando segredos.
#
# Lê env/secrets.json (gerado por setup_env.sh) e passa para o Flutter via
# --dart-define-from-file APENAS nos subcomandos que aceitam essa flag.
#
# Exemplos:
#   ./scripts/run.sh                    # flutter run com segredos
#   ./scripts/run.sh -d chrome          # flags extras pro flutter run
#   ./scripts/run.sh build apk          # flutter build apk com segredos
#   ./scripts/run.sh test               # flutter test com segredos
#   ./scripts/run.sh analyze            # flutter analyze (sem segredos — não suporta)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_FILE="$PROJECT_ROOT/env/secrets.json"

if ! command -v flutter >/dev/null 2>&1; then
  echo "✗ flutter não encontrado no PATH." >&2
  exit 1
fi

cd "$PROJECT_ROOT"

# Primeiro arg pode ser um subcomando do flutter. Default = run.
sub="run"
if [[ $# -gt 0 && "$1" =~ ^(run|build|test|drive|analyze|pub|format|clean|doctor)$ ]]; then
  sub="$1"; shift
fi

# Apenas estes subcomandos aceitam --dart-define-from-file.
case "$sub" in
  run|build|test|drive)
    if [[ ! -f "$SECRETS_FILE" ]]; then
      echo "✗ $SECRETS_FILE não existe." >&2
      echo "  Rode primeiro: ./scripts/setup_env.sh" >&2
      exit 1
    fi
    exec flutter "$sub" --dart-define-from-file="$SECRETS_FILE" "$@"
    ;;
  *)
    exec flutter "$sub" "$@"
    ;;
esac
