services:
  influxdb:
    image: influxdb:2.7.3
    ports:
      - '8086:8086'
      - '8088:8088'
    volumes:
      - "/data/docker-volumes/influxdb/data:/var/lib/influxdb2"
      - "/etc/ssl/myserver:/etc/ssl/myserver"
    environment:
      - INFLUXDB_DB=db0
      - INFLUXDB_ADMIN_USER=${INFLUXDB_USERNAME}
      - INFLUXDB_ADMIN_PASSWORD=${INFLUXDB_PASSWORD}
      - INFLUXD_TLS_CERT=${TLS_CERT}
      - INFLUXD_TLS_KEY=${TLS_KEY}
  grafana:
    image: grafana/grafana:latest
    ports:
      - '3000:3000'
    volumes:
      - "/data/docker-volumes/grafana/data:/var/lib/grafana"
      - "/home/docker-compose/grafana-provisioning:/etc/grafana/provisioning"
      - "/etc/ssl/myserver:/etc/ssl/myserver"
    depends_on:
      - influxdb
    environment:
      - GF_SECURITY_ADMIN_USER=${GRAFANA_USERNAME}
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
      - GF_SERVER_PROTOCOL=https
      - GF_SERVER_CERT_FILE=${TLS_CERT}
      - GF_SERVER_CERT_KEY=${TLS_KEY}
      - GF_SERVER_DOMAIN=url
      - GF_SERVER_ROOT_URL=https://url:3000
