FROM python:3.14-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    GO_VERSION=1.26.1 \
    GOPATH="/go" \
    PATH="/usr/local/go/bin:/go/bin:/opt/nvim-linux-x86_64/bin:${PATH}"

# ----------------------
# System packages
# ----------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gosu \
    curl \
    ca-certificates \
    unzip \
    zsh \
    bash \
    ripgrep \
    fzf \
    sudo \
    make \
 && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man /var/cache/*

# ----------------------
# Neovim (latest stable)
# ----------------------
RUN curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    | tar -C /opt -xz

# ----------------------
# Go
# ----------------------
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -C /usr/local -xz

# ----------------------
# Python
# ----------------------
RUN pip install --upgrade pip

# ---------------------
# Nodejs
# ---------------------
RUN curl -fsSL https://raw.githubusercontent.com/mklement0/n-install/stable/bin/n-install | bash -s 24

# ----------------------
# User setup
# ----------------------
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
 && useradd --uid $USER_UID --gid $USER_GID -ms /bin/zsh $USERNAME \
 && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

USER root

# ----------------------
# Entrypoint
# ----------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]
