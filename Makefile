COMPOSE=docker-compose
UP=$(COMPOSE) up -d

start: ## Starts all containers
	$(UP)

stop: ## Stops all containers
	$(COMPOSE) down

sql: ## Starts SQL Server Container
	$(UP) mssql

sqlstop: ## Stops SQL Server Container
	$(UP) --scale mssql=0 mssql

redis: ## Starts Redis Containers
	$(UP) redis readis phpredisadmin

redisstop: ## Stops Redis Containers
	$(UP) --scale redis=0 --scale readis=0 --scale phpredisadmin=0 redis readis phpredisadmin

mongo: ## Starts MongoDB Containers
	$(UP) mongo mongo-express

mongostop: ## Stops MongoDB Containers
	$(UP) --scale mongo=0 --scale mongo-express=0 mongo mongo-express

cassandra: ## Starts Cassandra Container
	$(UP) cassandra

cassandrastop: ## Stops Cassandra Container
	$(UP) --scale cassandra=0 cassandra

neo4j: ## Starts Neo4j Container
	$(UP) neo4j

neo4jstop: ## Stops Neo4j Container
	$(UP) --scale neo4j=0 neo4j

.PHONY: help all stop sql sqlstop

.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
