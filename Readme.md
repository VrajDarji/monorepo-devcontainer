# Monorepo Dev Container (Next.js + Nest.js + PostgreSQL + MongoDB)

This repository contains a monorepo development environment using **VS Code Dev Containers** and Docker.  
It is designed for fast onboarding — simply clone the repo, open in VS Code, and start coding.

---

## Prerequisites

Ensure your machine has:

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (or Docker Engine + Compose) installed and running
- [Visual Studio Code](https://code.visualstudio.com/) with the **Dev Containers** extension (aka Remote - Containers)
- Basic Docker knowledge (helpful, but not strictly required)

---

## Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/VrajDarji/monorepo-devcontainer.git
   cd monorepo-devcontainer
    ```

2. **Start the Dev Container**

   * **Windows**

     ```bash
     start.bat
     ```
   * **macOS / Linux**
     Follow the steps shown in your terminal after running:

     ```bash
     ./start.sh
     ```

3. **Open in VS Code**

   * When prompted by VS Code, choose **Reopen in Container**.
   * The Dev Container will automatically build and install dependencies.


## Opening a Terminal Inside the Container

Once the container is running, you can access its shell in several ways:

### From VS Code

* Press `Ctrl + Shift + P` → type **"Dev Containers: Open Container Terminal"** → Enter
* Or open the integrated terminal (`` Ctrl + ` ``) — you’ll already be inside the container

### From Host Machine

```bash
docker ps  # list running containers
docker exec -it <container_name_or_id> bash
```

> If bash is not available, use `sh` instead.

---

## Tech Stack in This Dev Environment

* **Frontend:** Next.js (inside `/apps/frontend`)
* **Backend:** Nest.js (inside `/apps/backend`)
* **Databases:** PostgreSQL, MongoDB
* **Tooling:** Prettier, ESLint, GitLens, Docker integration

---

## Notes

* Node modules for frontend and backend are persisted in Docker volumes for faster installs.
* You can modify the `.devcontainer/devcontainer.json` file to adjust mounts, extensions, or environment settings.

