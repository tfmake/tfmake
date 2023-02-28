FROM ubuntu:20.04

RUN apt-get update && true
RUN apt-get install wget uuid make -y

RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 -O /usr/bin/yq 
RUN chmod +x /usr/bin/yq

WORKDIR /app
COPY usr/ /usr

ENTRYPOINT ["bash", "tfmake"]
CMD [ "--help" ]
