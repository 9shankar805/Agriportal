'use client';
import { useState } from 'react';
import { Search, UserPlus, Eye, UserCheck, UserX, ExternalLink } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Avatar from '@/components/ui/Avatar';
import Badge from '@/components/ui/Badge';
import Modal from '@/components/ui/Modal';
import type { AppUser } from '@/lib/types';
import SortableHeader, { type SortDirection } from '@/components/ui/SortableHeader';

export default function UsersSection() {
  const { users, apps, setUsers, showToast, firebaseReady } = useAdmin();
  const [search,  setSearch]  = useState('');
  const [roleF,   setRoleF]   = useState('');
  const [kycF,    setKycF]    = useState('');
  const [modal,   setModal]   = useState<AppUser | null>(null);
  const [confirm, setConfirm] = useState<{ user: AppUser; action: 'enable' | 'disable' } | null>(null);
  const [sort, setSort] = useState<{ column: string; direction: SortDirection }>({ column: 'name', direction: 'asc' });

  const filtered = users.filter(u =>
    (!search || u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase())) &&
    (!roleF  || u.role === roleF) &&
    (!kycF   || u.kycStatus === kycF)
  );
  const list = [...filtered].sort((a, b) => {
    const value = (user: AppUser) => sort.column === 'status'
      ? (user.isActive ? 'active' : 'disabled')
      : user[sort.column as keyof AppUser] ?? '';
    return String(value(a)).localeCompare(String(value(b)), undefined, { numeric: true }) * (sort.direction === 'asc' ? 1 : -1);
  });
  const handleSort = (column: string) => setSort(prev => ({
    column,
    direction: prev.column === column && prev.direction === 'asc' ? 'desc' : 'asc',
  }));

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
          title: 'KYC Verified ✓', body: 'Your KYC has been verified! You can now apply for land listings.',
          type: 'kyc', isRead: false, createdAt: serverTimestamp(),
        });
      } catch {}
    }
    showToast(`KYC approved for ${u.name}`, 'success');
    setModal(prev => prev ? { ...prev, kycStatus: 'verified' } : null);
  };

  return (
    <div className="space-y-6">
      {/* Toolbar */}
      <div className="admin-toolbar">
        <div className="admin-search flex-1 max-w-md">
          <Search size={20} className="text-gray-400 flex-shrink-0" />
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search by name or email…"
            className="border-none outline-none bg-transparent text-sm flex-1 min-w-0"
          />
        </div>
        <select value={roleF} onChange={e => setRoleF(e.target.value)}
          className="admin-select"
        >
          <option value="">All Roles</option>
          <option value="farmer">Farmer</option>
          <option value="landOwner">Land Owner</option>
        </select>
        <select value={kycF} onChange={e => setKycF(e.target.value)}
          className="admin-select"
        >
          <option value="">All KYC</option>
          <option value="pending">Pending</option>
          <option value="verified">Verified</option>
          <option value="rejected">Rejected</option>
        </select>
        <button className="admin-button-primary ml-auto">
          <UserPlus size={18} /> Add User
        </button>
      </div>

      {/* Summary chips */}
      <div className="flex flex-wrap gap-3">
        {[
          { label: 'Total', count: users.length, color: 'bg-gray-100 text-gray-700 border border-gray-200' },
          { label: 'Farmers', count: users.filter(u => u.role === 'farmer').length, color: 'bg-green-100 text-green-700 border border-green-200' },
          { label: 'Land Owners', count: users.filter(u => u.role === 'landOwner').length, color: 'bg-violet-100 text-violet-700 border border-violet-200' },
          { label: 'Pending KYC', count: users.filter(u => u.kycStatus === 'pending').length, color: 'bg-amber-100 text-amber-700 border border-amber-200' },
          { label: 'Verified', count: users.filter(u => u.kycStatus === 'verified').length, color: 'bg-emerald-100 text-emerald-700 border border-emerald-200' },
        ].map(c => (
          <span key={c.label} className={`px-4 py-2 rounded-full font-extrabold text-sm ${c.color}`}>
            {c.label}: {c.count}
          </span>
        ))}
      </div>

      {/* Table */}
      <div className="admin-table-panel">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr>
                <th className="admin-table-static-heading text-center">#</th>
                <SortableHeader label="User" column="name" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Role" column="role" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Contact" column="phone" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="KYC" column="kycStatus" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Joined" column="joined" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Status" column="status" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <th className="admin-table-static-heading text-left">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {list.length === 0 ? (
                <tr>
                  <td colSpan={8} className="text-center py-20 text-gray-400">
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center">
                        <Search size={28} className="text-gray-300" />
                      </div>
                      <div className="text-base font-semibold text-gray-600">No users found</div>
                      <div className="text-sm text-gray-400">Try adjusting your filters</div>
                    </div>
                  </td>
                </tr>
              ) : list.map((u, i) => (
                <tr key={u.id} className="hover:bg-green-50/40 transition-colors group">
                  <td className="px-6 py-5 text-sm text-gray-400 text-center font-mono font-semibold">{i + 1}</td>
                  <td className="px-6 py-5">
                    <div className="flex items-center gap-4">
                      <Avatar name={u.name} photoUrl={u.photoUrl} size={52} />
                      <div className="min-w-0">
                        <div className="font-extrabold text-base text-gray-900 truncate">{u.name}</div>
                        <div className="text-sm text-gray-500 truncate">{u.email}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-5">
                    <Badge variant={u.role}>{u.role === 'farmer' ? 'Farmer' : 'Land Owner'}</Badge>
                  </td>
                  <td className="px-6 py-5 text-sm text-gray-500">{u.phone || '—'}</td>
                  <td className="px-6 py-5">
                    <Badge variant={u.kycStatus}>{u.kycStatus.charAt(0).toUpperCase() + u.kycStatus.slice(1)}</Badge>
                  </td>
                  <td className="px-6 py-5 text-sm text-gray-500 whitespace-nowrap">{u.joined}</td>
                  <td className="px-6 py-5">
                    <Badge variant={u.isActive ? 'active' : 'inactive'}>{u.isActive ? 'Active' : 'Disabled'}</Badge>
                  </td>
                  <td className="px-6 py-5">
                    <div className="flex gap-2 opacity-80 group-hover:opacity-100 transition-opacity">
                      <button onClick={() => setModal(u)}
                        className="admin-icon-button hover:!border-blue-200 hover:!bg-blue-50 hover:!text-blue-700"
                        title="View Details"
                      >
                        <Eye size={16} />
                      </button>
                      {u.kycStatus === 'pending' && (
                        <button onClick={() => approveKyc(u)}
                          className="admin-icon-button hover:!border-green-200 hover:!bg-green-50 hover:!text-green-700"
                          title="Approve KYC"
                        >
                          <UserCheck size={16} />
                        </button>
                      )}
                      <button
                        onClick={() => setConfirm({ user: u, action: u.isActive ? 'disable' : 'enable' })}
                        className={`admin-icon-button
                          ${u.isActive
                            ? 'hover:!border-red-200 hover:!bg-red-50 hover:!text-red-600'
                            : 'hover:!border-green-200 hover:!bg-green-50 hover:!text-green-700'
                          }`
                        }
                        title={u.isActive ? 'Disable User' : 'Enable User'}
                      >
                        <UserX size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="px-6 py-4 border-t border-gray-100 bg-gray-50/60 text-sm text-gray-500 flex items-center justify-between font-medium">
          <span>Showing {list.length} of {users.length} users</span>
          {list.length !== users.length && (
            <button onClick={() => { setSearch(''); setRoleF(''); setKycF(''); }} className="text-green-600 font-extrabold hover:underline hover:text-green-700 transition-colors">
              Clear filters
            </button>
          )}
        </div>
      </div>

      {/* User Detail Modal */}
      {modal && (
        <Modal open={!!modal} onClose={() => setModal(null)} title="User Details" size="md"
          footer={
            <>
              <button onClick={() => setModal(null)} className="admin-button-secondary">Close</button>
              {modal.kycStatus === 'pending' && (
                <button onClick={() => approveKyc(modal)} className="admin-button-primary">
                  Approve KYC
                </button>
              )}
            </>
          }
        >
          {/* Profile header */}
          <div className="flex items-center gap-5 mb-6 p-5 bg-gray-50 rounded-lg border border-gray-200">
            <Avatar name={modal.name} photoUrl={modal.photoUrl} size={72} radius="12px" />
            <div className="flex-1 min-w-0">
              <div className="font-extrabold text-xl text-gray-900 truncate">{modal.name}</div>
              <div className="text-base text-gray-500 truncate">{modal.email}</div>
              <div className="flex gap-3 mt-3 flex-wrap">
                <Badge variant={modal.role}>{modal.role === 'farmer' ? 'Farmer' : 'Land Owner'}</Badge>
                <Badge variant={modal.kycStatus}>{modal.kycStatus.charAt(0).toUpperCase() + modal.kycStatus.slice(1)}</Badge>
                <Badge variant={modal.isActive ? 'active' : 'inactive'}>{modal.isActive ? 'Active' : 'Disabled'}</Badge>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4 text-sm">
            {[
              { label: 'User ID', value: <span className="font-mono text-xs truncate block">{modal.id}</span> },
              { label: 'Phone', value: modal.phone || '—' },
              { label: 'Joined', value: modal.joined },
              { label: 'Applications', value: apps.filter(a => a.applicant === modal.name).length },
            ].map(({ label, value }) => (
              <div key={label} className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                <div className="text-xs font-extrabold text-gray-400 uppercase tracking-wider mb-2">{label}</div>
                <div className="font-extrabold text-gray-800 text-base">{value}</div>
              </div>
            ))}
          </div>

          {/* KYC documents in modal */}
          {modal.kycDocuments && (
            <div className="mt-6">
              <div className="text-xs font-extrabold text-gray-400 uppercase tracking-wider mb-4">KYC Documents</div>
              <div className="flex gap-4 flex-wrap">
                {[
                  { url: modal.kycDocuments.citizenshipFront, label: 'ID Front' },
                  { url: modal.kycDocuments.citizenshipBack, label: 'ID Back' },
                  { url: modal.kycDocuments.selfie, label: 'Selfie' },
                ].filter(d => d.url).map(d => (
                  <a key={d.label} href={d.url} target="_blank" rel="noreferrer"
                    className="group flex flex-col items-center gap-2 border border-gray-200 hover:border-green-400 rounded-lg overflow-hidden transition-all w-28"
                  >
                    <img src={d.url} alt={d.label} className="w-28 h-20 object-cover" />
                    <span className="flex items-center gap-1 text-xs font-semibold text-gray-500 pb-3 group-hover:text-green-700 transition-colors">{d.label} <ExternalLink size={12} /></span>
                  </a>
                ))}
              </div>
            </div>
          )}
        </Modal>
      )}

      {/* Confirm Modal */}
      {confirm && (
        <Modal open={!!confirm} onClose={() => setConfirm(null)}
          title={`${confirm.action === 'enable' ? 'Enable' : 'Disable'} User`} size="sm"
          footer={
            <>
              <button onClick={() => setConfirm(null)} className="admin-button-secondary">Cancel</button>
              <button onClick={() => toggleUser(confirm.user)}
                className="admin-button-danger !bg-red-600 !text-white hover:!bg-red-700"
              >
                Confirm
              </button>
            </>
          }
        >
          <div className="flex items-center gap-4 mb-4">
            <Avatar name={confirm.user.name} photoUrl={confirm.user.photoUrl} size={60} />
            <div>
              <div className="font-extrabold text-lg">{confirm.user.name}</div>
              <div className="text-sm text-gray-500">{confirm.user.email}</div>
            </div>
          </div>
          <p className="text-base text-gray-600">
            Are you sure you want to <strong>{confirm.action}</strong> this user?
          </p>
        </Modal>
      )}
    </div>
  );
}
