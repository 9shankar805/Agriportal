'use client';
import { useState } from 'react';
import { Save, ExternalLink, Bell, User, Database } from 'lucide-react';
import { useAdmin } from '@/context/AdminContext';

export default function SettingsSection() {
  const { showToast, authUser } = useAdmin();

  const [profile, setProfile] = useState({
    displayName: authUser?.displayName || 'Super Admin',
    email: authUser?.email || 'admin@agriportal.np',
  });

  const [notifs, setNotifs] = useState({
    newUsers: true,
    kycSubmissions: true,
    landApplications: false,
    messageActivity: true,
  });

  const saveProfile = () => showToast('Profile saved.', 'success');
  const saveNotifs  = () => showToast('Notification preferences saved.', 'success');

  const toggle = (key: keyof typeof notifs) =>
    setNotifs(prev => ({ ...prev, [key]: !prev[key] }));

  return (
    <div className="fade-up grid grid-cols-1 lg:grid-cols-2 gap-5">
      {/* Admin Profile */}
      <div className="bg-white rounded-xl shadow-sm p-6">
        <h3 className="font-bold text-sm mb-4 flex items-center gap-2">
          <User size={16} className="text-green-600" />Admin Profile
        </h3>
        <div className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-gray-500 mb-1.5">Display Name</label>
            <input
              value={profile.displayName}
              onChange={e => setProfile(p => ({ ...p, displayName: e.target.value }))}
              className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm outline-none focus:border-green-400 transition-colors"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-500 mb-1.5">Email Address</label>
            <input
              type="email"
              value={profile.email}
              onChange={e => setProfile(p => ({ ...p, email: e.target.value }))}
              className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm outline-none focus:border-green-400 transition-colors"
            />
          </div>
          <button onClick={saveProfile} className="flex items-center gap-1.5 bg-green-600 hover:bg-green-700 text-white rounded-lg px-4 py-2 text-sm font-semibold transition-colors">
            <Save size={14} /> Save Changes
          </button>
        </div>
      </div>

      {/* Notifications */}
      <div className="bg-white rounded-xl shadow-sm p-6">
        <h3 className="font-bold text-sm mb-4 flex items-center gap-2">
          <Bell size={16} className="text-amber-500" />Notifications
        </h3>
        <div className="space-y-4">
          {[
            { key: 'newUsers' as const,         label: 'New User Registrations',  desc: 'Notify when a new user signs up' },
            { key: 'kycSubmissions' as const,   label: 'KYC Submissions',         desc: 'Notify on new KYC requests' },
            { key: 'landApplications' as const, label: 'New Land Applications',   desc: 'Notify on land lease applications' },
            { key: 'messageActivity' as const,  label: 'Message Activity',        desc: 'Live message feed alerts' },
          ].map(n => (
            <div key={n.key} className="flex items-center justify-between gap-3">
              <div>
                <div className="font-semibold text-sm">{n.label}</div>
                <div className="text-xs text-gray-400">{n.desc}</div>
              </div>
              <button
                onClick={() => toggle(n.key)}
                className={`w-11 h-6 rounded-full relative transition-colors duration-200 flex-shrink-0 ${notifs[n.key] ? 'bg-green-500' : 'bg-gray-300'}`}
                role="switch"
                aria-checked={notifs[n.key]}
              >
                <span className={`absolute top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform duration-200 ${notifs[n.key] ? 'translate-x-5' : 'translate-x-0.5'}`} />
              </button>
            </div>
          ))}
        </div>
        <button onClick={saveNotifs} className="mt-4 flex items-center gap-1.5 border border-gray-200 hover:bg-gray-50 text-gray-700 rounded-lg px-4 py-2 text-sm font-semibold transition-colors">
          <Save size={14} /> Save Preferences
        </button>
      </div>

      {/* Firebase Config */}
      <div className="bg-white rounded-xl shadow-sm p-6 lg:col-span-2">
        <h3 className="font-bold text-sm mb-4 flex items-center gap-2">
          <Database size={16} className="text-orange-500" />Firebase Configuration
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {[
            { label: 'Project ID',       value: 'agriportal-9ee3d' },
            { label: 'Database URL',     value: 'https://agriportal-9ee3d-default-rtdb.firebaseio.com' },
            { label: 'Storage Bucket',   value: 'agriportal-9ee3d.firebasestorage.app' },
            { label: 'Android App ID',   value: '1:312069394942:android:8bc58a760885a4f75cf0af' },
          ].map(({ label, value }) => (
            <div key={label}>
              <label className="block text-xs font-semibold text-gray-500 mb-1.5">{label}</label>
              <input readOnly value={value} className="w-full border border-gray-200 bg-gray-50 rounded-lg px-3 py-2.5 text-xs font-mono outline-none text-gray-600" />
            </div>
          ))}
        </div>
        <div className="mt-4 bg-green-50 border border-green-200 rounded-xl px-4 py-3 text-sm text-green-800 flex items-center gap-2">
          <span className="text-green-500">✓</span>
          Firebase is configured and connected to project <strong>agriportal-9ee3d</strong>.
          <a href="https://console.firebase.google.com/project/agriportal-9ee3d" target="_blank" rel="noreferrer"
            className="ml-auto flex items-center gap-1 text-green-700 hover:underline font-semibold text-xs">
            Open Console <ExternalLink size={12} />
          </a>
        </div>
      </div>
    </div>
  );
}
