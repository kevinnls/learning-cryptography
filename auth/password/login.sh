#!/bin/bash

set -e
source ./signup_login_functions.sh
check_deps

printf 'enter your username: '
while ! get_uname uname; do printf '\ntry again: ' ; done

hashing_algo="$(jq -r ".${uname}.hashalg" "${user_db}" 2>/dev/null || echo sha256)"
printf 'enter your password: '
while ! get_passwd passwd; do printf '\ntry again: ' ; done

if [[ "$(jq -r ".${uname}.passwd" ${user_db} )" == "${passwd}" ]] ; then
    echo "you are totally logged in!"
    exit 0
fi

>&2 echo user credentials mismatch
exit 9
