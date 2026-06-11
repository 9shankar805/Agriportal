'use client';
import { useState, useEffect } from 'react';
import Sidebar from './layout/Sidebar';
import Topbar from './layout/Topbar';
import Overview from './sections/Overview';
import UsersSection from './sections/UsersSection';
import KycSection from './sections/KycSection';
import LandsSection from './sections/LandsSection';
import ApplicationsSection from './sections/ApplicationsSection';
import MessagesSection from './sections/MessagesSection';
import AnalyticsSection from './sections/AnalyticsSection';
import SupportSection from './sections/SupportSection';
import SettingsSection from './sections/SettingsSection';
import { useAdmin } from '@/context/AdminContext';

type SectionId = 'overview'|'users'|'kyc'|'lands'|'applications'|'messages'|'analytics'|'support'|'settings';

interface DashboardProps {
  adminName: string;
  onLogout: () => void;
}

export default function Dashboard({ adminName, onLogout }: DashboardProps) {
  const { loadAllFirebase } = useAdmin();
  const [section,     setSection]     = useState<SectionId>('overview');
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    loadAllFirebase();
  }, [loadAllFirebase]);

  const nav = (id: string) => {
    setSection(id as SectionId);
    setSidebarOpen(false);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleLogout = () => {
    import('@/lib/firebase').then(({ logOut }) => logOut().catch(() => {}));
    onLogout();
  };

  const sectionMap: Record<SectionId, React.ReactNode> = {
    overview:     <Overview onNav={nav} />,
    users:        <UsersSection />,
    kyc:          <KycSection />,
    lands:        <LandsSection />,
    applications: <ApplicationsSection />,
    messages:     <MessagesSection />,
    analytics:    <AnalyticsSection />,
    support:      <SupportSection />,
    settings:     <SettingsSection />,
  };

  return (
    <div className="flex min-h-screen">
      {/* Mobile sidebar backdrop */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-black/40 z-[150] lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div className={`fixed top-0 left-0 h-full z-[200] transition-transform duration-300 lg:translate-x-0 lg:static lg:block
        ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <Sidebar active={section} onNav={nav} onLogout={handleLogout} adminName={adminName} />
      </div>

      {/* Main */}
      <div className="flex-1 flex flex-col min-h-screen lg:ml-0" style={{ minWidth: 0 }}>
        <Topbar
          section={section}
          onMenuClick={() => setSidebarOpen(true)}
          onRefresh={() => loadAllFirebase()}
        />
        <main className="flex-1 p-5 md:p-6 overflow-y-auto">
          {sectionMap[section]}
        </main>
      </div>
    </div>
  );
}
