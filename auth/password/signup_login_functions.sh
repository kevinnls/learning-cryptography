user_db='database.json'
deps=( jo jq md5sum sha256sum sha512sum )

check_deps() {
    for dep in ${deps[@]}; do
	    if ! { command -v ${dep} >/dev/null; } ; then
		    >&2 echo " \`${dep} \` is an unmet dependency"
	    fi
    done
}

# hash_passwd PASSWD
get_uname() {
    read uname
    uname=${uname,}
    if ! [[ "${uname}" =~ ^[a-z]{1}[a-z0-9]{2,}$ ]]; then
	>&2 echo name should begin with a letter and may contain a-z, 0-9
	return 3;
    fi
}

hash_passwd(){
    hashing_algo="${hashing_algo:-sha256}"

    case "${hashing_algo^^}" in
	SHA256)
	    tmp=($( printf '%s' "${1}" | sha256sum ))
	    ;;
	SHA512)
	    tmp=($( printf '%s' "${1}" | sha512sum ))
	    ;;
	MD5)
	    tmp=($( printf '%s' "${1}" | md5sum ))
	    ;;
	* )
	    >&2 echo "invalid/unsupported option for \`hashing_algo\`"
	    return 1
	    ;;
    esac

    echo ${tmp[0]}
    return 0
}

safe_read(){ IFS= read -r -s -n1 -t 15 "${@}" ;}

# get_passwd NAME
get_passwd() {
    if [[ ${#} -ne 1 ]]; then >&2 echo "incorrect usage of get_passwd"; return 1; fi

    local buffer=''
    safe_read char || { >&2 printf "\ntimed out waiting for input"; exit 142; }
    while [[ "${char}" != '' ]]; do
	printf '*'
	buffer+="${char}"
	safe_read char
    done
    printf '\n'

    if [[ ${#buffer} -le 8 ]]; then >&2 echo "password too short"; return 2; fi

    eval $1="$(hash_passwd "${buffer}")"
}
