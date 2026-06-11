'use client';
import { useEffect, useState, useRef } from 'react';
import { Users, Hourglass, MapPin, MessageSquare, ShieldQuestion, Clock, FileCheck, Headphones, TrendingUp } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import StatCard from '@/components/ui/StatCard';
import Avatar from '@/components/ui/Avatar';
import Badge from '@/components/ui/Badge';
import { relTime, greeting, avatarColor } from '@/lib/utils';
import { LIVE_FEED_POOL } from '@/lib/seed';

const LIVE_COLORS = ['#22c55e','#f59e0b','#6366f1','#06b6d4','#ec4899'];

interface LiveItem { text: string; color: string; ts: number }

interface OverviewProps { onNav: (id: string) => void }

export default function Overview({ onNav }: OverviewProps) {
  const { users, lands, apps, convs, supportMsgs } = useAdmin();
  const [liveItems, setLiveItems] = useState<LiveItem[]>([]);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    const initial = LIVE_FEED_POOL.slice(0, 4).map((text, i) => ({
      text, color: LIVE_COLORS[i % LIVE_COLORS.length], ts: Date.now() - i * 90000,
    }));
    setLiveItems(initial);
    timerRef.current = setInterval(() => {
      const text  = LIVE_FEED_POOL[Math.floor(Math.random() * LIVE_FEED_POOL.length)];
      const color = LIVE_COLORS[Math.floor(Math.random() * LIVE_COLORS.length)];
      setLiveItems(prev => [{ text, color, ts: Date.now() }, ...prev].slice(0, 10));
    }, 4500);
    return () => { if (timerRef.current) clearInterval(timerRef.current); };
  }, []);

  const pendingKyc   = users.filter(u => u.kycStatus === 'pending').length;
  const pendingLands = lands.filter(l => l.status === 'pending').length;
  const pendingApps  = apps.filter(a => a.status === 'pending').length;
  const openSupport  = supportMsgs.filter(m => m.status === 'open').length;
  const recentUsers  = [...users].sort((a, b) => new Date(b.joined).getTime() - new Date(a.joined).getTime()).slice(0, 6);
  const pendingKycList = users.filter(u => u.kycStatus === 'pending').slice(0, 5);
  const recentConvs  = [...convs].sort((a, b) => b.ts - a.ts).slice(0, 8);

  const adminName = 'Admin';

  return (
    <div className="fade-up space-y-5">
      {/* Welcome strip */}
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div>
          <h2 className="font-extrabold text-lg">Good {greeting()}, {adminName} 👋</h2>
          <p className="text-sm text-gray-500">Here&apos;s what&apos;s happening on AgriPortal today.</p>
        </div>
      </div>

      {/* Main stat cards */}
      <div className="grid grid-cols-2 xl:grid-cols-4 gap-3">
        <StatCard icon={Users}        value={users.length}                    label="Total Users"      trend="↑ +12 this week"  trendUp accent="#22c55e" accentBg="#dcfce7" />
        <StatCard icon={Hourglass}    value={pendingKyc}                      label="Pending KYC"      trend="Needs review"               accent="#f59e0b" accentBg="#fef3c7" />
        <StatCard icon={MapPin}       value={lands.filter(l=>l.status==='active').length} label="Active Listings" trend="↑ +5 this week" trendUp accent="#6366f1" accentBg="#ede9fe" />
        <StatCard icon={MessageSquare}value={convs.length}                    label="Conversations"    trend="Real-time"                  accent="#06b6d4" accentBg="#cffafe" />
      </div>

      {/* Pending action cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard icon={ShieldQuestion}value={pendingKyc}   label="Pending KYC"         trend="→ Review now" accent="#f59e0b" accentBg="#fef3c7" onClick={() => onNav('kyc')} />
        <StatCard icon={Clock}         value={pendingLands} label="Pending Listings"     trend="→ Approve/Reject" accent="#8b5cf6" accentBg="#ede9fe" onClick={() => onNav('lands')} />
        <StatCard icon={FileCheck}     value={pendingApps}  label="Pending Applications" trend="→ Review" accent="#ec4899" accentBg="#fce7f3" onClick={() => onNav('applications')} />
        <StatCard icon={Headphones}    value={openSupport}  label="Open Support Msgs"    trend="→ Respond" accent="#14b8a6" accentBg="#ccfbf1" onClick={() => onNav('support')} />
      </div>

      {/* Three-column panels */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        {/* Recent Users */}
        <div className="lg:col-span-5 bg-white rounded-xl shadow-sm p-5">
          <div className="flex items-center justify-between mb-4">
            <span className="font-bold text-sm flex items-center gap-2"><Users size={15} className="text-green-500" />Recent Users</span>
            <button onClick={() => onNav('users')} className="text-xs text-green-600 font-semibold hover:underline flex items-center gap-1">View all →</button>
          </div>
          <div className="space-y-1">
            {recentUsers.map(u => (
              <div key={u.id} className="flex items-center gap-2.5 py-2 border-b border-gray-50 last:border-0">
                <Avatar name={u.name} size={34} />
                <div className="flex-1 min-w-0">
                  <div className="font-semibold text-sm truncate">{u.name}</div>
                  <div className="text-xs text-gray-400 truncate">{u.email}</div>
                </div>
                <Badge variant={u.role}>{u.role === 'farmer' ? 'Farmer' : 'Owner'}</Badge>
                <Badge variant={u.kycStatus}>{u.kycStatus.charAt(0).toUpperCase() + u.kycStatus.slice(1)}</Badge>
              </div>
            ))}
          </div>
        </div>

        {/* Pending KYC */}
        <div className="lg:col-span-4 bg-white rounded-xl shadow-sm p-5">
          <div className="flex items-center justify-between mb-4">
            <span className="font-bold text-sm flex items-center gap-2"><ShieldQuestion size={15} className="text-amber-500" />Pending KYC</span>
            <button onClick={() => onNav('kyc')} className="text-xs text-green-600 font-semibold hover:underline flex items-center gap-1">View all →</button>
          </div>
          {pendingKycList.length === 0 ? (
            <div className="text-sm text-gray-400 text-center py-4">✓ All KYC reviewed</div>
          ) : (
            <div className="space-y-1">
              {pendingKycList.map(u => (
                <KycQuickRow key={u.id} user={u} />
              ))}
            </div>
          )}
        </div>

        {/* Live Activity */}
        <div className="lg:col-span-3 bg-white rounded-xl shadow-sm p-5">
          <div className="flex items-center justify-between mb-4">
            <span className="font-bold text-sm flex items-center gap-2"><TrendingUp size={15} className="text-red-500" />Live Activity</span>
            <span className="flex items-center gap-1.5 bg-green-50 text-green-700 text-[10px] font-bold px-2 py-0.5 rounded-full border border-green-200">
              <span className="live-dot w-1.5 h-1.5 rounded-full bg-green-500 inline-block" />Now
            </span>
          </div>
          <div className="space-y-2 max-h-48 overflow-y-auto">
            {liveItems.map((item, i) => (
              <div key={i} className="flex gap-2.5 items-start py-1 border-b border-gray-50 last:border-0 fade-up">
                <div className="w-2 h-2 rounded-full mt-1.5 flex-shrink-0" style={{ background: item.color }} />
                <div>
                  <div className="text-xs leading-snug">{item.text}</div>
                  <div className="text-[10px] text-gray-400">{relTime(item.ts)}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Message Feed */}
      {recentConvs.length > 0 && (
        <div className="bg-white rounded-xl shadow-sm p-5">
          <div className="flex items-center justify-between mb-4">
            <span className="font-bold text-sm flex items-center gap-2"><MessageSquare size={15} className="text-blue-500" />Latest Message Activity</span>
            <button onClick={() => onNav('messages')} className="text-xs text-green-600 font-semibold hover:underline flex items-center gap-1">Open Messages →</button>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3">
            {recentConvs.map(c => (
              <div
                key={c.id}
                className="bg-green-50/60 border border-green-100 rounded-lg p-3 flex gap-2.5 hover:bg-green-50 cursor-pointer transition-colors"
                onClick={() => onNav('messages')}
              >
                <div className="w-9 h-9 rounded-full flex items-center justify-center font-bold text-white text-sm flex-shrink-0"
                  style={{ background: avatarColor(c.aName) }}>
                  {c.aName[0]}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-center mb-0.5">
                    <div className="font-semibold text-xs truncate">{c.aName} ↔ {c.bName}</div>
                    <div className="text-[10px] text-gray-400 ml-1 flex-shrink-0">{relTime(c.ts)}</div>
                  </div>
                  <div className="text-[10px] text-gray-400 truncate">{c.land}</div>
                  <div className="text-xs truncate mt-0.5">{c.lastMsg}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

function KycQuickRow({ user }: { user: import('@/lib/types').AppUser }) {
  const { users, setUsers, showToast, firebaseReady } = useAdmin();

  const approve = async () => {
    setUsers(prev => prev.map(u => u.id === user.id ? { ...u, kycStatus: 'verified' } : u));
    if (firebaseReady) {
      try {
        const { db, updateDoc, doc, addDoc, collection, serverTimestamp } = await import('@/lib/firebase');
        await updateDoc(doc(db, 'users', user.id), { kycStatus: 'verified', kycReviewedAt: serverTimestamp() });
        await addDoc(collection(db, `users/${user.id}/notifications`), {
          title: 'KYC Verified ✓',
          body: 'Your KYC has been verified! You can now apply for land listings.',
          type: 'kyc', isRead: false, createdAt: serverTimestamp(),
        });
      } catch {}
    }
    showToast(`KYC approved for ${user.name}`, 'success');
  };

  const reject = async () => {
    setUsers(prev => prev.map(u => u.id === user.id ? { ...u, kycStatus: 'rejected' } : u));
    if (firebaseReady) {
      try {
        const { db, updateDoc, doc, addDoc, collection, serverTimestamp } = await import('@/lib/firebase');
        await updateDoc(doc(db, 'users', user.id), { kycStatus: 'rejected', kycReviewedAt: serverTimestamp() });
        await addDoc(collection(db, `users/${user.id}/notifications`), {
          title: 'KYC Not Approved',
          body: 'Your KYC was not approved. Please resubmit with clearer documents.',
          type: 'kyc', isRead: false, createdAt: serverTimestamp(),
        });
      } catch {}
    }
    showToast(`KYC rejected for ${user.name}`, 'warning');
  };

  return (
    <div className="flex items-center gap-2 py-2 border-b border-gray-50 last:border-0">
      <Avatar name={user.name} size={32} />
      <div className="flex-1 min-w-0">
        <div className="font-semibold text-xs truncate">{user.name}</div>
        <div className="text-[10px] text-gray-400">{user.phone}</div>
      </div>
      <button onClick={approve} className="w-7 h-7 rounded-lg bg-green-100 hover:bg-green-200 text-green-700 flex items-center justify-center transition-colors" title="Approve KYC">
        <svg width="12" height="12" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
      </button>
      <button onClick={reject} className="w-7 h-7 rounded-lg bg-red-50 hover:bg-red-100 text-red-600 flex items-center justify-center transition-colors" title="Reject KYC">
        <svg width="12" height="12" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>
  );
}
