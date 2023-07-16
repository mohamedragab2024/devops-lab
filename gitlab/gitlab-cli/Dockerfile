FROM ubuntu
RUN apt update
RUN apt install -y curl wget
RUN wget https://github.com/profclems/glab/releases/latest/download/glab_linux_amd64.tar.gz
RUN tar xf glab_linux_amd64.tar.gz
RUN  mv glab /usr/local/bin/
