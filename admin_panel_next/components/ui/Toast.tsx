'use client';
import { CheckCircle, AlertTriangle, XCircle, Info, X } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';

const CONFIG = {
  success: { bg: 'bg-green-700', icon: CheckCircle },
  warning: { bg: 'bg-amber-600', icon: AlertTriangle },
  danger:  { bg: 'bg-red-600',   icon: XCircle },
  info:    { bg: 'bg-blue-600',   icon: Info },
};

export default function ToastContainer() {
  const { toasts, removeToast } = useAdmin();
  return (
    <div className="fixed bottom-6 right-6 z-[9999] flex flex-col gap-3 pointer-events-none">
      {toasts.map(t => {
        const { bg, icon: Icon } = CONFIG[t.type] || CONFIG.info;
        return (
          <div
            key={t.id}
            className={`toast-in flex items-center gap-3 px-5 py-4 rounded-lg shadow-xl text-white text-sm font-semibold min-w-[300px] pointer-events-auto ${bg}`}
          >
            <Icon size={20} className="flex-shrink-0" />
            <span className="flex-1">{t.msg}</span>
            <button
              onClick={() => removeToast(t.id)}
              className="p-1 hover:bg-white/20 rounded-lg transition-colors"
              aria-label="Close"
            >
              <X size={16} />
            </button>
          </div>
        );
      })}
    </div>
  );
}
