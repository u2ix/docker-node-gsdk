FROM circleci/node:10.12

# --- install gcloud sdk
# user is circleci in the FROM image, switch to root for system lib installation
USER root

ENV CCI /home/circleci
ENV GTMP /tmp/gcloud-install
ENV GSDK $CCI/google-cloud-sdk
ENV PATH="${GSDK}/bin:${PATH}"
ENV DOCKER_VER="18.06.0-ce"

# do all system lib installation in one-line to optimize layers
RUN curl -sSL https://sdk.cloud.google.com > $GTMP && bash $GTMP --install-dir=$CCI --disable-prompts \
  && rm -rf $GTMP \
  && chmod +x $GSDK/bin/* \
  \
  && chown -Rf circleci:circleci $CCI

RUN curl -L -o /tmp/docker-$DOCKER_VER.tgz https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VER.tgz \
  && tar -xz -C /tmp -f /tmp/docker-$DOCKER_VER.tgz \
  && mv /tmp/docker/* /usr/bin

# Install kubectl
RUN curl -L -o /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
  && chmod +x /tmp/kubectl \
  && sudo mv /tmp/kubectl /usr/local/bin/kubectl

# change back to the user in the FROM image
USER circleci

# setup gcloud specifics to your liking
RUN gcloud config set core/disable_usage_reporting true \
  && gcloud config set component_manager/disable_update_check true \
  && gcloud components install alpha beta --quiet
