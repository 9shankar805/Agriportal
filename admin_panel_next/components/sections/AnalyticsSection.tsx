'use client';
import { useAdmin } from '@/context/AdminContext';
import { Users, ShieldCheck, MapPin, FileText } from 'lucide-react';

function BarChart({ data }: { data: { label: string; count: number; color: string; total: number }[] }) {
  return (
    <div className="space-y-4">
      {data.map(d => {
        const pct = d.total ? ((d.count / d.total) * 100).toFixed(1) : '0';
        return (
          <div key={d.label}>
            <div className="flex justify-between text-sm font-semibold mb-1.5">
              <span className="text-gray-700">{d.label}</span>
              <span style={{ color: d.color }}>{d.count}</span>
            </div>
            <div className="h-2.5 rounded-full bg-gray-100 overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-1000"
                style={{ width: `${pct}%`, background: d.color }}
              />
            </div>
          </div>
        );
      })}
    </div>
  );
}

export default function AnalyticsSection() {
  const { users, lands, apps } = useAdmin();

  const total    = users.length || 1;
  const farmers  = users.filter(u => u.role === 'farmer').length;
  const owners   = users.filter(u => u.role === 'landOwner').length;
  const verified = users.filter(u => u.kycStatus === 'verified').length;
  const pending  = users.filter(u => u.kycStatus === 'pending').length;
  const rejected = users.filter(u => u.kycStatus === 'rejected').length;

  const provinceCounts: Record<string, number> = {};
  lands.forEach(l => { provinceCounts[l.province] = (provinceCounts[l.province] || 0) + 1; });
  const maxProvince = Math.max(...Object.values(provinceCounts), 1);
  const provinceData = Object.entries(provinceCounts)
    .sort((a, b) => b[1] - a[1])
    .map(([label, count]) => ({ label, count, color: '#06b6d4', total: maxProvince }));

  const appStatuses = ['approved','pending','rejected'].map(s => ({
    label: s.charAt(0).toUpperCase() + s.slice(1),
    count: apps.filter(a => a.status === s).length,
    color: s === 'approved' ? '#22c55e' : s === 'pending' ? '#f59e0b' : '#ef4444',
    total: apps.length || 1,
  }));

  const tiles = [
    { icon: Users,       value: users.length,  label: 'Total Users',     color: '#22c55e' },
    { icon: ShieldCheck, value: verified,       label: 'KYC Verified',    color: '#6366f1' },
    { icon: MapPin,      value: lands.length,  label: 'Total Listings',  color: '#f59e0b' },
    { icon: FileText,    value: apps.length,   label: 'Applications',    color: '#06b6d4' },
  ];

  return (
    <div className="fade-up space-y-5">
      {/* Summary tiles */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {tiles.map(t => (
          <div key={t.label} className="bg-white rounded-xl p-6 text-center shadow-sm" style={{ borderTop: `3px solid ${t.color}` }}>
            <t.icon size={28} className="mx-auto mb-2" style={{ color: t.color }} />
            <div className="text-3xl font-extrabold count-up" style={{ color: t.color }}>{t.value}</div>
            <div className="text-xs text-gray-500 mt-1 font-medium">{t.label}</div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* User Role Distribution */}
        <div className="bg-white rounded-xl shadow-sm p-5">
          <h3 className="font-bold text-sm mb-4 flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-green-500 inline-block" />User Role Distribution
          </h3>
          <BarChart data={[
            { label: 'Farmers',     count: farmers, color: '#22c55e', total },
            { label: 'Land Owners', count: owners,  color: '#6366f1', total },
          ]} />
          <div className="grid grid-cols-2 gap-3 mt-4">
            <div className="bg-green-50 rounded-lg p-3 text-center">
              <div className="text-xl font-extrabold text-green-600">{farmers}</div>
              <div className="text-xs text-gray-500">Farmers</div>
            </div>
            <div className="bg-violet-50 rounded-lg p-3 text-center">
              <div className="text-xl font-extrabold text-violet-600">{owners}</div>
              <div className="text-xs text-gray-500">Land Owners</div>
            </div>
          </div>
        </div>

        {/* KYC Breakdown */}
        <div className="bg-white rounded-xl shadow-sm p-5">
          <h3 className="font-bold text-sm mb-4 flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-blue-500 inline-block" />KYC Status Breakdown
          </h3>
          <BarChart data={[
            { label: 'Verified', count: verified, color: '#22c55e', total },
            { label: 'Pending',  count: pending,  color: '#f59e0b', total },
            { label: 'Rejected', count: rejected, color: '#ef4444', total },
          ]} />
          <div className="grid grid-cols-3 gap-2 mt-4">
            {[['Verified',verified,'bg-green-50 text-green-600'],['Pending',pending,'bg-amber-50 text-amber-600'],['Rejected',rejected,'bg-red-50 text-red-600']].map(([l,v,c]) => (
              <div key={l as string} className={`rounded-lg p-2 text-center ${c as string}`}>
                <div className="text-lg font-extrabold">{v as number}</div>
                <div className="text-[10px] font-medium">{l as string}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Land by Province */}
        <div className="bg-white rounded-xl shadow-sm p-5">
          <h3 className="font-bold text-sm mb-4 flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-amber-500 inline-block" />Land Listings by Province
          </h3>
          {provinceData.length === 0
            ? <div className="text-gray-400 text-sm text-center py-6">No listings yet.</div>
            : <BarChart data={provinceData} />
          }
        </div>

        {/* Application Status */}
        <div className="bg-white rounded-xl shadow-sm p-5">
          <h3 className="font-bold text-sm mb-4 flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-purple-500 inline-block" />Application Status
          </h3>
          <BarChart data={appStatuses} />
          <div className="grid grid-cols-3 gap-2 mt-4">
            {appStatuses.map(s => (
              <div key={s.label} className="rounded-lg p-2 text-center bg-gray-50">
                <div className="text-lg font-extrabold" style={{ color: s.color }}>{s.count}</div>
                <div className="text-[10px] text-gray-500 font-medium">{s.label}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
