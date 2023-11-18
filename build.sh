#!/bin/bash

# Define your environment variables here
APP_NAME="avatars.continuum-ai.de"
APP_PORT=3000
DB_CONTAINER_NAME="database"
DB_NAME="main"
DB_USER="main"
DB_PASSWORD="ctACGEEnNe5NHL76qXKYiAwyBht4hRKz743EDFcpzDXXtLU4QBRPZAvVdhDQgrQf"
DB_PORT=5432

git_pull_force() {
	git reset --hard HEAD
	git clean -f -d
	git pull origin main
}

# Zuerst müssen wir neue Änderungen von GitHub pullen.
cd ~/apps/$APP_NAME
git_pull_force;

# Dann bauen wir das Docker Image unserer Application
cd ~/apps/$APP_NAME
docker stop $APP_NAME
docker rm $APP_NAME
docker build -t $APP_NAME .

# Wir legen ein persistent directory an
PERSISTENT_DIR="${HOME}/persistent/avatars.continuum-ai.de";
mkdir -p $PERSISTENT_DIR;

# Wir legen einen .env file für unsere letsencrypt keys an.
rm -f ~/apps/$APP_NAME/.env;
touch ~/apps/$APP_NAME/.env;
echo "PRIVATE_KEY=$(cat /etc/letsencrypt/live/continuum-ai.de/privkey.pem | base64 | tr -d '\n')" >> ~/apps/$APP_NAME/.env;
echo "CERTIFICATE=$(cat /etc/letsencrypt/live/continuum-ai.de/fullchain.pem | base64 | tr -d '\n')" >> ~/apps/$APP_NAME/.env;

# Und starten unsere App wieder.
docker run -d --name $APP_NAME --link $DB_CONTAINER_NAME \
	-v "${PERSISTENT_DIR}:/persistent" \
	-p "${APP_PORT}:80" \
	-e DB_CONNECTION=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_CONTAINER_NAME}:${DB_PORT}/${DB_NAME} \
	-e DB_PORT=${DB_PORT} \
	--env-file ~/apps/${APP_NAME}/.env \
	$APP_NAME;
