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

**macOS / Linux:**
```bash
curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh | sh
```

**Windows (PowerShell):**
```powershell
irm https://ai.snowflake.com/static/cc-scripts/install.ps1 | iex
```

Verify the installation:
```bash
cortex --version
```

### Step 2: Configure a Snowflake Connection

Cortex Code uses connections defined in `~/.snowflake/config.toml`. Create this file with your connection details:

```bash
mkdir -p ~/.snowflake
```

Edit `~/.snowflake/config.toml`:

```toml
[connections.my-account]
account = "abc12345.us-east-1"
user = "your_username"
password = "your_password"
role = "ACCOUNTADMIN"
warehouse = "COMPUTE_WH"
database = "SNOWFLAKE_SAMPLE_DATA"
schema = "TPCH_SF1"
```

Verify the connection works:
```bash
cortex connections list
cortex connections set my-account
```

### Step 2b: Key-Pair Authentication (Recommended)

Key-pair authentication is more secure than password authentication and is recommended for production use.

#### Generate an RSA Key Pair

```bash
# Create a directory for your keys
mkdir -p ~/.snowflake/keys

# Generate a private key (no passphrase for simplicity, or add -aes256 for encrypted)
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out ~/.snowflake/keys/rsa_key.p8 -nocrypt

# Generate the public key
openssl rsa -in ~/.snowflake/keys/rsa_key.p8 -pubout -out ~/.snowflake/keys/rsa_key.pub

# Set secure permissions
chmod 600 ~/.snowflake/keys/rsa_key.p8
```

#### Register the Public Key in Snowflake

Copy your public key (without the header/footer lines):

```bash
cat ~/.snowflake/keys/rsa_key.pub | grep -v "PUBLIC KEY" | tr -d '\n'
```

Then run this SQL in Snowflake (Snowsight):

```sql
ALTER USER your_username SET RSA_PUBLIC_KEY='MIIBIjANBgkqh...your-key-here...';
```

#### Configure the Connection with Key-Pair Auth

Edit `~/.snowflake/config.toml`:

```toml
[connections.my-account]
account = "abc12345.us-east-1"
user = "your_username"
authenticator = "SNOWFLAKE_JWT"
private_key_file = "~/.snowflake/keys/rsa_key.p8"
role = "ACCOUNTADMIN"
warehouse = "COMPUTE_WH"
database = "SNOWFLAKE_SAMPLE_DATA"
schema = "TPCH_SF1"
```

#### Using an Encrypted Private Key (Optional)

For additional security, you can encrypt your private key with a passphrase:

```bash
# Generate an encrypted private key
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out ~/.snowflake/keys/rsa_key_encrypted.p8 -v2 aes256
```

Then add `private_key_file_pwd` to your connection or set the environment variable:

```bash
export PRIVATE_KEY_PASSPHRASE='your-passphrase'
```

Or in `config.toml`:

```toml
[connections.my-account]
# ... other settings ...
private_key_file = "~/.snowflake/keys/rsa_key_encrypted.p8"
private_key_file_pwd = "your-passphrase"  # Or use env var for security
```

---

## VS Code Setup

Open the project in VS Code and install recommended extensions for the best experience.

### Recommended Extensions

When you open the project, VS Code will prompt you to install recommended extensions. Or install manually:

| Extension | Purpose |
|-----------|---------|
| **Snowflake** (`snowflake.snowflake-vsc`) | Run SQL, browse objects, view results |
| **Python** (`ms-python.python`) | Python IntelliSense and debugging |
| **Pylance** (`ms-python.vscode-pylance`) | Fast Python language server |
| **ESLint** (`dbaeumer.vscode-eslint`) | JavaScript/React linting |
| **Prettier** (`esbenp.prettier-vscode`) | Code formatting |
| **Docker** (`ms-azuretools.vscode-docker`) | Dockerfile support, container management |

Install all at once via Command Palette:
```
> Extensions: Show Recommended Extensions
```

### Using the Snowflake Extension

1. Click the Snowflake icon in the sidebar
2. Click **"Add Connection"** and enter your credentials
3. Browse databases, schemas, and tables visually
4. Run SQL directly in VS Code with `Cmd+Enter` / `Ctrl+Enter`

### Running Cortex Code in VS Code Terminal

Open the integrated terminal (`` Ctrl+` ``) and run:

```bash
cortex
```

**Pro tip:** Use VS Code's split terminal to have Cortex Code open alongside your regular shell:
- `Cmd+\` (macOS) or `Ctrl+\` (Windows/Linux) to split
- Run `cortex` in one pane, use the other for git/npm/docker commands

### Debugging with VS Code

The project includes debug configurations. Press `F5` or go to **Run and Debug** to see:

- **Backend: FastAPI** – Debug the Python API with breakpoints
- **Frontend: Vite Dev** – Debug the React app
- **Full Stack** – Launch both simultaneously

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
