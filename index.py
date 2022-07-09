# coding:utf-8

import sys
import io
import os
import time

sys.path.append(os.getcwd() + "/class/core")
import mw

app_debug = False
if mw.isAppleSystem():
    app_debug = True


def getPluginName():
    return 'mtproxy'


def getPluginDir():
    return mw.getPluginDir() + '/' + getPluginName()


def getServerDir():
    return mw.getServerDir() + '/' + getPluginName()


def getServiceTpl():
    path = getPluginDir() + "/init.d/" + getPluginName() + ".service.tpl"
    return path


def getConfEnvTpl():
    path = getPluginDir() + "/mt.toml"
    return path


def getConfEnv():
    path = getServerDir() + "/mt.toml"
    return path


def getArgs():
    args = sys.argv[2:]
    tmp = {}
    args_len = len(args)

    if args_len == 1:
        t = args[0].strip('{').strip('}')
        t = t.split(':')
        tmp[t[0]] = t[1]
    elif args_len > 1:
        for i in range(len(args)):
            t = args[i].split(':')
            tmp[t[0]] = t[1]

    return tmp


def status():
    data = mw.execShell(
        "ps -ef|grep mtproxy |grep -v grep | grep -v python  | awk '{print $2}'")

    if data[0] == '':
        return 'stop'
    return 'start'


def getServiceFile():
    return '/usr/lib/systemd/system/mtproxy.service'


def initDreplace():

    envTpl = getConfEnvTpl()
    dstEnv = getConfEnv()
    secret = mw.execShell('head -c 16 /dev/urandom | xxd -ps')
    if not os.path.exists(env):
        env_content = mw.readFile(envTpl)
        env_content = env_content.replace('{$PROT}', '8349')
        env_content = env_content.replace('{$SECRET}', secret[0].strip())
        mw.writeFile(dstEnv, env_content)

    # systemd
    systemDir = '/usr/lib/systemd/system'
    systemService = systemDir + '/mtproxy.service'
    systemServiceTpl = getServiceTpl()
    if os.path.exists(systemDir) and not os.path.exists(systemService):
        service_path = mw.getServerDir()
        se_content = mw.readFile(systemServiceTpl)
        se_content = se_content.replace('{$SERVER_PATH}', service_path)
        mw.writeFile(systemService, se_content)
        mw.execShell('systemctl daemon-reload')

    return file_bin


def mtOp(method):
    file = initDreplace()

    if not mw.isAppleSystem():
        data = mw.execShell('systemctl ' + method + ' mtproxy')
        if data[1] == '':
            return 'ok'
        return 'fail'

    return 'fail'


def start():
    return mtOp('start')


def stop():
    return mtOp('stop')


def restart():
    return mtOp('restart')


def reload():
    return redisOp('reload')


def initdStatus():
    if mw.isAppleSystem():
        return "Apple Computer does not support"

    shell_cmd = 'systemctl status mtproxy | grep loaded | grep "enabled;"'
    data = mw.execShell(shell_cmd)
    if data[0] == '':
        return 'fail'
    return 'ok'


def initdInstall():
    if mw.isAppleSystem():
        return "Apple Computer does not support"

    mw.execShell('systemctl enable mtproxy')
    return 'ok'


def initdUinstall():

    if mw.isAppleSystem():
        return "Apple Computer does not support"

    mw.execShell('systemctl disable mtproxy')
    return 'ok'

if __name__ == "__main__":
    func = sys.argv[1]
    if func == 'status':
        print(status())
    elif func == 'start':
        print(start())
    elif func == 'stop':
        print(stop())
    elif func == 'restart':
        print(restart())
    elif func == 'reload':
        print(reload())
    elif func == 'initd_status':
        print(initdStatus())
    elif func == 'initd_install':
        print(initdInstall())
    elif func == 'initd_uninstall':
        print(initdUinstall())
    elif func == 'conf':
        print(getServiceFile())
    elif func == 'conf_env':
        print(getConfEnv())
    else:
        print('error')
