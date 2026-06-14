'use client';
import { useState, useEffect, useRef } from 'react';
import { Search, MessageSquare } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import { relTime, fmtTime, avatarColor } from '@/lib/utils';
import type { Message } from '@/lib/types';

export default function MessagesSection() {
  const { convs, firebaseReady } = useAdmin();
  const [search, setSearch]       = useState('');
  const [active, setActive]       = useState<string | null>(null);
  const [msgs,   setMsgs]         = useState<Message[]>([]);
  const bodyRef = useRef<HTMLDivElement>(null);

  const filtered = convs.filter(c =>
    !search ||
    c.aName.toLowerCase().includes(search.toLowerCase()) ||
    c.bName.toLowerCase().includes(search.toLowerCase()) ||
    c.land.toLowerCase().includes(search.toLowerCase())
  );

  useEffect(() => {
    if (!active) return;
    const conv = convs.find(c => c.id === active);
    if (!conv) return;

    if (firebaseReady) {
      import('@/lib/firebase').then(({ rtdb, rtRef, rtOnValue, rtQuery, orderByChild }) => {
        const msgRef = rtQuery(rtRef(rtdb, `messages/${active}`), orderByChild('timestamp'));
        rtOnValue(msgRef, snap => {
          if (!snap.exists()) { setMsgs([]); return; }
          const list: Message[] = [];
          snap.forEach((child: import('firebase/database').IteratedDataSnapshot) => {
            list.push({ key: child.key ?? undefined, ...child.val() } as Message);
          });
          setMsgs(list);
          setTimeout(() => { if (bodyRef.current) bodyRef.current.scrollTop = bodyRef.current.scrollHeight; }, 50);
        });
      });
    } else {
      setMsgs(conv.msgs || []);
      setTimeout(() => { if (bodyRef.current) bodyRef.current.scrollTop = bodyRef.current.scrollHeight; }, 50);
    }
  }, [active, convs, firebaseReady]);

  const activeConv = convs.find(c => c.id === active);

  return (
    <div className="fade-up">
      <div className="grid grid-cols-1 lg:grid-cols-[320px_1fr] gap-4" style={{ height: 'calc(100vh - 136px)', minHeight: 480 }}>
        {/* Conversation list */}
        <div className="admin-card flex flex-col overflow-hidden">
          <div className="flex items-center justify-between px-4 py-3 border-b border-gray-100 font-bold text-sm">
            <span>Conversations</span>
            <span className="flex items-center gap-1.5 bg-green-50 text-green-700 text-[10px] font-bold px-2 py-0.5 rounded-full border border-green-200">
              <span className="live-dot w-1.5 h-1.5 rounded-full bg-green-500 inline-block" />Live
            </span>
          </div>
          <div className="admin-search !rounded-none !border-x-0 !border-t-0 !shadow-none">
            <Search size={13} className="text-gray-400" />
            <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search…" className="border-none outline-none bg-transparent text-sm flex-1" />
          </div>
          <div className="flex-1 overflow-y-auto">
            {filtered.length === 0 ? (
              <div className="text-center py-8 text-gray-400 text-sm">No conversations yet.</div>
            ) : filtered.map(c => (
              <div
                key={c.id}
                onClick={() => setActive(c.id)}
                className={`flex items-start gap-2.5 px-4 py-3 cursor-pointer border-b border-gray-50 transition-colors
                  ${active === c.id ? 'bg-green-50 border-l-2 border-l-green-500' : 'hover:bg-gray-50'}`}
              >
                <div className="w-9 h-9 rounded-full flex items-center justify-center text-white font-bold text-sm flex-shrink-0"
                  style={{ background: avatarColor(c.aName) }}>
                  {c.aName[0]}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-center">
                    <div className="font-semibold text-xs truncate">{c.aName} ↔ {c.bName}</div>
                    <div className="text-[10px] text-gray-400 ml-1 flex-shrink-0">{relTime(c.ts)}</div>
                  </div>
                  <div className="text-[10px] text-gray-400 truncate">{c.land}</div>
                  <div className="text-xs truncate mt-0.5 text-gray-600">{c.lastMsg}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Message viewer */}
        <div className="admin-card flex flex-col overflow-hidden">
          {!activeConv ? (
            <div className="flex-1 flex items-center justify-center text-gray-400">
              <div className="text-center">
                <MessageSquare size={40} className="mx-auto mb-3 text-green-200" />
                <p className="text-sm">Select a conversation to view messages</p>
              </div>
            </div>
          ) : (
            <>
              {/* Header */}
              <div className="flex items-center gap-3 px-5 py-3.5 border-b border-gray-100">
                <div className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold flex-shrink-0"
                  style={{ background: avatarColor(activeConv.aName) }}>
                  {activeConv.aName[0]}
                </div>
                <div className="flex-1">
                  <div className="font-bold text-sm">{activeConv.aName} ↔ {activeConv.bName}</div>
                  <div className="text-xs text-gray-400">{activeConv.land}</div>
                </div>
                <span className="flex items-center gap-1.5 bg-green-50 text-green-700 text-[10px] font-bold px-2 py-0.5 rounded-full border border-green-200">
                  <span className="live-dot w-1.5 h-1.5 rounded-full bg-green-500 inline-block" />Live
                </span>
              </div>

              {/* Messages */}
              <div ref={bodyRef} className="flex-1 overflow-y-auto p-5 bg-gray-50 flex flex-col gap-3">
                {msgs.length === 0 ? (
                  <div className="text-center py-8 text-gray-400 text-sm">No messages in this conversation yet.</div>
                ) : msgs.map((m, i) => {
                  const isRight = firebaseReady
                    ? (activeConv.aId ? m.senderId !== activeConv.aId : false)
                    : m.from === 'b';
                  const senderName = m.senderName || (isRight ? activeConv.bName : activeConv.aName);
                  const ts = m.timestamp || m.ts || 0;

                  return (
                    <div key={m.key || i} className={`flex flex-col ${isRight ? 'items-end' : 'items-start'}`}>
                      <div className="text-[10px] text-gray-400 mb-1">{senderName} · {ts ? fmtTime(ts) : ''}</div>
                      <div className={`max-w-[65%] px-3.5 py-2.5 rounded-2xl text-sm leading-relaxed shadow-sm
                        ${isRight
                          ? 'bg-green-700 text-white rounded-br-sm'
                          : 'bg-white text-gray-800 rounded-bl-sm'
                        }`}>
                        {m.text}
                      </div>
                    </div>
                  );
                })}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
