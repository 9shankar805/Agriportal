'use client';
import { useState } from 'react';
import {
  Search,
  CheckCircle2,
  XCircle,
  RotateCcw,
  ZoomIn,
  Phone,
  CalendarDays,
  MapPin,
  Files,
  AlertTriangle,
  ShieldCheck,
} from 'lucide-react';
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
    { value: 'pending',  label: 'Pending',  active: 'bg-white text-gray-950 shadow-sm border-gray-200' },
    { value: 'verified', label: 'Verified', active: 'bg-white text-gray-950 shadow-sm border-gray-200' },
    { value: 'rejected', label: 'Rejected', active: 'bg-white text-gray-950 shadow-sm border-gray-200' },
    { value: '',         label: 'All',      active: 'bg-white text-gray-950 shadow-sm border-gray-200' },
  ];

  return (
    <div className="fade-up space-y-4">
      {/* Toolbar */}
      <div className="admin-toolbar">
        <div className="admin-search flex-1 max-w-sm">
          <Search size={14} className="text-gray-400 flex-shrink-0" />
          <input value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search KYC requests…"
            className="border-none outline-none bg-transparent text-sm flex-1" />
        </div>
        <div className="flex gap-1 bg-gray-100 border border-gray-200 rounded-lg p-1">
          {TABS.map(t => (
            <button key={t.value} onClick={() => setTab(t.value)}
              className={`border border-transparent px-3 py-2 rounded-md text-xs font-semibold transition-colors
                ${tab === t.value ? t.active : 'text-gray-500 hover:text-gray-900'}`}>
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
        <div className="admin-card flex flex-col items-center justify-center py-20">
          <div className="w-12 h-12 rounded-lg bg-green-50 flex items-center justify-center mb-3">
            <CheckCircle2 size={22} className="text-green-600" />
          </div>
          <div className="font-semibold text-gray-700">No KYC records match this filter</div>
          {tab === 'pending' && <div className="text-xs text-gray-400 mt-1">All pending requests have been reviewed.</div>}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 2xl:grid-cols-3 gap-4">
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
              <button onClick={() => setConfirm(null)} className="admin-button-secondary">Cancel</button>
              <button
                onClick={() => updateKyc(confirm.user,
                  confirm.action === 'approve' ? 'verified' :
                  confirm.action === 'reject'  ? 'rejected' : 'pending')}
                className={`min-h-10 px-4 rounded-lg text-white text-sm font-semibold transition-colors
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
          <img src={imgZoom} alt="Document" className="max-w-full max-h-[90vh] rounded-lg shadow-2xl object-contain" />
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
  const statusMap = {
    pending:  { border: 'border-l-amber-400', icon: 'bg-amber-50 text-amber-600', label: 'Awaiting review' },
    verified: { border: 'border-l-green-500', icon: 'bg-green-50 text-green-700', label: 'Identity verified' },
    rejected: { border: 'border-l-red-400', icon: 'bg-red-50 text-red-600', label: 'Needs resubmission' },
  };
  const docs = user.kycDocuments;
  const status = statusMap[user.kycStatus];
  const documentList = docs ? [
    { url: docs.citizenshipFront, label: 'ID Front' },
    { url: docs.citizenshipBack,  label: 'ID Back' },
    { url: docs.selfie,           label: 'Selfie' },
  ].filter(d => d.url) : [];

  return (
    <article className={`admin-card overflow-hidden border-l-4 ${status.border}`}>

      {/* Header */}
      <div className="flex items-start gap-3 border-b border-gray-100 px-5 py-4">
        <Avatar name={user.name} photoUrl={user.photoUrl} size={48} radius="10px" />
        <div className="flex-1 min-w-0">
          <div className="font-semibold text-gray-950 truncate">{user.name}</div>
          <div className="text-xs text-gray-400 truncate">{user.email}</div>
          <div className="flex gap-1.5 mt-2 flex-wrap">
            <Badge variant={user.role}>{user.role === 'farmer' ? 'Farmer' : 'Land Owner'}</Badge>
            <Badge variant={user.kycStatus}>{user.kycStatus.charAt(0).toUpperCase() + user.kycStatus.slice(1)}</Badge>
          </div>
        </div>
        <div className={`w-9 h-9 rounded-lg flex items-center justify-center ${status.icon}`} title={status.label}>
          <ShieldCheck size={18} />
        </div>
      </div>

      {/* Info */}
      <div className="grid grid-cols-2 gap-x-4 gap-y-3 px-5 py-4 text-xs text-gray-600">
        <div className="flex items-center gap-2 min-w-0"><Phone size={14} className="text-gray-400 flex-shrink-0" /><span className="truncate">{user.phone || 'Not provided'}</span></div>
        <div className="flex items-center gap-2 min-w-0"><CalendarDays size={14} className="text-gray-400 flex-shrink-0" /><span className="truncate">{user.joined}</span></div>
        {user.kycAddress && (
          <div className="col-span-2 flex items-start gap-2">
            <MapPin size={14} className="text-gray-400 flex-shrink-0 mt-0.5" />
            <span className="truncate">
              {[user.kycAddress.city, user.kycAddress.district, user.kycAddress.province].filter(Boolean).join(', ')}
            </span>
          </div>
        )}
      </div>

      {/* KYC Documents */}
      <div className="border-t border-gray-100 px-5 py-4">
        <div className="mb-3 flex items-center justify-between">
          <div className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-wider text-gray-500">
            <Files size={14} className="text-gray-400" /> Submitted documents
          </div>
          <span className="text-[10px] font-semibold text-gray-400">{documentList.length}/3</span>
        </div>
        {documentList.length > 0 ? (
          <div className="grid grid-cols-3 gap-2">
            {documentList.map(d => (
              <button key={d.label} onClick={() => onZoom(d.url!)}
                className="group relative min-w-0 overflow-hidden rounded-lg border border-gray-200 bg-gray-50 text-left transition-colors hover:border-green-300">
                <img src={d.url} alt={d.label} className="aspect-[4/3] w-full object-cover" />
                <div className="absolute inset-x-0 top-0 aspect-[4/3] bg-black/0 group-hover:bg-black/20 transition-colors flex items-center justify-center">
                  <ZoomIn size={16} className="text-white opacity-0 group-hover:opacity-100 transition-opacity" />
                </div>
                <span className="block truncate px-2 py-1.5 text-[10px] font-semibold text-gray-600">{d.label}</span>
              </button>
            ))}
          </div>
        ) : (
          <div className="flex items-center gap-2 rounded-lg border border-amber-200 bg-amber-50 px-3 py-3 text-xs text-amber-700">
            <AlertTriangle size={15} className="flex-shrink-0" /> No documents uploaded yet
          </div>
        )}
      </div>

      {/* Actions */}
      <div className="border-t border-gray-100 bg-gray-50/70 px-5 py-3">
        {user.kycStatus === 'pending' ? (
          <div className="flex gap-2">
            <button onClick={onApprove}
              className="admin-button-primary flex-1 !min-h-9 !text-xs">
              <CheckCircle2 size={14} /> Approve
            </button>
            <button onClick={onReject}
              className="admin-button-danger flex-1 !min-h-9 !text-xs">
              <XCircle size={14} /> Reject
            </button>
          </div>
        ) : (
          <button onClick={onReset}
            className="admin-button-secondary w-full !min-h-9 !text-xs">
            <RotateCcw size={14} /> Reset to Pending
          </button>
        )}
      </div>
    </article>
  );
}
