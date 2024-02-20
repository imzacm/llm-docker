# Based on https://gist.github.com/jsjolund/c03089becae815ad6cdd863d1a3f20d4

ARG BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04
FROM ${BASE_IMAGE} AS base

ENV DEBIAN_FRONTEND noninteractive\
    SHELL=/bin/bash\
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu\
    PATH="/opt/venv/bin:$PATH"

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Install system dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt install -y --no-install-recommends \
    git wget curl build-essential \
    python3-dev python3-venv python3-pip python-is-python3 && \
    apt-get clean

# Install yq
ARG YQ_VERSION=latest
ARG YQ_URL=https://github.com/mikefarah/yq/releases/${YQ_VERSION}/download/yq_linux_amd64
RUN curl -fsSL "${YQ_URL}" --output /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip setuptools wheel virtualenv

# Install Torch with CUDA 12.1 support
RUN pip install torch torchvision torchaudio --pre -f https://download.pytorch.org/whl/nightly/cu121/torch_nightly.html

FROM base AS lollms

# Can be any tag or branch e.g. main or v9.2
ARG WEBUI_VERSION=v9.2
ARG WEBUI_REPO=https://github.com/ParisNeo/lollms-webui.git

# Should be true for main branch
ARG UPDATE_SUBMODULES=false

ARG LOLLMS_DIR=/src/lollms-webui
RUN mkdir -p "$(dirname -- "${LOLLMS_DIR}")"

# Clone lollms-webui
RUN git clone --recurse-submodules "${WEBUI_REPO}" --branch="${WEBUI_VERSION}" --depth=1 "${LOLLMS_DIR}"

# Update submodules
RUN if [ "${UPDATE_SUBMODULES}" = true ]; then \
      cd "${LOLLMS_DIR}" && \
      git submodule foreach 'git checkout main && git pull' \
    ; fi

# Install pip dependencies
RUN for dir in lollms_core 'utilities/safe_store'; do \
      cd "${LOLLMS_DIR}/$dir" && pip install -e . \
    ; done && \
    cd "${LOLLMS_DIR}" && \
    while IFS= read -r requirement; do \
      if echo "$requirement" | grep -q "git+"; then \
        package_name=$(echo "$requirement" | awk -F'/' '{ print $4 }' | awk -F'@' '{ print $1 }') && \
        pip uninstall -y "$package_name" \
      ; fi \
    ; done < requirements.txt && \
    pip install -r requirements.txt --upgrade

COPY start.sh /
RUN chmod +x /start.sh

ENV WEBUI_HOST=0.0.0.0
ENV WEBUI_PORT=9600
ENV UPDATE_SUBMODULES=${UPDATE_SUBMODULES}

WORKDIR /workspace

CMD [ "/start.sh" ]

FROM lollms AS debug
RUN apt-get update && \
    apt-get upgrade -y && \
    apt install -y --no-install-recommends \
    vim openssh-server rsync
RUN sed -i 's/PermitRootLogin prohibit-password//' /etc/ssh/sshd_config && \
    printf 'PermitRootLogin yes\n' >> /etc/ssh/sshd_config && \
    printf 'password\npassword\n' | passwd && \
    printf 'source /opt/venv/bin/activate || true\n' >> $HOME/.bashrc

# To update start.sh:
# Host: `docker cp ~/Code/muah-ai-core-data/lollms-webui/start.sh c852e95c7203://start.sh`
# Container: `chmod +x /start.sh && /start.sh`

EXPOSE 22

CMD [ "bash", "-c", "service ssh start && bash" ]

# Change lollms to debug for debugging
FROM lollms AS runtime
