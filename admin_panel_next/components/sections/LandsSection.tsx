'use client';
import { useState } from 'react';
import { Search, Eye, Check, X, Pause, Trash2, Plus } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Badge from '@/components/ui/Badge';
import Modal from '@/components/ui/Modal';
import type { Land } from '@/lib/types';

export default function LandsSection() {
  const { lands, apps, setLands, showToast, firebaseReady } = useAdmin();
  const [search,  setSearch]  = useState('');
  const [statusF, setStatusF] = useState('');
  const [modal,   setModal]   = useState<Land | null>(null);
  const [confirm, setConfirm] = useState<{ land: Land; action: string } | null>(null);

  const list = lands.filter(l =>
    (!search  || l.title.toLowerCase().includes(search.toLowerCase()) || l.location.toLowerCase().includes(search.toLowerCase()) || l.owner.toLowerCase().includes(search.toLowerCase())) &&
    (!statusF || l.status === statusF)
  );

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
      <div className="flex items-center gap-2 flex-wrap">
        <div className="flex items-center gap-2 bg-white border border-green-100 rounded-lg px-3 py-2 flex-1 max-w-xs shadow-sm">
          <Search size={14} className="text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search listings…" className="border-none outline-none bg-transparent text-sm flex-1" />
        </div>
        <select value={statusF} onChange={e => setStatusF(e.target.value)}
          className="border border-green-100 rounded-lg px-3 py-2 text-sm bg-white shadow-sm outline-none cursor-pointer">
          <option value="">All Status</option>
          <option value="active">Active</option>
          <option value="pending">Pending Review</option>
          <option value="inactive">Inactive</option>
        </select>
        <button
          onClick={() => window.open('https://console.firebase.google.com/project/agriportal-9ee3d/firestore/data/~2Flands','_blank')}
          className="flex items-center gap-1.5 bg-green-600 hover:bg-green-700 text-white rounded-lg px-4 py-2 text-sm font-semibold transition-colors ml-auto">
          <Plus size={14} /> Add Listing
        </button>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-green-50/60 border-b-2 border-green-100">
                {['#','Land Title','Owner','Location','Area','Price/Bigha','Status','Actions'].map(h => (
                  <th key={h} className="px-4 py-3 text-left text-[11px] font-extrabold uppercase tracking-wide text-gray-500 whitespace-nowrap">{h}</th>
                ))}
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
                    <span className="text-green-600 mr-1">📍</span>{l.location}
                  </td>
                  <td className="px-4 py-3 text-sm font-semibold">{l.area} Bigha</td>
                  <td className="px-4 py-3 text-sm font-semibold">Rs {l.price.toLocaleString()}</td>
                  <td className="px-4 py-3"><Badge variant={l.status}>{l.status.charAt(0).toUpperCase()+l.status.slice(1)}</Badge></td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1">
                      <button onClick={() => setModal(l)} className="w-7 h-7 rounded-lg border border-blue-200 bg-blue-50 hover:bg-blue-100 text-blue-600 flex items-center justify-center transition-colors" title="View">
                        <Eye size={12} />
                      </button>
                      {l.status === 'pending' && <>
                        <button onClick={() => setStatus(l.id, 'active')} className="w-7 h-7 rounded-lg border border-green-200 bg-green-50 hover:bg-green-100 text-green-600 flex items-center justify-center" title="Approve">
                          <Check size={12} />
                        </button>
                        <button onClick={() => setStatus(l.id, 'inactive')} className="w-7 h-7 rounded-lg border border-red-200 bg-red-50 hover:bg-red-100 text-red-600 flex items-center justify-center" title="Reject">
                          <X size={12} />
                        </button>
                      </>}
                      {l.status === 'active' && (
                        <button onClick={() => setStatus(l.id, 'inactive')} className="w-7 h-7 rounded-lg border border-amber-200 bg-amber-50 hover:bg-amber-100 text-amber-600 flex items-center justify-center" title="Deactivate">
                          <Pause size={12} />
                        </button>
                      )}
                      {l.status === 'inactive' && (
                        <button onClick={() => setStatus(l.id, 'active')} className="w-7 h-7 rounded-lg border border-green-200 bg-green-50 hover:bg-green-100 text-green-600 flex items-center justify-center" title="Activate">
                          <Check size={12} />
                        </button>
                      )}
                      <button onClick={() => setConfirm({ land: l, action: 'delete' })} className="w-7 h-7 rounded-lg border border-red-200 bg-red-50 hover:bg-red-100 text-red-600 flex items-center justify-center" title="Delete">
                        <Trash2 size={12} />
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
              <button onClick={() => setModal(null)} className="px-4 py-2 rounded-lg bg-gray-100 text-sm font-semibold">Close</button>
              {modal.status === 'pending' && <>
                <button onClick={() => setStatus(modal.id, 'inactive')} className="px-4 py-2 rounded-lg border border-red-200 text-red-600 text-sm font-semibold hover:bg-red-50">Reject</button>
                <button onClick={() => setStatus(modal.id, 'active')} className="px-4 py-2 rounded-lg bg-green-600 hover:bg-green-700 text-white text-sm font-semibold">Approve</button>
              </>}
              {modal.status === 'active' && (
                <button onClick={() => setStatus(modal.id, 'inactive')} className="px-4 py-2 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-sm font-semibold">Deactivate</button>
              )}
              {modal.status === 'inactive' && (
                <button onClick={() => setStatus(modal.id, 'active')} className="px-4 py-2 rounded-lg bg-green-600 hover:bg-green-700 text-white text-sm font-semibold">Activate</button>
              )}
              <button onClick={() => { setConfirm({ land: modal, action: 'delete' }); setModal(null); }} className="px-4 py-2 rounded-lg border border-red-200 text-red-600 text-sm font-semibold hover:bg-red-50">
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
              <button onClick={() => setConfirm(null)} className="px-4 py-2 rounded-lg bg-gray-100 text-sm font-semibold">Cancel</button>
              <button onClick={() => deleteLand(confirm.land.id)} className="px-4 py-2 rounded-lg bg-red-600 hover:bg-red-700 text-white text-sm font-semibold">Delete</button>
            </>
          }
        >
          <p className="text-sm text-gray-600">Permanently delete <strong>&ldquo;{confirm.land.title}&rdquo;</strong>? This cannot be undone.</p>
        </Modal>
      )}
    </div>
  );
}
