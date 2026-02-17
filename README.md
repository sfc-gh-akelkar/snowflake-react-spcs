# Build a React App on Snowflake with Cortex Code CLI

Learn how to use **Cortex Code CLI (CoCo)** by building a real application: a React dashboard powered by Snowflake data and deployed to Snowpark Container Services (SPCS).

By the end of this quickstart, you'll:
- Know the core Cortex Code CLI commands and workflows
- Have a working React + FastAPI application
- Understand how to deploy containerized apps to Snowflake

---

## Prerequisites

- **Snowflake account** with ACCOUNTADMIN access
- **Docker Desktop** installed and running ([download](https://www.docker.com/products/docker-desktop))
- **Python 3.8+** (for installing Snow CLI)

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

**What you'll learn:** How to deploy containerized apps to Snowpark Container Services using CoCo.

### Prerequisites for Deployment

Before deploying, ensure **Docker Desktop** is running and **Snow CLI** is installed:

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

### Step 1: Set up SPCS infrastructure

```
> Help me set up SPCS infrastructure for this app - I need a compute pool, 
  image repository, and warehouse
```

CoCo will create the SQL and run it in Snowflake. Wait for the compute pool to be ready:

```
> Check if my compute pool is ready
```

### Step 2: Log in to the image registry

```
> Log in to the Snowflake image registry
```

CoCo will run the Snow CLI command to authenticate Docker with your Snowflake registry.

### Step 3: Build and push Docker images

```
> Build and push the Docker images to my SPCS image repository
```

CoCo will:
- Get your repository URL from Snowflake
- Build images for the correct platform (linux/amd64)
- Push both frontend and backend images

### Step 4: Deploy the service

```
> Deploy the React app as an SPCS service
```

CoCo will create and run the service definition with the correct configuration (warehouse, networking, etc.).

### Step 5: Access your app

```
> What's the URL for my deployed app?
```

CoCo will query the service endpoints and give you the public URL.

---

## 6. Troubleshooting

When something goes wrong, ask CoCo for help:

```
> My SPCS service isn't working. Can you check the status and logs?
```

```
> The frontend is returning a 502 error. Help me debug.
```

```
> I'm getting "unauthorized" when pushing images. How do I fix this?
```

CoCo can run diagnostic queries, check container logs, and suggest fixes.

### Quick Reference

| Issue | Ask CoCo |
|-------|----------|
| Service won't start | "Check my SPCS service status and logs" |
| 502 Bad Gateway | "Debug the frontend container logs" |
| 500 Internal Server Error | "Check backend logs and service configuration" |
| Image push fails | "Help me authenticate with the image registry" |
| Compute pool stuck | "Check my compute pool status" |

### Redeploying After Changes

```
> I updated the code. Rebuild and redeploy the app.
```

CoCo will rebuild the images, push them, and restart the service.

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
