# 🌲 Forest Cloud

Forest Cloud is a lightweight, self-hosted cloud storage solution built with NestJS and Next.js.

## 🚀 Quick Start

The fastest way to get started is to run the installation script directly. This will clone the repository, initialize submodules, clean up Git metadata, set up data directories with correct permissions, and start the application using Docker Compose.

```bash
curl -sSL https://raw.githubusercontent.com/forestcloud-drive/forest-cloud/refs/heads/main/install.sh | bash
```

Alternatively, if you have already cloned the repository:

```bash
./install.sh
```

Once completed, you can access:
- **Frontend:** [http://localhost:7180](http://localhost:7180)
- **Backend API:** [http://localhost:9180/api](http://localhost:9180/api)

---

## 🛠 Manual Installation

If you prefer to set up the project manually, follow these steps:

### 1. Prerequisites
- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/)

### 2. Initialize Submodules
```bash
git submodule update --init --recursive
```

### 3. Environment Setup
Copy the example environment files and adjust them as needed:

```bash
cp server/.env.example server/.env
cp client/.env.example client/.env
```

Make sure to set a secure `JWT_SECRET` in `server/.env`.

### 4. Run with Docker Compose
```bash
docker compose up -d --build
```

---

## 📂 Project Structure

- `/client`: Frontend application (Next.js)
- `/server`: Backend API (NestJS)
- `/data`: Persistent storage for database and file uploads

## 📄 License
This project is licensed under the [MIT License](LICENSE).
