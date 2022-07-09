#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

curPath=`pwd`
rootPath=$(dirname "$curPath")
rootPath=$(dirname "$rootPath")
serverPath=$(dirname "$rootPath")

install_tmp=${rootPath}/tmp/mw_install.pl


apt install -y golang

VERSION=v2.1.6
VERSION_MIN=2.1.6
OS=$(uname | tr '[:upper:]' '[:lower:]')


get_arch() {
	echo "package main
import (
	\"fmt\"
	\"runtime\"
)
func main() { fmt.Println(runtime.GOARCH) }" > /tmp/go_arch.go

	ARCH=$(go run /tmp/go_arch.go)
}

TARGET_DIR="${serverPath}/mtproxy"



get_download_url() {
	DOWNLOAD_URL="https://github.com/9seconds/mtg/releases/download/$VERSION/mtg-${VERSION_MIN}-${OS}-${ARCH}.tar.gz"
}

# download file
download_file() {
    url="${1}"
    destination="${2}"

    printf "Fetching ${url} \n\n"

    if test -x "$(command -v curl)"; then
        code=$(curl --connect-timeout 15 -w '%{http_code}' -L "${url}" -o "${destination}")
    elif test -x "$(command -v wget)"; then
        code=$(wget -t2 -T15 -O "${destination}" --server-response "${url}" 2>&1 | awk '/^  HTTP/{print $2}' | tail -1)
    else
        printf "\e[1;31mNeither curl nor wget was available to perform http requests.\e[0m\n"
        exit 1
    fi

    if [ "${code}" != 200 ]; then
        printf "\e[1;31mRequest failed with code %s\e[0m\n" $code
        exit 1
    else 
	    printf "\n\e[1;33mDownload succeeded\e[0m\n"
    fi
}



Install_app()
{

	mkdir -p ${serverPath}/mtproxy
	mkdir -p ${serverPath}/source/mtproxy

	get_arch
	get_download_url

	DOWNLOAD_FILE="$(mktemp).tar.gz"
	download_file $DOWNLOAD_URL $DOWNLOAD_FILE

	tar -C "$TARGET_DIR" -zxf $DOWNLOAD_FILE
	rm -rf $DOWNLOAD_FILE

	if [ -f ${serverPath}/mtproxy/mtg ];then
		rm -rf ${serverPath}/mtproxy/mtg
	fi

	mv ${serverPath}/mtproxy/mtg-${VERSION_MIN}-${OS}-${ARCH} ${serverPath}/mtproxy/mtg

	# cd ${serverPath}/mtproxy
	# curl -s https://core.telegram.org/getProxySecret -o proxy-secret
	# curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf


	echo "${1}" > ${serverPath}/mtproxy/version.pl
	echo '安装完成' > $install_tmp
		
}

Uninstall_app()
{
	rm -rf ${serverPath}/mtproxy
	echo '卸载完成' > $install_tmp
}

action=$1
if [ "${1}" == 'install' ];then
	Install_app $2
else
	Uninstall_app $2
fi
