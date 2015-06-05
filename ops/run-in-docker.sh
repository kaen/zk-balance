#!/bin/bash
docker build --tag=zk-balance .
docker kill zk-balance
docker kill zk-balance-postgres
docker rm zk-balance
docker rm zk-balance-postgres
docker run --name=zk-balance-postgres -p=5432 -e POSTGRES_PASSWORD=mysecretpassword -e POSTGRES_USER=zk-balance -d postgres
sleep 3
docker run --name=zk-balance -e POSTGRES_PASSWORD=mysecretpassword -e POSTGRES_USER=zk-balance --link zk-balance-postgres:postgres -p 1337 --rm zk-balance
