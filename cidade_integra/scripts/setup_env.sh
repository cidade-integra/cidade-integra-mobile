#!/usr/bin/env bash
# ==============================================================================
# setup_env.sh — Cidade Integra
# ------------------------------------------------------------------------------
# Configura segredos locais (Firebase + Supabase) sem expô-los no código.
#
# O script é interativo: pergunta cada valor, oferece manter o valor atual
# (se já existir) e gera o arquivo env/secrets.json — que está no .gitignore.
#
# Uso:
#   ./scripts/setup_env.sh           # modo interativo
#   ./scripts/setup_env.sh --check   # apenas valida o arquivo existente
#   ./scripts/setup_env.sh --reset   # apaga e recria do zero
# ==============================================================================
set -euo pipefail

# ---------- Cores (graceful fallback se terminal não suportar) ----------------
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

# ---------- Helpers -----------------------------------------------------------
banner() {
  echo
  echo "${BOLD}${BLUE}============================================================${RESET}"
  echo "${BOLD}${BLUE}  Cidade Integra — Setup de Segredos Locais${RESET}"
  echo "${BOLD}${BLUE}============================================================${RESET}"
  echo "${DIM}Os valores ficam em ${SECRETS_FILE/$PROJECT_ROOT\//}"
  echo "Esse arquivo está no .gitignore — NUNCA será commitado.${RESET}"
  echo
}

info()    { echo "${CYAN}ℹ${RESET}  $*"; }
success() { echo "${GREEN}✓${RESET}  $*"; }
warn()    { echo "${YELLOW}⚠${RESET}  $*"; }
err()     { echo "${RED}✗${RESET}  $*" >&2; }

# Lê um valor do JSON existente (se houver). Usa python3 para parse seguro.
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

# Mostra uma versão mascarada de um segredo (primeiros 4 + últimos 4)
mask() {
  local v="$1"
  local len=${#v}
  if [[ $len -eq 0 ]]; then echo "${DIM}(vazio)${RESET}"
  elif [[ $len -le 8 ]]; then echo "${DIM}***${RESET}"
  else echo "${DIM}${v:0:4}…${v: -4}${RESET}"
  fi
}

# Pergunta um valor. Argumentos:
#   $1 = chave JSON     $2 = label amigável     $3 = "secret" | "plain"
#   $4 = (opcional) valor default sugerido se não houver atual
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
    if [[ -z "$new" ]]; then
      RESULT="$current"
    else
      RESULT="$new"
    fi
  else
    if [[ -n "$default_hint" ]]; then
      read -r -p "  valor [${DIM}${default_hint}${RESET}]: " new || true
      RESULT="${new:-$default_hint}"
    else
      read -r -p "  valor: " new || true
      RESULT="$new"
    fi
  fi
}

# Escreve um par chave/valor JSON-safe
emit() {
  local key="$1"; local val="$2"
  python3 - "$key" "$val" <<'PY'
import json, sys
print(f'  {json.dumps(sys.argv[1])}: {json.dumps(sys.argv[2])}', end='')
PY
}

# ---------- Pré-checagens -----------------------------------------------------
require_python() {
  if ! command -v python3 >/dev/null 2>&1; then
    err "python3 é necessário para gerar/ler JSON com segurança."
    exit 1
  fi
}

ensure_gitignore() {
  local gi="$PROJECT_ROOT/.gitignore"
  if [[ -f "$gi" ]] && ! grep -qE '(^|/)env/secrets\.json$|^env/$' "$gi"; then
    warn "env/secrets.json não está no .gitignore — adicione manualmente."
  fi
}

# ---------- Modo --check ------------------------------------------------------
check_only() {
  if [[ ! -f "$SECRETS_FILE" ]]; then
    err "Arquivo $SECRETS_FILE não existe. Rode sem --check para criar."
    exit 1
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
  success "Arquivo válido."
}

# ---------- Fluxo principal ---------------------------------------------------
main() {
  require_python
  banner

  case "${1:-}" in
    --check) check_only; exit 0 ;;
    --reset)
      [[ -f "$SECRETS_FILE" ]] && rm "$SECRETS_FILE"
      info "secrets.json removido. Recriando..."
      ;;
    "" ) : ;;
    * ) err "Flag desconhecida: $1"; exit 1 ;;
  esac

  mkdir -p "$ENV_DIR"

  if [[ -f "$SECRETS_FILE" ]]; then
    info "Arquivo existente detectado. Pressione Enter para manter cada valor atual."
  else
    info "Primeira execução. Vamos preencher cada segredo."
  fi

  declare -a OUT_KEYS OUT_VALS

  add() { OUT_KEYS+=("$1"); OUT_VALS+=("$RESULT"); }

  echo
  echo "${BOLD}${YELLOW}── Supabase ─────────────────────────────────────${RESET}"
  ask SUPABASE_URL          "Supabase URL"           plain
  add SUPABASE_URL
  ask SUPABASE_ANON_KEY     "Supabase Anon Key"      secret
  add SUPABASE_ANON_KEY

  echo
  echo "${BOLD}${YELLOW}── Google Sign-In ───────────────────────────────${RESET}"
  ask GOOGLE_SERVER_CLIENT_ID "Google Server Client ID" plain
  add GOOGLE_SERVER_CLIENT_ID

  echo
  echo "${BOLD}${YELLOW}── Firebase (geral) ─────────────────────────────${RESET}"
  ask FIREBASE_PROJECT_ID            "Project ID"            plain "cidadeintegra"
  add FIREBASE_PROJECT_ID
  ask FIREBASE_MESSAGING_SENDER_ID   "Messaging Sender ID"   plain
  add FIREBASE_MESSAGING_SENDER_ID
  ask FIREBASE_STORAGE_BUCKET        "Storage Bucket"        plain
  add FIREBASE_STORAGE_BUCKET

  echo
  echo "${BOLD}${YELLOW}── Firebase (Android) ───────────────────────────${RESET}"
  ask FIREBASE_ANDROID_API_KEY    "Android API Key"    secret
  add FIREBASE_ANDROID_API_KEY
  ask FIREBASE_ANDROID_APP_ID     "Android App ID"     plain
  add FIREBASE_ANDROID_APP_ID
  ask FIREBASE_ANDROID_CLIENT_ID  "Android Client ID"  plain
  add FIREBASE_ANDROID_CLIENT_ID

  echo
  echo "${BOLD}${YELLOW}── Firebase (iOS) ───────────────────────────────${RESET}"
  ask FIREBASE_IOS_API_KEY    "iOS API Key"    secret
  add FIREBASE_IOS_API_KEY
  ask FIREBASE_IOS_APP_ID     "iOS App ID"     plain
  add FIREBASE_IOS_APP_ID
  ask FIREBASE_IOS_CLIENT_ID  "iOS Client ID"  plain
  add FIREBASE_IOS_CLIENT_ID
  ask FIREBASE_IOS_BUNDLE_ID  "iOS Bundle ID"  plain "com.example.cidadeIntegra"
  add FIREBASE_IOS_BUNDLE_ID

  echo
  echo "${BOLD}${YELLOW}── Firebase (macOS) ─────────────────────────────${RESET}"
  ask FIREBASE_MACOS_API_KEY  "macOS API Key"  secret
  add FIREBASE_MACOS_API_KEY
  ask FIREBASE_MACOS_APP_ID   "macOS App ID"   plain
  add FIREBASE_MACOS_APP_ID

  echo
  echo "${BOLD}${YELLOW}── Outras APIs ──────────────────────────────────${RESET}"
  ask VIA_CEP_BASE_URL  "ViaCEP Base URL"  plain  "https://viacep.com.br/ws"
  add VIA_CEP_BASE_URL

  # ---------- Gera JSON com python (escape correto) ---------------------------
  python3 - "$SECRETS_FILE" "${OUT_KEYS[@]}" "::sep::" "${OUT_VALS[@]}" <<'PY'
import json, sys
out_path = sys.argv[1]
rest = sys.argv[2:]
sep = rest.index("::sep::")
keys = rest[:sep]
vals = rest[sep+1:]
data = dict(zip(keys, vals))
with open(out_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

  chmod 600 "$SECRETS_FILE" 2>/dev/null || true
  ensure_gitignore

  echo
  success "Segredos gravados em ${BOLD}${SECRETS_FILE/$PROJECT_ROOT\//}${RESET}"
  info "Permissões: $(stat -f '%Sp' "$SECRETS_FILE" 2>/dev/null || stat -c '%a' "$SECRETS_FILE")"
  echo
  echo "${BOLD}Próximos passos:${RESET}"
  echo "  ${CYAN}./scripts/run.sh${RESET}              # rodar o app"
  echo "  ${CYAN}./scripts/run.sh build apk${RESET}   # build com os segredos"
  echo "  ${CYAN}./scripts/setup_env.sh --check${RESET}  # validar"
  echo
}

main "$@"
