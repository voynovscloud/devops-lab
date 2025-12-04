FROM jenkins/jenkins:lts

USER root

# Инсталираме Docker CLI
RUN apt-get update && apt-get install -y docker.io

# Добавяме Jenkins потребителя към групата на docker (GID от хоста)
ARG DOCKER_GID
RUN groupadd -g $DOCKER_GID docker || true
RUN usermod -aG docker jenkins

USER jenkins
