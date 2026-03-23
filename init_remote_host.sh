#!/usr/bin/env bash
# init_remote_host.sh
# Runs on the controller machine, optionally installs your local SSH key on the
# target machine, and writes inventory.ini for this repo.

set -euo pipefail

die() { echo "Error: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Required tool '$1' not found."; }

usage() {
  cat <<'EOF'
Usage: ./init_remote_host.sh

Description:
  Runs on the controller machine.
  Prompts for the target host details, optionally installs your local SSH key
  on the target using ssh-copy-id, and writes inventory.ini for this repo.
EOF
}

sanitize_name() {
  local value="${1:-}"
  value="$(printf '%s' "$value" | tr -cs 'A-Za-z0-9._-' '-')"
  value="${value#-}"
  value="${value%-}"
  if [[ -z "$value" ]]; then
    value="ubuntu-target"
  fi
  printf '%s\n' "$value"
}

ensure_local_key() {
  local ssh_dir="$HOME/.ssh"
  local key_path="${ssh_dir}/id_ed25519"

  if [[ -f "$key_path" && -f "${key_path}.pub" ]]; then
    printf '%s\n' "$key_path"
    return 0
  fi

  echo "No local SSH key found at ${key_path}. Generating a new ed25519 key."
  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"
  ssh-keygen -t ed25519 -f "$key_path" -N "" >/dev/null
  printf '%s\n' "$key_path"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

need ssh
need ssh-keygen

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
INVENTORY_FILE="${SCRIPT_DIR}/inventory.ini"

echo "This script runs on the controller machine and prepares inventory.ini for one target machine."
echo

read -rp "Target hostname or IP: " HOST
[[ -n "$HOST" ]] || die "Target hostname or IP is required."

read -rp "SSH username: " USER
[[ -n "$USER" ]] || die "SSH username is required."

read -rp "SSH port [22]: " PORT
PORT="${PORT:-22}"

DEFAULT_NAME="$(sanitize_name "$HOST")"
read -rp "Inventory host name [${DEFAULT_NAME}]: " INVENTORY_NAME
INVENTORY_NAME="${INVENTORY_NAME:-$DEFAULT_NAME}"

read -rp "Install your local SSH public key on the target with ssh-copy-id? [Y/n]: " INSTALL_KEY_REPLY
INSTALL_KEY_REPLY="${INSTALL_KEY_REPLY:-Y}"

if [[ "$INSTALL_KEY_REPLY" =~ ^[Yy]$ ]]; then
  need ssh-copy-id
  KEY_PATH="$(ensure_local_key)"
  echo
  echo "Running ssh-copy-id to install ${KEY_PATH}.pub on ${USER}@${HOST}."
  echo "The target may ask for your password."
  ssh-copy-id -i "${KEY_PATH}.pub" -p "$PORT" -o StrictHostKeyChecking=accept-new "${USER}@${HOST}"
  echo
  echo "Verifying key-based SSH login."
  ssh -p "$PORT" -o StrictHostKeyChecking=accept-new -o BatchMode=yes -o PasswordAuthentication=no "${USER}@${HOST}" 'echo "SSH key login OK on $(hostname)"'
else
  echo
  echo "Skipping ssh-copy-id. Assuming SSH access is already configured."
  echo "Checking SSH connectivity."
  ssh -p "$PORT" -o StrictHostKeyChecking=accept-new "${USER}@${HOST}" 'echo "SSH login OK on $(hostname)"'
fi

TMP_FILE="$(mktemp)"
{
  echo "[ubuntu]"
  printf "%s ansible_host=%s ansible_user=%s" "$INVENTORY_NAME" "$HOST" "$USER"
  if [[ "$PORT" != "22" ]]; then
    printf " ansible_port=%s" "$PORT"
  fi
  printf "\n"
} > "$TMP_FILE"
mv "$TMP_FILE" "$INVENTORY_FILE"

echo
echo "Wrote ${INVENTORY_FILE}:"
cat "$INVENTORY_FILE"

read -rp "Run 'ansible -i inventory.ini ubuntu -m ping' now? [Y/n]: " RUN_PING_REPLY
RUN_PING_REPLY="${RUN_PING_REPLY:-Y}"

if [[ "$RUN_PING_REPLY" =~ ^[Yy]$ ]]; then
  if command -v ansible >/dev/null 2>&1; then
    echo
    ansible -i "$INVENTORY_FILE" ubuntu -m ping
  else
    echo
    echo "Skipping Ansible ping because 'ansible' is not installed on the controller machine yet."
  fi
fi

echo
echo "Next steps on the controller machine:"
echo "  ansible-galaxy collection install -r requirements.yml"
echo "  ./run_install.sh -i inventory.ini -K"
