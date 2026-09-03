#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT
source ${BASH_FUNCTION_DIR}/iterm_fns.sh
source ${BASH_FUNCTION_DIR}/colorscheme_fns.sh

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  if is_iTerm; then
    iterm_profile_set $colors
  fi
}


if is_iTerm; then
  colors=$(iterm_get_profile_name)
  if is_Dark; then
    iterm_profile_set MERM-Selenized-HC-Dark
  else
    iterm_profile_set MERM-Selenized-HC-Light
  fi
fi


if [[ -f ./.prove ]]; then
  find lib t xt examples | entr prove
else
  prove --norc -l --state=all,save t/*.t
fi

