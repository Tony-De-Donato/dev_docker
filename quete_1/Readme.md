# Rendu quête 1 - De Donato Tony

## Résultat de la commande `\dt`

```text
demo-db=# \dt
          List of relations
 Schema |   Name   | Type  |  Owner
--------+----------+-------+----------
 public | products | table | postgres
(1 row)
```

---

## Résultat du SELECT

```text
demo-db=# SELECT * FROM products;
 id |     name     | price_cents
----+--------------+-------------
  1 | Sticker Démo |         150
(1 row)
```

---

## Les trois dernières lignes de log du conteneur postgres

*(à son lancement j'imagine, sinon c'est juste des erreur résultant de mon incapacité à taper une commande correctement)*

```text
2026-10-06 09:31:21.291 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2026-10-06 09:31:21.303 UTC [57] LOG:  database system was shut down at 2026-10-06 09:31:21 UTC
2026-10-06 09:31:21.314 UTC [1] LOG:  database system is ready to accept connections
```