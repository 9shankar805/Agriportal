'use client';
import { useState } from 'react';
import { Search, UserPlus, Eye, UserCheck, UserX } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Avatar from '@/components/ui/Avatar';
import Badge from '@/components/ui/Badge';
import Modal from '@/components/ui/Modal';
import type { AppUser } from '@/lib/types';

export default function UsersSection() {
  const { users, apps, setUsers, showToast, firebaseReady } = useAdmin();
  const [search, setSearch]     = useState('');
  const [roleF,  setRoleF]      = useState('');
  const [kycF,   setKycF]       = useState('');
  const [modal,  setModal]      = useState<AppUser | null>(null);
  const [confirm, setConfirm]   = useState<{ user: AppUser; action: 'enable' | 'disable' } | null>(null);

  const list = users.filter(u =>
    (!search || u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase())) &&
    (!roleF  || u.role === roleF) &&
    (!kycF   || u.kycStatus === kycF)
  );

  const toggleUser = async (u: AppUser) => {
    const next = !u.isActive;
    setUsers(prev => prev.map(x => x.id === u.id ? { ...x, isActive: next } : x));
    if (firebaseReady) {
      try {
        const { db, updateDoc, doc } = await import('@/lib/firebase');
        await updateDoc(doc(db, 'users', u.id), { isActive: next });
      } catch {}
    }
    showToast(`User ${next ? 'enabled' : 'disabled'}.`, 'success');
    setConfirm(null);
  };

  const approveKyc = async (u: AppUser) => {
    setUsers(prev => prev.map(x => x.id === u.id ? { ...x, kycStatus: 'verified' } : x));
    if (firebaseReady) {
      try {
        const { db, updateDoc, doc, addDoc, collection, serverTimestamp } = await import('@/lib/firebase');
        await updateDoc(doc(db, 'users', u.id), { kycStatus: 'verified', kycReviewedAt: serverTimestamp() });
        await addDoc(collection(db, `users/${u.id}/notifications`), {
          title: 'KYC Verified ✓', body: 'Your KYC has been verified!',
          type: 'kyc', isRead: false, createdAt: serverTimestamp(),
        });
      } catch {}
    }
    showToast(`KYC approved for ${u.name}`, 'success');
    setModal(prev => prev ? { ...prev, kycStatus: 'verified' } : null);
  };

  return (
    <div className="fade-up space-y-4">
      {/* Toolbar */}
      <div className="flex items-center gap-2 flex-wrap">
        <div className="flex items-center gap-2 bg-white border border-green-100 rounded-lg px-3 py-2 flex-1 max-w-xs shadow-sm">
          <Search size={14} className="text-gray-400" />
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search by name or email…"
            className="border-none outline-none bg-transparent text-sm flex-1"
          />
        </div>
        <select value={roleF} onChange={e => setRoleF(e.target.value)}
          className="border border-green-100 rounded-lg px-3 py-2 text-sm bg-white shadow-sm outline-none cursor-pointer">
          <option value="">All Roles</option>
          <option value="farmer">Farmer</option>
          <option value="landOwner">Land Owner</option>
        </select>
        <select value={kycF} onChange={e => setKycF(e.target.value)}
          className="border border-green-100 rounded-lg px-3 py-2 text-sm bg-white shadow-sm outline-none cursor-pointer">
          <option value="">KYC Status</option>
          <option value="pending">Pending</option>
          <option value="verified">Verified</option>
          <option value="rejected">Rejected</option>
        </select>
        <button className="flex items-center gap-1.5 bg-green-600 hover:bg-green-700 text-white rounded-lg px-4 py-2 text-sm font-semibold transition-colors ml-auto">
          <UserPlus size={14} /> Add User
        </button>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-green-50/60 border-b-2 border-green-100">
                {['#','User','Role','Contact','KYC','Joined','Status','Actions'].map(h => (
                  <th key={h} className="px-4 py-3 text-left text-[11px] font-extrabold uppercase tracking-wide text-gray-500 whitespace-nowrap">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {list.length === 0 ? (
                <tr><td colSpan={8} className="text-center py-12 text-gray-400 text-sm">No users match the current filters.</td></tr>
              ) : list.map((u, i) => (
                <tr key={u.id} className="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                  <td className="px-4 py-3 text-xs text-gray-400 text-center">{i+1}</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2.5">
                      <Avatar name={u.name} size={34} />
                      <div>
                        <div className="font-semibold text-sm">{u.name}</div>
                        <div className="text-xs text-gray-400">{u.email}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3"><Badge variant={u.role}>{u.role === 'farmer' ? 'Farmer' : 'Land Owner'}</Badge></td>
                  <td className="px-4 py-3 text-xs text-gray-500">{u.phone}</td>
                  <td className="px-4 py-3"><Badge variant={u.kycStatus}>{u.kycStatus.charAt(0).toUpperCase()+u.kycStatus.slice(1)}</Badge></td>
                  <td className="px-4 py-3 text-xs text-gray-500">{u.joined}</td>
                  <td className="px-4 py-3"><Badge variant={u.isActive ? 'active' : 'inactive'}>{u.isActive ? 'Active' : 'Disabled'}</Badge></td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1">
                      <button onClick={() => setModal(u)} className="w-7 h-7 rounded-lg border border-blue-200 bg-blue-50 hover:bg-blue-100 text-blue-600 flex items-center justify-center transition-colors" title="View">
                        <Eye size={12} />
                      </button>
                      {u.kycStatus === 'pending' && (
                        <button onClick={() => approveKyc(u)} className="w-7 h-7 rounded-lg border border-green-200 bg-green-50 hover:bg-green-100 text-green-600 flex items-center justify-center transition-colors" title="Approve KYC">
                          <UserCheck size={12} />
                        </button>
                      )}
                      <button
                        onClick={() => setConfirm({ user: u, action: u.isActive ? 'disable' : 'enable' })}
                        className={`w-7 h-7 rounded-lg border flex items-center justify-center transition-colors ${u.isActive ? 'border-red-200 bg-red-50 hover:bg-red-100 text-red-600' : 'border-green-200 bg-green-50 hover:bg-green-100 text-green-600'}`}
                        title={u.isActive ? 'Disable' : 'Enable'}
                      >
                        <UserX size={12} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="px-4 py-3 border-t border-gray-100 bg-gray-50/60 text-xs text-gray-400">
          {list.length} of {users.length} users
        </div>
      </div>

      {/* User Detail Modal */}
      {modal && (
        <Modal
          open={!!modal}
          onClose={() => setModal(null)}
          title="User Details"
          size="md"
          footer={
            <>
              <button onClick={() => setModal(null)} className="px-4 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-sm font-semibold transition-colors">Close</button>
              {modal.kycStatus === 'pending' && (
                <button onClick={() => approveKyc(modal)} className="px-4 py-2 rounded-lg bg-green-600 hover:bg-green-700 text-white text-sm font-semibold transition-colors">
                  Approve KYC
                </button>
              )}
            </>
          }
        >
          <div className="flex items-center gap-3 mb-4">
            <Avatar name={modal.name} size={52} radius="14px" />
            <div>
              <div className="font-extrabold text-base">{modal.name}</div>
              <div className="text-sm text-gray-400">{modal.email}</div>
              <div className="flex gap-2 mt-2 flex-wrap">
                <Badge variant={modal.role}>{modal.role === 'farmer' ? 'Farmer' : 'Land Owner'}</Badge>
                <Badge variant={modal.kycStatus}>{modal.kycStatus.charAt(0).toUpperCase()+modal.kycStatus.slice(1)}</Badge>
                <Badge variant={modal.isActive ? 'active' : 'inactive'}>{modal.isActive ? 'Active' : 'Disabled'}</Badge>
              </div>
            </div>
          </div>
          <hr className="my-3" />
          <div className="grid grid-cols-2 gap-3 text-sm">
            <div><div className="text-xs text-gray-400">User ID</div><div className="font-semibold text-xs font-mono truncate">{modal.id}</div></div>
            <div><div className="text-xs text-gray-400">Phone</div><div className="font-semibold">{modal.phone || '—'}</div></div>
            <div><div className="text-xs text-gray-400">Joined</div><div className="font-semibold">{modal.joined}</div></div>
            <div><div className="text-xs text-gray-400">Applications</div><div className="font-semibold">{apps.filter(a => a.applicant === modal.name).length}</div></div>
          </div>
        </Modal>
      )}

      {/* Confirm Modal */}
      {confirm && (
        <Modal
          open={!!confirm}
          onClose={() => setConfirm(null)}
          title={`${confirm.action === 'enable' ? 'Enable' : 'Disable'} User`}
          size="sm"
          footer={
            <>
              <button onClick={() => setConfirm(null)} className="px-4 py-2 rounded-lg bg-gray-100 text-sm font-semibold">Cancel</button>
              <button onClick={() => toggleUser(confirm.user)} className="px-4 py-2 rounded-lg bg-red-600 hover:bg-red-700 text-white text-sm font-semibold">
                Confirm
              </button>
            </>
          }
        >
          <p className="text-sm text-gray-600">
            Are you sure you want to {confirm.action} <strong>{confirm.user.name}</strong>?
          </p>
        </Modal>
      )}
    </div>
  );
}
