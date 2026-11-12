#!/bin/sh

# Login to SUDA gateway

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <username> <password> [<ip>]"
  exit 1
fi

username="$1"
password="$2"
ip="$3"

# Login to the gateway using the given username and password
# IP can be specified if your computer has multiple network interfaces, defaults to the first IP address returned by `hostname -I` (Linux) or `ifconfig` (macOS)
login() {
  username="$1"
  password="$2"
  ip="$3"
  if [ -z "$ip" ]; then
    if hostname -I >/dev/null 2>&1; then
      ip=$(hostname -I | cut -d' ' -f1)
    else
      ip=$(ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{ print $2 }' | head -n 1)
    fi
  fi

  url="http://10.9.1.3:801/eportal/?c=Portal&a=login&login_method=1&user_account=%2C0%2C$username&user_password=$password&wlan_user_ip=$ip"
  printf '%s\n' "Trying to login SUDA gateway with username=$username and password=$password via IP=$ip..."
  resp=$(curl -s "$url")

  json_resp=$(printf '%s\n' "$resp" | sed 's/^(//' | sed 's/)$//')

  case "$json_resp" in
  '{"result":"1","msg":"\u8ba4\u8bc1\u6210\u529f"}')
    echo "Login successful"
    ;;
  '{"result":"0",'*'"ret_code":2}')
    echo "Already logged in"
    ;;
  *)
    printf '%s\n' "Error: $json_resp"
    ;;
  esac
}

if curl -s -m 5 'http://10.9.1.3/drcom/chkstatus?callback=x' | grep -q '^[[:space:]]*x({"result":1,'; then
  echo "Already logged in"
  exit 0
fi

login "$username" "$password" "$ip"
