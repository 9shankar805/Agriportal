'use client';
import { Leaf, LayoutDashboard, Users, ShieldCheck, MapPin, FileText, MessageSquare, BarChart3, Headphones, Settings, LogOut } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';

type SectionId = 'overview' | 'users' | 'kyc' | 'lands' | 'applications' | 'messages' | 'analytics' | 'support' | 'settings';

interface SidebarProps {
  active: SectionId;
  onNav: (id: SectionId) => void;
  onLogout: () => void;
  adminName: string;
}

const MAIN_NAV = [
  { id: 'overview'     as SectionId, label: 'Overview',        icon: LayoutDashboard },
  { id: 'users'        as SectionId, label: 'Users',           icon: Users,        badge: 'nbUsers' },
  { id: 'kyc'          as SectionId, label: 'KYC Verification',icon: ShieldCheck,  badge: 'nbKyc', warn: true },
];
const CONTENT_NAV = [
  { id: 'lands'        as SectionId, label: 'Land Listings',   icon: MapPin },
  { id: 'applications' as SectionId, label: 'Applications',    icon: FileText,     badge: 'nbApps', warn: true },
  { id: 'messages'     as SectionId, label: 'Messages',        icon: MessageSquare,badge: 'nbMsgs' },
];
const REPORT_NAV = [
  { id: 'analytics'    as SectionId, label: 'Analytics',       icon: BarChart3 },
  { id: 'support'      as SectionId, label: 'Support Messages',icon: Headphones,   badge: 'nbSupport', warn: true },
  { id: 'settings'     as SectionId, label: 'Settings',        icon: Settings },
];

export default function Sidebar({ active, onNav, onLogout, adminName }: SidebarProps) {
  const { users, apps, convs, supportMsgs } = useAdmin();
  const badges: Record<string, number> = {
    nbUsers:   users.length,
    nbKyc:     users.filter(u => u.kycStatus === 'pending').length,
    nbApps:    apps.filter(a => a.status === 'pending').length,
    nbMsgs:    convs.length,
    nbSupport: supportMsgs.filter(m => m.status === 'open').length,
  };

  const NavItem = ({ item }: { item: typeof MAIN_NAV[0] }) => {
    const count = item.badge ? badges[item.badge] : 0;
    const isActive = active === item.id;
    return (
      <li>
        <button
          onClick={() => onNav(item.id)}
          className={`w-full flex items-center gap-2.5 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-150
            ${isActive
              ? 'bg-white/20 text-white font-bold shadow-inner border-l-2 border-green-300'
              : 'text-white/70 hover:bg-white/10 hover:text-white'
            }`}
          aria-current={isActive ? 'page' : undefined}
        >
          <item.icon size={17} className="flex-shrink-0" />
          <span className="flex-1 text-left">{item.label}</span>
          {count > 0 && (
            <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded-full flex-shrink-0
              ${item.warn ? 'bg-amber-400 text-amber-900' : 'bg-green-400 text-green-900'}`}>
              {count}
            </span>
          )}
        </button>
      </li>
    );
  };

  return (
    <nav
      className="w-[260px] min-w-[260px] min-h-screen flex flex-col"
      style={{ background: 'linear-gradient(180deg, #1b5e20 0%, #1e7e34 60%, #256029 100%)' }}
      aria-label="Admin navigation"
    >
      {/* Brand */}
      <div className="flex items-center gap-3 px-5 py-5 border-b border-white/10">
        <div className="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center flex-shrink-0">
          <Leaf size={20} className="text-green-200" />
        </div>
        <div>
          <div className="font-extrabold text-white leading-none">AgriPortal</div>
          <div className="text-white/50 text-[10px] mt-0.5">Admin Console</div>
        </div>
      </div>

      {/* Navigation */}
      <div className="flex-1 py-3 overflow-y-auto">
        <div className="px-5 py-2 text-[10px] font-extrabold tracking-widest text-white/35 uppercase">Main</div>
        <ul className="px-2 space-y-0.5">
          {MAIN_NAV.map(item => <NavItem key={item.id} item={item} />)}
        </ul>

        <div className="px-5 py-2 mt-3 text-[10px] font-extrabold tracking-widest text-white/35 uppercase">Content</div>
        <ul className="px-2 space-y-0.5">
          {CONTENT_NAV.map(item => <NavItem key={item.id} item={item} />)}
        </ul>

        <div className="px-5 py-2 mt-3 text-[10px] font-extrabold tracking-widest text-white/35 uppercase">Reports</div>
        <ul className="px-2 space-y-0.5">
          {REPORT_NAV.map(item => <NavItem key={item.id} item={item} />)}
        </ul>
      </div>

      {/* Footer */}
      <div className="border-t border-white/10 px-4 py-4 flex items-center gap-3">
        <img
          src={`https://ui-avatars.com/api/?name=${encodeURIComponent(adminName)}&background=4ade80&color=1a2d1c&bold=true`}
          alt={adminName}
          className="w-9 h-9 rounded-full border-2 border-white/30 flex-shrink-0"
        />
        <div className="flex-1 min-w-0">
          <div className="text-white font-semibold text-sm truncate">{adminName}</div>
          <div className="text-white/50 text-[10px]">Super Admin</div>
        </div>
        <button
          onClick={onLogout}
          className="p-1.5 rounded-lg text-white/60 hover:bg-white/15 hover:text-white transition-colors"
          title="Logout"
          aria-label="Logout"
        >
          <LogOut size={16} />
        </button>
      </div>
    </nav>
  );
}
