'use client';
import { CheckCircle, AlertTriangle, XCircle, Info, X } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';

const CONFIG = {
  success: { bg: 'bg-green-600', icon: CheckCircle },
  warning: { bg: 'bg-amber-500', icon: AlertTriangle },
  danger:  { bg: 'bg-red-600',   icon: XCircle },
  info:    { bg: 'bg-blue-600',  icon: Info },
};

export default function ToastContainer() {
  const { toasts } = useAdmin();
  return (
    <div className="fixed bottom-4 right-4 z-[9999] flex flex-col gap-2 pointer-events-none">
      {toasts.map(t => {
        const { bg, icon: Icon } = CONFIG[t.type] || CONFIG.info;
        return (
          <div
            key={t.id}
            className={`toast-in flex items-center gap-3 px-4 py-3 rounded-xl shadow-xl text-white text-sm font-semibold min-w-[260px] pointer-events-auto ${bg}`}
          >
            <Icon size={16} className="flex-shrink-0" />
            <span className="flex-1">{t.msg}</span>
          </div>
        );
      })}
    </div>
  );
}
