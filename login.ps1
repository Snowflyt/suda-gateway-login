param (
    [Parameter(Position = 0)]
    [string]$id,

    [Parameter(Position = 1)]
    [string]$passwd
)


function Login {
    param (
        [string]$username,
        [string]$password,
        [string]$ip
    )

    # 构建 URL
    $url = "http://10.9.1.3:801/eportal/?c=Portal&a=login&login_method=1&user_account=%2C0%2C$username&user_password=$password&wlan_user_ip=$ip"
    
    Write-Host "Trying to login with username=$username and password=$password via IP=$ip..."
    

    try {
        # 获取响应并解析为 PowerShell 对象
        $resp = Invoke-RestMethod -Uri $url -Method Get

        # 如果响应是一个字符串，先去掉括号再解析
        if ($resp.StartsWith('(') -and $resp.EndsWith(')')) {
            $resp = $resp.Substring(1, $resp.Length - 2)
        }
        $json_resp = $resp | ConvertFrom-Json
        if ($json_resp.result -eq 1 -and $json_resp.msg -eq "认证成功") {
            Write-Host "Login successful"
        } elseif ($json_resp.result -eq 0 -and $json_resp.ret_code -eq 2) {
            Write-Host "Already logged in"
        } else {
            Write-Host "Error: $($json_resp | ConvertTo-Json -Depth 5)"
        }
    } catch {
        Write-Host "Error during the request: $_"
    }
}

ipconfig /release
ipconfig /renew

# 获取所有启用的适配器，过滤出 WLAN 适配器
$wlanAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -like "*WLAN*" }

if ($wlanAdapter) {
    # 获取 WLAN 适配器的 IPv4 地址
    $ipv4Address = (Get-NetIPAddress -InterfaceIndex $wlanAdapter.InterfaceIndex -AddressFamily IPv4).IPAddress

    Write-Host "$ipv4Address"
    Login -username "$id" -password "$passwd" -ip "$ipv4Address"

} else {
    Write-Host "No active Wi-Fi adapter found."
}
