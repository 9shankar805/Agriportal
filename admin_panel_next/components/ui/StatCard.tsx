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
      className={`bg-white rounded-lg p-5 shadow-sm border border-gray-200 hover:border-gray-300 hover:shadow-md transition-all duration-200 ${onClick ? 'cursor-pointer' : ''}`}
      onClick={onClick}
    >
      <div className="flex items-center justify-between mb-4">
        <div className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: accentBg }}>
          <Icon size={19} style={{ color: accent }} />
        </div>
        {trend && (
          <div className={`text-[10px] font-semibold px-2 py-1 rounded-full ${trendUp ? 'bg-green-50 text-green-700' : 'bg-amber-50 text-amber-700'}`}>
            {trend}
          </div>
        )}
      </div>
      <div className="text-3xl font-bold leading-none mb-2 count-up text-gray-950">{value}</div>
      <div className="text-xs font-medium text-gray-500">{label}</div>
    </div>
  );
}
