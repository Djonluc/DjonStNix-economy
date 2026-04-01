import React, { useState, useEffect } from "react";
import {
  BarChart3,
  TrendingUp,
  TrendingDown,
  Zap,
  Wallet,
  History,
  Activity,
  ChevronUp,
  ChevronDown,
  Info,
  DollarSign,
} from "lucide-react";

interface SectorDemand {
  name: string;
  demand: number;
  label: string;
}

interface EconomyData {
  inflationRate: number;
  globalMoneySupply: number;
  state: "inflation" | "deflation" | "stable";
  sectors: SectorDemand[];
  recentEvents: {
    id: number;
    text: string;
    time: string;
    type: "positive" | "negative" | "neutral";
  }[];
}

const StatCard: React.FC<{
  title: string;
  value: string;
  subValue?: string;
  icon: React.ReactNode;
  trend?: "up" | "down" | "neutral";
}> = ({ title, value, subValue, icon, trend }) => (
  <div className="glass-card rounded-2xl p-6 flex flex-col gap-4">
    <div className="flex items-center justify-between">
      <div className="p-3 bg-premium-gold/10 rounded-xl border border-premium-gold/20 text-premium-gold">
        {icon}
      </div>
      {trend && (
        <div
          className={`flex items-center gap-1 text-[10px] font-black uppercase tracking-widest ${
            trend === "up"
              ? "text-emerald-400"
              : trend === "down"
                ? "text-red-400"
                : "text-white/40"
          }`}
        >
          {trend === "up" ? (
            <ChevronUp className="w-3 h-3" />
          ) : trend === "down" ? (
            <ChevronDown className="w-3 h-3" />
          ) : null}
          {trend}
        </div>
      )}
    </div>
    <div>
      <p className="text-premium-muted text-[10px] font-black uppercase tracking-widest mb-1">
        {title}
      </p>
      <h3 className="text-2xl font-black text-white">{value}</h3>
      {subValue && (
        <p className="text-[10px] text-white/40 font-medium mt-1">{subValue}</p>
      )}
    </div>
  </div>
);

const App: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [data, setData] = useState<EconomyData | null>(null);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.action === "openEconomyDashboard") {
        setData(event.data.payload);
        setVisible(true);
      }
    };
    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && visible) {
        setVisible(false);
        fetch(`https://djonstnix-economy/close`, { method: "POST" });
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [visible]);

  if (!visible || !data) return null;

  return (
    <div className="fixed inset-0 flex items-center justify-center p-8 font-sans pointer-events-none dsn-fade-in">
      <div className="w-full max-w-[1200px] h-[80vh] glass rounded-[2.5rem] overflow-hidden flex flex-col shadow-2xl relative border border-white/10 pointer-events-auto">
        {/* Header */}
        <div className="flex items-center justify-between px-10 pt-10 pb-6 shrink-0 border-b border-white/5 bg-white/[0.01]">
          <div className="flex items-center gap-6">
            <div className="p-4 bg-premium-gold rounded-2xl shadow-xl shadow-premium-gold/30">
              <Zap className="text-black w-8 h-8 fill-black" />
            </div>
            <div>
              <h1 className="text-4xl font-black tracking-tighter text-white">
                Ecosystem Economic Pulse
              </h1>
              <div className="flex items-center gap-3 mt-1.5">
                <span className="text-premium-gold text-[10px] font-black tracking-[0.2em] uppercase">
                  V2.5 EPE Engine
                </span>
                <span className="w-1 h-1 rounded-full bg-white/20"></span>
                <span
                  className={`text-[10px] font-black uppercase tracking-widest ${
                    data.state === "inflation"
                      ? "text-red-400"
                      : data.state === "deflation"
                        ? "text-emerald-400"
                        : "text-premium-gold"
                  }`}
                >
                  Market State: {data.state}
                </span>
              </div>
            </div>
          </div>
          <div className="flex flex-col items-end">
            <div className="px-5 py-2.5 rounded-xl bg-white/5 border border-white/10 flex items-center gap-3">
              <Activity className="w-4 h-4 text-premium-gold animate-pulse" />
              <span className="text-[10px] font-black text-white/60 uppercase tracking-widest">
                Live Multi-Vector Telemetry
              </span>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto custom-scrollbar p-10 flex gap-10">
          {/* Left Column: Stats & Demand */}
          <div className="flex-1 space-y-10">
            {/* Top Stats */}
            <div className="grid grid-cols-2 gap-6">
              <StatCard
                title="Inflation Index"
                value={(data.inflationRate * 100).toFixed(2) + "%"}
                subValue="Reactive scaling applied"
                icon={<BarChart3 className="w-6 h-6" />}
                trend={
                  data.state === "inflation"
                    ? "up"
                    : data.state === "deflation"
                      ? "down"
                      : "neutral"
                }
              />
              <StatCard
                title="Global Supply"
                value={"$" + (data.globalMoneySupply / 100).toLocaleString()}
                subValue="Aggregated Cash & Bank"
                icon={<Wallet className="w-6 h-6" />}
              />
            </div>

            {/* Sector Demand Bars */}
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <h2 className="text-sm font-black uppercase tracking-widest text-white/50">
                  Market Sector Demand
                </h2>
                <Info className="w-4 h-4 text-white/20" />
              </div>
              <div className="grid gap-4">
                {data.sectors.map((sector) => (
                  <div
                    key={sector.name}
                    className="glass-card rounded-2xl p-5 group"
                  >
                    <div className="flex justify-between items-center mb-3">
                      <span className="text-xs font-bold text-white/80 group-hover:text-premium-gold transition-colors capitalize">
                        {sector.label}
                      </span>
                      <span className="text-[10px] font-black text-premium-gold">
                        {(sector.demand * 100).toFixed(0)}%
                      </span>
                    </div>
                    <div className="h-1.5 w-full bg-white/5 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-premium-gold shadow-[0_0_10px_rgba(197,160,89,0.3)] transition-all duration-1000 ease-out"
                        style={{
                          width: `${Math.min(100, sector.demand * 100)}%`,
                        }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Right Column: Ledger / Events */}
          <div className="w-[400px] flex flex-col gap-6">
            <div className="flex items-center gap-2 mb-2">
              <History className="w-4 h-4 text-premium-gold" />
              <h2 className="text-sm font-black uppercase tracking-widest text-white/50">
                Ecosystem Ledger
              </h2>
            </div>
            <div className="flex-1 glass-card rounded-3xl overflow-hidden flex flex-col p-2">
              <div className="flex-1 overflow-y-auto custom-scrollbar p-4 space-y-4">
                {data.recentEvents.map((event) => (
                  <div
                    key={event.id}
                    className="p-4 rounded-xl bg-white/[0.03] border border-white/5 flex gap-4 items-start dsn-fade-in"
                  >
                    <div
                      className={`mt-1 w-2 h-2 rounded-full shrink-0 ${
                        event.type === "positive"
                          ? "bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.5)]"
                          : event.type === "negative"
                            ? "bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.5)]"
                            : "bg-premium-gold"
                      }`}
                    />
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-medium text-white/80 leading-relaxed">
                        {event.text}
                      </p>
                      <p className="text-[10px] text-white/20 font-black uppercase tracking-widest mt-2">
                        {event.time}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
              {/* Footer Action */}
              <div className="p-4 border-t border-white/5">
                <button
                  onClick={() => setVisible(false)}
                  className="w-full py-4 rounded-2xl bg-white/5 border border-white/5 text-[10px] font-black uppercase tracking-[0.2em] text-premium-muted hover:bg-premium-gold hover:text-black hover:border-premium-gold transition-all active:scale-[0.98]"
                >
                  Acknowledge Pulse
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Global Economy Banner */}
        <div className="px-10 py-5 bg-premium-gold/10 border-t border-premium-gold/20 flex items-center justify-between shrink-0">
          <div className="flex items-center gap-6">
            <div className="flex items-center gap-2">
              <DollarSign className="w-4 h-4 text-premium-gold" />
              <span className="text-[10px] font-black text-white/40 uppercase tracking-widest">
                Consumer Pricing Multiplier:
              </span>
              <span className="text-[10px] font-black text-premium-gold">
                {(data.inflationRate + 1.2).toFixed(2)}x (Retail Average)
              </span>
            </div>
          </div>
          <div className="flex flex-col items-end gap-3">
            {/* DjonStNix Logo */}
            <div className="flex justify-center scale-110 origin-right">
              <svg
                width="200"
                height="60"
                viewBox="0 0 240 80"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
                className="filter drop-shadow-[0_0_6px_rgba(197,160,89,0.4)] opacity-50"
              >
                <path
                  d="M10 10H230V70H10V10Z"
                  stroke="#c5a059"
                  strokeWidth="1"
                  strokeDasharray="700"
                  strokeDashoffset="700"
                  className="opacity-20"
                  style={{ animation: "draw 2s ease-in-out forwards" }}
                />
                <path
                  d="M5 15V5H15"
                  stroke="#c5a059"
                  strokeWidth="2"
                  className="animate-pulse"
                />
                <path
                  d="M225 5H235V15"
                  stroke="#c5a059"
                  strokeWidth="2"
                  className="animate-pulse"
                />
                <path
                  d="M235 65V75H225"
                  stroke="#c5a059"
                  strokeWidth="2"
                  className="animate-pulse"
                />
                <path
                  d="M15 75H5V65"
                  stroke="#c5a059"
                  strokeWidth="2"
                  className="animate-pulse"
                />
                <text
                  x="50%"
                  y="38"
                  dominantBaseline="middle"
                  textAnchor="middle"
                  fill="white"
                  fontSize="26"
                  fontWeight="900"
                  letterSpacing="2"
                  fontFamily="'Inter', sans-serif"
                >
                  Djon
                  <tspan fill="#c5a059" className="animate-pulse">
                    St
                  </tspan>
                  Nix
                </text>
                <text
                  x="50%"
                  y="58"
                  textAnchor="middle"
                  fill="#c5a059"
                  fontSize="7"
                  fontFamily="monospace"
                  className="opacity-50"
                >
                  FINANCIAL SYSTEMS
                </text>
              </svg>
            </div>
            <p className="text-[9px] font-bold text-premium-gold text-right uppercase tracking-[0.2em] opacity-60">
              Property of the United State Government Treasury & DjonStNix
              Banking Corporation
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default App;
