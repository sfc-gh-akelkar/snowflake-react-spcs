from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from snowflake.snowpark import Session
from contextlib import asynccontextmanager
import os

# Global session variable
snowpark_session = None


def get_snowpark_session() -> Session:
    """
    Create a Snowpark session.
    In SPCS, uses OAuth token authentication automatically.
    For local dev, uses environment variables.
    """
    # Check if running in SPCS (token file exists)
    token_path = "/snowflake/session/token"
    
    if os.path.exists(token_path):
        # Running in SPCS - use OAuth token
        with open(token_path, "r") as f:
            token = f.read()
        
        connection_params = {
            "account": os.environ["SNOWFLAKE_ACCOUNT"],
            "host": os.environ["SNOWFLAKE_HOST"],
            "authenticator": "oauth",
            "token": token,
            "warehouse": os.environ.get("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"),
            "database": os.environ.get("SNOWFLAKE_DATABASE", "SNOWFLAKE_SAMPLE_DATA"),
            "schema": os.environ.get("SNOWFLAKE_SCHEMA", "TPCH_SF1"),
        }
    else:
        # Local development - use environment variables
        connection_params = {
            "account": os.environ["SNOWFLAKE_ACCOUNT"],
            "user": os.environ["SNOWFLAKE_USER"],
            "password": os.environ["SNOWFLAKE_PASSWORD"],
            "warehouse": os.environ.get("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"),
            "database": os.environ.get("SNOWFLAKE_DATABASE", "SNOWFLAKE_SAMPLE_DATA"),
            "schema": os.environ.get("SNOWFLAKE_SCHEMA", "TPCH_SF1"),
        }
    
    return Session.builder.configs(connection_params).create()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage Snowpark session lifecycle."""
    global snowpark_session
    snowpark_session = get_snowpark_session()
    yield
    if snowpark_session:
        snowpark_session.close()


app = FastAPI(
    title="Snowflake React Backend",
    description="API backend for the Snowflake React Dashboard",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}


@app.get("/api/stats")
async def get_stats():
    """Get summary statistics from the TPCH dataset."""
    try:
        # Total orders and revenue
        orders_stats = snowpark_session.sql("""
            SELECT 
                COUNT(*) as total_orders,
                ROUND(SUM(O_TOTALPRICE), 2) as total_revenue,
                ROUND(AVG(O_TOTALPRICE), 2) as avg_order_value
            FROM ORDERS
        """).collect()[0]
        
        # Total customers
        customer_count = snowpark_session.sql("""
            SELECT COUNT(*) as count FROM CUSTOMER
        """).collect()[0]["COUNT"]
        
        # Orders by status
        orders_by_status = snowpark_session.sql("""
            SELECT 
                O_ORDERSTATUS as status,
                COUNT(*) as count
            FROM ORDERS
            GROUP BY O_ORDERSTATUS
            ORDER BY count DESC
        """).collect()
        
        return {
            "total_orders": orders_stats["TOTAL_ORDERS"],
            "total_revenue": orders_stats["TOTAL_REVENUE"],
            "avg_order_value": orders_stats["AVG_ORDER_VALUE"],
            "total_customers": customer_count,
            "orders_by_status": [
                {"status": row["STATUS"], "count": row["COUNT"]}
                for row in orders_by_status
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/orders")
async def get_orders(limit: int = 20):
    """Get recent orders with customer information."""
    try:
        orders = snowpark_session.sql(f"""
            SELECT 
                O.O_ORDERKEY as order_key,
                C.C_NAME as customer_name,
                O.O_ORDERSTATUS as order_status,
                O.O_TOTALPRICE as total_price,
                O.O_ORDERDATE as order_date
            FROM ORDERS O
            JOIN CUSTOMER C ON O.O_CUSTKEY = C.C_CUSTKEY
            ORDER BY O.O_ORDERDATE DESC
            LIMIT {limit}
        """).collect()
        
        return [
            {
                "order_key": row["ORDER_KEY"],
                "customer_name": row["CUSTOMER_NAME"],
                "order_status": row["ORDER_STATUS"],
                "total_price": float(row["TOTAL_PRICE"]),
                "order_date": str(row["ORDER_DATE"])
            }
            for row in orders
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/customers")
async def get_customers(limit: int = 20):
    """Get customers with their nation information."""
    try:
        customers = snowpark_session.sql(f"""
            SELECT 
                C.C_CUSTKEY as customer_key,
                C.C_NAME as name,
                N.N_NAME as nation,
                C.C_ACCTBAL as account_balance
            FROM CUSTOMER C
            JOIN NATION N ON C.C_NATIONKEY = N.N_NATIONKEY
            ORDER BY C.C_ACCTBAL DESC
            LIMIT {limit}
        """).collect()
        
        return [
            {
                "customer_key": row["CUSTOMER_KEY"],
                "name": row["NAME"],
                "nation": row["NATION"],
                "account_balance": float(row["ACCOUNT_BALANCE"])
            }
            for row in customers
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
