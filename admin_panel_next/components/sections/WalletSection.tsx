'use client';
import { useState } from 'react';
import { Search, Wallet, TrendingUp, TrendingDown, ArrowUpRight, ArrowDownRight, X } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';
import Avatar from '@/components/ui/Avatar';
import Modal from '@/components/ui/Modal';
import type { WalletEntry, WalletTransaction } from '@/lib/types';
import { relTime } from '@/lib/utils';
import SortableHeader, { type SortDirection } from '@/components/ui/SortableHeader';

export default function WalletSection() {
  const { wallets } = useAdmin();
  const [search,  setSearch]  = useState('');
  const [detail,  setDetail]  = useState<WalletEntry | null>(null);
  const [sort, setSort] = useState<{ column: string; direction: SortDirection }>({ column: 'balance', direction: 'desc' });

  const searched = wallets.filter(w =>
    !search ||
    w.userName.toLowerCase().includes(search.toLowerCase()) ||
    w.userEmail.toLowerCase().includes(search.toLowerCase())
  );
  const filtered = [...searched].sort((a, b) => {
    const totals = (wallet: WalletEntry) => ({
      credits: wallet.transactions.filter(t => t.type === 'credit').reduce((sum, t) => sum + t.amount, 0),
      debits: wallet.transactions.filter(t => t.type === 'debit').reduce((sum, t) => sum + t.amount, 0),
      transactions: wallet.transactions.length,
    });
    const value = (wallet: WalletEntry) => ['credits', 'debits', 'transactions'].includes(sort.column)
      ? totals(wallet)[sort.column as keyof ReturnType<typeof totals>]
      : wallet[sort.column as keyof WalletEntry];
    return String(value(a) ?? '').localeCompare(String(value(b) ?? ''), undefined, { numeric: true }) * (sort.direction === 'asc' ? 1 : -1);
  });
  const handleSort = (column: string) => setSort(prev => ({
    column,
    direction: prev.column === column && prev.direction === 'asc' ? 'desc' : 'asc',
  }));

  const totalBalance  = wallets.reduce((s, w) => s + w.balance, 0);
  const totalCredits  = wallets.flatMap(w => w.transactions).filter(t => t.type === 'credit').reduce((s, t) => s + t.amount, 0);
  const totalDebits   = wallets.flatMap(w => w.transactions).filter(t => t.type === 'debit').reduce((s, t) => s + t.amount, 0);
  const activeWallets = wallets.filter(w => w.balance > 0).length;

  return (
    <div className="fade-up space-y-5">

      {/* Summary cards */}
      <div className="grid grid-cols-2 xl:grid-cols-4 gap-3">
        <SummaryCard
          icon={<Wallet size={20} className="text-violet-600" />}
          bg="bg-violet-50"
          label="Total Wallet Balance"
          value={`Rs ${totalBalance.toLocaleString()}`}
          sub={`across ${wallets.length} users`}
        />
        <SummaryCard
          icon={<TrendingUp size={20} className="text-green-600" />}
          bg="bg-green-50"
          label="Total Credits"
          value={`Rs ${totalCredits.toLocaleString()}`}
          sub="all time"
          accent="text-green-600"
        />
        <SummaryCard
          icon={<TrendingDown size={20} className="text-red-500" />}
          bg="bg-red-50"
          label="Total Debits (Fees)"
          value={`Rs ${totalDebits.toLocaleString()}`}
          sub="listing fees collected"
          accent="text-red-500"
        />
        <SummaryCard
          icon={<ArrowUpRight size={20} className="text-blue-600" />}
          bg="bg-blue-50"
          label="Active Wallets"
          value={String(activeWallets)}
          sub={`${wallets.length - activeWallets} empty`}
        />
      </div>

      {/* Search */}
      <div className="admin-toolbar">
        <div className="admin-search flex-1 max-w-sm">
          <Search size={14} className="text-gray-400 flex-shrink-0" />
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search by name or email…"
            className="border-none outline-none bg-transparent text-sm flex-1"
          />
        </div>
        {search && (
          <button onClick={() => setSearch('')} className="flex items-center gap-1.5 text-xs text-gray-400 hover:text-gray-600 transition-colors">
            <X size={13} /> Clear
          </button>
        )}
        <span className="ml-auto text-xs text-gray-400 font-medium">{filtered.length} of {wallets.length} users</span>
      </div>

      {/* Table */}
      <div className="admin-table-panel">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr>
                <th className="admin-table-static-heading text-center">#</th>
                <SortableHeader label="User" column="userName" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Balance" column="balance" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Credits" column="credits" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Debits" column="debits" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <SortableHeader label="Transactions" column="transactions" activeColumn={sort.column} direction={sort.direction} onSort={handleSort} />
                <th className="admin-table-static-heading text-left">Details</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-16 text-center">
                    <div className="flex flex-col items-center gap-2 text-gray-400">
                      <Wallet size={32} className="text-gray-200" />
                      <div className="text-sm font-medium">No wallet data found</div>
                      <div className="text-xs text-gray-300">Wallets are created when users top up their balance</div>
                    </div>
                  </td>
                </tr>
              ) : filtered.map((w, i) => {
                const credits = w.transactions.filter(t => t.type === 'credit').reduce((s, t) => s + t.amount, 0);
                const debits  = w.transactions.filter(t => t.type === 'debit').reduce((s, t) => s + t.amount, 0);
                return (
                  <tr key={w.userId} className="hover:bg-violet-50/30 transition-colors group">
                    <td className="px-4 py-3.5 text-xs text-gray-400 text-center font-mono">{i + 1}</td>
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-3">
                        <Avatar name={w.userName} photoUrl={w.userPhoto} size={38} />
                        <div className="min-w-0">
                          <div className="font-semibold text-sm text-gray-900 truncate">{w.userName}</div>
                          <div className="text-xs text-gray-400 truncate">{w.userEmail}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3.5">
                      <div className={`font-extrabold text-base ${w.balance > 0 ? 'text-violet-700' : 'text-gray-300'}`}>
                        Rs {w.balance.toLocaleString()}
                      </div>
                    </td>
                    <td className="px-4 py-3.5">
                      <span className="flex items-center gap-1 text-green-600 font-semibold text-sm">
                        <ArrowUpRight size={13} /> Rs {credits.toLocaleString()}
                      </span>
                    </td>
                    <td className="px-4 py-3.5">
                      <span className="flex items-center gap-1 text-red-500 font-semibold text-sm">
                        <ArrowDownRight size={13} /> Rs {debits.toLocaleString()}
                      </span>
                    </td>
                    <td className="px-4 py-3.5">
                      <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-600">
                        {w.transactions.length} txn{w.transactions.length !== 1 ? 's' : ''}
                      </span>
                    </td>
                    <td className="px-4 py-3.5">
                      <button
                        onClick={() => setDetail(w)}
                        className="admin-button-secondary !min-h-8 !px-3 !text-xs opacity-80 group-hover:opacity-100"
                      >
                        View <ArrowUpRight size={13} />
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Detail Modal */}
      {detail && (
        <Modal open={!!detail} onClose={() => setDetail(null)} title="Wallet Details" size="lg"
          footer={
            <button onClick={() => setDetail(null)} className="admin-button-secondary">
              Close
            </button>
          }
        >
          {/* User header */}
          <div className="flex items-center gap-4 p-4 bg-gradient-to-r from-violet-50 to-purple-50 rounded-xl border border-violet-100 mb-5">
            <Avatar name={detail.userName} photoUrl={detail.userPhoto} size={56} radius="14px" />
            <div className="flex-1 min-w-0">
              <div className="font-extrabold text-base text-gray-900 truncate">{detail.userName}</div>
              <div className="text-sm text-gray-500 truncate">{detail.userEmail}</div>
              <div className="text-xs text-gray-400 font-mono mt-1 truncate">{detail.userId}</div>
            </div>
            <div className="text-right flex-shrink-0">
              <div className="text-xs text-gray-400 font-medium uppercase tracking-wide">Balance</div>
              <div className={`text-2xl font-extrabold ${detail.balance > 0 ? 'text-violet-700' : 'text-gray-400'}`}>
                Rs {detail.balance.toLocaleString()}
              </div>
            </div>
          </div>

          {/* Stats row */}
          <div className="grid grid-cols-3 gap-3 mb-5">
            {[
              {
                label: 'Total Credited',
                value: `Rs ${detail.transactions.filter(t => t.type === 'credit').reduce((s, t) => s + t.amount, 0).toLocaleString()}`,
                color: 'text-green-600', bg: 'bg-green-50 border-green-100',
              },
              {
                label: 'Total Debited',
                value: `Rs ${detail.transactions.filter(t => t.type === 'debit').reduce((s, t) => s + t.amount, 0).toLocaleString()}`,
                color: 'text-red-500', bg: 'bg-red-50 border-red-100',
              },
              {
                label: 'Transactions',
                value: String(detail.transactions.length),
                color: 'text-violet-700', bg: 'bg-violet-50 border-violet-100',
              },
            ].map(s => (
              <div key={s.label} className={`rounded-xl p-3 border text-center ${s.bg}`}>
                <div className={`font-extrabold text-lg ${s.color}`}>{s.value}</div>
                <div className="text-xs text-gray-500 mt-0.5">{s.label}</div>
              </div>
            ))}
          </div>

          {/* Transactions list */}
          <div className="font-bold text-sm mb-3 text-gray-700">Transaction History</div>
          {detail.transactions.length === 0 ? (
            <div className="text-center py-8 text-gray-400 text-sm bg-gray-50 rounded-xl">No transactions yet</div>
          ) : (
            <div className="space-y-2 max-h-72 overflow-y-auto pr-1">
              {detail.transactions.map(tx => (
                <TxRow key={tx.id} tx={tx} />
              ))}
            </div>
          )}
        </Modal>
      )}
    </div>
  );
}

function SummaryCard({ icon, bg, label, value, sub, accent = 'text-gray-800' }: {
  icon: React.ReactNode;
  bg: string;
  label: string;
  value: string;
  sub: string;
  accent?: string;
}) {
  return (
    <div className="admin-card p-5">
      <div className={`w-11 h-11 rounded-xl ${bg} flex items-center justify-center mb-3`}>
        {icon}
      </div>
      <div className={`text-2xl font-extrabold ${accent}`}>{value}</div>
      <div className="text-xs font-semibold text-gray-600 mt-1">{label}</div>
      <div className="text-[10px] text-gray-400 mt-0.5">{sub}</div>
    </div>
  );
}

function TxRow({ tx }: { tx: WalletTransaction }) {
  const isCredit = tx.type === 'credit';
  return (
    <div className={`flex items-center gap-3 px-4 py-3 rounded-xl border transition-colors
      ${isCredit ? 'bg-green-50/60 border-green-100' : 'bg-red-50/50 border-red-100'}`}>
      <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0
        ${isCredit ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-600'}`}>
        {isCredit ? <ArrowUpRight size={14} /> : <ArrowDownRight size={14} />}
      </div>
      <div className="flex-1 min-w-0">
        <div className="text-sm font-semibold text-gray-800 truncate">{tx.description || (isCredit ? 'Credit' : 'Debit')}</div>
        <div className="text-[10px] text-gray-400">{tx.ts ? relTime(tx.ts) : tx.createdAt}</div>
      </div>
      <div className={`font-extrabold text-sm flex-shrink-0 ${isCredit ? 'text-green-700' : 'text-red-600'}`}>
        {isCredit ? '+' : '-'}Rs {tx.amount.toLocaleString()}
      </div>
    </div>
  );
}
