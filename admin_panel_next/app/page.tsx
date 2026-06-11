'use client';
import { useState, useEffect } from 'react';
import LoginScreen from '@/components/LoginScreen';
import Dashboard from '@/components/Dashboard';
import ToastContainer from '@/components/ui/Toast';
import { useAdmin } from '@/context/AdminContext';

export default function HomePage() {
  const { authUser, firebaseReady } = useAdmin();
  const [loggedIn,   setLoggedIn]   = useState(false);
  const [adminName,  setAdminName]  = useState('Admin');
  const [hydrated,   setHydrated]   = useState(false);

  useEffect(() => { setHydrated(true); }, []);

  // Sync Firebase auth state → logged-in state
  useEffect(() => {
    if (firebaseReady && authUser) {
      setAdminName(authUser.displayName || authUser.email?.split('@')[0] || 'Admin');
      setLoggedIn(true);
    }
  }, [firebaseReady, authUser]);

  if (!hydrated) return null;

  return (
    <>
      {loggedIn
        ? <Dashboard adminName={adminName} onLogout={() => { setLoggedIn(false); setAdminName('Admin'); }} />
        : <LoginScreen onLogin={name => { setAdminName(name); setLoggedIn(true); }} />
      }
      <ToastContainer />
    </>
  );
}
