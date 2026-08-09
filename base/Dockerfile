FROM ubuntu:latest
ENV enabled="true"

ENV velocity_secret=""
ENV MC_VERSION="1.21.1"

#amount in GB minimum 1Gb
ENV MC_RAM="1" 

ENV reset_paper_config="true"
ENV port=25565
ENV rcon_port=25575

ENV PROJECT_ID="Vebnzrzj"
ENV MODRINTH_PROJECTS="Vebnzrzj"

WORKDIR /docker

COPY startmc.sh .
RUN sed -i 's/\r//' startmc.sh && apt-get update && apt-get install -y curl openjdk-25-jre jq && chmod +x startmc.sh

EXPOSE ${port}
EXPOSE ${rcon_port}

CMD ["/bin/bash", "./startmc.sh"]

