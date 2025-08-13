FROM node:20-bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git curl build-essential python3 python3-pip libpq-dev postgresql-client openssh-client ca-certificates sudo \
  && rm -rf /var/lib/apt/lists/*

# Create vscode user
ARG USERNAME=vscode
ARG USER_UID=1002
ARG USER_GID=1002
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && mkdir -p /workspace \
  && git config --global --add safe.directory /workspace

# Enable pnpm for monorepo (adjust version as needed)
RUN corepack enable && corepack prepare pnpm@9.1.0 --activate

# Optional global tools
RUN npm install -g nodemon typescript eslint

USER $USERNAME
WORKDIR /workspace

# Ports for Next.js, Nest.js, and Node debugging
EXPOSE 3000 3001 9229

# Keep container alive
CMD ["sleep", "infinity"]
