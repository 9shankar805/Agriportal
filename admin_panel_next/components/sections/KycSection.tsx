'use client';
import { useState } from 'react';
import { Search, CheckCircle, XCircle, RotateCcw, ExternalLink } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Avatar from '@/components/ui/Avatar';
import Badge from '@/components/ui/Badge';
import Modal from '@/components/ui/Modal';
import type { AppUser } from '@/lib/types';

type KycTab = 'pending' | 'verified' | 'rejected' | '';

export default function KycSection() {
  const { users, setUsers, showToast, firebaseReady } = useAdmin();
  const [tab,    setTab]    = useState<KycTab>('pending');
  const [search, setSearch] = useState('');
  const [confirm, setConfirm] = useState<{ user: AppUser; action: 'approve' | 'reject' | 'reset' } | null>(null);

  const list = users.filter(u =>
    (!tab    || u.kycStatus === tab) &&
    (!search || u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase()))
  );

  const updateKyc = async (u: AppUser, status: 'verified' | 'rejected' | 'pending') => {
    setUsers(prev => prev.map(x => x.id === u.id ? { ...x, kycStatus: status } : x));
    if (firebaseReady) {
      try {
        const { db, updateDoc, doc, addDoc, collection, serverTimestamp } = await import('@/lib/firebase');
        await updateDoc(doc(db, 'users', u.id), { kycStatus: status, kycReviewedAt: serverTimestamp() });
        if (status !== 'pending') {
          await addDoc(collection(db, `users/${u.id}/notifications`), {
            title: status === 'verified' ? 'KYC Verified ✓' : 'KYC Not Approved',
            body: status === 'verified'
              ? 'Your KYC has been verified! You can now apply for land listings.'
              : 'Your KYC was not approved. Please resubmit with clearer documents.',
            type: 'kyc', isRead: false, createdAt: serverTimestamp(),
          });
        }
      } catch (e) { console.warn(e); }
    }
    const msg = status === 'verified' ? `KYC approved for ${u.name}` : status === 'rejected' ? `KYC rejected for ${u.name}` : `KYC reset for ${u.name}`;
    const type = status === 'verified' ? 'success' : status === 'rejected' ? 'warning' : 'info';
    showToast(msg, type);
    setConfirm(null);
  };

  const TABS: { value: KycTab; label: string; color: string }[] = [
    { value: 'pending',  label: 'Pending',  color: 'bg-amber-400 text-amber-900' },
    { value: 'verified', label: 'Verified', color: 'bg-green-500 text-white' },
    { value: 'rejected', label: 'Rejected', color: 'bg-red-500 text-white' },
    { value: '',         label: 'All',      color: 'bg-gray-400 text-white' },
  ];

  return (
    <div className="fade-up space-y-4">
      {/* Toolbar */}
      <div className="flex items-center gap-2 flex-wrap">
        <div className="flex items-center gap-2 bg-white border border-green-100 rounded-lg px-3 py-2 flex-1 max-w-xs shadow-sm">
          <Search size={14} className="text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search KYC requests…" className="border-none outline-none bg-transparent text-sm flex-1" />
        </div>
        <div className="flex gap-1 bg-white border border-gray-200 rounded-lg p-1">
          {TABS.map(t => (
            <button
              key={t.value}
              onClick={() => setTab(t.value)}
              className={`px-3 py-1.5 rounded-md text-xs font-bold transition-colors ${tab === t.value ? t.color : 'text-gray-500 hover:bg-gray-100'}`}
            >
              {t.label}
              {t.value && <span className="ml-1">({users.filter(u => u.kycStatus === t.value).length})</span>}
            </button>
          ))}
        </div>
      </div>

      {/* Grid */}
      {list.length === 0 ? (
        <div className="text-center py-16 text-gray-400 bg-white rounded-xl shadow-sm">No KYC records match this filter.</div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
          {list.map(u => (
            <KycCard key={u.id} user={u}
              onApprove={() => setConfirm({ user: u, action: 'approve' })}
              onReject={() => setConfirm({ user: u, action: 'reject' })}
              onReset={() => setConfirm({ user: u, action: 'reset' })}
            />
          ))}
        </div>
      )}

      {/* Confirm Modal */}
      {confirm && (
        <Modal
          open={!!confirm}
          onClose={() => setConfirm(null)}
          title={confirm.action === 'approve' ? 'Approve KYC' : confirm.action === 'reject' ? 'Reject KYC' : 'Reset KYC'}
          size="sm"
          footer={
            <>
              <button onClick={() => setConfirm(null)} className="px-4 py-2 rounded-lg bg-gray-100 text-sm font-semibold">Cancel</button>
              <button
                onClick={() => updateKyc(confirm.user, confirm.action === 'approve' ? 'verified' : confirm.action === 'reject' ? 'rejected' : 'pending')}
                className={`px-4 py-2 rounded-lg text-white text-sm font-semibold ${confirm.action === 'approve' ? 'bg-green-600 hover:bg-green-700' : confirm.action === 'reject' ? 'bg-red-600 hover:bg-red-700' : 'bg-blue-600 hover:bg-blue-700'}`}
              >
                Confirm
              </button>
            </>
          }
        >
          <p className="text-sm text-gray-600">
            {confirm.action === 'approve' && `Approve KYC for ${confirm.user.name}?`}
            {confirm.action === 'reject'  && `Reject KYC for ${confirm.user.name}? They will lose verified access.`}
            {confirm.action === 'reset'   && `Reset KYC status for ${confirm.user.name} to pending?`}
          </p>
        </Modal>
      )}
    </div>
  );
}

function KycCard({ user, onApprove, onReject, onReset }: {
  user: AppUser;
  onApprove: () => void;
  onReject: () => void;
  onReset: () => void;
}) {
  const borderMap = { pending: 'border-amber-200', verified: 'border-green-200', rejected: 'border-red-200' };
  return (
    <div className={`bg-white rounded-xl p-5 shadow-sm border ${borderMap[user.kycStatus]} hover:-translate-y-1 transition-transform`}>
      <div className="flex items-center gap-3 mb-3">
        <Avatar name={user.name} size={46} radius="12px" />
        <div className="overflow-hidden">
          <div className="font-bold truncate">{user.name}</div>
          <div className="text-xs text-gray-400 truncate">{user.email}</div>
        </div>
      </div>

      <div className="flex gap-2 mb-3 flex-wrap">
        <Badge variant={user.role}>{user.role === 'farmer' ? 'Farmer' : 'Land Owner'}</Badge>
        <Badge variant={user.kycStatus}>{user.kycStatus.charAt(0).toUpperCase()+user.kycStatus.slice(1)}</Badge>
      </div>

      <div className="space-y-1 text-xs text-gray-500 mb-3">
        <div>📞 {user.phone || '—'}</div>
        <div>📅 Joined {user.joined}</div>
      </div>

      {/* KYC Documents */}
      {user.kycDocuments && (
        <div className="mb-3">
          <div className="text-[10px] font-extrabold text-gray-400 uppercase mb-2">Documents</div>
          <div className="flex gap-2 flex-wrap">
            {user.kycDocuments.citizenshipFront && (
              <a href={user.kycDocuments.citizenshipFront} target="_blank" rel="noreferrer"
                className="flex flex-col items-center w-[72px] border-2 border-green-100 rounded-lg overflow-hidden hover:border-green-400 transition-colors">
                <img src={user.kycDocuments.citizenshipFront} alt="ID Front" className="w-full h-14 object-cover" />
                <span className="text-[9px] font-bold p-1 text-gray-600">ID Front</span>
              </a>
            )}
            {user.kycDocuments.citizenshipBack && (
              <a href={user.kycDocuments.citizenshipBack} target="_blank" rel="noreferrer"
                className="flex flex-col items-center w-[72px] border-2 border-green-100 rounded-lg overflow-hidden hover:border-green-400 transition-colors">
                <img src={user.kycDocuments.citizenshipBack} alt="ID Back" className="w-full h-14 object-cover" />
                <span className="text-[9px] font-bold p-1 text-gray-600">ID Back</span>
              </a>
            )}
            {user.kycDocuments.selfie && (
              <a href={user.kycDocuments.selfie} target="_blank" rel="noreferrer"
                className="flex flex-col items-center w-[72px] border-2 border-green-100 rounded-lg overflow-hidden hover:border-green-400 transition-colors">
                <img src={user.kycDocuments.selfie} alt="Selfie" className="w-full h-14 object-cover" />
                <span className="text-[9px] font-bold p-1 text-gray-600">Selfie</span>
              </a>
            )}
          </div>
        </div>
      )}
      {!user.kycDocuments && user.kycStatus === 'pending' && (
        <div className="bg-amber-50 border border-amber-200 rounded-lg text-xs py-2 px-3 mb-3 text-amber-700">
          ⚠ No documents uploaded yet.
        </div>
      )}

      {/* Address */}
      {user.kycAddress && (
        <div className="text-[11px] text-gray-400 mb-3">
          📍 {[user.kycAddress.street, user.kycAddress.city, user.kycAddress.district, user.kycAddress.province].filter(Boolean).join(', ')}
        </div>
      )}

      {/* Actions */}
      {user.kycStatus === 'pending' ? (
        <div className="flex gap-2">
          <button onClick={onApprove} className="flex-1 flex items-center justify-center gap-1.5 bg-green-600 hover:bg-green-700 text-white rounded-lg py-2 text-xs font-bold transition-colors">
            <CheckCircle size={13} /> Approve
          </button>
          <button onClick={onReject} className="flex-1 flex items-center justify-center gap-1.5 border border-red-200 bg-red-50 hover:bg-red-100 text-red-600 rounded-lg py-2 text-xs font-bold transition-colors">
            <XCircle size={13} /> Reject
          </button>
        </div>
      ) : (
        <button onClick={onReset} className="w-full flex items-center justify-center gap-1.5 border border-gray-200 bg-gray-50 hover:bg-gray-100 text-gray-600 rounded-lg py-2 text-xs font-bold transition-colors">
          <RotateCcw size={13} /> Reset to Pending
        </button>
      )}
    </div>
  );
}
