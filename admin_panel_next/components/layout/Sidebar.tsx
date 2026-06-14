'use client';
import { Leaf, LayoutDashboard, Users, ShieldCheck, MapPin, FileText, MessageSquare, BarChart3, Headphones, Settings, LogOut, Wallet, ChevronRight } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Avatar from '@/components/ui/Avatar';

type SectionId = 'overview' | 'users' | 'kyc' | 'lands' | 'applications' | 'messages' | 'analytics' | 'wallet' | 'support' | 'settings';

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
  { id: 'wallet'       as SectionId, label: 'Wallet',          icon: Wallet,       badge: 'nbWallet' },
  { id: 'support'      as SectionId, label: 'Support Messages',icon: Headphones,   badge: 'nbSupport', warn: true },
  { id: 'settings'     as SectionId, label: 'Settings',        icon: Settings },
];

export default function Sidebar({ active, onNav, onLogout, adminName }: SidebarProps) {
  const { users, apps, convs, supportMsgs, wallets } = useAdmin();
  const badges: Record<string, number> = {
    nbUsers:   users.length,
    nbKyc:     users.filter(u => u.kycStatus === 'pending').length,
    nbApps:    apps.filter(a => a.status === 'pending').length,
    nbMsgs:    convs.length,
    nbSupport: supportMsgs.filter(m => m.status === 'open').length,
    nbWallet:  wallets.filter(w => w.balance > 0).length,
  };

  const NavItem = ({ item }: { item: typeof MAIN_NAV[0] }) => {
    const count = item.badge ? badges[item.badge] : 0;
    const isActive = active === item.id;
    return (
      <li>
        <button
          onClick={() => onNav(item.id)}
          className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-semibold transition-colors duration-200 group
            ${isActive
              ? 'bg-green-50 text-green-800 border border-green-200'
              : 'text-gray-600 border border-transparent hover:bg-gray-100 hover:text-gray-900'
            }`}
          aria-current={isActive ? 'page' : undefined}
        >
          <item.icon size={18} className="flex-shrink-0" />
          <span className="flex-1 text-left">{item.label}</span>
          {count > 0 && (
            <span className={`text-[10px] font-bold min-w-5 px-1.5 py-0.5 rounded-full flex-shrink-0 text-center
              ${item.warn ? 'bg-amber-100 text-amber-700' : 'bg-gray-100 text-gray-600'}`}>
              {count}
            </span>
          )}
          {isActive && <ChevronRight size={14} className="flex-shrink-0" />}
        </button>
      </li>
    );
  };

  return (
    <nav
      className="w-[272px] h-screen max-h-screen min-h-0 flex flex-col overflow-hidden bg-white border-r border-gray-200"
      aria-label="Admin navigation"
    >
      {/* Brand */}
      <div className="flex items-center gap-3 px-5 h-20 border-b border-gray-200">
        <div className="w-10 h-10 rounded-lg bg-green-700 flex items-center justify-center flex-shrink-0">
          <Leaf size={28} className="text-white" />
        </div>
        <div>
          <div className="font-bold text-gray-950 text-base leading-none">AgriPortal</div>
          <div className="text-gray-500 text-[11px] mt-1 font-medium">Administration</div>
        </div>
      </div>

      {/* Navigation */}
      <div className="flex-1 min-h-0 py-5 overflow-y-auto overscroll-contain px-3 space-y-5">
        <div>
          <div className="px-3 py-1.5 text-[10px] font-bold tracking-widest text-gray-400 uppercase mb-1">Main</div>
          <ul className="space-y-1">
            {MAIN_NAV.map(item => <NavItem key={item.id} item={item} />)}
          </ul>
        </div>

        <div>
          <div className="px-3 py-1.5 text-[10px] font-bold tracking-widest text-gray-400 uppercase mb-1">Content</div>
          <ul className="space-y-1">
            {CONTENT_NAV.map(item => <NavItem key={item.id} item={item} />)}
          </ul>
        </div>

        <div>
          <div className="px-3 py-1.5 text-[10px] font-bold tracking-widest text-gray-400 uppercase mb-1">Reports & Settings</div>
          <ul className="space-y-1">
            {REPORT_NAV.map(item => <NavItem key={item.id} item={item} />)}
          </ul>
        </div>
      </div>

      {/* Footer */}
      <div className="border-t border-gray-200 px-4 py-4 flex items-center gap-3">
        <Avatar
          name={adminName}
          photoUrl={typeof window !== 'undefined' ? undefined : undefined}
          size={40}
          radius="8px"
          className="flex-shrink-0"
        />
        <div className="flex-1 min-w-0">
          <div className="text-gray-900 font-semibold text-sm truncate">{adminName}</div>
          <div className="text-gray-500 text-[11px] font-medium">Super Admin</div>
        </div>
        <button
          onClick={onLogout}
          className="p-2 rounded-lg text-gray-400 hover:bg-red-50 hover:text-red-600 transition-colors"
          title="Logout"
          aria-label="Logout"
        >
          <LogOut size={17} />
        </button>
      </div>
    </nav>
  );
}
