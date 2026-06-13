'use client';
import { Menu, RefreshCw, Bell, Search } from 'lucide-react';
import { todayString } from '@/lib/utils';
import { useState } from 'react';

const LABELS: Record<string, string> = {
  overview:'Overview', users:'Users', kyc:'KYC Verification',
  lands:'Land Listings', applications:'Applications',
  messages:'Messages', analytics:'Analytics',
  wallet:'Wallet Overview',
  support:'Support Messages', settings:'Settings',
};

interface TopbarProps {
  section: string;
  onMenuClick: () => void;
  onRefresh: () => void;
}

export default function Topbar({ section, onMenuClick, onRefresh }: TopbarProps) {
  const [searchOpen, setSearchOpen] = useState(false);

  return (
    <header className="h-24 bg-white border-b border-gray-100 flex items-center px-8 gap-6 sticky top-0 z-20 shadow-sm">
      <button
        onClick={onMenuClick}
        className="lg:hidden p-3.5 rounded-2xl hover:bg-gray-100 transition-colors"
        aria-label="Toggle menu"
      >
        <Menu size={24} />
      </button>

      <div className="flex-1">
        <nav aria-label="Breadcrumb" className="hidden sm:block">
          <ol className="flex items-center gap-3 text-sm text-gray-500">
            <li className="font-bold text-gray-700">AgriPortal</li>
            <li className="text-gray-300">/</li>
            <li className="font-extrabold text-gray-900 text-xl">{LABELS[section] || section}</li>
          </ol>
        </nav>
        <h1 className="sm:hidden font-extrabold text-xl">{LABELS[section] || section}</h1>
      </div>

      <div className="flex items-center gap-4">
        {/* Search */}
        {searchOpen ? (
          <div className="flex items-center gap-3 bg-gray-50 border border-gray-200 rounded-2xl px-4 py-2.5">
            <Search size={18} className="text-gray-500" />
            <input 
              type="text" 
              placeholder="Search..." 
              className="bg-transparent border-none outline-none text-sm w-64"
              onBlur={() => setSearchOpen(false)}
              autoFocus
            />
          </div>
        ) : (
          <button 
            onClick={() => setSearchOpen(true)}
            className="p-3.5 rounded-2xl hover:bg-gray-100 transition-colors text-gray-600"
            aria-label="Search"
          >
            <Search size={22} />
          </button>
        )}

        {/* Notifications */}
        <button className="p-3.5 rounded-2xl hover:bg-gray-100 transition-colors text-gray-600 relative">
          <Bell size={22} />
          <span className="absolute top-2.5 right-2.5 w-2.5 h-2.5 bg-red-500 rounded-full animate-pulse"></span>
        </button>

        {/* Live pill */}
        <div className="hidden md:flex items-center gap-2 bg-gradient-to-r from-green-50 to-emerald-50 text-green-700 border border-green-200 rounded-full px-4 py-2 text-xs font-extrabold">
          <span className="w-2.5 h-2.5 rounded-full bg-green-500 inline-block animate-pulse"></span>
          Live
        </div>

        {/* Today's date */}
        <div className="hidden lg:flex items-center gap-2 bg-gray-50 text-gray-600 border border-gray-200 rounded-full px-4 py-2 text-xs font-semibold">
          {todayString()}
        </div>

        <button
          onClick={onRefresh}
          className="hidden md:flex items-center gap-2 bg-gray-50 hover:bg-gray-100 border border-gray-200 rounded-2xl px-5 py-3 text-sm font-bold transition-all hover:shadow-sm"
          aria-label="Refresh data"
        >
          <RefreshCw size={18} /> Refresh
        </button>

        {/* Avatar */}
        <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-green-400 to-emerald-600 flex items-center justify-center text-white font-extrabold text-lg shadow-md">
          A
        </div>
      </div>
    </header>
  );
}
