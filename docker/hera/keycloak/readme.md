for exporting as snapshot current docker container and reimport (and reuse) it, use the following commands:

docker export <container_id> > keycloak.tar
docker import < keycloak.tar img_keycloak

docker run -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin img_keycloak:latest /opt/keycloak/bin/kc.sh start-dev