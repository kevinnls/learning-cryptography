#!/bin/bash
set -e
source ./signup_login_functions.sh
trap 'rm ${user_db}.new 2>/dev/null' ERR INT
check_deps

if ! [[ -e $user_db ]]; then echo '{}' > ${user_db}; fi

printf "create username: "
while ! get_uname uname; do printf "try again: " ; done

if [[ "$(jq .${uname} < ${user_db})" != "null" ]]; then
    >&2 echo account ${uname} exists, try logging in with \`login.sh\`
    >&2 echo or use a different name
    exit 3
fi

printf "create password: "
while ! get_passwd passwd; do printf "try again: " ; done

printf "verify password: "
while ! get_passwd passwd_verify; do printf "try again: " ; done


while [[ "${passwd}" != "${passwd_verify}" ]]; do
    >&2 echo passwords do not match!
    while ! get_passwd passwd_verify; do printf "try again: " ; done
done

echo passwords match! creating new user

jo "${uname}={passwd=${passwd} hash=${hashing_algo}" | jq -s add ${user_db} /dev/stdin >${user_db}.new
mv ${user_db}.new ${user_db}

echo new user ${uname} created

