#! /bin/bash
COOKIE_SECRET=${COOKIE_SECRET:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}

mkdir -p secrets nginx oauth2_proxy

openssl req \
        -x509 \
        -nodes \
        -newkey rsa:$CERT_BITS \
        -keyout ./secrets/key.pem \
        -out ./secrets/cert.pem \
        -days $CERT_DAYS \
        -subj '/'

if [ ! -f ./secrets/dhparam.pem ]
then
	# takes a long to generate
	openssl dhparam \
		-out ./secrets/dhparam.pem \
		$CERT_BITS
fi

cat > ./oauth2_proxy/config << EOF
http_address = "0.0.0.0:80"
https_address = ":443"

redirect_url = "https://$HOST_DOMAIN:$HOST_PORT/oauth2/callback"

upstreams = [
	"http://nginx:80/"
]

request_logging = true

email_domains = [
	"$EMAIL_DOMAIN"
]

client_id = "$CLIENT_ID"
client_secret = "$CLIENT_SECRET"

cookie_name = "_oauth2_proxy"
cookie_secret = "$COOKIE_SECRET"
cookie_domain = "$HOST_DOMAIN"
cookie_expire = "168h"
cookie_refresh = "1h"
cookie_secure = true
cookie_httponly = true
EOF
