FROM ubuntu:latest

ENV MC_VERSION="1.21.1"

#amount in GB minimum 1Gb
ENV MC_RAM="1" 

WORKDIR /docker

COPY startmc.sh .
RUN sed -i 's/\r//' startmc.sh && apt-get update && apt-get install -y curl openjdk-21-jdk jq && chmod +x startmc.sh

EXPOSE 25565

CMD ["/bin/bash", "./startmc.sh"]

