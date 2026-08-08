FROM ubuntu:latest
ENV enabled="true"

ENV velocity_version="4.0.0"

ENV servers_ports="25565,25575"

#amount in GB minimum 1Gb
ENV MC_RAM="1" 

ENV port=25565
ENV rcon_port=25575

ENV PROJECT_ID="Vebnzrzj"
ENV MODRINTH_PROJECTS="Vebnzrzj"

WORKDIR /docker

COPY startvel.sh .
RUN sed -i 's/\r//' startvel.sh && apt-get update && apt-get install -y curl openjdk-25-jre jq && chmod +x startvel.sh

EXPOSE ${port}
EXPOSE ${rcon_port}

CMD ["/bin/bash", "./startvel.sh"]

