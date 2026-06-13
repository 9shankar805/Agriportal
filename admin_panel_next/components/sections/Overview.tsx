'use client';
import { useEffect, useState, useRef } from 'react';
import { Users, Hourglass, MapPin, MessageSquare, ShieldQuestion, Clock, FileCheck, Headphones, TrendingUp, ArrowRight, UserPlus, CheckCircle2, XCircle } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import StatCard from '@/components/ui/StatCard';
import Avatar from '@/components/ui/Avatar';
import Badge from '@/components/ui/Badge';
import { relTime, greeting, avatarColor } from '@/lib/utils';
import { LIVE_FEED_POOL } from '@/lib/seed';

const LIVE_COLORS = ['#22c55e', '#f59e0b', '#6366f1', '#06b6d4', '#ec4899'];

interface LiveItem { text: string; color: string; ts: number }

interface OverviewProps { onNav: (id: string) => void }

export default function Overview({ onNav }: OverviewProps) {
  const { users, lands, apps, convs, supportMsgs, authUser } = useAdmin();
  const [liveItems, setLiveItems] = useState<LiveItem[]>([]);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    const initial = LIVE_FEED_POOL.slice(0, 4).map((text, i) => ({
      text, 
      color: LIVE_COLORS[i % LIVE_COLORS.length], 
      ts: Date.now() - i * 90000,
    }));
    setLiveItems(initial);
    
    timerRef.current = setInterval(() => {
      const text = LIVE_FEED_POOL[Math.floor(Math.random() * LIVE_FEED_POOL.length)];
      const color = LIVE_COLORS[Math.floor(Math.random() * LIVE_COLORS.length)];
      setLiveItems(prev => [{ text, color, ts: Date.now() }, ...prev].slice(0, 10));
    }, 4500);
    
    return () => { 
      if (timerRef.current) clearInterval(timerRef.current); 
    };
  }, []);

  const pendingKyc = users.filter(u => u.kycStatus === 'pending').length;
  const pendingLands = lands.filter(l => l.status === 'pending').length;
  const pendingApps = apps.filter(a => a.status === 'pending').length;
  const openSupport = supportMsgs.filter(m => m.status === 'open').length;
  const recentUsers = [...users].sort((a, b) => new Date(b.joined).getTime() - new Date(a.joined).getTime()).slice(0, 6);
  const pendingKycList = users.filter(u => u.kycStatus === 'pending').slice(0, 5);
  const recentConvs = [...convs].sort((a, b) => b.ts - a.ts).slice(0, 8);

  const adminName = authUser?.displayName || (authUser?.email ? authUser.email.split('@')[0] : 'Admin');

  return (
    <div className="space-y-7">
      {/* Welcome strip */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-5">
        <div>
          <h2 className="text-3xl font-extrabold text-gray-900">Good {greeting()}, {adminName} 👋</h2>
          <p className="text-gray-500 mt-2 text-lg">Here's what's happening on AgriPortal today.</p>
        </div>
      </div>

      {/* Main stat cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">
        <StatCard 
          icon={Users} 
          value={users.length} 
          label="Total Users" 
          trend="↑ +12 this week" 
          trendUp 
          accent="#22c55e" 
          accentBg="#dcfce7" 
        />
        <StatCard 
          icon={Hourglass} 
          value={pendingKyc} 
          label="Pending KYC" 
          trend="Needs review" 
          accent="#f59e0b" 
          accentBg="#fef3c7" 
        />
        <StatCard 
          icon={MapPin} 
          value={lands.filter(l => l.status === 'active').length} 
          label="Active Listings" 
          trend="↑ +5 this week" 
          trendUp 
          accent="#6366f1" 
          accentBg="#ede9fe" 
        />
        <StatCard 
          icon={MessageSquare} 
          value={convs.length} 
          label="Conversations" 
          trend="Real-time" 
          accent="#06b6d4" 
          accentBg="#cffafe" 
        />
      </div>

      {/* Pending action cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div 
          onClick={() => onNav('kyc')}
          className="group cursor-pointer bg-gradient-to-br from-amber-50 to-orange-50 border border-amber-200 rounded-3xl p-7 transition-all hover:shadow-xl hover:-translate-y-2 shadow-sm"
        >
          <div className="flex items-center justify-between mb-5">
            <div className="w-12 h-12 rounded-2xl bg-amber-100 flex items-center justify-center text-amber-600 shadow-sm">
              <ShieldQuestion size={24} />
            </div>
            <div className="text-4xl font-extrabold text-amber-700">{pendingKyc}</div>
          </div>
          <h3 className="font-extrabold text-gray-900 mb-2 text-lg">Pending KYC</h3>
          <p className="text-sm text-gray-500 mb-5">Review user verifications</p>
          <div className="flex items-center text-amber-600 text-sm font-extrabold group-hover:text-amber-700">
            <span>Review now</span>
            <ArrowRight size={18} className="ml-2 group-hover:translate-x-1 transition-transform" />
          </div>
        </div>
        
        <div 
          onClick={() => onNav('lands')}
          className="group cursor-pointer bg-gradient-to-br from-indigo-50 to-purple-50 border border-indigo-200 rounded-3xl p-7 transition-all hover:shadow-xl hover:-translate-y-2 shadow-sm"
        >
          <div className="flex items-center justify-between mb-5">
            <div className="w-12 h-12 rounded-2xl bg-indigo-100 flex items-center justify-center text-indigo-600 shadow-sm">
              <Clock size={24} />
            </div>
            <div className="text-4xl font-extrabold text-indigo-700">{pendingLands}</div>
          </div>
          <h3 className="font-extrabold text-gray-900 mb-2 text-lg">Pending Listings</h3>
          <p className="text-sm text-gray-500 mb-5">Approve or reject lands</p>
          <div className="flex items-center text-indigo-600 text-sm font-extrabold group-hover:text-indigo-700">
            <span>Manage</span>
            <ArrowRight size={18} className="ml-2 group-hover:translate-x-1 transition-transform" />
          </div>
        </div>
        
        <div 
          onClick={() => onNav('applications')}
          className="group cursor-pointer bg-gradient-to-br from-pink-50 to-rose-50 border border-pink-200 rounded-3xl p-7 transition-all hover:shadow-xl hover:-translate-y-2 shadow-sm"
        >
          <div className="flex items-center justify-between mb-5">
            <div className="w-12 h-12 rounded-2xl bg-pink-100 flex items-center justify-center text-pink-600 shadow-sm">
              <FileCheck size={24} />
            </div>
            <div className="text-4xl font-extrabold text-pink-700">{pendingApps}</div>
          </div>
          <h3 className="font-extrabold text-gray-900 mb-2 text-lg">Pending Applications</h3>
          <p className="text-sm text-gray-500 mb-5">Review user applications</p>
          <div className="flex items-center text-pink-600 text-sm font-extrabold group-hover:text-pink-700">
            <span>Review</span>
            <ArrowRight size={18} className="ml-2 group-hover:translate-x-1 transition-transform" />
          </div>
        </div>
        
        <div 
          onClick={() => onNav('support')}
          className="group cursor-pointer bg-gradient-to-br from-teal-50 to-cyan-50 border border-teal-200 rounded-3xl p-7 transition-all hover:shadow-xl hover:-translate-y-2 shadow-sm"
        >
          <div className="flex items-center justify-between mb-5">
            <div className="w-12 h-12 rounded-2xl bg-teal-100 flex items-center justify-center text-teal-600 shadow-sm">
              <Headphones size={24} />
            </div>
            <div className="text-4xl font-extrabold text-teal-700">{openSupport}</div>
          </div>
          <h3 className="font-extrabold text-gray-900 mb-2 text-lg">Open Support Msgs</h3>
          <p className="text-sm text-gray-500 mb-5">Respond to user queries</p>
          <div className="flex items-center text-teal-600 text-sm font-extrabold group-hover:text-teal-700">
            <span>Respond</span>
            <ArrowRight size={18} className="ml-2 group-hover:translate-x-1 transition-transform" />
          </div>
        </div>
      </div>

      {/* Three-column panels */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Recent Users */}
        <div className="lg:col-span-5 bg-white rounded-3xl shadow-md border border-gray-100 p-7">
          <div className="flex items-center justify-between mb-6">
            <span className="font-extrabold text-gray-900 text-lg flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center text-green-600">
                <UserPlus size={20} />
              </div>
              Recent Users
            </span>
            <button onClick={() => onNav('users')} className="text-sm font-extrabold text-green-600 hover:text-green-700 flex items-center gap-2 transition-colors">
              View all <ArrowRight size={16} />
            </button>
          </div>
          <div className="space-y-4">
            {recentUsers.map(u => (
              <div key={u.id} className="flex items-center gap-4 p-4 rounded-2xl bg-gray-50/70 hover:bg-gray-50 transition-all hover:shadow-sm">
                <Avatar name={u.name} photoUrl={u.photoUrl} size={48} />
                <div className="flex-1 min-w-0">
                  <div className="font-extrabold text-gray-900 truncate">{u.name}</div>
                  <div className="text-sm text-gray-500 truncate">{u.email}</div>
                </div>
                <div className="flex items-center gap-2">
                  <Badge variant={u.role}>{u.role === 'farmer' ? 'Farmer' : 'Land Owner'}</Badge>
                  <Badge variant={u.kycStatus}>{u.kycStatus.charAt(0).toUpperCase() + u.kycStatus.slice(1)}</Badge>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Pending KYC */}
        <div className="lg:col-span-4 bg-white rounded-3xl shadow-md border border-gray-100 p-7">
          <div className="flex items-center justify-between mb-6">
            <span className="font-extrabold text-gray-900 text-lg flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center text-amber-600">
                <ShieldQuestion size={20} />
              </div>
              Pending KYC
            </span>
            <button onClick={() => onNav('kyc')} className="text-sm font-extrabold text-green-600 hover:text-green-700 flex items-center gap-2 transition-colors">
              View all <ArrowRight size={16} />
            </button>
          </div>
          {pendingKycList.length === 0 ? (
            <div className="text-center py-12">
              <div className="w-16 h-16 rounded-full bg-green-50 flex items-center justify-center mx-auto mb-4">
                <CheckCircle2 size={32} className="text-green-500" />
              </div>
              <div className="text-sm font-medium text-gray-500">All KYC reviewed</div>
            </div>
          ) : (
            <div className="space-y-4">
              {pendingKycList.map(u => (
                <KycQuickRow key={u.id} user={u} />
              ))}
            </div>
          )}
        </div>

        {/* Live Activity */}
        <div className="lg:col-span-3 bg-white rounded-3xl shadow-md border border-gray-100 p-7">
          <div className="flex items-center justify-between mb-6">
            <span className="font-extrabold text-gray-900 text-lg flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-rose-50 flex items-center justify-center text-rose-600">
                <TrendingUp size={20} />
              </div>
              Live Activity
            </span>
            <span className="flex items-center gap-2 bg-gradient-to-r from-green-50 to-emerald-50 text-green-700 text-xs font-extrabold px-3 py-1.5 rounded-full border border-green-200">
              <span className="w-2.5 h-2.5 rounded-full bg-green-500 inline-block animate-pulse"></span>
              Now
            </span>
          </div>
          <div className="space-y-4 max-h-64 overflow-y-auto pr-2">
            {liveItems.map((item, i) => (
              <div key={i} className="flex gap-4 items-start py-3 border-b border-gray-100 last:border-0">
                <div className="w-3 h-3 rounded-full mt-1 flex-shrink-0" style={{ background: item.color }} />
                <div>
                  <div className="text-sm text-gray-700 leading-relaxed">{item.text}</div>
                  <div className="text-xs text-gray-400 mt-1">{relTime(item.ts)}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Message Feed */}
      {recentConvs.length > 0 && (
        <div className="bg-white rounded-3xl shadow-md border border-gray-100 p-7">
          <div className="flex items-center justify-between mb-6">
            <span className="font-extrabold text-gray-900 text-lg flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600">
                <MessageSquare size={20} />
              </div>
              Latest Message Activity
            </span>
            <button onClick={() => onNav('messages')} className="text-sm font-extrabold text-green-600 hover:text-green-700 flex items-center gap-2 transition-colors">
              Open Messages <ArrowRight size={16} />
            </button>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">
            {recentConvs.map(c => (
              <div
                key={c.id}
                onClick={() => onNav('messages')}
                className="bg-gradient-to-br from-green-50/90 to-emerald-50/90 border border-green-200 rounded-2xl p-5 flex gap-4 hover:from-green-50 hover:to-emerald-50 hover:shadow-lg cursor-pointer transition-all hover:-translate-y-1"
              >
                <div 
                  className="w-12 h-12 rounded-full flex items-center justify-center font-extrabold text-white text-base flex-shrink-0"
                  style={{ background: avatarColor(c.aName) }}
                >
                  {c.aName[0]}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-center mb-2">
                    <div className="font-extrabold text-base truncate text-gray-900">{c.aName} ↔ {c.bName}</div>
                    <div className="text-xs text-gray-400 ml-2 flex-shrink-0">{relTime(c.ts)}</div>
                  </div>
                  <div className="text-xs text-gray-500 truncate">{c.land}</div>
                  <div className="text-sm truncate mt-2 text-gray-700">{c.lastMsg}</div>
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
  const { setUsers, showToast, firebaseReady } = useAdmin();

  const approve = async () => {
    setUsers(prev => prev.map(u => u.id === user.id ? { ...u, kycStatus: 'verified' } : u));
    if (firebaseReady) {
      try {
        const { db, updateDoc, doc, addDoc, collection, serverTimestamp } = await import('@/lib/firebase');
        await updateDoc(doc(db, 'users', user.id), { kycStatus: 'verified', kycReviewedAt: serverTimestamp() });
        await addDoc(collection(db, `users/${user.id}/notifications`), {
          title: 'KYC Verified ✓',
          body: 'Your KYC has been verified! You can now apply for land listings.',
          type: 'kyc',
          isRead: false,
          createdAt: serverTimestamp(),
        });
      } catch (e) {
        console.error('Error approving KYC:', e);
      }
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
          type: 'kyc',
          isRead: false,
          createdAt: serverTimestamp(),
        });
      } catch (e) {
        console.error('Error rejecting KYC:', e);
      }
    }
    showToast(`KYC rejected for ${user.name}`, 'warning');
  };

  return (
    <div className="flex items-center gap-4 p-4 rounded-2xl bg-amber-50/60 hover:bg-amber-50 transition-all hover:shadow-sm">
      <Avatar name={user.name} photoUrl={user.photoUrl} size={48} />
      <div className="flex-1 min-w-0">
        <div className="font-extrabold text-sm text-gray-900 truncate">{user.name}</div>
        <div className="text-sm text-gray-500">{user.phone}</div>
      </div>
      <div className="flex items-center gap-3">
        <button 
          onClick={approve} 
          className="w-10 h-10 rounded-xl bg-green-100 hover:bg-green-200 text-green-700 flex items-center justify-center transition-all hover:scale-110 active:scale-95 shadow-sm" 
          title="Approve KYC"
        >
          <CheckCircle2 size={20} />
        </button>
        <button 
          onClick={reject} 
          className="w-10 h-10 rounded-xl bg-red-50 hover:bg-red-100 text-red-600 flex items-center justify-center transition-all hover:scale-110 active:scale-95 shadow-sm" 
          title="Reject KYC"
        >
          <XCircle size={20} />
        </button>
      </div>
    </div>
  );
}
