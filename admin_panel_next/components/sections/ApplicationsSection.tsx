'use client';
import { useState } from 'react';
import { Search, Check, X } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Avatar from '@/components/ui/Avatar';
import Badge from '@/components/ui/Badge';

export default function ApplicationsSection() {
  const { apps, setApps, showToast, firebaseReady } = useAdmin();
  const [search,  setSearch]  = useState('');
  const [statusF, setStatusF] = useState('');

  const list = apps.filter(a =>
    (!search  || a.applicant.toLowerCase().includes(search.toLowerCase()) || a.land.toLowerCase().includes(search.toLowerCase())) &&
    (!statusF || a.status === statusF)
  );

  const setStatus = async (id: string, status: 'approved' | 'rejected') => {
    setApps(prev => prev.map(a => a.id === id ? { ...a, status } : a));
    if (firebaseReady) {
      try {
        const { db, updateDoc, doc } = await import('@/lib/firebase');
        await updateDoc(doc(db, 'applications', id), { status });
      } catch {}
    }
    showToast(`Application ${status}.`, status === 'approved' ? 'success' : 'warning');
  };

  return (
    <div className="fade-up space-y-4">
      {/* Toolbar */}
      <div className="flex items-center gap-2 flex-wrap">
        <div className="flex items-center gap-2 bg-white border border-green-100 rounded-lg px-3 py-2 flex-1 max-w-xs shadow-sm">
          <Search size={14} className="text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search applications…" className="border-none outline-none bg-transparent text-sm flex-1" />
        </div>
        <select value={statusF} onChange={e => setStatusF(e.target.value)}
          className="border border-green-100 rounded-lg px-3 py-2 text-sm bg-white shadow-sm outline-none cursor-pointer">
          <option value="">All Status</option>
          <option value="pending">Pending</option>
          <option value="approved">Approved</option>
          <option value="rejected">Rejected</option>
        </select>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-green-50/60 border-b-2 border-green-100">
                {['#','Applicant','Land','Land Owner','Applied','Status','Actions'].map(h => (
                  <th key={h} className="px-4 py-3 text-left text-[11px] font-extrabold uppercase tracking-wide text-gray-500 whitespace-nowrap">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {list.length === 0 ? (
                <tr><td colSpan={7} className="text-center py-12 text-gray-400 text-sm">No applications match the current filters.</td></tr>
              ) : list.map((a, i) => (
                <tr key={a.id} className="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                  <td className="px-4 py-3 text-xs text-gray-400 text-center">{i+1}</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <Avatar name={a.applicant} size={30} />
                      <span className="font-semibold text-sm">{a.applicant}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm font-semibold">{a.land}</td>
                  <td className="px-4 py-3 text-sm text-gray-500">{a.owner}</td>
                  <td className="px-4 py-3 text-xs text-gray-500">{a.applied}</td>
                  <td className="px-4 py-3">
                    <Badge variant={a.status}>{a.status.charAt(0).toUpperCase()+a.status.slice(1)}</Badge>
                  </td>
                  <td className="px-4 py-3">
                    {a.status === 'pending' ? (
                      <div className="flex gap-1">
                        <button onClick={() => setStatus(a.id, 'approved')} className="w-7 h-7 rounded-lg border border-green-200 bg-green-50 hover:bg-green-100 text-green-600 flex items-center justify-center" title="Approve">
                          <Check size={12} />
                        </button>
                        <button onClick={() => setStatus(a.id, 'rejected')} className="w-7 h-7 rounded-lg border border-red-200 bg-red-50 hover:bg-red-100 text-red-600 flex items-center justify-center" title="Reject">
                          <X size={12} />
                        </button>
                      </div>
                    ) : <span className="text-xs text-gray-300">—</span>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="px-4 py-3 border-t border-gray-100 bg-gray-50/60 text-xs text-gray-400">{list.length} of {apps.length} applications</div>
      </div>
    </div>
  );
}
