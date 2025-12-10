# Dartwing Platform – Architecture & Dev Environment

## 0. Repository Layout

All Dartwing code lives under a single root folder:

```text
~/projects/dartwing
├─ .devcontainer/              # Root full-stack devcontainer (optional)
├─ docker-compose.yml          # Root full-stack compose with profiles
├─ dartwing-app/               # Mobile app repo
├─ dartwing-frappe/            # Frappe backend repo
├─ dartwing-gateway/           # .NET gateway repo
└─ dartwing-ai/                # Python AI repo (optional)
```

Each subfolder (`dartwing-app`, `dartwing-frappe`, `dartwing-gateway`, `dartwing-ai`) is a **standalone subproject** with its own:

- `.devcontainer/` (stack-specific devcontainer)
- `docker-compose.dev.yml` (minimal dev compose for that subproject)

The root `docker-compose.yml` orchestrates the **full stack** using Docker Compose **profiles**.

---

## 1. High-Level Architecture Overview

### 1.1 Concept

Dartwing is a multi-service platform composed of:

- **Frappe core app** – main Dartwing domain logic and admin UI.
- **.NET Gateway** – API façade, broker/orchestrator, and notification hub.
- **Python AI service** – AI-specific functionality behind the gateway.
- **Keycloak** – identity provider for both mobile users and Frappe admins.
- **Dartwing mobile app** – client that talks to the Gateway and authenticates via Keycloak.

Frappe is the **system of record** for most core Dartwing data (organizations, users, workspaces, etc.).
The Gateway provides a clean API surface for the mobile app and other clients and hides the internal topology.

---

## 2. Components

### 2.1 Client

#### dartwing-app (mobile)

- **Tech**: Flutter (or similar cross-platform framework).
- **Responsibilities**:
  - Authenticate via **Keycloak** using **OIDC Authorization Code + PKCE**.
  - Store access/refresh tokens securely on-device.
  - Call **Gateway API** using Bearer tokens in the `Authorization` header.
  - Render primary Dartwing user experience.

#### Frappe Admin UI (browser)

- **Tech**: Frappe desk UI in browser.
- **Responsibilities**:
  - Back-office and administration of Dartwing (orgs, members, workflow config, etc.).
  - Uses **Keycloak SSO** (OIDC) for admin authentication.

---

### 2.2 Backend Services

#### 2.2.1 Frappe – `dartwing-frappe`

- **Tech**: Frappe Framework (Python).
- **Role**: Core Dartwing application.
  - Defines Dartwing domain models (DocTypes): organizations, users, memberships, workspace entities, etc.
  - Implements business logic and workflows.
  - Provides built-in admin UI.
- **Data store**: `mariadb-frappe` (MariaDB instance dedicated to Frappe).
- **Interfaces**:
  - Frappe REST / RPC APIs for data access and actions.
  - Webhooks to notify external services (Gateway) of important events.
- **Auth**:
  - For admin UI: OIDC SSO with **Keycloak**.
  - For service calls: Gateway uses a **Frappe service account** (API key/secret) and passes user context via headers.

#### 2.2.2 .NET Gateway – `dartwing-gateway`

- **Tech**: .NET (Web API).
- **Role**:
  - **API Façade**:
    - Single public base URL (e.g. `https://api.dartwing.local`).
    - All client interactions go through the gateway.
  - **Auth / Authorization**:
    - Validates JWT access tokens issued by Keycloak.
    - Enforces authorization per endpoint (roles, org membership, features).
  - **Broker / Orchestrator**:
    - Calls Frappe APIs for core data and workflows.
    - Calls AI service for AI-enhanced features.
  - **Notifications (Notify)**:
    - Manages device registrations and push tokens (if needed).
    - Sends push notifications, emails, or websockets/SignalR events.
- **Data store**:
  - Initially stateless (no DB required).
  - Optional **Postgres** (`postgres-core`) later for:
    - Device registrations (notifications).
    - API keys / client registrations.
    - Idempotency / logs / audits.

#### 2.2.3 AI Service – `dartwing-ai`

- **Tech**: Python (FastAPI or similar).
- **Role**:
  - Hosts AI/ML logic:
    - Recommendations, summarizations, workflow suggestions, etc.
  - Called **only by the Gateway** (never directly from mobile app).
- **Data store**:
  - Initially stateless.
  - May later store embeddings/artifacts in:
    - `postgres-core` (structured AI metadata).
    - `minio` (S3-compatible object storage).

#### 2.2.4 Identity Provider – `keycloak`

- **Tech**: Keycloak.
- **Role**:
  - Single IDP for Dartwing.
  - Issues OIDC tokens for mobile app and SSO for Frappe admins.
- **Realm / Clients (indicative)**:
  - Realm: `dartwing`.
  - Clients:
    - `dartwing-mobile` – public client using PKCE.
    - `dartwing-gateway` – API resource/audience used by gateway.
    - `dartwing-frappe` – confidential client for Frappe admin SSO.

---

### 2.3 Infrastructure Services

#### 2.3.1 Databases

- **MariaDB – `mariadb-frappe`**
  - Holds Frappe schema and core Dartwing data.

- **Postgres – `postgres-core` (optional)**
  - Holds gateway and/or AI-related data, if needed.

#### 2.3.2 Caching & Async

- **Redis – `redis-core`**
  - Shared cache and ephemeral store.
  - Use cases:
    - Gateway cache (e.g., Frappe responses).
    - Rate limiting, token blacklists.
    - (Optional) Frappe tasks, if sharing or separate Redis for Frappe.

- **Message broker – future**
  - `rabbitmq` or `kafka` if we add decoupled event-driven flows.

#### 2.3.3 Storage / Networking / Dev Helpers

- **MinIO – `minio` (future)**: S3-compatible storage.
- **Reverse proxy – `traefik` or `nginx-gateway`**:
  - Routes:
    - `https://api.dartwing.local` → `dartwing-gateway`
    - `https://erp.dartwing.local` → `dartwing-frappe`
    - `https://auth.dartwing.local` → `keycloak`
- **Dev helpers**:
  - `mailhog` – capture outgoing email in dev.
  - `pgadmin` / `adminer` – DB browser.
  - Logging/metrics stack: `prometheus`, `loki`, `grafana` (optional).

---

## 3. Authentication & Authorization Flows

### 3.1 Mobile App Login Flow

**Goal**: Mobile app obtains a Keycloak access token and calls Gateway with it.

1. **App → Keycloak (login)**
   - App starts OIDC Authorization Code with PKCE against Keycloak:
     - Client: `dartwing-mobile` (public client).
   - User logs in via Keycloak’s UI.

2. **Keycloak → App (tokens)**
   - App receives:
     - Access token (JWT).
     - Refresh token.
   - Stores them securely on the device.

3. **App → Gateway**
   - Every API request includes:
     - `Authorization: Bearer <access_token>`.
   - Calls `https://api.dartwing.local` (or env-specific base URL).

4. **Gateway – Token Validation**
   - Validates token:
     - Signature via Keycloak JWKS.
     - `iss` matches realm.
     - `aud` contains `dartwing-gateway`.
     - `exp` is valid.
   - Builds `UserContext` with:
     - `user_id` (`sub`).
     - `username`, `email`.
     - Roles from `realm_access.roles`.

5. **Gateway → Frappe / AI**
   - Applies authorization.
   - Calls Frappe and/or AI on behalf of the user.

---

### 3.2 Admin Login to Frappe (SSO)

**Goal**: Admins log into Frappe using Keycloak SSO (Option 2).

1. **Admin → Frappe**
   - Admin visits `https://erp.dartwing.local`.
   - Frappe detects no session and redirects to Keycloak.

2. **Frappe → Keycloak**
   - Frappe acts as an OIDC client (`dartwing-frappe`).
   - Redirects admin to Keycloak login.

3. **Keycloak → Frappe**
   - After login, Keycloak returns an authorization code.
   - Frappe exchanges the code for tokens and user info.

4. **User Mapping**
   - Frappe maps Keycloak user → Frappe `User` (username/email).
   - Possibly auto-provision new Frappe users on first login.

5. **Session**
   - Frappe establishes its own session for the admin.
   - Logout can be integrated with Keycloak session logout.

---

## 4. Inter-Service Interactions

### 4.1 Gateway ↔ Frappe

- **Authentication**:
  - Gateway uses a Frappe **service account** (API key/secret) for all calls.
- **Context**:
  - Gateway sends user context via headers, for example:
    - `X-Dartwing-User-Id`
    - `X-Dartwing-Org-Id`
    - `X-Dartwing-Roles`
- **Usage**:
  - CRUD on domain entities.
  - Trigger Frappe workflows.
  - Read/write operations needed to fulfill API requests.

### 4.2 Gateway ↔ AI Service

- **Authentication**:
  - Shared secret or service-level auth (e.g., Keycloak client credentials flow).
- **Usage**:
  - Gateway sends curated data payload for AI processing.
  - AI returns structured responses to the gateway.

### 4.3 Notifications (within Gateway)

- Gateway may track device registrations and push tokens (later in Postgres).
- When events occur (from Frappe webhooks or AI results):
  - Gateway routes notifications to the appropriate devices/users via:
    - Push notifications.
    - Email (through SMTP/Mailhog in dev).
    - WebSocket/SignalR if real-time channels are implemented.

---

## 5. Environments & Compose Profiles

The root `docker-compose.yml` in `~/projects/dartwing` uses **profiles** to group services:

- `frappe` – Frappe + MariaDB + Redis (Frappe-related).
- `gateway` – .NET Gateway (and its optional Postgres).
- `ai` – AI service.
- `infra` – Keycloak, Mailhog, MinIO, etc.
- `app` – Flutter dev container.

### Examples

- **Full stack (local)**:

  ```bash
  COMPOSE_PROFILES=frappe,gateway,ai,infra,app docker compose up -d
  ```

- **Backend only (no mobile dev container)**:

  ```bash
  COMPOSE_PROFILES=frappe,gateway,ai,infra docker compose up -d
  ```

---

## 6. Dev Environment – Root Project Setup

### 6.1 Root `docker-compose.yml` (Conceptual Example)

> Note: This example assumes Docker build contexts under the `dartwing/` root.

```yaml
version: "3.9"

services:
  frappe:
    profiles: ["frappe"]
    build:
      context: ./dartwing-frappe/.devcontainer
      dockerfile: Dockerfile
    container_name: dartwing-frappe
    volumes:
      - ./dartwing-frappe:/workspace
    working_dir: /workspace
    depends_on:
      - mariadb-frappe
      - redis-core
    environment:
      DB_HOST: mariadb-frappe
      DB_ROOT_USER: root
      DB_ROOT_PASSWORD: root
    ports:
      - "8000:8000"

  mariadb-frappe:
    profiles: ["frappe"]
    image: mariadb:10.6
    container_name: dartwing-mariadb-frappe
    environment:
      MARIADB_ROOT_PASSWORD: root
    volumes:
      - frappe-mariadb-data:/var/lib/mysql

  redis-core:
    profiles: ["frappe", "gateway", "ai"]
    image: redis:6
    container_name: dartwing-redis-core
    volumes:
      - redis-core-data:/data

  dartwing-gateway:
    profiles: ["gateway"]
    build:
      context: ./dartwing-gateway
    container_name: dartwing-gateway
    volumes:
      - ./dartwing-gateway:/src
    working_dir: /src
    depends_on:
      - keycloak
      - frappe
    environment:
      ASPNETCORE_URLS: http://0.0.0.0:8080
      AUTH_AUTHORITY: http://keycloak:8080/realms/dartwing
      AUTH_AUDIENCE: dartwing-gateway
      FRAPPE_BASE_URL: http://frappe:8000
      FRAPPE_API_KEY: dartwing_gateway_key
      FRAPPE_API_SECRET: dartwing_gateway_secret
    ports:
      - "5000:8080"

  dartwing-ai:
    profiles: ["ai"]
    build:
      context: ./dartwing-ai
    container_name: dartwing-ai
    volumes:
      - ./dartwing-ai:/app
    working_dir: /app
    depends_on:
      - dartwing-gateway
    ports:
      - "6000:8000"

  keycloak:
    profiles: ["infra"]
    image: quay.io/keycloak/keycloak:latest
    container_name: dartwing-keycloak
    environment:
      KC_DB: dev-mem
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
    command: ["start-dev", "--http-port=8080"]
    ports:
      - "8081:8080"

  mailhog:
    profiles: ["infra"]
    image: mailhog/mailhog
    container_name: dartwing-mailhog
    ports:
      - "8025:8025"

  flutter-dev:
    profiles: ["app"]
    build:
      context: ./dartwing-app/.devcontainer
      dockerfile: Dockerfile
    container_name: dartwing-flutter-dev
    volumes:
      - ./dartwing-app:/workspace
    working_dir: /workspace
    environment:
      API_BASE_URL: http://dartwing-gateway:8080

volumes:
  frappe-mariadb-data:
  redis-core-data:
```

### 6.2 Root Devcontainer (Optional)

`~/projects/dartwing/.devcontainer/devcontainer.json`:

```json
{
  "name": "Dartwing Full Stack Dev",
  "dockerComposeFile": ["../docker-compose.yml"],
  "service": "flutter-dev",
  "workspaceFolder": "/workspace",
  "runServices": [
    "frappe",
    "mariadb-frappe",
    "redis-core",
    "dartwing-gateway",
    "dartwing-ai",
    "keycloak",
    "mailhog",
    "flutter-dev"
  ],
  "containerEnv": {
    "COMPOSE_PROFILES": "frappe,gateway,ai,infra,app"
  },
  "shutdownAction": "none"
}
```

---

## 7. Subproject Dev Setups

Each subproject has its own `docker-compose.dev.yml` and `.devcontainer/` folder so it can be worked on independently.

### 7.1 `dartwing-app` (Mobile App)

**Folder**: `~/projects/dartwing/dartwing-app`

#### `docker-compose.dev.yml`

```yaml
version: "3.9"

services:
  flutter-dev:
    build:
      context: ./.devcontainer
      dockerfile: Dockerfile
    container_name: dartwing-flutter-dev
    volumes:
      - .:/workspace
    working_dir: /workspace
    environment:
      API_BASE_URL: "https://api.dev.dartwing.com"  # remote Gateway by default
```

#### `.devcontainer/devcontainer.json`

```json
{
  "name": "Dartwing App Dev",
  "dockerComposeFile": ["../docker-compose.dev.yml"],
  "service": "flutter-dev",
  "workspaceFolder": "/workspace",
  "shutdownAction": "none"
}
```

*(Dockerfile omitted here – it would install Flutter/Android tooling.)*

Usage:

- Open `dartwing-app` in VS Code → "Reopen in Container".
- App builds/runs and calls `API_BASE_URL`.

---

### 7.2 `dartwing-frappe` (Frappe Backend)

**Folder**: `~/projects/dartwing/dartwing-frappe`

#### `docker-compose.dev.yml`

```yaml
version: "3.9"

services:
  frappe:
    build:
      context: ./.devcontainer
      dockerfile: Dockerfile
    container_name: dartwing-frappe-dev
    volumes:
      - .:/workspace
    working_dir: /workspace
    depends_on:
      - mariadb-frappe
      - redis-frappe
    ports:
      - "8000:8000"

  mariadb-frappe:
    image: mariadb:10.6
    container_name: dartwing-mariadb-frappe-dev
    environment:
      MARIADB_ROOT_PASSWORD: root
    volumes:
      - frappe-mariadb-dev-data:/var/lib/mysql

  redis-frappe:
    image: redis:6
    container_name: dartwing-redis-frappe-dev
    volumes:
      - redis-frappe-dev-data:/data

volumes:
  frappe-mariadb-dev-data:
  redis-frappe-dev-data:
```

#### `.devcontainer/devcontainer.json`

```json
{
  "name": "Dartwing Frappe Dev",
  "dockerComposeFile": ["../docker-compose.dev.yml"],
  "service": "frappe",
  "workspaceFolder": "/workspace",
  "shutdownAction": "none",
  "postCreateCommand": "bash .devcontainer/post-create.sh"
}
```

#### `.devcontainer/post-create.sh` (Example)

```bash
#!/usr/bin/env bash
set -e

cd /workspace

# Create Python venv
python -m venv env
source env/bin/activate

# Install bench if not present
if ! command -v bench &> /dev/null; then
    pip install frappe-bench
fi

# Initialize bench if not already
if [ ! -f "Procfile" ]; then
    bench init . --frappe-branch version-15 --skip-assets --python python
fi

echo "Frappe bench initialized. Next steps (inside container):"
echo "  bench new-site dartwing.local"
echo "  bench start"
```

Usage:

- Open `dartwing-frappe` in VS Code → devcontainer.
- Inside container:
  - `bench new-site dartwing.local` using `mariadb-frappe-dev` as DB host.
  - `bench start`.
- Access: `http://localhost:8000`.

---

### 7.3 `dartwing-gateway` (.NET Gateway)

**Folder**: `~/projects/dartwing/dartwing-gateway`

#### `docker-compose.dev.yml`

```yaml
version: "3.9"

services:
  dartwing-gateway:
    build:
      context: .
    container_name: dartwing-gateway-dev
    volumes:
      - .:/src
    working_dir: /src
    environment:
      ASPNETCORE_URLS: http://0.0.0.0:8080
      AUTH_AUTHORITY: http://localhost:8081/realms/dartwing
      AUTH_AUDIENCE: dartwing-gateway
      FRAPPE_BASE_URL: http://localhost:8000
    ports:
      - "5000:8080"
```

#### `.devcontainer/devcontainer.json`

```json
{
  "name": "Dartwing Gateway Dev",
  "dockerComposeFile": ["../docker-compose.dev.yml"],
  "service": "dartwing-gateway",
  "workspaceFolder": "/src",
  "shutdownAction": "none"
}
```

Usage:

- Open `dartwing-gateway` in VS Code → devcontainer.
- Run/Debug the .NET Web API inside the container.

---

### 7.4 `dartwing-ai` (Python AI Service)

**Folder**: `~/projects/dartwing/dartwing-ai`

#### `docker-compose.dev.yml`

```yaml
version: "3.9"

services:
  dartwing-ai:
    build:
      context: .
    container_name: dartwing-ai-dev
    volumes:
      - .:/app
    working_dir: /app
    environment:
      GATEWAY_URL: http://localhost:5000
    ports:
      - "6000:8000"
```

#### `.devcontainer/devcontainer.json`

```json
{
  "name": "Dartwing AI Dev",
  "dockerComposeFile": ["../docker-compose.dev.yml"],
  "service": "dartwing-ai",
  "workspaceFolder": "/app",
  "shutdownAction": "none"
}
```

Usage:

- Open `dartwing-ai` in VS Code → devcontainer.
- Implement FastAPI/AI endpoints called by the Gateway.

---

## 8. Recommended Workflows

### 8.1 Full-Stack Local Dev

1. Open `~/projects/dartwing` in VS Code.
2. Use root devcontainer to bring up all services with appropriate profiles.
3. Develop across Frappe, Gateway, AI, and the app in a single workspace.

### 8.2 Focused Subproject Dev

- **Mobile app only**:
  - Open `dartwing-app` in VS Code.
  - Use its devcontainer and connect to remote or local gateway.

- **Backend-only**:
  - Open `dartwing-frappe`, `dartwing-gateway`, or `dartwing-ai` individually.
  - Use their respective devcontainers and minimal stacks.

This single architecture + setup document defines both the **system design** and the **developer experience** for the Dartwing project.

