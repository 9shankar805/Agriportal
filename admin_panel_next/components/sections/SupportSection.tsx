'use client';
import { useState } from 'react';
import { Search, CheckCircle2, RotateCcw, Trash2, Mail, UserRound, Info } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Badge from '@/components/ui/Badge';
import Modal from '@/components/ui/Modal';
import { avatarColor } from '@/lib/utils';
import type { SupportMessage } from '@/lib/types';

type SupTab = 'open' | 'resolved' | '';

export default function SupportSection() {
  const { supportMsgs, setSupportMsgs, showToast, firebaseReady } = useAdmin();
  const [tab,    setTab]    = useState<SupTab>('open');
  const [search, setSearch] = useState('');
  const [active, setActive] = useState<SupportMessage | null>(null);
  const [confirm, setConfirm] = useState<SupportMessage | null>(null);

  const list = supportMsgs.filter(m =>
    (!tab    || m.status === tab) &&
    (!search || m.name.toLowerCase().includes(search.toLowerCase()) || m.email.toLowerCase().includes(search.toLowerCase()) || m.message.toLowerCase().includes(search.toLowerCase()) || m.category.toLowerCase().includes(search.toLowerCase()))
  );

  const setStatus = async (id: string, status: 'open' | 'resolved') => {
    setSupportMsgs(prev => prev.map(m => m.id === id ? { ...m, status } : m));
    if (firebaseReady) {
      try {
        const { db, updateDoc, doc } = await import('@/lib/firebase');
        await updateDoc(doc(db, 'supportMessages', id), { status });
      } catch {}
    }
    setActive(prev => prev ? { ...prev, status } : null);
    showToast(status === 'resolved' ? 'Message marked as resolved.' : 'Message reopened.', 'success');
  };

  const deleteMsg = async (id: string) => {
    setSupportMsgs(prev => prev.filter(m => m.id !== id));
    if (firebaseReady) {
      try {
        const { db, deleteDoc, doc } = await import('@/lib/firebase');
        await deleteDoc(doc(db, 'supportMessages', id));
      } catch {}
    }
    if (active?.id === id) setActive(null);
    setConfirm(null);
    showToast('Message deleted.', 'warning');
  };

  const TABS: { value: SupTab; label: string }[] = [
    { value: 'open',     label: 'Open' },
    { value: 'resolved', label: 'Resolved' },
    { value: '',         label: 'All' },
  ];

  return (
    <div className="fade-up space-y-4">
      {/* Toolbar */}
      <div className="admin-toolbar">
        <div className="admin-search flex-1 max-w-sm">
          <Search size={14} className="text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search messages…" className="border-none outline-none bg-transparent text-sm flex-1" />
        </div>
        <div className="flex gap-1 bg-gray-100 border border-gray-200 rounded-lg p-1">
          {TABS.map(t => (
            <button key={t.value}
              onClick={() => setTab(t.value)}
              className={`border border-transparent px-3 py-2 rounded-md text-xs font-semibold transition-colors
                ${tab === t.value ? 'bg-white text-gray-950 shadow-sm border-gray-200' : 'text-gray-500 hover:text-gray-900'}`}>
              {t.label}
            </button>
          ))}
        </div>
      </div>

      {/* Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-[340px_1fr] gap-4" style={{ minHeight: 480 }}>
        {/* List */}
        <div className="admin-card overflow-hidden flex flex-col">
          <div className="px-4 py-3 border-b border-gray-100 flex items-center justify-between font-bold text-sm">
            <span><Mail size={14} className="inline mr-2 text-green-600" />Messages</span>
            <span className="text-xs bg-gray-100 text-gray-500 rounded-full px-2 py-0.5 font-semibold">{list.length}</span>
          </div>
          <div className="flex-1 overflow-y-auto">
            {list.length === 0 ? (
              <div className="text-center py-12 text-gray-400 text-sm">No messages match this filter.</div>
            ) : list.map(m => (
              <div
                key={m.id}
                onClick={() => setActive(m)}
                className={`flex gap-2.5 px-4 py-3.5 cursor-pointer border-b border-gray-50 transition-colors relative
                  ${active?.id === m.id ? 'bg-green-50 border-l-2 border-l-green-500' : 'hover:bg-gray-50'}
                  ${m.status === 'open' ? 'font-semibold' : ''}`}
              >
                <div className="w-9 h-9 rounded-full flex items-center justify-center text-white font-bold text-sm flex-shrink-0"
                  style={{ background: avatarColor(m.name) }}>
                  {m.name[0]}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <div className={`text-sm truncate ${m.status === 'open' ? 'font-bold' : 'font-medium'}`}>{m.name}</div>
                    <div className="text-[10px] text-gray-400 ml-1 flex-shrink-0">{m.createdAt}</div>
                  </div>
                  <div className="text-[10px] text-gray-400">{m.category} · {m.email}</div>
                  <div className="text-xs text-gray-500 truncate mt-0.5">{m.message}</div>
                </div>
                {m.status === 'open' && (
                  <div className="absolute top-3 right-3 w-2 h-2 rounded-full bg-green-500" />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Detail */}
        <div className="admin-card overflow-hidden flex flex-col">
          {!active ? (
            <div className="flex-1 flex items-center justify-center text-gray-400">
              <div className="text-center p-8">
                <Mail size={40} className="mx-auto mb-3 text-green-200" />
                <p className="text-sm">Select a message to view details</p>
              </div>
            </div>
          ) : (
            <>
              {/* Detail header */}
              <div className="flex items-start justify-between gap-3 px-6 py-4 border-b border-gray-100 flex-wrap">
                <div className="flex items-center gap-3">
                  <div className="w-11 h-11 rounded-full flex items-center justify-center text-white font-bold flex-shrink-0"
                    style={{ background: avatarColor(active.name) }}>
                    {active.name[0]}
                  </div>
                  <div>
                    <div className="font-extrabold">{active.name}</div>
                    <div className="text-sm text-gray-400">{active.email}</div>
                    <div className="flex gap-2 mt-1.5 flex-wrap">
                      <Badge variant={active.status === 'open' ? 'open' : 'resolved'}>
                        {active.status === 'open' ? 'Open' : 'Resolved'}
                      </Badge>
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-gray-100 text-gray-600 border">{active.category}</span>
                    </div>
                  </div>
                </div>
                <div className="flex gap-2 flex-wrap">
                  {active.status === 'open' ? (
                    <button onClick={() => setStatus(active.id, 'resolved')} className="admin-button-primary !min-h-8 !px-3 !text-xs">
                      <CheckCircle2 size={13} /> Mark Resolved
                    </button>
                  ) : (
                    <button onClick={() => setStatus(active.id, 'open')} className="admin-button-secondary !min-h-8 !px-3 !text-xs">
                      <RotateCcw size={13} /> Reopen
                    </button>
                  )}
                  <button onClick={() => setConfirm(active)} className="admin-icon-button hover:!border-red-200 hover:!bg-red-50 hover:!text-red-600" title="Delete message">
                    <Trash2 size={13} />
                  </button>
                </div>
              </div>

              {/* Detail body */}
              <div className="p-6 overflow-y-auto flex-1">
                <div className="grid grid-cols-2 gap-3 mb-5">
                  {[
                    { label: 'Received', value: active.createdAt },
                    { label: 'Category', value: active.category },
                    { label: 'Email', value: active.email },
                    { label: 'Status', value: <Badge variant={active.status === 'open' ? 'open' : 'resolved'}>{active.status}</Badge> },
                  ].map(({ label, value }) => (
                    <div key={label}>
                      <div className="text-[10px] font-extrabold text-gray-400 uppercase tracking-wide">{label}</div>
                      <div className="text-sm font-semibold mt-0.5">{value}</div>
                    </div>
                  ))}
                </div>

                <div className="font-bold text-sm mb-2">Message</div>
                <div className="rounded-lg border border-gray-200 bg-gray-50 px-4 py-3.5 text-sm leading-relaxed whitespace-pre-wrap text-gray-700 mb-4">
                  {active.message}
                </div>

                {active.uid ? (
                  <div className="flex items-center gap-2 rounded-lg border border-gray-200 bg-gray-50 px-4 py-3 text-sm text-gray-600">
                    <UserRound size={15} className="flex-shrink-0 text-gray-400" /> Sent by a registered user. UID: <code className="font-mono text-xs">{active.uid}</code>
                  </div>
                ) : (
                  <div className="flex items-center gap-2 rounded-lg border border-gray-200 bg-gray-50 px-4 py-3 text-sm text-gray-500">
                    <Info size={15} className="flex-shrink-0 text-gray-400" /> Sent as a guest (not signed in).
                  </div>
                )}
              </div>
            </>
          )}
        </div>
      </div>

      {/* Delete confirm */}
      {confirm && (
        <Modal open={!!confirm} onClose={() => setConfirm(null)} title="Delete Message" size="sm"
          footer={
            <>
              <button onClick={() => setConfirm(null)} className="admin-button-secondary">Cancel</button>
              <button onClick={() => deleteMsg(confirm.id)} className="admin-button-danger !bg-red-600 !text-white hover:!bg-red-700">Delete</button>
            </>
          }
        >
          <p className="text-sm text-gray-600">Permanently delete this support message? This cannot be undone.</p>
        </Modal>
      )}
    </div>
  );
}
