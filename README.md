# Build a React App on Snowflake with Cortex Code CLI

Learn how to use **Cortex Code CLI (CoCo)** by building a real application: a React dashboard powered by Snowflake data and deployed to Snowpark Container Services (SPCS).

By the end of this quickstart, you'll:
- Know the core Cortex Code CLI commands and workflows
- Have a working React + FastAPI application
- Understand how to deploy containerized apps to Snowflake

---

## Prerequisites

- **Snowflake account** with ACCOUNTADMIN access
- **VS Code** installed ([download](https://code.visualstudio.com/))
- **Python 3.10+** installed
- **Node.js 18+** (for local development)
- **Docker Desktop** (for deployment to SPCS)

---

## 0. Installing Cortex Code CLI

Before we begin, you'll need to install Cortex Code CLI and configure a Snowflake connection.

### Step 1: Install Cortex Code CLI

Cortex Code CLI (CoCo) is an AI-powered coding assistant that integrates with Snowflake.

**Supported environments:** macOS (Apple Silicon), Linux (Intel), or Windows Subsystem for Linux (WSL)

```bash
curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh | sh
```

Verify the installation:
```bash
cortex --version
```

### Step 2: Connect to Snowflake

After installing, run `cortex` to start the setup wizard:

```bash
cortex
```

The wizard will prompt you to:
- **Use an existing connection** from `~/.snowflake/connections.toml` (if you have one)
- **Create a new connection** by selecting "More options" and entering your Snowflake account details

> **Note:** The `connections.toml` file is shared with the Snowflake CLI (`snow` command). If you've already configured a connection for Snow CLI, you can use it with Cortex Code.

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

## 5. Deploying to SPCS

**What you'll learn:** How to deploy containerized apps to Snowpark Container Services.

### Prerequisites for Deployment

Before deploying to SPCS, ensure you have:

- **Docker Desktop** installed and running
- **Snow CLI** installed (required for registry authentication):
  ```bash
  pip install snowflake-cli
  ```

**If using key-pair authentication**, your `~/.snowflake/connections.toml` must have:
```toml
[connections.my-connection]
account = "your-account"
user = "your-user"
authenticator = "SNOWFLAKE_JWT"    # Must be uppercase
private_key_file = "/path/to/rsa_key.p8"  # Not "private_key_path"
```

Test your connection:
```bash
snow connection test -c my-connection
```

### Step 1: Set up SPCS infrastructure

```
> Help me set up SPCS infrastructure for this app - I need a compute pool 
  and image repository
```

CoCo will generate `deploy/setup.sql`. Run it in Snowsight or via CoCo:

```
> Run the setup.sql script in Snowflake
```

**Wait for the compute pool to be ready** before proceeding:
```sql
DESCRIBE COMPUTE POOL REACT_APP_POOL;
-- Wait until "state" shows ACTIVE or IDLE (can take 2-5 minutes)
```

### Step 2: Build and push Docker images

Get your image repository URL:

```sql
SHOW IMAGE REPOSITORIES LIKE 'REACT_APP_REPO' IN SCHEMA REACT_APP_DB.SPCS;
-- Copy the "repository_url" value
```

Log in to the Snowflake registry using Snow CLI:

```bash
snow spcs image-registry login --connection my-connection
```

> **Note:** This is the recommended method as it works with all authentication types including key-pair auth.

Build and push images:

```bash
# Set your repository URL
export REPO_URL=<your-repository-url>

# Backend
docker build --platform linux/amd64 -t $REPO_URL/backend:latest ./backend
docker push $REPO_URL/backend:latest

# Frontend
docker build --platform linux/amd64 -t $REPO_URL/frontend:latest ./frontend
docker push $REPO_URL/frontend:latest
```

> **Important for Apple Silicon (M1/M2/M3) users:** The `--platform linux/amd64` flag is required because SPCS runs on x86 architecture.

### Step 3: Create the service

```
> Generate the SPCS service definition that runs both frontend and backend containers
```

CoCo generates `deploy/service.sql`. Review and run it to create the service.

**Key configuration notes:**

1. **QUERY_WAREHOUSE is required** if your service executes Snowflake queries:
   ```sql
   CREATE SERVICE REACT_APP_SERVICE
       IN COMPUTE POOL REACT_APP_POOL
       FROM SPECIFICATION $$ ... $$
       QUERY_WAREHOUSE = REACT_APP_WH;  -- Required for backend queries
   ```

2. **Container networking:** In SPCS, containers in the same service communicate via `localhost`, not container names. The frontend's nginx config uses:
   ```nginx
   # SPCS containers share localhost
   proxy_pass http://localhost:8000;
   ```
   This is different from Docker Compose where you'd use `http://backend:8000`.

### Step 4: Access your app

Check the service status:
```sql
SELECT SYSTEM$GET_SERVICE_STATUS('REACT_APP_SERVICE');
-- Wait for both containers to show "READY"
```

Get your app URL:
```sql
SHOW ENDPOINTS IN SERVICE REACT_APP_SERVICE;
```

The `ingress_url` for the `frontend` endpoint is your live application!

---

## 6. Troubleshooting

**What you'll learn:** How to debug issues with CoCo's help.

### Debugging Commands

Check service status (shows container states):
```sql
SELECT SYSTEM$GET_SERVICE_STATUS('REACT_APP_SERVICE');
```

View container logs:
```sql
-- Backend logs
SELECT SYSTEM$GET_SERVICE_LOGS('REACT_APP_SERVICE', '0', 'backend', 100);

-- Frontend logs  
SELECT SYSTEM$GET_SERVICE_LOGS('REACT_APP_SERVICE', '0', 'frontend', 100);
```

### Common Issues

**Container shows FAILED status:**

Check the logs for the specific container. Common causes:
- Missing environment variables
- Image not found (check repository path)
- Port conflicts

**Frontend can't reach backend (502 Bad Gateway):**

SPCS containers in the same service share `localhost`. Ensure nginx.conf uses:
```nginx
proxy_pass http://localhost:8000;  # NOT http://backend:8000
```

**Backend returns 500 Internal Server Error:**

Usually means the service can't execute queries. Add `QUERY_WAREHOUSE`:
```sql
ALTER SERVICE REACT_APP_SERVICE SET QUERY_WAREHOUSE = REACT_APP_WH;
```

**"host not found in upstream" error:**

This nginx error means the config is trying to resolve a hostname. In SPCS, use `localhost` instead of container names.

**Image push fails with "unauthorized":**

Use Snow CLI for authentication:
```bash
snow spcs image-registry login --connection my-connection
```

**Compute pool stuck in STARTING:**

Compute pools can take 2-5 minutes to provision. Check status:
```sql
DESCRIBE COMPUTE POOL REACT_APP_POOL;
```

If stuck for more than 10 minutes, check your account's compute pool quota.

**Service won't start:**
```
> My SPCS service status shows PENDING. How do I debug this?
```

CoCo will help you analyze logs and identify the issue.

### Redeploying After Changes

If you need to update your containers:

```bash
# Rebuild and push new images
docker build --platform linux/amd64 -t $REPO_URL/backend:latest ./backend
docker push $REPO_URL/backend:latest

# Restart the service to pull new images
ALTER SERVICE REACT_APP_SERVICE SUSPEND;
ALTER SERVICE REACT_APP_SERVICE RESUME;
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

## Alternative: DevContainer for Workshops

If you're running a workshop or want a fully isolated development environment, use VS Code's DevContainer feature. This provides a pre-configured environment with all tools installed.

### Setup

1. Install the **Dev Containers** extension in VS Code
2. Clone and open the project:
   ```bash
   git clone https://github.com/sfc-gh-akelkar/snowflake-react-spcs.git
   code snowflake-react-spcs
   ```
3. When prompted, click **"Reopen in Container"** (or use Command Palette: `Dev Containers: Reopen in Container`)
4. Wait 2-3 minutes for the container to build

### What's Included

The DevContainer automatically:
- Installs Node.js 20, Python 3.10, and Docker
- Installs Snow CLI and Cortex Code CLI
- Installs all frontend and backend dependencies
- Mounts your `~/.snowflake` config (if it exists)

Once ready, open a terminal and run `cortex` to start.

> **Note:** DevContainers require Docker Desktop to be running.

---

## Project Structure

```
snowflake-react-spcs/
├── README.md                    # This file
├── .devcontainer/               # VS Code DevContainer config
│   ├── devcontainer.json        # Container settings & extensions
│   ├── docker-compose.yml       # DevContainer compose file
│   ├── Dockerfile               # DevContainer image
│   └── post-create.sh           # Setup script (runs after container created)
├── .vscode/
│   ├── extensions.json          # Recommended extensions
│   ├── settings.json            # Workspace settings
│   └── launch.json              # Debug configurations
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

## Optional: Snow CLI

While not required for this quickstart, [Snowflake CLI (Snow CLI)](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index) is useful for other Snowflake workflows like Native Apps, Snowpark development, and Streamlit deployments.

**Install Snow CLI:**
```bash
pip install snowflake-cli
```

Snow CLI provides an interactive connection wizard and can manage multiple Snowflake projects:
```bash
snow connection add        # Interactive connection setup
snow connection test       # Test a connection
snow connection list       # List all connections
```

Connections created with Snow CLI are stored in `~/.snowflake/config.toml` and are automatically available to Cortex Code.

---

## Resources

- [Cortex Code CLI Documentation](https://docs.snowflake.com/en/developer-guide/cortex-code)
- [Snowflake CLI Documentation](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index)
- [Snowpark Container Services Guide](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)
- [Snowpark Python Developer Guide](https://docs.snowflake.com/en/developer-guide/snowpark/python/index)
