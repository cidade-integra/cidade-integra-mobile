#!/usr/bin/env bash
# ==============================================================================
# setup_env.sh — Cidade Integra
# ------------------------------------------------------------------------------
# Configura segredos locais sem expô-los no código:
#
#   1. Roda `flutterfire configure` → gera lib/firebase_options.dart e baixa
#      google-services.json (Android) + GoogleService-Info.plist (iOS/macOS).
#      Esses arquivos são gitignored.
#
#   2. Pergunta interativamente os 3 segredos restantes e escreve em
#      env/secrets.json (também gitignored), consumido em tempo de compilação
#      via `flutter run --dart-define-from-file=env/secrets.json`.
#
# Uso:
#   ./scripts/setup_env.sh                 # tudo (Firebase + Supabase + Google)
#   ./scripts/setup_env.sh --secrets-only  # pula flutterfire, só atualiza .json
#   ./scripts/setup_env.sh --firebase-only # só roda flutterfire configure
#   ./scripts/setup_env.sh --check         # valida secrets.json
#   ./scripts/setup_env.sh --reset         # apaga secrets.json e recria
# ==============================================================================
set -euo pipefail

# ---------- Cores -------------------------------------------------------------
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
  BOLD=$(tput bold); DIM=$(tput dim); RED=$(tput setaf 1); GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3); BLUE=$(tput setaf 4); CYAN=$(tput setaf 6); RESET=$(tput sgr0)
else
  BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""; RESET=""
fi

# ---------- Paths -------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_DIR="$PROJECT_ROOT/env"
SECRETS_FILE="$ENV_DIR/secrets.json"
EXAMPLE_FILE="$ENV_DIR/secrets.example.json"
FIREBASE_OPTIONS="$PROJECT_ROOT/lib/firebase_options.dart"

# ---------- Helpers -----------------------------------------------------------
banner() {
  echo
  echo "${BOLD}${BLUE}============================================================${RESET}"
  echo "${BOLD}${BLUE}  Cidade Integra — Setup de Segredos Locais${RESET}"
  echo "${BOLD}${BLUE}============================================================${RESET}"
  echo "${DIM}Firebase: gerado por flutterfire configure (gitignored)"
  echo "Supabase + Google: env/secrets.json (gitignored)${RESET}"
  echo
}

info()    { echo "${CYAN}ℹ${RESET}  $*"; }
success() { echo "${GREEN}✓${RESET}  $*"; }
warn()    { echo "${YELLOW}⚠${RESET}  $*"; }
err()     { echo "${RED}✗${RESET}  $*" >&2; }
step()    { echo; echo "${BOLD}${YELLOW}▸ $*${RESET}"; }

read_existing() {
  local key="$1"
  [[ -f "$SECRETS_FILE" ]] || { echo ""; return; }
  python3 - "$SECRETS_FILE" "$key" <<'PY' 2>/dev/null || echo ""
import json, sys
try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
    print(data.get(sys.argv[2], ""))
except Exception:
    print("")
PY
}

mask() {
  local v="$1"; local len=${#v}
  if   [[ $len -eq 0 ]]; then echo "${DIM}(vazio)${RESET}"
  elif [[ $len -le 8 ]]; then echo "${DIM}***${RESET}"
  else echo "${DIM}${v:0:4}…${v: -4}${RESET}"
  fi
}

# ask <KEY> <Label> <secret|plain> [default]
ask() {
  local key="$1"; local label="$2"; local kind="${3:-plain}"; local default_hint="${4:-}"
  local current; current="$(read_existing "$key")"
  local display="$current"
  [[ "$kind" == "secret" && -n "$current" ]] && display="$(mask "$current")"

  echo
  echo "${BOLD}${label}${RESET}  ${DIM}[$key]${RESET}"
  if [[ -n "$current" ]]; then
    echo "  atual: $display"
    read -r -p "  novo valor (Enter mantém): " new || true
    RESULT="${new:-$current}"
  elif [[ -n "$default_hint" ]]; then
    read -r -p "  valor [${DIM}${default_hint}${RESET}]: " new || true
    RESULT="${new:-$default_hint}"
  else
    read -r -p "  valor: " new || true
    RESULT="$new"
  fi
}

# ---------- Pré-checagens -----------------------------------------------------
require_python() {
  command -v python3 >/dev/null 2>&1 || { err "python3 é necessário."; exit 1; }
}

ensure_firebase_cli() {
  if ! command -v firebase >/dev/null 2>&1; then
    err "firebase CLI não encontrado."
    echo "    Instale: ${CYAN}npm install -g firebase-tools${RESET}"
    echo "    Depois rode: ${CYAN}firebase login${RESET}"
    return 1
  fi
  if ! command -v flutterfire >/dev/null 2>&1; then
    err "flutterfire CLI não encontrado."
    echo "    Instale: ${CYAN}dart pub global activate flutterfire_cli${RESET}"
    return 1
  fi
}

# ---------- Etapa Firebase ----------------------------------------------------
run_flutterfire() {
  step "Etapa 1/2 — Firebase via flutterfire configure"

  ensure_firebase_cli || return 1

  if [[ -f "$FIREBASE_OPTIONS" ]]; then
    warn "lib/firebase_options.dart já existe."
    read -r -p "  Reconfigurar? (sobrescreve) [y/N]: " ans || true
    [[ "${ans:-N}" =~ ^[Yy]$ ]] || { info "Pulando flutterfire configure."; return 0; }
  fi

  info "Abrindo seletor interativo do flutterfire..."
  echo "${DIM}  Você vai escolher: projeto Firebase + plataformas (Android/iOS/macOS).${RESET}"
  echo
  ( cd "$PROJECT_ROOT" && flutterfire configure )
  success "Firebase configurado. Arquivos gerados ficam fora do git."
}

# ---------- Etapa Supabase + Google -------------------------------------------
run_secrets() {
  step "Etapa 2/2 — Supabase + Google Sign-In"

  mkdir -p "$ENV_DIR"

  if [[ -f "$SECRETS_FILE" ]]; then
    info "secrets.json existente. Pressione Enter para manter cada valor."
  else
    info "Primeira execução. Vamos preencher 3 valores (+ ViaCEP opcional)."
  fi

  declare -a OUT_KEYS OUT_VALS
  add() { OUT_KEYS+=("$1"); OUT_VALS+=("$RESULT"); }

  ask SUPABASE_URL            "Supabase URL"             plain
  add SUPABASE_URL
  ask SUPABASE_ANON_KEY       "Supabase Anon Key"        secret
  add SUPABASE_ANON_KEY
  ask GOOGLE_SERVER_CLIENT_ID "Google Server Client ID"  plain
  add GOOGLE_SERVER_CLIENT_ID
  ask VIA_CEP_BASE_URL        "ViaCEP Base URL"          plain "https://viacep.com.br/ws"
  add VIA_CEP_BASE_URL

  python3 - "$SECRETS_FILE" "${OUT_KEYS[@]}" "::sep::" "${OUT_VALS[@]}" <<'PY'
import json, sys
out_path = sys.argv[1]
rest = sys.argv[2:]
sep = rest.index("::sep::")
keys = rest[:sep]
vals = rest[sep+1:]
with open(out_path, "w") as f:
    json.dump(dict(zip(keys, vals)), f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

  chmod 600 "$SECRETS_FILE" 2>/dev/null || true
  success "Segredos gravados em ${BOLD}env/secrets.json${RESET} (perm 600)."
}

# ---------- Modo --check ------------------------------------------------------
check_only() {
  if [[ ! -f "$SECRETS_FILE" ]]; then
    err "$SECRETS_FILE não existe. Rode sem --check para criar."; exit 1
  fi
  python3 - "$SECRETS_FILE" "$EXAMPLE_FILE" <<'PY'
import json, sys
with open(sys.argv[1]) as f: cur = json.load(f)
with open(sys.argv[2]) as f: tpl = json.load(f)
missing = [k for k in tpl if not str(cur.get(k, "")).strip()]
if missing:
    print("Faltando ou vazios: " + ", ".join(missing))
    sys.exit(2)
print("OK — todos os segredos preenchidos.")
PY
  if [[ ! -f "$FIREBASE_OPTIONS" ]]; then
    warn "lib/firebase_options.dart não existe — rode com --firebase-only."
  else
    success "firebase_options.dart presente."
  fi
}

# ---------- Main --------------------------------------------------------------
main() {
  require_python
  banner

  case "${1:-}" in
    --check)         check_only; exit 0 ;;
    --secrets-only)  run_secrets ;;
    --firebase-only) run_flutterfire ;;
    --reset)
      [[ -f "$SECRETS_FILE" ]] && rm "$SECRETS_FILE" && info "secrets.json removido."
      run_secrets ;;
    "")              run_flutterfire || true; run_secrets ;;
    *)               err "Flag desconhecida: $1"; exit 1 ;;
  esac

  echo
  echo "${BOLD}Próximos passos:${RESET}"
  echo "  ${CYAN}./scripts/run.sh${RESET}                  # rodar o app"
  echo "  ${CYAN}./scripts/run.sh build apk${RESET}       # build release"
  echo "  ${CYAN}./scripts/setup_env.sh --check${RESET}   # validar"
  echo
}

main "$@"
