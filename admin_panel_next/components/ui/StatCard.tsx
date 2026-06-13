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
      className={`bg-white rounded-2xl p-6 shadow-md border border-gray-100 hover:shadow-lg hover:-translate-y-1.5 transition-all duration-300 ${onClick ? 'cursor-pointer' : ''}`}
      onClick={onClick}
    >
      <div className="flex items-center justify-between mb-5">
        <div className="w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0 shadow-sm" style={{ background: accentBg }}>
          <Icon size={24} style={{ color: accent }} />
        </div>
        {trend && (
          <div className={`text-xs font-bold px-2.5 py-1 rounded-full ${trendUp ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'}`}>
            {trend}
          </div>
        )}
      </div>
      <div className="text-4xl font-extrabold leading-none mb-2 count-up" style={{ color: accent }}>{value}</div>
      <div className="text-sm font-medium text-gray-500">{label}</div>
    </div>
  );
}
