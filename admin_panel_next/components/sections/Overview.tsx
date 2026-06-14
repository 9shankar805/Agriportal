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
    <div className="space-y-6">
      {/* Welcome strip */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-5">
        <div>
          <h2 className="text-2xl font-bold text-gray-950">Good {greeting()}, {adminName}</h2>
          <p className="text-gray-500 mt-1 text-sm">Here is today&apos;s operational snapshot for AgriPortal.</p>
        </div>
      </div>

      {/* Main stat cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
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
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div 
          onClick={() => onNav('kyc')}
          className="group cursor-pointer bg-white border border-gray-200 rounded-lg p-5 transition-all hover:border-amber-300 hover:shadow-md"
        >
          <div className="flex items-center justify-between mb-4">
            <div className="w-10 h-10 rounded-lg bg-amber-50 flex items-center justify-center text-amber-600">
              <ShieldQuestion size={20} />
            </div>
            <div className="text-3xl font-bold text-gray-950">{pendingKyc}</div>
          </div>
          <h3 className="font-semibold text-gray-900 mb-1 text-sm">Pending KYC</h3>
          <p className="text-xs text-gray-500 mb-4">Review user verifications</p>
          <div className="flex items-center text-green-700 text-xs font-semibold">
            <span>Review now</span>
            <ArrowRight size={14} className="ml-2 group-hover:translate-x-1 transition-transform" />
          </div>
        </div>
        
        <div 
          onClick={() => onNav('lands')}
          className="group cursor-pointer bg-white border border-gray-200 rounded-lg p-5 transition-all hover:border-indigo-300 hover:shadow-md"
        >
          <div className="flex items-center justify-between mb-4">
            <div className="w-10 h-10 rounded-lg bg-indigo-50 flex items-center justify-center text-indigo-600">
              <Clock size={20} />
            </div>
            <div className="text-3xl font-bold text-gray-950">{pendingLands}</div>
          </div>
          <h3 className="font-semibold text-gray-900 mb-1 text-sm">Pending Listings</h3>
          <p className="text-xs text-gray-500 mb-4">Approve or reject lands</p>
          <div className="flex items-center text-green-700 text-xs font-semibold">
            <span>Manage</span>
            <ArrowRight size={14} className="ml-2 group-hover:translate-x-1 transition-transform" />
          </div>
        </div>
        
        <div 
          onClick={() => onNav('applications')}
          className="group cursor-pointer bg-white border border-gray-200 rounded-lg p-5 transition-all hover:border-rose-300 hover:shadow-md"
        >
          <div className="flex items-center justify-between mb-4">
            <div className="w-10 h-10 rounded-lg bg-rose-50 flex items-center justify-center text-rose-600">
              <FileCheck size={20} />
            </div>
            <div className="text-3xl font-bold text-gray-950">{pendingApps}</div>
          </div>
          <h3 className="font-semibold text-gray-900 mb-1 text-sm">Pending Applications</h3>
          <p className="text-xs text-gray-500 mb-4">Review user applications</p>
          <div className="flex items-center text-green-700 text-xs font-semibold">
            <span>Review</span>
            <ArrowRight size={14} className="ml-2 group-hover:translate-x-1 transition-transform" />
          </div>
        </div>
        
        <div 
          onClick={() => onNav('support')}
          className="group cursor-pointer bg-white border border-gray-200 rounded-lg p-5 transition-all hover:border-cyan-300 hover:shadow-md"
        >
          <div className="flex items-center justify-between mb-4">
            <div className="w-10 h-10 rounded-lg bg-cyan-50 flex items-center justify-center text-cyan-600">
              <Headphones size={20} />
            </div>
            <div className="text-3xl font-bold text-gray-950">{openSupport}</div>
          </div>
          <h3 className="font-semibold text-gray-900 mb-1 text-sm">Open Support Messages</h3>
          <p className="text-xs text-gray-500 mb-4">Respond to user queries</p>
          <div className="flex items-center text-green-700 text-xs font-semibold">
            <span>Respond</span>
            <ArrowRight size={14} className="ml-2 group-hover:translate-x-1 transition-transform" />
          </div>
        </div>
      </div>

      {/* Three-column panels */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        {/* Recent Users */}
        <div className="lg:col-span-5 bg-white rounded-lg shadow-sm border border-gray-200 p-5">
          <div className="flex items-center justify-between mb-4">
            <span className="font-semibold text-gray-900 text-sm flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center text-gray-600">
                <UserPlus size={16} />
              </div>
              Recent Users
            </span>
            <button onClick={() => onNav('users')} className="text-xs font-semibold text-green-700 hover:text-green-800 flex items-center gap-1.5 transition-colors">
              View all <ArrowRight size={14} />
            </button>
          </div>
          <div className="space-y-1">
            {recentUsers.map(u => (
              <div key={u.id} className="flex items-center gap-3 px-2 py-3 rounded-lg hover:bg-gray-50 transition-colors">
                <Avatar name={u.name} photoUrl={u.photoUrl} size={40} />
                <div className="flex-1 min-w-0">
                  <div className="font-semibold text-sm text-gray-900 truncate">{u.name}</div>
                  <div className="text-xs text-gray-500 truncate">{u.email}</div>
                </div>
                <div className="hidden sm:flex items-center gap-1.5">
                  <Badge variant={u.role}>{u.role === 'farmer' ? 'Farmer' : 'Land Owner'}</Badge>
                  <Badge variant={u.kycStatus}>{u.kycStatus.charAt(0).toUpperCase() + u.kycStatus.slice(1)}</Badge>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Pending KYC */}
        <div className="lg:col-span-4 bg-white rounded-lg shadow-sm border border-gray-200 p-5">
          <div className="flex items-center justify-between mb-4">
            <span className="font-semibold text-gray-900 text-sm flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-amber-50 flex items-center justify-center text-amber-600">
                <ShieldQuestion size={16} />
              </div>
              Pending KYC
            </span>
            <button onClick={() => onNav('kyc')} className="text-xs font-semibold text-green-700 hover:text-green-800 flex items-center gap-1.5 transition-colors">
              View all <ArrowRight size={14} />
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
            <div className="space-y-1">
              {pendingKycList.map(u => (
                <KycQuickRow key={u.id} user={u} />
              ))}
            </div>
          )}
        </div>

        {/* Live Activity */}
        <div className="lg:col-span-3 bg-white rounded-lg shadow-sm border border-gray-200 p-5">
          <div className="flex items-center justify-between mb-4">
            <span className="font-semibold text-gray-900 text-sm flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center text-gray-600">
                <TrendingUp size={16} />
              </div>
              Live Activity
            </span>
            <span className="flex items-center gap-1.5 bg-green-50 text-green-700 text-[10px] font-semibold px-2 py-1 rounded-full border border-green-200">
              <span className="w-2 h-2 rounded-full bg-green-500 inline-block live-dot"></span>
              Now
            </span>
          </div>
          <div className="max-h-64 overflow-y-auto pr-2">
            {liveItems.map((item, i) => (
              <div key={i} className="flex gap-3 items-start py-3 border-b border-gray-100 last:border-0">
                <div className="w-2 h-2 rounded-full mt-1.5 flex-shrink-0" style={{ background: item.color }} />
                <div>
                  <div className="text-xs text-gray-700 leading-relaxed">{item.text}</div>
                  <div className="text-xs text-gray-400 mt-1">{relTime(item.ts)}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Message Feed */}
      {recentConvs.length > 0 && (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-5">
          <div className="flex items-center justify-between mb-4">
            <span className="font-semibold text-gray-900 text-sm flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center text-gray-600">
                <MessageSquare size={16} />
              </div>
              Latest Message Activity
            </span>
            <button onClick={() => onNav('messages')} className="text-xs font-semibold text-green-700 hover:text-green-800 flex items-center gap-1.5 transition-colors">
              Open Messages <ArrowRight size={14} />
            </button>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3">
            {recentConvs.map(c => (
              <div
                key={c.id}
                onClick={() => onNav('messages')}
                className="bg-white border border-gray-200 rounded-lg p-4 flex gap-3 hover:border-green-300 hover:shadow-sm cursor-pointer transition-all"
              >
                <div 
                  className="w-10 h-10 rounded-lg flex items-center justify-center font-bold text-white text-sm flex-shrink-0"
                  style={{ background: avatarColor(c.aName) }}
                >
                  {c.aName[0]}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-center mb-1">
                    <div className="font-semibold text-sm truncate text-gray-900">{c.aName} ↔ {c.bName}</div>
                    <div className="text-xs text-gray-400 ml-2 flex-shrink-0">{relTime(c.ts)}</div>
                  </div>
                  <div className="text-xs text-gray-500 truncate">{c.land}</div>
                  <div className="text-xs truncate mt-2 text-gray-700">{c.lastMsg}</div>
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
    <div className="flex items-center gap-3 px-2 py-3 rounded-lg hover:bg-gray-50 transition-colors">
      <Avatar name={user.name} photoUrl={user.photoUrl} size={40} />
      <div className="flex-1 min-w-0">
        <div className="font-semibold text-sm text-gray-900 truncate">{user.name}</div>
        <div className="text-xs text-gray-500">{user.phone}</div>
      </div>
      <div className="flex items-center gap-1.5">
        <button 
          onClick={approve} 
          className="w-8 h-8 rounded-lg bg-green-50 hover:bg-green-100 text-green-700 flex items-center justify-center transition-colors"
          title="Approve KYC"
        >
          <CheckCircle2 size={16} />
        </button>
        <button 
          onClick={reject} 
          className="w-8 h-8 rounded-lg bg-red-50 hover:bg-red-100 text-red-600 flex items-center justify-center transition-colors"
          title="Reject KYC"
        >
          <XCircle size={16} />
        </button>
      </div>
    </div>
  );
}
