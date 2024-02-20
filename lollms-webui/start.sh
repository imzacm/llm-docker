#!/bin/bash
set -eo pipefail

WEBUI_DIR="/src/lollms-webui"
SERVER_DIR="${WEBUI_DIR}/lollms_core"
LOLLMS_DIR="${SERVER_DIR}/lollms"
DATA_DIR="/workspace/data"
CONFIG_DIR="${DATA_DIR}/configs"

WEBUI_PATH_CFG="${WEBUI_DIR}/global_paths_cfg.yaml"
WEBUI_DEFAULT_CONFIG="${WEBUI_DIR}/configs/config.yaml"
WEBUI_CONFIG="${DATA_DIR}/configs/local_config.yaml"
WEBUI_DEBUG_LOG="${DATA_DIR}/webui-debug.log"

mkdir -p "${DATA_DIR}"

[[ ! -f $WEBUI_PATH_CFG ]] && printf 'lollms_path: %s\nlollms_personal_path: %s\n' "${LOLLMS_DIR}" "${DATA_DIR}" >"${WEBUI_PATH_CFG}"

mkdir -p "${CONFIG_DIR}"
[[ ! -f $WEBUI_CONFIG ]] && cp "${WEBUI_DEFAULT_CONFIG}" "${WEBUI_CONFIG}"

yq -i '.auto_show_browser = false' "${WEBUI_CONFIG}"
WEBUI_HOST="${WEBUI_HOST}" yq -i '.host = strenv(WEBUI_HOST)' "${WEBUI_CONFIG}"
yq -i ".port = $WEBUI_PORT" "${WEBUI_CONFIG}"

# yq -i '.debug = true' "${WEBUI_CONFIG}"
WEBUI_DEBUG_LOG="${WEBUI_DEBUG_LOG}" \
  yq -i '.debug_log_file_path = strenv(WEBUI_DEBUG_LOG)' "${WEBUI_CONFIG}"

# Check if the CPU limit is set
[[ ! $CPU_THREADS ]] && CPU_THREADS=$(nproc)
yq -i ".n_threads = ${CPU_THREADS}" "${WEBUI_CONFIG}"

# Disable auto update for submodules
if [[ "${UPDATE_SUBMODULES}" != true ]]; then
  yq -i '.auto_update = false' "${WEBUI_CONFIG}"
fi

# Activate the python environment and start the web server
source /opt/venv/bin/activate
cd "${WEBUI_DIR}"
python app.py "$@"
