# Docker Setup for dolg Employee Web App

This document provides instructions for running the dolg Employee web application using Docker.

## Prerequisites

- Docker installed on your machine
- Docker Compose installed on your machine

## Files

- `Dockerfile`: Builds the Flutter web application and serves it using Nginx
- `docker-compose.yml`: Orchestrates the web app, API, and database services
- `nginx.conf`: Configuration for the Nginx web server
- `.dockerignore`: Specifies files to exclude from the Docker build

## Environment Variables

You can customize the deployment by setting these environment variables:

- `API_URL`: Base URL of the backend API without trailing slash (default: https://app.dolg.net)
- `X-API-TOKEN`: API token used for authentication with the backend (default: your-api-token-here)
- `DATABASE_URL`: PostgreSQL connection string (default: postgres://postgres:postgres@db:5432/dolg)
- `POSTGRES_PASSWORD`: PostgreSQL password (default: postgres)
- `POSTGRES_USER`: PostgreSQL username (default: postgres)
- `POSTGRES_DB`: PostgreSQL database name (default: dolg)

## Running the Application

1. Build and start all services:

```bash
docker-compose up -d
```

2. View logs:

```bash
docker-compose logs -f
```

3. Stop all services:

```bash
docker-compose down
```

## Accessing the Application

- Web App: http://localhost
- API: http://localhost:5000

## Notes

- The API service in the docker-compose.yml is a placeholder. Replace `your-backend-image:latest` with your actual backend image.
- You may need to adjust the database configuration based on your backend requirements.
- For production deployment, consider adding SSL/TLS configuration to the Nginx server.