'use client';
import { useState } from 'react';
import { Search, Check, X } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Avatar from '@/components/ui/Avatar';
import Badge from '@/components/ui/Badge';
import SortableHeader, { type SortDirection } from '@/components/ui/SortableHeader';

export default function ApplicationsSection() {
  const { apps, setApps, showToast, firebaseReady } = useAdmin();
  const [search,  setSearch]  = useState('');
  const [statusF, setStatusF] = useState('');
  const [sort, setSort] = useState<{ column: string; direction: SortDirection }>({ column: 'applied', direction: 'desc' });

  const filtered = apps.filter(a =>
    (!search  || a.applicant.toLowerCase().includes(search.toLowerCase()) || a.land.toLowerCase().includes(search.toLowerCase())) &&
    (!statusF || a.status === statusF)
  );
  const list = [...filtered].sort((a, b) => {
    const aValue = String(a[sort.column as keyof typeof a] ?? '');
    const bValue = String(b[sort.column as keyof typeof b] ?? '');
    return aValue.localeCompare(bValue, undefined, { numeric: true }) * (sort.direction === 'asc' ? 1 : -1);
  });
  const handleSort = (column: string) => setSort(prev => ({
    column,
    direction: prev.column === column && prev.direction === 'asc' ? 'desc' : 'asc',
  }));

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
      <div className="admin-toolbar">
        <div className="admin-search flex-1 max-w-sm">
          <Search size={14} className="text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search applications…" className="border-none outline-none bg-transparent text-sm flex-1" />
        </div>
        <select value={statusF} onChange={e => setStatusF(e.target.value)}
          className="admin-select">
          <option value="">All Status</option>
          <option value="pending">Pending</option>
          <option value="approved">Approved</option>
          <option value="rejected">Rejected</option>
        </select>
      </div>

      {/* Table */}
      <div className="admin-table-panel">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr>
                <th className="admin-table-static-heading text-center">#</th>
                <SortableHeader label="Applicant" column="applicant" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Land" column="land" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Land Owner" column="owner" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Applied" column="applied" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Status" column="status" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <th className="admin-table-static-heading text-left">Actions</th>
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
                        <button onClick={() => setStatus(a.id, 'approved')} className="admin-icon-button hover:!border-green-200 hover:!bg-green-50 hover:!text-green-700" title="Approve">
                          <Check size={14} />
                        </button>
                        <button onClick={() => setStatus(a.id, 'rejected')} className="admin-icon-button hover:!border-red-200 hover:!bg-red-50 hover:!text-red-600" title="Reject">
                          <X size={14} />
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
