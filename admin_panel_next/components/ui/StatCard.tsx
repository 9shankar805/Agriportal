'use client';
import { type LucideIcon } from 'lucide-react';

interface StatCardProps {
  icon: LucideIcon;
  value: number | string;
  label: string;
  trend?: string;
  trendUp?: boolean;
  accent: string;
  accentBg: string;
  onClick?: () => void;
}

export default function StatCard({ icon: Icon, value, label, trend, trendUp, accent, accentBg, onClick }: StatCardProps) {
  return (
    <div
      className={`bg-white rounded-xl p-5 shadow-sm border-t-2 hover:-translate-y-1 transition-transform duration-200 ${onClick ? 'cursor-pointer' : ''}`}
      style={{ borderTopColor: accent }}
      onClick={onClick}
    >
      <div className="flex items-center gap-3 mb-3">
        <div className="w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: accentBg }}>
          <Icon size={20} style={{ color: accent }} />
        </div>
      </div>
      <div className="text-3xl font-extrabold leading-none mb-1 count-up" style={{ color: accent }}>{value}</div>
      <div className="text-xs text-gray-500 font-medium mt-1">{label}</div>
      {trend && (
        <div className={`text-xs font-semibold mt-2 flex items-center gap-1 ${trendUp ? 'text-green-600' : 'text-amber-600'}`}>
          {trend}
        </div>
      )}
    </div>
  );
}
