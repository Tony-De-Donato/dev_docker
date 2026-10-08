#!/usr/bin/env bash
set -e

# Pour éviter les problèmes de conversion de chemin avec Git Bash
# j'ai galéré bien 30 min la dessus
export MSYS_NO_PATHCONV=1

# Je fais 3 rm ici pour clean avant de lancer le script
docker rm -f demo-db demo-api 2>/dev/null || true
docker network rm demo-net 2>/dev/null || true
docker volume rm demo_pgdata 2>/dev/null || true

docker network create demo-net

docker build -t demo-api:1.0 ./api

docker volume create demo_pgdata

docker run -d --name demo-db --network demo-net -v demo_pgdata:/var/lib/postgresql/data -v "$(pwd)/db/init.sql":/docker-entrypoint-initdb.d/init.sql:ro -e POSTGRES_USER=demo -e POSTGRES_PASSWORD=demo -e POSTGRES_DB=demo postgres:16-alpine

echo "attente du pg_isready"
until docker exec demo-db pg_isready -U demo; do
  sleep 1
done

docker run -d --name demo-api --network demo-net -p 8080:3000 -e PGHOST=demo-db demo-api:1.0

sleep 2

echo -e "\n---------------------------\n"
echo -e "Ajout d'un produit :"
curl -s -X POST -H 'content-type: application/json' -d '{"name":"Casquette Démo","price_cents":1200}' http://localhost:8080/products

echo -e "\n---------------------------\n"
echo -e "Produits en base :"
curl -s http://localhost:8080/products


echo -e "\n\n\n-------------------------------------------------------\n\n\n\n"

echo -e "On suppr le conteneur demo-db pour tester la persistance \n"
docker rm -f demo-db


echo -e "On le re crée"
docker run -d --name demo-db --network demo-net -v demo_pgdata:/var/lib/postgresql/data -v "$(pwd)/db/init.sql":/docker-entrypoint-initdb.d/init.sql:ro -e POSTGRES_USER=demo -e POSTGRES_PASSWORD=demo -e POSTGRES_DB=demo postgres:16-alpine

until docker exec demo-db pg_isready -U demo; do
  sleep 1
done

docker restart demo-api
sleep 2

echo -e "\n---------------------------\n"
echo -e "Liste des volumes"
docker volume ls | grep demo_pgdata

echo -e "\n---------------------------\n"
echo -e "Produits après re création (pour vérifier la persistance)"
curl -s http://localhost:8080/products


echo -e "\n\n\n fin du script"