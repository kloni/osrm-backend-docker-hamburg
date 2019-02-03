# Image to prepare the map data

FROM osrm/osrm-backend as preparationStage

RUN apt-get update && apt-get -y --no-install-recommends install wget

RUN mkdir /data

WORKDIR /data

RUN wget http://download.geofabrik.de/europe/germany/hamburg-latest.osm.pbf

RUN /usr/local/bin/osrm-extract -p /opt/car.lua /data/hamburg-latest.osm.pbf

RUN /usr/local/bin/osrm-partition /data/hamburg-latest.osrm

RUN /usr/local/bin/osrm-customize /data/hamburg-latest.osrm

RUN rm hamburg-latest.osm.pbf


# Image to run the service

FROM osrm/osrm-backend

COPY --from=preparationStage /data/. /data/.

CMD ["/usr/local/bin/osrm-routed",  "--algorithm", "mld",  "/data/hamburg-latest.osrm"]

EXPOSE 5000
