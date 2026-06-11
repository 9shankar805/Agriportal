'use client';

import React, { createContext, useContext, useState, useEffect, useCallback, useRef } from 'react';
import type { User } from 'firebase/auth';
import type { AppUser, Land, Application, Conversation, SupportMessage } from '@/lib/types';
import { SEED_USERS, SEED_LANDS, SEED_APPS, SEED_CONVS, SEED_SUPPORT } from '@/lib/seed';
import { tsToDate } from '@/lib/utils';

interface Toast { msg: string; type: 'success' | 'warning' | 'danger' | 'info'; id: number }

interface AdminContextType {
  // Auth
  authUser: User | null;
  firebaseReady: boolean;
  // Data
  users: AppUser[];
  lands: Land[];
  apps: Application[];
  convs: Conversation[];
  supportMsgs: SupportMessage[];
  // Setters
  setUsers: React.Dispatch<React.SetStateAction<AppUser[]>>;
  setLands: React.Dispatch<React.SetStateAction<Land[]>>;
  setApps: React.Dispatch<React.SetStateAction<Application[]>>;
  setConvs: React.Dispatch<React.SetStateAction<Conversation[]>>;
  setSupportMsgs: React.Dispatch<React.SetStateAction<SupportMessage[]>>;
  // Toast
  toasts: Toast[];
  showToast: (msg: string, type?: Toast['type']) => void;
  // Firebase loaders
  loadAllFirebase: () => Promise<void>;
}

const AdminContext = createContext<AdminContextType | null>(null);

export function AdminProvider({ children }: { children: React.ReactNode }) {
  const [authUser, setAuthUser]         = useState<User | null>(null);
  const [firebaseReady, setFirebaseReady] = useState(false);
  const [users,       setUsers]         = useState<AppUser[]>(SEED_USERS);
  const [lands,       setLands]         = useState<Land[]>(SEED_LANDS);
  const [apps,        setApps]          = useState<Application[]>(SEED_APPS);
  const [convs,       setConvs]         = useState<Conversation[]>(SEED_CONVS);
  const [supportMsgs, setSupportMsgs]   = useState<SupportMessage[]>(SEED_SUPPORT);
  const [toasts,      setToasts]        = useState<Toast[]>([]);
  const toastCounter = useRef(0);

  const showToast = useCallback((msg: string, type: Toast['type'] = 'success') => {
    const id = ++toastCounter.current;
    setToasts(prev => [...prev, { msg, type, id }]);
    setTimeout(() => setToasts(prev => prev.filter(t => t.id !== id)), 3500);
  }, []);

  useEffect(() => {
    // Dynamically import firebase to avoid SSR issues
    import('@/lib/firebase').then(({ onAuth }) => {
      setFirebaseReady(true);
      const unsub = onAuth(u => setAuthUser(u));
      return unsub;
    });
  }, []);

  const loadAllFirebase = useCallback(async () => {
    if (!firebaseReady) return;
    try {
      const { db, getDocs, collection } = await import('@/lib/firebase');

      // Load users
      const uSnap = await getDocs(collection(db, 'users'));
      if (!uSnap.empty) {
        setUsers(uSnap.docs.map(d => {
          const v = d.data();
          return {
            id:           d.id,
            name:         v.name || v.displayName || 'Unknown',
            email:        v.email || '',
            phone:        v.phone || v.phoneNumber || '',
            role:         v.role || 'farmer',
            kycStatus:    v.kycStatus || 'pending',
            kycDocuments: v.kycDocuments || null,
            kycAddress:   v.kycAddress || null,
            isActive:     v.isActive !== false,
            joined:       tsToDate(v.createdAt),
          };
        }));
        showToast('Users loaded from Firebase', 'success');
      }

      // Load lands
      const lSnap = await getDocs(collection(db, 'lands'));
      if (!lSnap.empty) {
        setLands(lSnap.docs.map(d => {
          const v = d.data();
          return {
            id:       d.id,
            title:    v.title || 'Untitled',
            owner:    v.ownerName || '—',
            ownerId:  v.ownerId || '',
            location: v.location || v.district || '—',
            province: v.province || '—',
            area:     v.areaBigha || v.area || 0,
            price:    v.pricePerBigha || v.price || 0,
            status:   v.status || 'pending',
          };
        }));
      }

      // Load applications
      const aSnap = await getDocs(collection(db, 'applications'));
      if (!aSnap.empty) {
        setApps(aSnap.docs.map(d => {
          const v = d.data();
          return {
            id:          d.id,
            applicant:   v.applicantName || '—',
            applicantId: v.applicantId || '',
            land:        v.landTitle || '—',
            landId:      v.landId || '',
            owner:       v.ownerName || '—',
            applied:     tsToDate(v.appliedAt),
            status:      v.status || 'pending',
          };
        }));
      }

      // Load support messages
      const sSnap = await getDocs(collection(db, 'supportMessages'));
      if (!sSnap.empty) {
        const msgs = sSnap.docs.map(d => {
          const v = d.data();
          return {
            id:        d.id,
            name:      v.name || 'Unknown',
            email:     v.email || '',
            category:  v.category || 'General',
            message:   v.message || '',
            status:    v.status || 'open',
            uid:       v.uid || null,
            createdAt: tsToDate(v.createdAt),
            ts:        v.createdAt?.seconds ? v.createdAt.seconds * 1000 : Date.now(),
          } as SupportMessage;
        });
        msgs.sort((a, b) => b.ts - a.ts);
        setSupportMsgs(msgs);
      }

      // Subscribe to RTDB conversations
      const { rtdb, rtRef, rtOnValue } = await import('@/lib/firebase');
      const convRef = rtRef(rtdb, 'conversations');
      rtOnValue(convRef, snap => {
        if (!snap.exists()) return;
        const data = snap.val() as Record<string, Record<string, unknown>>;
        const loaded: Conversation[] = Object.entries(data).map(([id, v]) => ({
          id,
          aId:     String(v.participantAId   || ''),
          bId:     String(v.participantBId   || ''),
          aName:   String(v.participantAName || 'User A'),
          bName:   String(v.participantBName || 'User B'),
          land:    String(v.landTitle        || ''),
          lastMsg: String(v.lastMessage      || ''),
          ts:      Number(v.lastMessageTimestamp) || Date.now(),
          msgs:    [],
        }));
        loaded.sort((a, b) => b.ts - a.ts);
        setConvs(loaded);
      });
    } catch (e) {
      console.warn('[Admin] loadAllFirebase:', (e as Error).message);
      showToast('Running on demo data', 'info');
    }
  }, [firebaseReady, showToast]);

  return (
    <AdminContext.Provider value={{
      authUser, firebaseReady,
      users, lands, apps, convs, supportMsgs,
      setUsers, setLands, setApps, setConvs, setSupportMsgs,
      toasts, showToast,
      loadAllFirebase,
    }}>
      {children}
    </AdminContext.Provider>
  );
}

export function useAdmin() {
  const ctx = useContext(AdminContext);
  if (!ctx) throw new Error('useAdmin must be used inside AdminProvider');
  return ctx;
}
