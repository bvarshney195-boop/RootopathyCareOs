#!/bin/sh
set -eu

backend_hostport="${BACKEND_HOSTPORT:-backend:8080}"
backend_host="${backend_hostport%:*}"
backend_port="${backend_hostport##*:}"

if [ "$backend_host" = "$backend_hostport" ] || [ -z "$backend_host" ]; then
  echo "BACKEND_HOSTPORT must use host:port form" >&2
  exit 1
fi

case "$backend_host" in
  *[!A-Za-z0-9._-]*)
    echo "BACKEND_HOSTPORT contains an invalid host" >&2
    exit 1
    ;;
esac

case "$backend_port" in
  ''|*[!0-9]*)
    echo "BACKEND_HOSTPORT contains an invalid port" >&2
    exit 1
    ;;
esac

if [ "$backend_port" -lt 1 ] || [ "$backend_port" -gt 65535 ]; then
  echo "BACKEND_HOSTPORT port is outside 1-65535" >&2
  exit 1
fi

if [ "${RENDER:-false}" = "true" ]; then
  forwarded_proto="https"
else
  forwarded_proto='$scheme'
fi

mkdir -p /tmp/nginx-conf
sed \
  -e "s|__BACKEND_HOSTPORT__|${backend_host}:${backend_port}|g" \
  -e "s|__FORWARDED_PROTO__|${forwarded_proto}|g" \
  /etc/careos/default.conf.template \
  > /tmp/nginx-conf/default.conf

exec nginx -g 'daemon off;'
