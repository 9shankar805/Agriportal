'use client';
import { useState } from 'react';
import { Eye, EyeOff, Leaf, LogIn } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';

interface LoginScreenProps {
  onLogin: (name: string) => void;
}

export default function LoginScreen({ onLogin }: LoginScreenProps) {
  const { firebaseReady, showToast } = useAdmin();
  const [email,    setEmail]    = useState('admin@agriportal.np');
  const [password, setPassword] = useState('admin123');
  const [showPw,   setShowPw]   = useState(false);
  const [loading,  setLoading]  = useState(false);
  const [error,    setError]    = useState('');
  const [showGoogle, setShowGoogle] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) { setError('Please enter your email address.'); return; }
    setError('');
    setLoading(true);

    if (firebaseReady) {
      try {
        const { signIn } = await import('@/lib/firebase');
        const cred = await signIn(email, password);
        const name = cred.user.displayName || email.split('@')[0];
        onLogin(name);
      } catch (e: unknown) {
        const err = e as { code?: string; message?: string };
        const msgs: Record<string, string> = {
          'auth/invalid-email':         'Invalid email address.',
          'auth/user-not-found':        'No account found with this email.',
          'auth/wrong-password':        'Incorrect password.',
          'auth/invalid-credential':    'Incorrect email or password.',
          'auth/too-many-requests':     'Too many attempts. Try again later.',
          'auth/operation-not-allowed': 'Email/Password sign-in is not enabled in Firebase Console.',
        };
        setError(msgs[err.code || ''] || 'Sign-in failed: ' + err.message);
        if (err.code === 'auth/operation-not-allowed') setShowGoogle(true);
      }
    } else {
      // Demo mode
      await new Promise(r => setTimeout(r, 800));
      onLogin(email.split('@')[0]);
    }
    setLoading(false);
  };

  const handleGoogle = async () => {
    if (!firebaseReady) { showToast('Firebase not ready yet.', 'danger'); return; }
    setLoading(true);
    try {
      const { signInGoogle } = await import('@/lib/firebase');
      const cred = await signInGoogle();
      onLogin(cred.user.displayName || cred.user.email?.split('@')[0] || 'Admin');
    } catch (e: unknown) {
      setError('Google sign-in failed: ' + (e as Error).message);
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden"
      style={{ background: 'linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 40%, #a5d6a7 100%)' }}>

      {/* Background shapes */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="shape-float-1 absolute w-96 h-96 rounded-full opacity-25 bg-green-400 -top-28 -right-20" />
        <div className="shape-float-2 absolute w-72 h-72 rounded-full opacity-25 bg-green-600 -bottom-20 -left-16" />
        <div className="shape-float-3 absolute w-52 h-52 rounded-full opacity-20 bg-green-300 top-1/3 left-[10%]" />
      </div>

      {/* Card */}
      <div className="relative z-10 w-full max-w-[420px] mx-4">
        <div className="bg-white/95 backdrop-blur-xl rounded-2xl shadow-2xl p-10">
          {/* Logo */}
          <div className="text-center mb-7">
            <div className="w-18 h-18 rounded-2xl mx-auto mb-4 flex items-center justify-center"
              style={{ background: 'linear-gradient(135deg, #c8e6c9, #66bb6a)', width: 72, height: 72 }}>
              <Leaf size={30} className="text-green-800" />
            </div>
            <h1 className="text-xl font-extrabold text-gray-900">AgriPortal</h1>
            <span className="inline-block mt-1 px-3 py-0.5 rounded-full text-xs font-bold bg-green-100 text-green-700 border border-green-200">
              Admin Dashboard
            </span>
          </div>

          {/* Error */}
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 text-sm mb-4">
              {error}
            </div>
          )}

          <form onSubmit={handleLogin} className="space-y-4">
            {/* Email */}
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1.5">Email Address</label>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="admin@agriportal.np"
                className="w-full border border-gray-200 bg-gray-50 rounded-xl px-4 py-3 text-sm outline-none focus:border-green-400 focus:bg-white transition-colors"
                autoComplete="email"
              />
            </div>

            {/* Password */}
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1.5">Password</label>
              <div className="relative">
                <input
                  type={showPw ? 'text' : 'password'}
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full border border-gray-200 bg-gray-50 rounded-xl px-4 py-3 pr-10 text-sm outline-none focus:border-green-400 focus:bg-white transition-colors"
                  autoComplete="current-password"
                />
                <button
                  type="button"
                  onClick={() => setShowPw(!showPw)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  aria-label={showPw ? 'Hide password' : 'Show password'}
                >
                  {showPw ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            {/* Submit */}
            <button
              type="submit"
              disabled={loading}
              className="w-full flex items-center justify-center gap-2 bg-green-600 hover:bg-green-700 disabled:opacity-60 text-white font-bold rounded-xl py-3 text-sm transition-colors"
            >
              {loading ? (
                <svg className="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                </svg>
              ) : <LogIn size={16} />}
              Sign In to Dashboard
            </button>
          </form>

          {/* Google fallback */}
          {showGoogle && (
            <div className="mt-4">
              <div className="bg-amber-50 border border-amber-200 rounded-xl px-4 py-3 text-xs text-amber-800 mb-3">
                Enable Email/Password in{' '}
                <a href="https://console.firebase.google.com/project/agriportal-9ee3d/authentication/providers" target="_blank" rel="noreferrer" className="font-bold underline">
                  Firebase Console → Authentication
                </a>
                , or use Google Sign-In below.
              </div>
              <button
                onClick={handleGoogle}
                disabled={loading}
                className="w-full flex items-center justify-center gap-2 border border-gray-200 bg-white hover:bg-gray-50 text-gray-700 font-semibold rounded-xl py-3 text-sm transition-colors"
              >
                <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" width={18} alt="Google" />
                Continue with Google
              </button>
            </div>
          )}

          <p className="text-center text-xs text-gray-400 mt-5">
            🔒 Secure admin access
          </p>
        </div>
      </div>
    </div>
  );
}
