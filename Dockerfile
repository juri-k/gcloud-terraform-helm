FROM alpine:3.10

ENV CLOUD_SDK_VERSION 258.0.0
ENV TERRAFORM_VERSION=0.12.6
ENV HELM_VERSION=2.14.3
ENV HELMFILE_VERSION=0.81.0
ENV KUBECTL_VERSION=1.15.3

ENV PATH /google-cloud-sdk/bin:$PATH
RUN apk --no-cache add \
        curl \
        python \
        py-pip \
        bash \
        libc6-compat \
        git \
        gettext \
        coreutils \
        findutils

RUN pip install --upgrade pip && \
        pip install jinja2

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set core/disable_prompts true && \
    gcloud config set component_manager/disable_update_check true

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/bin/

RUN wget --quiet https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xzf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/bin \
    && rm -rf linux-amd64

RUN curl -L -o /usr/bin/helmfile https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 && \
    chmod +x /usr/bin/helmfile

RUN mkdir -p ~/.helm/plugins && \
    helm plugin install https://github.com/rimusz/helm-tiller && \
    helm plugin install https://github.com/futuresimple/helm-secrets 

RUN wget --quiet https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && rm -rf /tmp/* \
  && rm -rf /var/cache/apk/* \
  && rm -rf /var/tmp/*
