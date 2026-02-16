# Build a React App on Snowflake with Cortex Code CLI

Learn how to use **Cortex Code CLI (CoCo)** by building a real application: a React dashboard powered by Snowflake data and deployed to Snowpark Container Services (SPCS).

By the end of this quickstart, you'll:
- Know the core Cortex Code CLI commands and workflows
- Have a working React + FastAPI application
- Understand how to deploy containerized apps to Snowflake

---

## Prerequisites

- **Snowflake account** with ACCOUNTADMIN access
- **Docker Desktop** installed and running
- **Python 3.10+** installed
- **Node.js 18+** (for local development)

---

## 0. Installing Snowflake CLI and Cortex Code CLI

Before we begin, you'll need to install the Snowflake CLI (Snow CLI) and Cortex Code CLI.

### Step 1: Install Snow CLI

Snow CLI is Snowflake's command-line tool for managing Snowflake resources.

**macOS / Linux:**
```bash
pip install snowflake-cli
```

**Windows:**
```bash
pip install snowflake-cli
```

Verify the installation:
```bash
snow --version
```

### Step 2: Configure a Snowflake Connection

Create a connection to your Snowflake account:

```bash
snow connection add
```

You'll be prompted for:
- **Connection name**: A friendly name (e.g., `my-account`)
- **Account identifier**: Your Snowflake account (e.g., `abc12345.us-east-1`)
- **User**: Your Snowflake username
- **Password**: Your Snowflake password (or choose a different authenticator)
- **Role**: `ACCOUNTADMIN` (or your preferred role)
- **Warehouse**: `COMPUTE_WH` (or your preferred warehouse)
- **Database**: `SNOWFLAKE_SAMPLE_DATA` (optional)
- **Schema**: `TPCH_SF1` (optional)

Test the connection:
```bash
snow connection test -c my-account
```

Set it as your default connection:
```bash
snow connection set-default my-account
```

### Step 3: Install Cortex Code CLI

Cortex Code CLI (CoCo) is an AI-powered coding assistant that integrates with Snowflake.

```bash
snow cortex code install
```

This downloads and installs the Cortex Code CLI binary.

Verify the installation:
```bash
cortex --version
```

### Alternative: Manual Installation

If the `snow cortex code install` command isn't available, you can install manually:

**macOS (Apple Silicon):**
```bash
curl -fsSL https://downloads.snowflake.com/cortex-code/latest/cortex-darwin-arm64 -o /usr/local/bin/cortex
chmod +x /usr/local/bin/cortex
```

**macOS (Intel):**
```bash
curl -fsSL https://downloads.snowflake.com/cortex-code/latest/cortex-darwin-x64 -o /usr/local/bin/cortex
chmod +x /usr/local/bin/cortex
```

**Linux:**
```bash
curl -fsSL https://downloads.snowflake.com/cortex-code/latest/cortex-linux-x64 -o /usr/local/bin/cortex
chmod +x /usr/local/bin/cortex
```

**Windows (PowerShell as Administrator):**
```powershell
Invoke-WebRequest -Uri "https://downloads.snowflake.com/cortex-code/latest/cortex-win-x64.exe" -OutFile "$env:LOCALAPPDATA\Programs\cortex.exe"
# Add to PATH or run from that location
```

---

## 1. Getting Started with Cortex Code CLI

Cortex Code CLI (CoCo) is an AI-powered assistant that helps you write code, explore data, and deploy applications to Snowflake.

### Setting up your connection

First, let's check your Snowflake connections:

```bash
cortex connections list
```

Set your active connection:

```bash
cortex connections set <your-connection-name>
```

### Starting a session

Launch CoCo:

```bash
cortex
```

You're now in an interactive session where you can ask CoCo to help with tasks.

---

## 2. Exploring Your Data

**What you'll learn:** How to discover and understand data using CoCo's built-in tools.

### Try it:

```
> What tables are in SNOWFLAKE_SAMPLE_DATA.TPCH_SF1?
```

CoCo will query the schema and describe the available tables.

### Using the # shorthand

You can quickly inspect any table using the `#` prefix:

```
> #SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
```

CoCo will show you the table's schema, sample rows, and statistics.

### Searching for objects

```
> cortex search object "orders"
```

This searches across your Snowflake account for matching tables, views, and other objects.

---

## 3. Scaffolding the Project

**What you'll learn:** How CoCo generates project structure and boilerplate code.

### Creating the frontend

```
> Create a React frontend using Vite that will display data from Snowflake. 
  Include a dashboard with stats cards and a chart showing orders by status.
```

**What CoCo does:**
1. Creates the project structure (`frontend/src/`, etc.)
2. Sets up `package.json` with React and charting dependencies
3. Generates components (`App.jsx`, `OrdersChart.jsx`)
4. Adds styling (`App.css`)

### Creating the backend

```
> Create a FastAPI backend that connects to Snowflake using Snowpark. 
  It should query the TPCH_SF1 dataset and expose /api/stats and /api/orders endpoints.
```

**What CoCo does:**
1. Creates `backend/app.py` with FastAPI routes
2. Adds Snowpark session management
3. Handles both SPCS (OAuth) and local (password) authentication
4. Creates `requirements.txt`

---

## 4. Iterating on the Code

**What you'll learn:** How to modify and improve code with CoCo's help.

### Adding features

```
> Add a customers endpoint that shows top customers by account balance, 
  including their country
```

### Debugging errors

When you hit an error, paste it directly:

```
> I'm getting this error when running the app:
  
  TypeError: Cannot read properties of undefined (reading 'toLocaleString')
```

CoCo will analyze the error, identify the root cause, and fix the code.

### Refactoring

```
> Refactor the frontend to use a custom hook for data fetching
```

---

## 5. Local Development

**What you'll learn:** Running and testing your app locally.

### Setting up environment variables

Create a `.env` file (CoCo won't create files with secrets, so do this manually):

```bash
# .env (do not commit this file!)
SNOWFLAKE_ACCOUNT=your-account
SNOWFLAKE_USER=your-username
SNOWFLAKE_PASSWORD=your-password
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
```

### Running with Docker Compose

```
> Help me run this app locally with Docker Compose
```

CoCo will generate a `docker-compose.yaml` and guide you through:

```bash
docker compose up --build
```

Visit http://localhost:3000 to see your dashboard.

### Running without Docker (for development)

**Backend:**
```bash
cd backend
pip install -r requirements.txt
uvicorn app:app --reload --port 8000
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

---

## 6. Deploying to SPCS

**What you'll learn:** How to deploy containerized apps to Snowpark Container Services.

### Step 1: Set up SPCS infrastructure

```
> Help me set up SPCS infrastructure for this app - I need a compute pool 
  and image repository
```

CoCo will generate `deploy/setup.sql`. Run it in Snowsight or via CoCo:

```
> Run the setup.sql script in Snowflake
```

### Step 2: Build and push Docker images

Get your image repository URL:

```sql
SHOW IMAGE REPOSITORIES LIKE 'REACT_APP_REPO' IN SCHEMA REACT_APP_DB.SPCS;
```

Log in to the Snowflake registry:

```bash
docker login <repository-url> -u <username>
```

Build and push images:

```bash
# Backend
docker build -t <repository-url>/backend:latest ./backend
docker push <repository-url>/backend:latest

# Frontend
docker build -t <repository-url>/frontend:latest ./frontend
docker push <repository-url>/frontend:latest
```

### Step 3: Create the service

```
> Generate the SPCS service definition that runs both frontend and backend containers
```

CoCo generates `deploy/service.sql`. Run it to create the service:

```sql
-- In Snowsight or via CoCo
CREATE SERVICE REACT_APP_SERVICE
    IN COMPUTE POOL REACT_APP_POOL
    FROM SPECIFICATION $$ ... $$;
```

### Step 4: Access your app

```sql
SHOW ENDPOINTS IN SERVICE REACT_APP_SERVICE;
```

The `frontend` endpoint URL is your live application!

---

## 7. Troubleshooting

**What you'll learn:** How to debug issues with CoCo's help.

### Common issues

**Service won't start:**
```
> My SPCS service status shows PENDING. How do I debug this?
```

CoCo will show you how to check logs:
```sql
SELECT SYSTEM$GET_SERVICE_LOGS('REACT_APP_SERVICE', '0', 'backend', 100);
```

**Connection errors:**
```
> The backend can't connect to Snowflake. Here are the logs: [paste logs]
```

**Image push failures:**
```
> I'm getting "unauthorized" when pushing to the Snowflake registry
```

### Viewing logs

```
> Show me the backend container logs for my SPCS service
```

---

## What's Next?

Now that you've built and deployed your first app, try these extensions:

1. **Add authentication** - "Add Snowflake OAuth login to the frontend"
2. **Create a semantic model** - "Create a semantic model for this dashboard"
3. **Add more visualizations** - "Add a line chart showing orders over time"
4. **Set up CI/CD** - "Create a GitHub Actions workflow to deploy on push"

### CoCo commands to remember

| Command | Description |
|---------|-------------|
| `cortex connections list` | List Snowflake connections |
| `cortex search object "query"` | Search for Snowflake objects |
| `#TABLE_NAME` | Quick table inspection |
| `/help` | Get help within CoCo |
| `/clear` | Clear conversation history |

---

## Project Structure

```
snowflake-react-spcs/
├── README.md                    # This file
├── frontend/
│   ├── src/
│   │   ├── App.jsx              # Main React component
│   │   ├── App.css              # Styling
│   │   ├── main.jsx             # Entry point
│   │   └── components/
│   │       └── OrdersChart.jsx  # Chart component
│   ├── index.html
│   ├── package.json
│   ├── vite.config.js
│   ├── nginx.conf               # Production nginx config
│   └── Dockerfile
├── backend/
│   ├── app.py                   # FastAPI + Snowpark
│   ├── requirements.txt
│   └── Dockerfile
├── docker-compose.yaml          # Local development
└── deploy/
    ├── setup.sql                # SPCS infrastructure
    └── service.sql              # Service definition
```

---

## Resources

- [Cortex Code CLI Documentation](https://docs.snowflake.com/en/developer-guide/snowflake-cli)
- [Snowpark Container Services Guide](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)
- [Snowpark Python Developer Guide](https://docs.snowflake.com/en/developer-guide/snowpark/python/index)
