FROM ubuntu:latest
ENV enabled="true"

ENV velocity_version="4.0.0"
ENV MC_VERSION="1.21.11"

ENV reset_toml="true"

ENV servers_ports="survival:25567,creative:25566"

#amount in GB minimum 1Gb
ENV MC_RAM="1" 

ENV server_port=25565
ENV rcon_port=25575

ENV PROJECT_ID="Vebnzrzj"
ENV MODRINTH_PROJECTS="Vebnzrzj"

WORKDIR /docker

COPY startvel.sh .
RUN sed -i 's/\r//' startvel.sh && apt-get update && apt-get install -y curl openjdk-25-jre jq && chmod +x startvel.sh

EXPOSE ${port}
EXPOSE ${rcon_port}

CMD ["/bin/bash", "./startvel.sh"]

