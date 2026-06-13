'use client';
import { useState } from 'react';
import { Search, CheckCircle, XCircle, RotateCcw, ZoomIn } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Avatar from '@/components/ui/Avatar';
import Badge from '@/components/ui/Badge';
import Modal from '@/components/ui/Modal';
import type { AppUser } from '@/lib/types';

type KycTab = 'pending' | 'verified' | 'rejected' | '';

export default function KycSection() {
  const { users, setUsers, showToast, firebaseReady } = useAdmin();
  const [tab,     setTab]     = useState<KycTab>('pending');
  const [search,  setSearch]  = useState('');
  const [confirm, setConfirm] = useState<{ user: AppUser; action: 'approve' | 'reject' | 'reset' } | null>(null);
  const [imgZoom, setImgZoom] = useState<string | null>(null);

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
    showToast(
      status === 'verified' ? `KYC approved for ${u.name}` :
      status === 'rejected' ? `KYC rejected for ${u.name}` :
      `KYC reset for ${u.name}`,
      status === 'verified' ? 'success' : status === 'rejected' ? 'warning' : 'info'
    );
    setConfirm(null);
  };

  const TABS: { value: KycTab; label: string; active: string }[] = [
    { value: 'pending',  label: 'Pending',  active: 'bg-amber-400 text-amber-900' },
    { value: 'verified', label: 'Verified', active: 'bg-green-500 text-white' },
    { value: 'rejected', label: 'Rejected', active: 'bg-red-500 text-white' },
    { value: '',         label: 'All',      active: 'bg-gray-500 text-white' },
  ];

  return (
    <div className="fade-up space-y-4">
      {/* Toolbar */}
      <div className="flex items-center gap-2 flex-wrap">
        <div className="flex items-center gap-2 bg-white border border-green-100 rounded-xl px-3 py-2.5 flex-1 max-w-sm shadow-sm">
          <Search size={14} className="text-gray-400 flex-shrink-0" />
          <input value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search KYC requests…"
            className="border-none outline-none bg-transparent text-sm flex-1" />
        </div>
        <div className="flex gap-1 bg-white border border-gray-200 rounded-xl p-1 shadow-sm">
          {TABS.map(t => (
            <button key={t.value} onClick={() => setTab(t.value)}
              className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-colors
                ${tab === t.value ? t.active : 'text-gray-500 hover:bg-gray-100'}`}>
              {t.label}
              {t.value !== '' && (
                <span className="ml-1.5 opacity-75">({users.filter(u => u.kycStatus === t.value).length})</span>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* Empty state */}
      {list.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 bg-white rounded-2xl shadow-sm border border-gray-100">
          <div className="w-14 h-14 rounded-full bg-gray-100 flex items-center justify-center mb-3">
            <CheckCircle size={24} className="text-gray-300" />
          </div>
          <div className="font-semibold text-gray-400">No KYC records match this filter</div>
          {tab === 'pending' && <div className="text-xs text-gray-300 mt-1">All caught up! ✓</div>}
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
          {list.map(u => (
            <KycCard key={u.id} user={u}
              onApprove={() => setConfirm({ user: u, action: 'approve' })}
              onReject={() => setConfirm({ user: u, action: 'reject' })}
              onReset={() => setConfirm({ user: u, action: 'reset' })}
              onZoom={setImgZoom}
            />
          ))}
        </div>
      )}

      {/* Confirm Modal */}
      {confirm && (
        <Modal open={!!confirm} onClose={() => setConfirm(null)}
          title={confirm.action === 'approve' ? 'Approve KYC' : confirm.action === 'reject' ? 'Reject KYC' : 'Reset KYC'}
          size="sm"
          footer={
            <>
              <button onClick={() => setConfirm(null)} className="px-4 py-2 rounded-xl bg-gray-100 text-sm font-semibold">Cancel</button>
              <button
                onClick={() => updateKyc(confirm.user,
                  confirm.action === 'approve' ? 'verified' :
                  confirm.action === 'reject'  ? 'rejected' : 'pending')}
                className={`px-4 py-2 rounded-xl text-white text-sm font-semibold transition-colors
                  ${confirm.action === 'approve' ? 'bg-green-600 hover:bg-green-700' :
                    confirm.action === 'reject'  ? 'bg-red-600 hover:bg-red-700' :
                    'bg-blue-600 hover:bg-blue-700'}`}>
                Confirm
              </button>
            </>
          }
        >
          <div className="flex items-center gap-3 mb-3">
            <Avatar name={confirm.user.name} photoUrl={confirm.user.photoUrl} size={44} />
            <div>
              <div className="font-bold">{confirm.user.name}</div>
              <div className="text-xs text-gray-400">{confirm.user.email}</div>
            </div>
          </div>
          <p className="text-sm text-gray-600">
            {confirm.action === 'approve' && 'Approve KYC? The user will be notified and can apply for listings.'}
            {confirm.action === 'reject'  && 'Reject KYC? The user will be notified to resubmit documents.'}
            {confirm.action === 'reset'   && 'Reset KYC to pending? The user will need to re-verify.'}
          </p>
        </Modal>
      )}

      {/* Image zoom lightbox */}
      {imgZoom && (
        <div className="fixed inset-0 z-[600] bg-black/80 flex items-center justify-center p-4 cursor-zoom-out"
          onClick={() => setImgZoom(null)}>
          <img src={imgZoom} alt="Document" className="max-w-full max-h-[90vh] rounded-2xl shadow-2xl object-contain" />
        </div>
      )}
    </div>
  );
}

function KycCard({ user, onApprove, onReject, onReset, onZoom }: {
  user: AppUser;
  onApprove: () => void;
  onReject: () => void;
  onReset: () => void;
  onZoom: (url: string) => void;
}) {
  const borderMap = {
    pending:  'border-amber-200 bg-amber-50/30',
    verified: 'border-green-200 bg-green-50/20',
    rejected: 'border-red-200 bg-red-50/20',
  };
  const docs = user.kycDocuments;

  return (
    <div className={`rounded-2xl p-5 shadow-sm border-2 hover:-translate-y-1 transition-all duration-200 ${borderMap[user.kycStatus]}`}
      style={{ background: 'white' }}>

      {/* Header */}
      <div className="flex items-center gap-3 mb-4">
        <Avatar name={user.name} photoUrl={user.photoUrl} size={52} radius="14px" />
        <div className="flex-1 min-w-0">
          <div className="font-bold text-gray-900 truncate">{user.name}</div>
          <div className="text-xs text-gray-400 truncate">{user.email}</div>
          <div className="flex gap-1.5 mt-1.5 flex-wrap">
            <Badge variant={user.role}>{user.role === 'farmer' ? 'Farmer' : 'Land Owner'}</Badge>
            <Badge variant={user.kycStatus}>{user.kycStatus.charAt(0).toUpperCase() + user.kycStatus.slice(1)}</Badge>
          </div>
        </div>
      </div>

      {/* Info */}
      <div className="grid grid-cols-2 gap-2 mb-4 text-xs text-gray-500">
        <div className="flex items-center gap-1.5"><span>📞</span>{user.phone || '—'}</div>
        <div className="flex items-center gap-1.5"><span>📅</span>{user.joined}</div>
        {user.kycAddress && (
          <div className="col-span-2 flex items-start gap-1.5">
            <span>📍</span>
            <span className="truncate">
              {[user.kycAddress.city, user.kycAddress.district, user.kycAddress.province].filter(Boolean).join(', ')}
            </span>
          </div>
        )}
      </div>

      {/* KYC Documents */}
      {docs ? (
        <div className="mb-4">
          <div className="text-[10px] font-extrabold text-gray-400 uppercase tracking-wider mb-2">Documents</div>
          <div className="flex gap-2">
            {[
              { url: docs.citizenshipFront, label: 'ID Front' },
              { url: docs.citizenshipBack,  label: 'ID Back' },
              { url: docs.selfie,           label: 'Selfie' },
            ].filter(d => d.url).map(d => (
              <button key={d.label} onClick={() => onZoom(d.url!)}
                className="group relative flex flex-col items-center border-2 border-gray-200 hover:border-green-400 rounded-xl overflow-hidden transition-all w-[72px] flex-shrink-0">
                <img src={d.url} alt={d.label} className="w-full h-14 object-cover" />
                <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors flex items-center justify-center">
                  <ZoomIn size={16} className="text-white opacity-0 group-hover:opacity-100 transition-opacity" />
                </div>
                <span className="text-[9px] font-bold py-1 text-gray-500 group-hover:text-green-600 transition-colors">{d.label}</span>
              </button>
            ))}
          </div>
        </div>
      ) : user.kycStatus === 'pending' ? (
        <div className="mb-4 bg-amber-50 border border-amber-200 rounded-xl px-3 py-2.5 text-xs text-amber-700 flex items-center gap-2">
          <span>⚠</span> No documents uploaded yet
        </div>
      ) : null}

      {/* Actions */}
      <div className="pt-3 border-t border-gray-100">
        {user.kycStatus === 'pending' ? (
          <div className="flex gap-2">
            <button onClick={onApprove}
              className="flex-1 flex items-center justify-center gap-1.5 bg-green-600 hover:bg-green-700 text-white rounded-xl py-2 text-xs font-bold transition-colors">
              <CheckCircle size={13} /> Approve
            </button>
            <button onClick={onReject}
              className="flex-1 flex items-center justify-center gap-1.5 border-2 border-red-200 bg-white hover:bg-red-50 text-red-600 rounded-xl py-2 text-xs font-bold transition-colors">
              <XCircle size={13} /> Reject
            </button>
          </div>
        ) : (
          <button onClick={onReset}
            className="w-full flex items-center justify-center gap-1.5 border-2 border-gray-200 bg-white hover:bg-gray-50 text-gray-600 rounded-xl py-2 text-xs font-bold transition-colors">
            <RotateCcw size={13} /> Reset to Pending
          </button>
        )}
      </div>
    </div>
  );
}
