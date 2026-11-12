#!/bin/sh

# Login to SUDA gateway

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <password>"
  exit 1
fi

username="$1"
password="$2"

if hostname -I >/dev/null 2>&1; then
  all_ips=$(hostname -I)
else
  all_ips=$(ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{ print $2 }')
fi
ips_to_login=""
for ip in $all_ips; do
  if printf '%s\n' "$ip" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    ips_to_login="$ips_to_login $ip"
  fi
done

# Login to the gateway using the given username, password and IPv4 address
login() {
  username="$1"
  password="$2"
  ip="$3"

  url="http://10.9.1.3:801/eportal/?c=Portal&a=login&login_method=1&user_account=%2C0%2C$username&user_password=$password&wlan_user_ip=$ip"
  printf '%s\n' "Trying to login with username=$username and password=$password via IP=$ip..."
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

for ip in $ips_to_login; do
  login "$username" "$password" "$ip"
done
