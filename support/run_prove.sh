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


prove_dirs='t '

while [[ "$#" -gt 0 ]]; do
  if [[ "$1" == '--verbose' ]]; then
    prove_args+=' --verbose'
  elif [[ "$1" == '--author' ]]; then
    export AUTHOR_TESTING=1
    prove_dirs+='xt '
  fi
  shift
done
if [[ -f ./.prove ]]; then
  find lib t xt examples | entr prove $prove_dirs
else
  prove --norc -l --state=all,save t/*.t xt/*.t
fi

