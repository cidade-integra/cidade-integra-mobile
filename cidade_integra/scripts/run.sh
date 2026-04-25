#!/usr/bin/env bash
# ==============================================================================
# run.sh — wrapper para `flutter run|build|test` injetando segredos.
#
# Lê env/secrets.json (gerado por setup_env.sh) e passa para o Flutter via
# --dart-define-from-file, sem que segredos apareçam em histórico de shell.
#
# Exemplos:
#   ./scripts/run.sh                    # equivalente a `flutter run`
#   ./scripts/run.sh -d chrome          # passa flags extras pro flutter
#   ./scripts/run.sh build apk          # `flutter build apk` com segredos
#   ./scripts/run.sh test               # `flutter test` com segredos
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_FILE="$PROJECT_ROOT/env/secrets.json"

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "✗ $SECRETS_FILE não existe." >&2
  echo "  Rode primeiro: ./scripts/setup_env.sh" >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "✗ flutter não encontrado no PATH." >&2
  exit 1
fi

cd "$PROJECT_ROOT"

# Primeiro arg pode ser um subcomando do flutter (build, test, ...).
# Default = run.
sub="run"
if [[ $# -gt 0 && "$1" =~ ^(run|build|test|drive|analyze)$ ]]; then
  sub="$1"; shift
fi

exec flutter "$sub" --dart-define-from-file="$SECRETS_FILE" "$@"
