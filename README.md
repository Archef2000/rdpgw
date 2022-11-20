# RDPGW docker container
A easy setup of the rdpgw docker container from [bolkedebruin](https://github.com/bolkedebruin/rdpgw).

# Docker Compose
```
version: '3.3'
services:
  rdpgw:
    container_name: rdpgw
    image: archef2000/rdpgw
    environment:
      - 'SES_KEY=thisisasessionkeyreplacethisjetzt'
      - 'SES_ENC=thisisasessionkeyreplacethisnunu!'
      - 'PAA_SIG=thisisasessionkeyreplacethisjetzt'
      - 'PAA_ENC=thisisasessionkeyreplacethisjetzt'
      - 'OIDC_URL=http://keycloak:8080/auth/realms/rdpgw'
      - 'OIDC_ID=rdpgw'
      - 'OIDC_SEC=01cd304c-6f43-4480-9479-618eb6fd578f'
      - 'GW_ADD=localhost:9443'
      - 'LISTEN_PORT=9443'
      - 'AUTH=OIDC'
      - 'ALLOWED_HOSTS=xrdp:3389'
    ports:
      - '9443:9443/tcp'
    restart: on-failure
```

# Docker run
```
docker run -d \
	-e SES_KEY=thisisasessionkeyreplacethisjetzt \
	-e SES_ENC=thisisasessionkeyreplacethisnunu! \
	-e PAA_SIG=thisisasessionkeyreplacethisjetzt \
	-e PAA_ENC=thisisasessionkeyreplacethisjetzt \
	-e OIDC_URL="http://keycloak:8080/auth/realms/rdpgw" \
	-e OIDC_ID="rdpgw" \
	-e OIDC_SEC="01cd304c-6f43-4480-9479-618eb6fd578f" \
	-e GW_ADD=localhost:9443 \
	-e LISTEN_PORT=9443 \
	-e AUTH=OIDC \
	-e ALLOWED_HOSTS=xrdp:3389 \
	-p 9443:9443/tcp \
	--restart=on-failure \
	--name rdpgw \
	archef2000/rdpgw
```

# Variables,
## Environment Variables
| Variable | Required | Function | Example |
|----------|----------|----------|----------|
|`SES_KEY`|yes|Sets the SessionKey in the config file.|`SES_KEY=thisisasessionkeyreplacethisjetzt`|
|`SES_ENC`|yes|Sets the SessionEncryptionKey in the config file.|`SES_ENC=thisisasessionkeyreplacethisnunu!`|
|`PAA_SIG`|yes|Sets the PAATokenSigningKey in the config file.|`PAA_SIG=thisisasessionkeyreplacethisjetzt`|
|`PAA_ENC`|yes|Sets the PAATokenEncryptionKey in the config file.|`PAA_ENC=thisisasessionkeyreplacethisjetzt`|
|`OIDC_URL`|yes|If AUTH is set to OIDC this sets the AUTH entpoint.|`OIDC_URL="http://keycloak:8080/auth/realms/rdpgw"`|
|`OIDC_ID`|yes|OIDC Client ID.|`OIDC_ID="rdpgw"`|
|`OIDC_SEC`|yes|OIDC AUTH secret.|`OIDC_SEC="01cd304c-6f43-4480-9479-618eb6fd578f"`|
|`GW_ADD`|yes||`GW_ADD=localhost:9443`|
|`ALLOWED_HOSTS`|yes||`ALLOWED_HOSTS="xrdp:3389,xrdp2:3389"`|
|`LISTEN_PORT`|no||`LISTEN_PORT=9443`|
|`AUTH`|no||`AUTH=OIDC`|

## Ports
| Port | Proto | Required | Function | Example |
|----------|----------|----------|----------|----------|
| `9443` | TCP | Yes | rdpgw server TCP listening port | `9443:9443/tcp`|





