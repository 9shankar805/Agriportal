'use client';
import { Menu, RefreshCw } from 'lucide-react';
import { todayString } from '@/lib/utils';

const LABELS: Record<string, string> = {
  overview:'Overview', users:'Users', kyc:'KYC Verification',
  lands:'Land Listings', applications:'Applications',
  messages:'Messages', analytics:'Analytics',
  support:'Support Messages', settings:'Settings',
};

interface TopbarProps {
  section: string;
  onMenuClick: () => void;
  onRefresh: () => void;
}

export default function Topbar({ section, onMenuClick, onRefresh }: TopbarProps) {
  return (
    <header className="h-16 bg-white border-b border-gray-100 flex items-center px-6 gap-4 sticky top-0 z-20 shadow-sm">
      <button
        onClick={onMenuClick}
        className="lg:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors"
        aria-label="Toggle menu"
      >
        <Menu size={20} />
      </button>

      <div className="flex-1">
        <nav aria-label="Breadcrumb" className="hidden sm:block">
          <ol className="flex items-center gap-2 text-sm text-gray-500">
            <li>AgriPortal</li>
            <li className="text-gray-300">/</li>
            <li className="font-semibold text-gray-800">{LABELS[section] || section}</li>
          </ol>
        </nav>
        <h1 className="sm:hidden font-extrabold text-base">{LABELS[section] || section}</h1>
      </div>

      <div className="flex items-center gap-3">
        {/* Live pill */}
        <span className="hidden md:flex items-center gap-1.5 bg-green-50 text-green-700 border border-green-200 rounded-full px-3 py-1 text-xs font-semibold">
          <span className="live-dot w-1.5 h-1.5 rounded-full bg-green-500 inline-block" />
          Live
        </span>

        {/* Today's date */}
        <span className="hidden lg:flex items-center gap-1.5 bg-green-50 text-green-700 border border-green-200 rounded-full px-3 py-1 text-xs font-semibold">
          {todayString()}
        </span>

        <button
          onClick={onRefresh}
          className="hidden md:flex items-center gap-1.5 bg-gray-50 hover:bg-gray-100 border border-gray-200 rounded-full px-3 py-1.5 text-xs font-semibold transition-colors"
          aria-label="Refresh data"
        >
          <RefreshCw size={13} /> Refresh
        </button>

        {/* Avatar */}
        <div className="w-9 h-9 rounded-full bg-gradient-to-br from-green-300 to-green-500 flex items-center justify-center text-white font-extrabold text-sm">
          A
        </div>
      </div>
    </header>
  );
}
