# suda-gateway-login

一个简单的 Bash 脚本，用于通过命令行直接登录苏州大学网关（校园网），适用于 Linux 与 macOS.

## 使用说明

仓库提供了 [login.sh](./login.sh) 用于登录苏州大学网关，它的使用方法如下：

```bash
bash login.sh <username> <password> [<ip>]
```

其中 `<ip>` 是可选参数，可用于指定用于登录网关的 IPv4 地址（假如你电脑上接了多根网线的话，比如一台 Linux 服务器）。如不指定 `<ip>`，则默认使用 `hostname -I` (Linux) 或 `ipconfig` (macOS) 命令获取的第一个 IPv4 地址。

使用示例如下：

```bash
bash login.sh 2030123456 123456
```

仓库也提供了 [login_all.sh](./login_all.sh)，它会提取 `hostname -I` (Linux) 或 `ipconfig` (macOS) 命令获取的所有 IPv4 地址，然后依次尝试登录网关。使用方法如下：

```bash
bash login_all.sh <username> <password>
```

为了方便使用，你可以下载 [login.sh](./login.sh) 或 [login_all.sh](./login_all.sh) 到你的电脑上，并复制到 `/usr/local/bin` 或 `/usr/bin` 目录下，然后给予执行权限：

```bash
sudo curl -o /usr/local/bin/login_suda_gateway https://raw.githubusercontent.com/Snowflyt/suda-gateway-login/main/login_all.sh
sudo chmod +x /usr/local/bin/login_suda_gateway
```

然后你就可以直接在命令行中使用 `login_suda_gateway` 命令了：

```bash
login_suda_gateway <username> <password>
```

## 这有啥用？

如果你使用一个带图形界面的操作系统，登录校园网不是什么难事——你可以直接打开浏览器，输入用户名和密码登录按钮。但是如果你使用的是一个只有命令行界面的操作系统（比如你们实验室的 Linux 服务器），那么登录校园网就不那么方便了，这就是这个脚本的存在意义。

另外你苏带的校园网经常踢人，尤其是计时收费组，你也可以把这个脚本写到一个定时任务里（比如 Cron），让它每隔一段时间自动登录一次，避免被踢，省去时不时重新登录校园网的麻烦。

## Windows 版本喵？

懒得写 Cmd.exe 或 PowerShell 版本了，毕竟 Windows 用户一般也不会遇到只有命令行界面的情况。不过如果你有需求的话，可以直接参照仓库的脚本自己写一个，原理很简单，就是通过 cURL 发 HTTP 请求而已。
