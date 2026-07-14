FROM ubuntu:latest

ENV MC_VERSION="1.21.1"

#amount in GB minimum 1Gb
ENV MC_RAM="1" 

ENV port=25565

ENV PROJECT_ID="Vebnzrzj"

WORKDIR /docker

COPY startmc.sh .
RUN sed -i 's/\r//' startmc.sh && apt-get update && apt-get install -y curl openjdk-25-jre jq && chmod +x startmc.sh

EXPOSE ${port}

CMD ["/bin/bash", "./startmc.sh"]

