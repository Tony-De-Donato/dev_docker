#!/usr/bin/env bash
set -e
# Pour éviter les problèmes de conversion de chemin avec Git Bash
export MSYS_NO_PATHCONV=1

# ptit clean
docker rm -f demo-db demo-api 2>/dev/null || true
docker network rm demo_front demo_back 2>/dev/null || true

echo "Création des réseaux demo_front et demo_back"
docker network create demo_front
docker network create demo_back

echo -e "\nBuild de demo-api:1.0"
docker build -t demo-api:1.0 ./api

echo -e "\nLancement de demo-db sur le réseau demo_back"
docker run -d --name demo-db \
  --network demo_back \
  -v "$PWD/db/init.sql":/docker-entrypoint-initdb.d/init.sql:ro \
  -e POSTGRES_USER=demo \
  -e POSTGRES_PASSWORD=demo \
  -e POSTGRES_DB=demo \
  postgres:16-alpine

until docker exec demo-db pg_isready -U demo; do
  sleep 1
done

echo -e "\nLancement de demo-api sur le réseau demo_front, puis connection à demo_back"
docker run -d --name demo-api \
  --network demo_front \
  -p 8080:3000 \
  -e PGHOST=demo-db \
  demo-api:1.0

docker network connect demo_back demo-api

sleep 3

echo -e "\n--------------------------------------------------\n"
echo "1. Résolution DNS de demo-db depuis demo-api :"
docker exec demo-api getent hosts demo-db

echo -e "\n--------------------------------------------------\n"
echo "2. Test d'isolation depuis demo_front, on s'attend a ce que ça plante :"
if ! docker run --rm --network demo_front alpine nc -zv demo-db 5432; then
  echo "=> si ce message s'affiche c'est que ça a bien échoué (car il est dans un 'if echec_de_la_commande'), donc l'isolation est faite"
fi

echo -e "\n--------------------------------------------------\n"
echo "3. Adresses IPv4 des conteneurs :"
echo -e "\n--> demo-db :"
# merci d'avoir donné les commande ici, pcq flemme hien
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAMConfig}} {{.IPAddress}}{{"\n"}}{{end}}' demo-db
echo -e "\n--> demo-api :"
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAMConfig}} {{.IPAddress}}{{"\n"}}{{end}}' demo-api

echo -e "\n--------------------------------------------------\n"
echo "4. Réponse de l'API (on fait un curl sur /products) :"
curl -s http://localhost:8080/products
echo ""


echo -e "\n clean final"
docker rm -f demo-db demo-api
docker network rm demo_front demo_back