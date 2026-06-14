'use client';
import { useState } from 'react';
import { Search, Eye, Check, X, Pause, Trash2, Plus, MapPin } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Badge from '@/components/ui/Badge';
import Modal from '@/components/ui/Modal';
import type { Land } from '@/lib/types';
import SortableHeader, { type SortDirection } from '@/components/ui/SortableHeader';

export default function LandsSection() {
  const { lands, apps, setLands, showToast, firebaseReady } = useAdmin();
  const [search,  setSearch]  = useState('');
  const [statusF, setStatusF] = useState('');
  const [modal,   setModal]   = useState<Land | null>(null);
  const [confirm, setConfirm] = useState<{ land: Land; action: string } | null>(null);
  const [sort, setSort] = useState<{ column: string; direction: SortDirection }>({ column: 'title', direction: 'asc' });

  const filtered = lands.filter(l =>
    (!search  || l.title.toLowerCase().includes(search.toLowerCase()) || l.location.toLowerCase().includes(search.toLowerCase()) || l.owner.toLowerCase().includes(search.toLowerCase())) &&
    (!statusF || l.status === statusF)
  );
  const list = [...filtered].sort((a, b) => {
    const aValue = a[sort.column as keyof Land] ?? '';
    const bValue = b[sort.column as keyof Land] ?? '';
    return String(aValue).localeCompare(String(bValue), undefined, { numeric: true }) * (sort.direction === 'asc' ? 1 : -1);
  });
  const handleSort = (column: string) => setSort(prev => ({
    column,
    direction: prev.column === column && prev.direction === 'asc' ? 'desc' : 'asc',
  }));

  const setStatus = async (id: string, status: Land['status']) => {
    setLands(prev => prev.map(l => l.id === id ? { ...l, status } : l));
    if (firebaseReady) {
      try {
        const { db, updateDoc, doc, getDoc, addDoc, collection, serverTimestamp } = await import('@/lib/firebase');
        await updateDoc(doc(db, 'lands', id), { status });
        const snap = await getDoc(doc(db, 'lands', id));
        const ownerId = snap.data()?.ownerId;
        if (ownerId) {
          const land = lands.find(l => l.id === id);
          await addDoc(collection(db, `users/${ownerId}/notifications`), {
            title: status === 'active' ? 'Land Listing Approved ✓' : 'Land Listing Update',
            body: status === 'active'
              ? `"${land?.title}" has been approved and is now live.`
              : `"${land?.title}" status changed to ${status}.`,
            type: 'land', isRead: false, createdAt: serverTimestamp(),
          });
        }
      } catch {}
    }
    const land = lands.find(l => l.id === id);
    showToast(`"${land?.title}" is now ${status}.`, 'success');
    setModal(null);
    setConfirm(null);
  };

  const deleteLand = async (id: string) => {
    const land = lands.find(l => l.id === id);
    setLands(prev => prev.filter(l => l.id !== id));
    if (firebaseReady) {
      try {
        const { db, deleteDoc, doc } = await import('@/lib/firebase');
        await deleteDoc(doc(db, 'lands', id));
      } catch {}
    }
    showToast(`"${land?.title}" deleted.`, 'warning');
    setConfirm(null);
  };

  return (
    <div className="fade-up space-y-4">
      {/* Toolbar */}
      <div className="admin-toolbar">
        <div className="admin-search flex-1 max-w-sm">
          <Search size={14} className="text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search listings…" className="border-none outline-none bg-transparent text-sm flex-1" />
        </div>
        <select value={statusF} onChange={e => setStatusF(e.target.value)}
          className="admin-select">
          <option value="">All Status</option>
          <option value="active">Active</option>
          <option value="pending">Pending Review</option>
          <option value="inactive">Inactive</option>
        </select>
        <button
          onClick={() => window.open('https://console.firebase.google.com/project/agriportal-9ee3d/firestore/data/~2Flands','_blank')}
          className="admin-button-primary ml-auto">
          <Plus size={14} /> Add Listing
        </button>
      </div>

      {/* Table */}
      <div className="admin-table-panel">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr>
                <th className="admin-table-static-heading text-center">#</th>
                <SortableHeader label="Land Title" column="title" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Owner" column="owner" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Location" column="location" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Area" column="area" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Price / Bigha" column="price" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Status" column="status" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <th className="admin-table-static-heading text-left">Actions</th>
              </tr>
            </thead>
            <tbody>
              {list.length === 0 ? (
                <tr><td colSpan={8} className="text-center py-12 text-gray-400 text-sm">No listings match the current filters.</td></tr>
              ) : list.map((l, i) => (
                <tr key={l.id} className="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                  <td className="px-4 py-3 text-xs text-gray-400 text-center">{i+1}</td>
                  <td className="px-4 py-3">
                    <div className="font-semibold text-sm">{l.title}</div>
                    <div className="text-xs text-gray-400">{l.province}</div>
                  </td>
                  <td className="px-4 py-3 text-sm">{l.owner}</td>
                  <td className="px-4 py-3 text-xs text-gray-500">
                    <span className="flex items-center gap-1.5"><MapPin size={13} className="text-gray-400" />{l.location}</span>
                  </td>
                  <td className="px-4 py-3 text-sm font-semibold">{l.area} Bigha</td>
                  <td className="px-4 py-3 text-sm font-semibold">Rs {l.price.toLocaleString()}</td>
                  <td className="px-4 py-3"><Badge variant={l.status}>{l.status.charAt(0).toUpperCase()+l.status.slice(1)}</Badge></td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1">
                      <button onClick={() => setModal(l)} className="admin-icon-button hover:!border-blue-200 hover:!bg-blue-50 hover:!text-blue-700" title="View">
                        <Eye size={14} />
                      </button>
                      {l.status === 'pending' && <>
                        <button onClick={() => setStatus(l.id, 'active')} className="admin-icon-button hover:!border-green-200 hover:!bg-green-50 hover:!text-green-700" title="Approve">
                          <Check size={14} />
                        </button>
                        <button onClick={() => setStatus(l.id, 'inactive')} className="admin-icon-button hover:!border-red-200 hover:!bg-red-50 hover:!text-red-600" title="Reject">
                          <X size={14} />
                        </button>
                      </>}
                      {l.status === 'active' && (
                        <button onClick={() => setStatus(l.id, 'inactive')} className="admin-icon-button hover:!border-amber-200 hover:!bg-amber-50 hover:!text-amber-700" title="Deactivate">
                          <Pause size={14} />
                        </button>
                      )}
                      {l.status === 'inactive' && (
                        <button onClick={() => setStatus(l.id, 'active')} className="admin-icon-button hover:!border-green-200 hover:!bg-green-50 hover:!text-green-700" title="Activate">
                          <Check size={14} />
                        </button>
                      )}
                      <button onClick={() => setConfirm({ land: l, action: 'delete' })} className="admin-icon-button hover:!border-red-200 hover:!bg-red-50 hover:!text-red-600" title="Delete">
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="px-4 py-3 border-t border-gray-100 bg-gray-50/60 text-xs text-gray-400">{list.length} of {lands.length} listings</div>
      </div>

      {/* Land Detail Modal */}
      {modal && (
        <Modal open={!!modal} onClose={() => setModal(null)} title="Land Listing Details" size="lg"
          footer={
            <>
              <button onClick={() => setModal(null)} className="admin-button-secondary">Close</button>
              {modal.status === 'pending' && <>
                <button onClick={() => setStatus(modal.id, 'inactive')} className="admin-button-danger">Reject</button>
                <button onClick={() => setStatus(modal.id, 'active')} className="admin-button-primary">Approve</button>
              </>}
              {modal.status === 'active' && (
                <button onClick={() => setStatus(modal.id, 'inactive')} className="admin-button-secondary">Deactivate</button>
              )}
              {modal.status === 'inactive' && (
                <button onClick={() => setStatus(modal.id, 'active')} className="admin-button-primary">Activate</button>
              )}
              <button onClick={() => { setConfirm({ land: modal, action: 'delete' }); setModal(null); }} className="admin-button-danger">
                <Trash2 size={13} className="inline mr-1" />Delete
              </button>
            </>
          }
        >
          <div className="grid grid-cols-2 gap-4 text-sm">
            <div className="col-span-2"><div className="text-xs text-gray-400">Title</div><div className="font-bold text-base">{modal.title}</div></div>
            <div><div className="text-xs text-gray-400">Status</div><Badge variant={modal.status}>{modal.status.charAt(0).toUpperCase()+modal.status.slice(1)}</Badge></div>
            <div><div className="text-xs text-gray-400">Owner</div><div className="font-semibold">{modal.owner}</div></div>
            <div><div className="text-xs text-gray-400">Location</div><div className="font-semibold">{modal.location}</div></div>
            <div><div className="text-xs text-gray-400">Province</div><div className="font-semibold">{modal.province}</div></div>
            <div><div className="text-xs text-gray-400">Area</div><div className="font-semibold">{modal.area} Bigha</div></div>
            <div><div className="text-xs text-gray-400">Price / Bigha</div><div className="font-semibold">Rs {modal.price.toLocaleString()}</div></div>
            <div><div className="text-xs text-gray-400">Applications</div><div className="font-semibold">{apps.filter(a => a.land === modal.title).length}</div></div>
          </div>
        </Modal>
      )}

      {/* Delete Confirm */}
      {confirm?.action === 'delete' && (
        <Modal open={!!confirm} onClose={() => setConfirm(null)} title="Delete Listing" size="sm"
          footer={
            <>
              <button onClick={() => setConfirm(null)} className="admin-button-secondary">Cancel</button>
              <button onClick={() => deleteLand(confirm.land.id)} className="admin-button-danger !bg-red-600 !text-white hover:!bg-red-700">Delete</button>
            </>
          }
        >
          <p className="text-sm text-gray-600">Permanently delete <strong>&ldquo;{confirm.land.title}&rdquo;</strong>? This cannot be undone.</p>
        </Modal>
      )}
    </div>
  );
}
