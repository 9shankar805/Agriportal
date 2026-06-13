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
          className={`w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl text-sm font-bold transition-all duration-200 group
            ${isActive
              ? 'bg-white/20 text-white shadow-lg border border-white/30'
              : 'text-white/70 hover:bg-white/10 hover:text-white hover:translate-x-1'
            }`}
          aria-current={isActive ? 'page' : undefined}
        >
          <item.icon size={20} className="flex-shrink-0" />
          <span className="flex-1 text-left">{item.label}</span>
          {count > 0 && (
            <span className={`text-[11px] font-black px-2.5 py-1 rounded-full flex-shrink-0 shadow-sm
              ${item.warn ? 'bg-amber-400 text-amber-900' : 'bg-green-400 text-green-900'}`}>
              {count}
            </span>
          )}
          {isActive && <ChevronRight size={16} className="flex-shrink-0" />}
        </button>
      </li>
    );
  };

  return (
    <nav
      className="w-72 min-h-screen flex flex-col shadow-xl"
      style={{ background: 'linear-gradient(180deg, #14532d 0%, #166534 40%, #15803d 100%)' }}
      aria-label="Admin navigation"
    >
      {/* Brand */}
      <div className="flex items-center gap-4 px-6 py-7 border-b border-white/10">
        <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-green-400 to-emerald-600 flex items-center justify-center flex-shrink-0 shadow-lg">
          <Leaf size={28} className="text-white" />
        </div>
        <div>
          <div className="font-black text-white text-xl leading-none">AgriPortal</div>
          <div className="text-white/60 text-xs mt-1 font-semibold">Admin Console</div>
        </div>
      </div>

      {/* Navigation */}
      <div className="flex-1 py-6 overflow-y-auto px-4 space-y-5">
        <div>
          <div className="px-4 py-2 text-[11px] font-black tracking-widest text-white/40 uppercase mb-2">Main</div>
          <ul className="space-y-2">
            {MAIN_NAV.map(item => <NavItem key={item.id} item={item} />)}
          </ul>
        </div>

        <div>
          <div className="px-4 py-2 text-[11px] font-black tracking-widest text-white/40 uppercase mb-2">Content</div>
          <ul className="space-y-2">
            {CONTENT_NAV.map(item => <NavItem key={item.id} item={item} />)}
          </ul>
        </div>

        <div>
          <div className="px-4 py-2 text-[11px] font-black tracking-widest text-white/40 uppercase mb-2">Reports & Settings</div>
          <ul className="space-y-2">
            {REPORT_NAV.map(item => <NavItem key={item.id} item={item} />)}
          </ul>
        </div>
      </div>

      {/* Footer */}
      <div className="border-t border-white/10 px-5 py-6 flex items-center gap-4 mx-4 my-4 rounded-3xl bg-white/10">
        <Avatar
          name={adminName}
          photoUrl={typeof window !== 'undefined' ? undefined : undefined}
          size={52}
          radius="16px"
          className="border-2 border-white/30 flex-shrink-0 shadow-md"
        />
        <div className="flex-1 min-w-0">
          <div className="text-white font-extrabold text-sm truncate">{adminName}</div>
          <div className="text-white/60 text-xs font-medium">Super Admin</div>
        </div>
        <button
          onClick={onLogout}
          className="p-3 rounded-2xl text-white/70 hover:bg-white/20 hover:text-white transition-all"
          title="Logout"
          aria-label="Logout"
        >
          <LogOut size={20} />
        </button>
      </div>
    </nav>
  );
}
