![Tests](https://github.com/skatsev-catchpoint/demo-app/actions/workflows/test.yml/badge.svg)
# CI/CD Pipeline Status



![Tests](https://github.com/skatsev-catchpoint/demo-app/actions/workflows/ci-cd.yml/badge.svg?branch=main&job=test) 
![CI/CD](https://github.com/skatsev-catchpoint/demo-app/actions/workflows/ci-cd.yml/badge.svg?branch=main&job=ci-cd) 
![WebPageTest](https://github.com/skatsev-catchpoint/demo-app/actions/workflows/ci-cd.yml/badge.svg?branch=main&job=wpt) 


# Demo App

This project is a simple full-stack demo application with a React frontend and an Express backend. The frontend fetches a message from the backend and displays it.

## Project Structure

```
demo-app/
  frontend/   # React app
  backend/    # Express API
  docker-compose.yml
```

## Prerequisites

- [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/)
- Or [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/) for local development

---

## Running with Docker Compose

You can run both the frontend and backend together using Docker Compose. Docker recommended. 

### 1. Build and Start the Services

From the root of the project, run:

```sh
docker-compose up --build
```

This will:
- Build the frontend and backend Docker images
- Start both containers
- By default:
  - The backend will be available at [http://localhost:3000](http://localhost:3000)
  - The frontend will be available at [http://localhost:3001](http://localhost:3001)

### 2. Stopping the Services

To stop the containers, press `Ctrl+C` in the terminal where Docker Compose is running, then:

```sh
docker-compose down
```

---

## Running Locally (without Docker)

See previous instructions for installing dependencies and running each app with `npm start`.

---

## How It Works

- The frontend React app makes a request to `http://localhost:3000/` to fetch a message.
- The backend Express app responds with `"Hello World!"`.
- CORS is enabled on the backend to allow the frontend to communicate with it.

---

## Troubleshooting

- **CORS errors:**  
  Make sure the backend is running and CORS is enabled (`app.use(cors())` in `backend/index.js`).
- **Port mismatch:**  
  Ensure the frontend fetch URL matches the backend port. By default, the backend runs on port 3000 and the frontend on port 3001.

---

## License

MIT
