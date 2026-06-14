'use client';
import { X } from 'lucide-react';
import { useEffect } from 'react';

interface ModalProps {
  open: boolean;
  onClose: () => void;
  title?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  children: React.ReactNode;
  footer?: React.ReactNode;
}

const SIZE_MAP = { sm: 'max-w-sm', md: 'max-w-md', lg: 'max-w-lg', xl: 'max-w-2xl' };

export default function Modal({ open, onClose, title, size = 'md', children, footer }: ModalProps) {
  useEffect(() => {
    const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    if (open) document.addEventListener('keydown', handler);
    return () => document.removeEventListener('keydown', handler);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[500] flex items-center justify-center p-4" role="dialog" aria-modal="true">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/50 backdrop-blur-md animate-in fade-in duration-200" onClick={onClose} />
      {/* Panel */}
      <div className={`relative bg-white rounded-xl shadow-2xl border border-gray-200 w-full ${SIZE_MAP[size]} flex flex-col max-h-[90vh] animate-in slide-up duration-300`}>
        {/* Header */}
        {title && (
          <div className="flex items-center justify-between px-6 py-5 border-b border-gray-100">
            <h2 className="font-extrabold text-lg text-gray-900">{title}</h2>
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-lg transition-colors" aria-label="Close">
              <X size={20} className="text-gray-500" />
            </button>
          </div>
        )}
        {/* Body */}
        <div className="px-6 py-5 overflow-y-auto flex-1">{children}</div>
        {/* Footer */}
        {footer && (
          <div className="px-6 py-5 border-t border-gray-100 flex justify-end gap-3">{footer}</div>
        )}
      </div>
    </div>
  );
}
