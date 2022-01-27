Bases de données avancées
=========================

Ce dépôt contient des ressources à destination des étudiants de seconde année de DUT Informatique à l'IUT d'Amiens en spécialité bases de données avancées.

Utilisation
-----------

### UNIX / WSL2

Sous unix ou wsl2, vous pouvez utiliser la commande `make` pour démarrer et arrêter les conteneurs, vous pouvez consulter les commandes disponibles avec `make` ou `make help`.

> Vous aurez peut-être besoin d'installer make

#### SQL Server

| Action               | Commande           |
|----------------------|--------------------|
| Démmarer le SGBD     | `make start-sql`   |
| Arrêter le SGBD      | `make stop-sql`    |
| Se connecter au SGBD | `make connect-sql` |

#### Redis

| Action               | Commande             |
|----------------------|----------------------|
| Démmarer le SGBD     | `make start-redis`   |
| Arrêter le SGBD      | `make stop-redis`    |
| Se connecter au SGBD | `make connect-redis` |

#### MongoDB

| Action               | Commande             |
|----------------------|----------------------|
| Démmarer le SGBD     | `make start-mongo`   |
| Arrêter le SGBD      | `make stop-mongo`    |
| Se connecter au SGBD | `make connect-mongo` |

#### Cassandra

| Action               | Commande                 |
|----------------------|--------------------------|
| Démmarer le SGBD     | `make start-cassandra`   |
| Arrêter le SGBD      | `make stop-cassandra`    |
| Se connecter au SGBD | `make connect-cassandra` |

#### Neo4j

| Action               | Commande                       |
|----------------------|--------------------------------|
| Démmarer le SGBD     | `make start-neo4j`             |
| Arrêter le SGBD      | `make stop-neo4j`              |
| Se connecter au SGBD | [Neo4j](http://127.0.0.1:7474) |

### Tous systèmes

L'ensemble des SGBD que l'on va utiliser sont portés sous docker, nous allons pour utiliser la commande `docker-compose` pour les démarrés et arrêtés à notre guide, ainsi que pour lancer des shells pour s'y connecter.

#### SQL Server

| Action               | Commande                                     |
|----------------------|----------------------------------------------|
| Démmarer le SGBD     | `docker-compose up -d mssql`                 |
| Arrêter le SGBD      | `docker-compose up -d --scale mssql=0 mssql` |
| Se connecter au SGBD | `docker-compose run sqlcmd`                  |

#### Redis

| Action               | Commande                                                                                                   |
|----------------------|------------------------------------------------------------------------------------------------------------|
| Démmarer le SGBD     | `docker-compose up -d redis readis phpredisadmin`                                                          |
| Arrêter le SGBD      | `docker-compose up -d --scale redis=0 --scale readis=0 --scale phpredisadmin=0 redis readis phpredisadmin` |
| Se connecter au SGBD | `docker-compose run rcli`                                                                                  |

#### MongoDB

| Action               | Commande                                                                           |
|----------------------|------------------------------------------------------------------------------------|
| Démmarer le SGBD     | `docker-compose up -d mongo mongo-express`                                         |
| Arrêter le SGBD      | `docker-compose up -d --scale mongo=0 --scale mongo-express=0 mongo mongo-express` |
| Se connecter au SGBD | `docker-compose run mgcli`                                                         |

#### Cassandra

| Action               | Commande                                             |
|----------------------|------------------------------------------------------|
| Démmarer le SGBD     | `docker-compose up -d cassandra`                     |
| Arrêter le SGBD      | `docker-compose up -d --scale cassandra=0 cassandra` |
| Se connecter au SGBD | `docker-compose run cqlsh`                           |

#### Neo4j

| Action               | Commande                                     |
|----------------------|----------------------------------------------|
| Démmarer le SGBD     | `docker-compose up -d neo4j`                 |
| Arrêter le SGBD      | `docker-compose up -d --scale neo4j=0 neo4j` |
| Se connecter au SGBD | [Neo4j](http://127.0.0.1:7474)               |

Outils
------

Nous avons à disposition plusieurs IHM en mode web pour différents SGBDs

| SGBD       | Lien                                                                       |
|------------|----------------------------------------------------------------------------|
| Redis      | [Readis](http://127.0.0.1:8080/) - [phpRedisAdmin](http://127.0.0.1:8081/) |
| MongoDB    | [MongoExpress](http://127.0.0.1:8082)                                      |
| Neo4j      | [Neo4j](http://127.0.0.1:7474)                                             |
| Postgres   | [Adminer](http://127.0.0.1:8083)                                           |
