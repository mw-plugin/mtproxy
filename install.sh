#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

curPath=`pwd`
rootPath=$(dirname "$curPath")
rootPath=$(dirname "$rootPath")
serverPath=$(dirname "$rootPath")

install_tmp=${rootPath}/tmp/mw_install.pl

Install_app()
{

	mkdir -p ${serverPath}/mtproxy
	mkdir -p ${serverPath}/source/mtproxy

	cd ${serverPath}/source/mtproxy
	git clone https://github.com/TelegramMessenger/MTProxy
	cd MTProxy && make && cd objs/bin

	${serverPath}/mtproxy
	curl -s https://core.telegram.org/getProxySecret -o proxy-secret
	curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf


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
