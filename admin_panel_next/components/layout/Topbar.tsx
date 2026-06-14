'use client';
import { Menu, RefreshCw, Bell, Search } from 'lucide-react';
import { todayString } from '@/lib/utils';
import { useState } from 'react';

const LABELS: Record<string, string> = {
  overview: 'Overview', users: 'Users', kyc: 'KYC Verification',
  lands: 'Land Listings', applications: 'Applications',
  messages: 'Messages', analytics: 'Analytics',
  wallet: 'Wallet Overview',
  support: 'Support Messages', settings: 'Settings',
};

interface TopbarProps {
  section: string;
  onMenuClick: () => void;
  onRefresh: () => void;
}

export default function Topbar({ section, onMenuClick, onRefresh }: TopbarProps) {
  const [searchOpen, setSearchOpen] = useState(false);

  return (
    <header className="h-20 shrink-0 bg-white border-b border-gray-200 flex items-center px-4 sm:px-6 lg:px-8 gap-4 sticky top-0 z-20">
      <button
        onClick={onMenuClick}
        className="lg:hidden p-2.5 rounded-lg hover:bg-gray-100 transition-colors"
        aria-label="Toggle menu"
      >
        <Menu size={21} />
      </button>

      <div className="flex-1">
        <nav aria-label="Breadcrumb" className="hidden sm:block">
          <ol className="flex flex-col gap-0.5">
            <li className="text-[11px] font-semibold uppercase tracking-wider text-gray-400">Admin Console</li>
            <li className="font-bold text-gray-950 text-lg">{LABELS[section] || section}</li>
          </ol>
        </nav>
        <h1 className="sm:hidden font-bold text-lg">{LABELS[section] || section}</h1>
      </div>

      <div className="flex items-center gap-2">
        {/* Search */}
        {searchOpen ? (
          <div className="flex items-center gap-2 bg-white border border-gray-300 rounded-lg px-3 py-2 focus-within:border-gray-300">
            <Search size={18} className="text-gray-500" />
            <input
              type="text"
              placeholder="Search..."
              className="bg-transparent !border-0 !outline-none !ring-0 !shadow-none text-sm w-40 lg:w-56 focus:!border-0 focus:!outline-none focus:!ring-0 focus:!shadow-none focus-visible:!outline-none focus-visible:!ring-0"
              onBlur={() => setSearchOpen(false)}
              autoFocus
            />
          </div>
        ) : (
          <button
            onClick={() => setSearchOpen(true)}
            className="p-2.5 rounded-lg hover:bg-gray-100 transition-colors text-gray-500"
            aria-label="Search"
          >
            <Search size={19} />
          </button>
        )}

        {/* Notifications */}
        <button className="p-2.5 rounded-lg hover:bg-gray-100 transition-colors text-gray-500 relative" aria-label="Notifications">
          <Bell size={19} />
          <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full ring-2 ring-white"></span>
        </button>

        {/* Today's date */}
        <div className="hidden xl:flex items-center gap-2 text-gray-500 border-l border-gray-200 pl-4 mx-1 text-xs font-medium">
          {todayString()}
        </div>

        <button
          onClick={onRefresh}
          className="hidden lg:flex items-center gap-2 bg-white hover:bg-gray-50 border border-gray-300 rounded-lg px-3.5 py-2 text-xs font-semibold text-gray-700 transition-colors"
          aria-label="Refresh data"
        >
          <RefreshCw size={15} /> Refresh
        </button>

        {/* Avatar */}
        <div className="w-9 h-9 rounded-lg bg-green-700 flex items-center justify-center text-white font-bold text-sm ml-1">
          A
        </div>
      </div>
    </header>
  );
}
