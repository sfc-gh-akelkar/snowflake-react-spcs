import { useState, useEffect } from 'react'
import OrdersChart from './components/OrdersChart'

function App() {
  const [stats, setStats] = useState(null)
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    async function fetchData() {
      try {
        const [statsRes, ordersRes] = await Promise.all([
          fetch('/api/stats'),
          fetch('/api/orders')
        ])

        if (!statsRes.ok || !ordersRes.ok) {
          throw new Error('Failed to fetch data')
        }

        const statsData = await statsRes.json()
        const ordersData = await ordersRes.json()

        setStats(statsData)
        setOrders(ordersData)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  if (loading) {
    return (
      <div className="app">
        <header>
          <h1>Snowflake React Dashboard</h1>
        </header>
        <div className="loading">Loading data from Snowflake...</div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="app">
        <header>
          <h1>Snowflake React Dashboard</h1>
        </header>
        <div className="error">Error: {error}</div>
      </div>
    )
  }

  return (
    <div className="app">
      <header>
        <h1>Snowflake React Dashboard</h1>
      </header>

      <div className="stats-grid">
        <div className="stat-card">
          <h3>Total Orders</h3>
          <div className="value">{stats?.total_orders?.toLocaleString()}</div>
        </div>
        <div className="stat-card">
          <h3>Total Revenue</h3>
          <div className="value">${stats?.total_revenue?.toLocaleString()}</div>
        </div>
        <div className="stat-card">
          <h3>Customers</h3>
          <div className="value">{stats?.total_customers?.toLocaleString()}</div>
        </div>
        <div className="stat-card">
          <h3>Avg Order Value</h3>
          <div className="value">${stats?.avg_order_value?.toLocaleString()}</div>
        </div>
      </div>

      <div className="chart-container">
        <h2>Orders by Status</h2>
        <OrdersChart data={stats?.orders_by_status || []} />
      </div>

      <div className="data-table">
        <h2>Recent Orders</h2>
        <table>
          <thead>
            <tr>
              <th>Order Key</th>
              <th>Customer</th>
              <th>Status</th>
              <th>Total Price</th>
              <th>Order Date</th>
            </tr>
          </thead>
          <tbody>
            {orders.map((order) => (
              <tr key={order.order_key}>
                <td>{order.order_key}</td>
                <td>{order.customer_name}</td>
                <td>{order.order_status}</td>
                <td>${order.total_price?.toLocaleString()}</td>
                <td>{order.order_date}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

export default App
