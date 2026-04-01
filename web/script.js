const app = document.getElementById("app");

window.addEventListener("message", (event) => {
  if (event.data.action === "openEconomyDashboard") {
    const data = event.data.payload;
    updateUI(data);
    app.style.display = "flex";
    lucide.createIcons();
  }
});

function updateUI(data) {
  // Market State
  const marketState = document.getElementById("market-state");
  marketState.textContent = `MARKET STATE: ${data.state.toUpperCase()}`;
  marketState.className = `badge ${data.state === "inflation" ? "red" : data.state === "deflation" ? "green" : "gold"}`;

  // Inflation Index
  document.getElementById("inflation-rate").textContent =
    `${(data.inflationRate * 100).toFixed(2)}%`;
  const trend = document.getElementById("inflation-trend");
  trend.textContent = data.state.toUpperCase();
  trend.style.color =
    data.state === "inflation"
      ? "#ef4444"
      : data.state === "deflation"
        ? "#10b981"
        : "rgba(255,255,255,0.4)";

  // Global Supply
  document.getElementById("money-supply").textContent =
    `$${(data.globalMoneySupply / 100).toLocaleString()}`;

  // Price Multiplier
  document.getElementById("price-multiplier").textContent =
    `${(data.inflationRate + 1.2).toFixed(2)}x (Retail Average)`;

  // Sector Demand
  const sectorList = document.getElementById("sector-list");
  sectorList.innerHTML = "";
  data.sectors.forEach((sector) => {
    const item = document.createElement("div");
    item.className = "sector-item";
    item.innerHTML = `
            <div class="sector-info">
                <span class="sector-label">${sector.label}</span>
                <span class="sector-value">${(sector.demand * 100).toFixed(0)}%</span>
            </div>
            <div class="progress-bg">
                <div class="progress-fill" style="width: ${Math.min(100, sector.demand * 100)}%"></div>
            </div>
        `;
    sectorList.appendChild(item);
  });

  // Recent Events
  const eventList = document.getElementById("event-list");
  eventList.innerHTML = "";
  data.recentEvents.forEach((event) => {
    const item = document.createElement("div");
    item.className = "event-item";
    item.innerHTML = `
            <div class="event-dot ${event.type}"></div>
            <div class="event-details">
                <p class="event-text">${event.text}</p>
                <p class="event-time">${event.time}</p>
            </div>
        `;
    eventList.appendChild(item);
  });
}

document.getElementById("close-btn").addEventListener("click", () => {
  app.style.display = "none";
  fetch(`https://djonstnix-economy/close`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify({}),
  });
});

window.addEventListener("keydown", (e) => {
  if (e.key === "Escape") {
    app.style.display = "none";
    fetch(`https://djonstnix-economy/close`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify({}),
    });
  }
});
