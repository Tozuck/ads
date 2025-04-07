#!/bin/bash

echo_info() {
  echo -e "\033[1;32m[INFO]\033[0m $1"
}
echo_error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
  exit 1
}

apt-get update; apt-get install curl socat git nload -y

if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh || echo_error "Docker installation failed."
else
  echo_info "Docker is already installed."
fi

rm -r Marzban-node

git clone https://github.com/Gozargah/Marzban-node

rm -r /var/lib/marzban-node

mkdir /var/lib/marzban-node

rm ~/Marzban-node/docker-compose.yml

cat <<EOL > ~/Marzban-node/docker-compose.yml
services:
  marzban-node:
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host
    environment:
      SSL_CERT_FILE: "/var/lib/marzban-node/ssl_cert.pem"
      SSL_KEY_FILE: "/var/lib/marzban-node/ssl_key.pem"
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert.pem"
      SERVICE_PROTOCOL: "rest"
    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
EOL

rm /var/lib/marzban-node/ssl_client_cert.pem

cat <<EOL > /var/lib/marzban-node/ssl_client_cert.pem
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjUwMzI2MDEyNTE4WhgPMjEyNTAzMDIwMTI1MThaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAq7fBn3fT3KfX
a4crVlTrCDD3zbmX2kHOiXfSaNWj7wXEMQbtwMG2yEUbbT1I7V0F4grb1YNYHJyf
bmFXR7XpSuBzcnCJnetmBLuMD+STxrZArZdce3TXmcY/f2z+jO/KixzE3CqbCkoX
p+GxJ8BvYFnmNgy/zabQu3f5FyxMUslvqbdcAjh73SFy/8WJrS4+I1w7RkiWjOeZ
9BcoK/6XMl7YqBXqXCokp+3mCnDZDHzjrmoetwFV7FLaQnDUiXMoLI+3sux+wD3t
vOiueTU5SW2AHHrQrg/ADVpbT2wrs3uRmkxlqxa3sXxFAPxHc4PSol/0KRCq33Ce
xDubN9d8GqBfgzg+gc4taTljbOL59Ix1mwd8ztCH69jGKeH6ebcU8O0YoQU+ip97
qqlmKHGESzbOdnmSdS1iSuBRG7DbwFZFdxzbgP5v03kog6l/71D+ZvTH6odG5N1H
CdMBy4ENUUdSb1sKaQTsZAaCCtQ+hKY6M2u1jvIsa+NUTorO20UNEUqNuEoGUrYg
39YF2GA+/PiKHmnqflBW9CzBe5CzOUH7rBb3C2zYd0lpru/ObE4qt16F3sMRKhY+
0epmnxnwazXl8e+ohlw3hVDql7uMQn2J+QDIkYxMOBEYMMVlcdrj6Mhb/u5940MP
GdwMkBP3rEdxmxI4GjZxvTj0n729UxECAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
V29R53f5Qa+8lKuX04yXlWfoYrPYsYbZEoqZsepbD03Sxe5EtWY0E5Kk9c0deGx9
BP8SwA0Ky8BuiHA7v5rkilFzhvCaQG1KmhWOj+Mue7VtPYRiWiRvyB6L96gUSuQU
gj9PTuACIUahE9iRbwEePcc0ldhXCT1UI/2QpVJY8kEsNYbFRWU+MIH3XRZ5x9qS
tHfCwAWh8Wv6kiaA3qlwXZuvP5nMDw3EQTJSAVdDS2bmhzLv+1dBEa8CU4YNxx4p
psbCWTmGaM2AiYDBWPASpoHmDDNxZZlLajyhVDLUWEABzE/dOugDWkc2t/E1B1PZ
N/thPb9xDsarKNrOZd9Xh4+BspvrReIB2wzxOMWPue3fygwXvRfaF34y8+h1koY8
2i4j1gf+BXAX9zEEmRpix/Wi6DNw79ADSOeK7eT5HHytN/ePOrz2hgMhrywbQNL/
HE4MKDJ8/3ozlNNyXNKSjtyRyYJukojHtg3vz2JthNh0KL/3Fyk2VBtoCdvdw0Oa
4z/Vsb7AvkGlMq4tivgFm63gC7UFKEsCA9aTfgmOgRo0lk9gcjCCoAY029LaA3x8
vhXXvERdXSqENTLhLlUCqj3r9piG2AHyT71k0V6ari9kKsiQH6X+7Q9lcAvnsdBT
jWBl029n0R9LEb1/W1xreC5HxW5Jl0XCuNyRhGKya5c=
-----END CERTIFICATE-----
EOL

cd ~/Marzban-node
docker compose up -d

echo_info "Finalizing UFW setup..."

ufw allow 22
ufw allow 80
ufw allow 2096
ufw allow 2053
ufw allow 62050
ufw allow 62051

ufw --force enable
ufw reload
