/**
 * admin.js — AgriPortal Admin Panel
 *
 * Architecture:
 *  - All data lives in module-level arrays (users, lands, apps, convs).
 *  - On load: arrays are seeded with DEMO data so the UI works immediately.
 *  - When "firebaseReady" fires: Firebase data is loaded and overlays demo data.
 *  - All write actions call both the local array AND Firebase (if connected).
 */
'use strict';

/* ════════════════════════════════════════════════════════
   CONSTANTS & STATE
════════════════════════════════════════════════════════ */
const AVATAR_COLORS = [
  '#22c55e','#6366f1','#f59e0b','#06b6d4',
  '#ec4899','#8b5cf6','#14b8a6','#f97316',
];

let firebaseReady = false;  // true once FB SDK fires
let currentUser   = null;   // Firebase auth user object
let activeConvId  = null;   // currently open conversation
let liveTimer     = null;   // live-activity interval

// Mutable data arrays — seeded with demo data, replaced by Firebase
let users = [];
let lands = [];
let apps  = [];
let convs = [];

/* ════════════════════════════════════════════════════════
   DEMO SEED DATA
════════════════════════════════════════════════════════ */
const SEED_USERS = [
  { id:'u1',  name:'Ramesh Sharma',   email:'ramesh@email.np',  phone:'+977 9841112233', role:'farmer',    kycStatus:'verified', isActive:true,  joined:'2024-03-15' },
  { id:'u2',  name:'Sita Thapa',      email:'sita@email.np',    phone:'+977 9862234455', role:'landOwner', kycStatus:'verified', isActive:true,  joined:'2024-04-02' },
  { id:'u3',  name:'Dorje Gurung',    email:'dorje@email.np',   phone:'+977 9813345566', role:'farmer',    kycStatus:'pending',  isActive:true,  joined:'2024-05-10' },
  { id:'u4',  name:'Anita Rai',       email:'anita@email.np',   phone:'+977 9874456677', role:'landOwner', kycStatus:'pending',  isActive:true,  joined:'2024-05-18' },
  { id:'u5',  name:'Hari Magar',      email:'hari@email.np',    phone:'+977 9825567788', role:'farmer',    kycStatus:'rejected', isActive:false, joined:'2024-06-01' },
  { id:'u6',  name:'Puja Tamang',     email:'puja@email.np',    phone:'+977 9856678899', role:'farmer',    kycStatus:'pending',  isActive:true,  joined:'2024-06-08' },
  { id:'u7',  name:'Bikram Shrestha', email:'bikram@email.np',  phone:'+977 9837789900', role:'landOwner', kycStatus:'verified', isActive:true,  joined:'2024-06-12' },
  { id:'u8',  name:'Gita Adhikari',   email:'gita@email.np',    phone:'+977 9808890011', role:'farmer',    kycStatus:'pending',  isActive:true,  joined:'2024-06-20' },
  { id:'u9',  name:'Ram Bahadur KC',  email:'ram@email.np',     phone:'+977 9849901122', role:'farmer',    kycStatus:'verified', isActive:true,  joined:'2024-07-01' },
  { id:'u10', name:'Laxmi Karki',     email:'laxmi@email.np',   phone:'+977 9810012233', role:'landOwner', kycStatus:'pending',  isActive:true,  joined:'2024-07-05' },
  { id:'u11', name:'Nabin Pokhrel',   email:'nabin@email.np',   phone:'+977 9871123344', role:'farmer',    kycStatus:'verified', isActive:true,  joined:'2024-07-10' },
  { id:'u12', name:'Sarita Limbu',    email:'sarita@email.np',  phone:'+977 9852234455', role:'farmer',    kycStatus:'pending',  isActive:true,  joined:'2024-07-14' },
];

const SEED_LANDS = [
  { id:'l1', title:'Fertile Paddy Fields',   owner:'Sita Thapa',      location:'Chitwan',   province:'Bagmati', area:12, price:45000, status:'active'   },
  { id:'l2', title:'Vegetable Garden Plot',  owner:'Bikram Shrestha', location:'Kavre',     province:'Bagmati', area:5,  price:32000, status:'active'   },
  { id:'l3', title:'Apple Orchard Land',     owner:'Anita Rai',       location:'Mustang',   province:'Gandaki', area:20, price:15000, status:'pending'  },
  { id:'l4', title:'Tea Garden Lease',       owner:'Sita Thapa',      location:'Ilam',      province:'Koshi',   area:30, price:20000, status:'active'   },
  { id:'l5', title:'Rice Farmland',          owner:'Laxmi Karki',     location:'Dang',      province:'Lumbini', area:8,  price:28000, status:'pending'  },
  { id:'l6', title:'Maize Growing Plots',    owner:'Bikram Shrestha', location:'Rupandehi', province:'Lumbini', area:15, price:22000, status:'active'   },
  { id:'l7', title:'Wheat Fields — Terai',   owner:'Anita Rai',       location:'Bara',      province:'Madhesh', area:25, price:18000, status:'active'   },
  { id:'l8', title:'Organic Farm Plots',     owner:'Laxmi Karki',     location:'Lalitpur',  province:'Bagmati', area:6,  price:55000, status:'inactive' },
];

const SEED_APPS = [
  { id:'a1', applicant:'Ramesh Sharma',  land:'Fertile Paddy Fields',  owner:'Sita Thapa',      applied:'2024-07-01', status:'approved' },
  { id:'a2', applicant:'Hari Magar',     land:'Tea Garden Lease',      owner:'Sita Thapa',      applied:'2024-07-03', status:'rejected' },
  { id:'a3', applicant:'Dorje Gurung',   land:'Apple Orchard Land',    owner:'Anita Rai',       applied:'2024-07-05', status:'pending'  },
  { id:'a4', applicant:'Puja Tamang',    land:'Vegetable Garden Plot', owner:'Bikram Shrestha', applied:'2024-07-08', status:'pending'  },
  { id:'a5', applicant:'Ram Bahadur KC', land:'Maize Growing Plots',   owner:'Bikram Shrestha', applied:'2024-07-10', status:'approved' },
  { id:'a6', applicant:'Nabin Pokhrel',  land:'Wheat Fields — Terai',  owner:'Anita Rai',       applied:'2024-07-12', status:'pending'  },
];

const SEED_CONVS = [
  {
    id:'c1', aName:'Ramesh Sharma', bName:'Sita Thapa',
    land:'Fertile Paddy Fields — Chitwan',
    lastMsg:'The land is available from next month.', ts: Date.now()-3600000,
    msgs:[
      { from:'a', text:'Hello! Is the paddy field still available?',           ts: Date.now()-7200000 },
      { from:'b', text:'Yes! What lease duration are you looking for?',        ts: Date.now()-6900000 },
      { from:'a', text:'I am looking for a 2-year lease.',                     ts: Date.now()-6600000 },
      { from:'b', text:'That works. Irrigation is fully functional.',          ts: Date.now()-6300000 },
      { from:'b', text:'The land is available from next month.',               ts: Date.now()-3600000 },
    ],
  },
  {
    id:'c2', aName:'Dorje Gurung', bName:'Anita Rai',
    land:'Apple Orchard — Mustang',
    lastMsg:'Yes, I can arrange a site visit this weekend.', ts: Date.now()-86400000,
    msgs:[
      { from:'a', text:'I am interested in the apple orchard.',                ts: Date.now()-90000000 },
      { from:'b', text:'Great! The soil is very fertile for apples.',          ts: Date.now()-89000000 },
      { from:'a', text:'Can we arrange a visit?',                              ts: Date.now()-88000000 },
      { from:'b', text:'Yes, I can arrange a site visit this weekend.',        ts: Date.now()-86400000 },
    ],
  },
  {
    id:'c3', aName:'Puja Tamang', bName:'Bikram Shrestha',
    land:'Vegetable Garden — Kavre',
    lastMsg:'Please submit your KYC first.', ts: Date.now()-172800000,
    msgs:[
      { from:'a', text:'I want to apply for the vegetable plot.',              ts: Date.now()-180000000 },
      { from:'b', text:'Please submit your KYC first.',                        ts: Date.now()-172800000 },
    ],
  },
];

const LIVE_FEED_POOL = [
  'New user registered — <b>Sagun Karki</b>',
  'KYC submitted by <b>Maya Bista</b>',
  'New listing added: <b>Tea Garden, Ilam</b>',
  'Message sent by <b>Hari Thapa</b>',
  'KYC approved for <b>Raju Yadav</b>',
  'Application from <b>Sunita Lama</b>',
  'Listing activated: <b>Paddy Fields, Chitwan</b>',
  'New user: <b>Binod Tiwari</b> (Land Owner)',
];
const LIVE_COLORS = ['#22c55e','#f59e0b','#6366f1','#06b6d4','#ec4899'];
let liveItems = [];

/* ════════════════════════════════════════════════════════
   INIT — page load
════════════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', () => {
  users = JSON.parse(JSON.stringify(SEED_USERS));
  lands = JSON.parse(JSON.stringify(SEED_LANDS));
  apps  = JSON.parse(JSON.stringify(SEED_APPS));
  convs = JSON.parse(JSON.stringify(SEED_CONVS));

  setDate();
  setGreeting();

  // Enter key on login screen
  document.addEventListener('keydown', e => {
    if (e.key === 'Enter' && !document.getElementById('loginScreen').classList.contains('d-none')) {
      doLogin();
    }
  });
});

/* ════════════════════════════════════════════════════════
   FIREBASE READY
════════════════════════════════════════════════════════ */
window.addEventListener('firebaseReady', () => {
  firebaseReady = true;
  console.log('[Admin] Firebase SDK ready');

  // Watch auth state
  window.FB.onAuth(fbUser => {
    if (fbUser) {
      currentUser = fbUser;
      // If we're already on the dashboard (demo login), just load live data
      if (!document.getElementById('app').classList.contains('d-none')) {
        document.getElementById('adminName').textContent =
          fbUser.displayName || fbUser.email?.split('@')[0] || 'Admin';
        loadAllFirebase();
      }
    } else {
      currentUser = null;
    }
  });
});

/* ════════════════════════════════════════════════════════
   LOGIN / LOGOUT
════════════════════════════════════════════════════════ */
function doLogin() {
  const email = document.getElementById('adminEmail').value.trim();
  const pw    = document.getElementById('adminPassword').value;
  const errEl = document.getElementById('loginError');

  errEl.classList.add('d-none');

  if (!email) {
    errEl.textContent = 'Please enter your email address.';
    errEl.classList.remove('d-none');
    return;
  }

  // Show spinner
  document.getElementById('loginSpinner').classList.remove('d-none');
  document.getElementById('loginIcon').classList.add('d-none');
  document.getElementById('loginBtn').disabled = true;

  const loginOk = (displayName) => {
    document.getElementById('loginScreen').classList.add('d-none');
    document.getElementById('app').classList.remove('d-none');
    document.getElementById('adminName').textContent = displayName;
    setGreeting();
    setDate();
    bootDashboard();
  };

  const loginFail = (msg) => {
    document.getElementById('loginSpinner').classList.add('d-none');
    document.getElementById('loginIcon').classList.remove('d-none');
    document.getElementById('loginBtn').disabled = false;
    errEl.textContent = msg;
    errEl.classList.remove('d-none');
  };

  if (firebaseReady) {
    // Real Firebase auth
    window.FB.signIn(email, pw)
      .then(cred => {
        currentUser = cred.user;
        const name = cred.user.displayName || email.split('@')[0];
        loginOk(name);
        loadAllFirebase();
      })
      .catch(e => {
      spin.classList.add('d-none');
      document.getElementById('loginBtn').disabled = false;
      ico.classList.remove('d-none');
      const msgs = {
        'auth/invalid-email':        'Invalid email address.',
        'auth/user-not-found':       'No account found with this email.',
        'auth/wrong-password':       'Incorrect password.',
        'auth/invalid-credential':   'Incorrect email or password.',
        'auth/too-many-requests':    'Too many attempts. Try again later.',
        'auth/operation-not-allowed': 'Email/Password sign-in is not enabled. Enable it in Firebase Console → Authentication → Sign-in method, or use Google Sign-In below.',
      };
      errEl.textContent = msgs[e.code] || 'Sign-in failed: ' + e.message;
      errEl.classList.remove('d-none');
      // Show Google sign-in button as fallback
      document.getElementById('googleSignInFallback').classList.remove('d-none');
    });
  } else {
    // Demo mode — any credential works
    setTimeout(() => loginOk(email.split('@')[0]), 800);
  }
}

function signInWithGoogle() {
  if (!firebaseReady) { showToast('Firebase not ready yet.', 'danger'); return; }
  window.FB.signInGoogle()
    .then(cred => {
      currentUser = cred.user;
      document.getElementById('loginScreen').classList.add('d-none');
      document.getElementById('app').classList.remove('d-none');
      document.getElementById('adminName').textContent =
        cred.user.displayName || cred.user.email?.split('@')[0] || 'Admin';
      setGreeting(); setDate(); bootDashboard(); loadAllFirebase();
    })
    .catch(e => {
      document.getElementById('loginError').textContent = 'Google sign-in failed: ' + e.message;
      document.getElementById('loginError').classList.remove('d-none');
    });
}

function doLogout() {
  if (liveTimer) clearInterval(liveTimer);
  if (firebaseReady && currentUser) window.FB.signOut().catch(() => {});
  currentUser = null;
  activeConvId = null;

  document.getElementById('app').classList.add('d-none');
  document.getElementById('loginScreen').classList.remove('d-none');
  document.getElementById('loginBtn').disabled = false;
  document.getElementById('loginSpinner').classList.add('d-none');
  document.getElementById('loginIcon').classList.remove('d-none');
  document.getElementById('loginError').classList.add('d-none');
}

function togglePw() {
  const inp = document.getElementById('adminPassword');
  const ico = document.getElementById('pwEyeIcon');
  if (inp.type === 'password') { inp.type = 'text';     ico.className = 'bi bi-eye-slash'; }
  else                         { inp.type = 'password'; ico.className = 'bi bi-eye'; }
}

/* ════════════════════════════════════════════════════════
   BOOT DASHBOARD
════════════════════════════════════════════════════════ */
function bootDashboard() {
  renderAll();
  startLiveFeed();
}

function renderAll() {
  updateStatCards();
  updateBadges();
  updateSupportBadge();
  renderOverviewPanels();
  renderUsers();
  renderKyc();
  renderLands();
  renderApps();
  renderConvs();
  renderSupport();
  renderAnalytics();
}

/* ════════════════════════════════════════════════════════
   FIREBASE — LOAD ALL DATA
════════════════════════════════════════════════════════ */
async function loadAllFirebase() {
  await Promise.all([
    fbLoadUsers(),
    fbLoadLands(),
    fbLoadApps(),
    fbLoadSupportMessages(),
  ]);
  fbSubscribeConversations();
}

async function fbLoadUsers() {
  try {
    const snap = await window.FB.getDocs(window.FB.col('users'));
    if (snap.empty) return;
    users = snap.docs.map(d => {
      const v = d.data();
      return {
        id:           d.id,
        name:         v.name         || v.displayName || 'Unknown',
        email:        v.email        || '',
        phone:        v.phone        || v.phoneNumber || '',
        role:         v.role         || 'farmer',
        kycStatus:    v.kycStatus    || 'pending',
        kycDocuments: v.kycDocuments || null,
        kycAddress:   v.kycAddress   || null,
        isActive:     v.isActive     !== false,
        joined:       tsToDate(v.createdAt),
      };
    });
    console.log(`[Admin] ${users.length} users from Firestore`);
    renderAll();
    showToast(`${users.length} users loaded from Firebase`, 'success');
  } catch (e) { console.warn('[Admin] fbLoadUsers:', e.message); }
}

async function fbLoadLands() {
  try {
    const snap = await window.FB.getDocs(window.FB.col('lands'));
    if (snap.empty) return;
    lands = snap.docs.map(d => {
      const v = d.data();
      return {
        id:       d.id,
        title:    v.title          || 'Untitled',
        owner:    v.ownerName      || '—',
        location: v.location       || v.district || '—',
        province: v.province       || '—',
        area:     v.areaBigha      || v.area  || 0,
        price:    v.pricePerBigha  || v.price || 0,
        status:   v.status         || 'pending',
      };
    });
    console.log(`[Admin] ${lands.length} listings from Firestore`);
    renderLands();
    updateStatCards();
    updateBadges();
  } catch (e) { console.warn('[Admin] fbLoadLands:', e.message); }
}

async function fbLoadApps() {
  try {
    const snap = await window.FB.getDocs(window.FB.col('applications'));
    if (snap.empty) return;
    apps = snap.docs.map(d => {
      const v = d.data();
      return {
        id:        d.id,
        applicant: v.applicantName || '—',
        land:      v.landTitle     || '—',
        owner:     v.ownerName     || '—',
        applied:   tsToDate(v.appliedAt),
        status:    v.status        || 'pending',
      };
    });
    console.log(`[Admin] ${apps.length} applications from Firestore`);
    renderApps();
    updateBadges();
  } catch (e) { console.warn('[Admin] fbLoadApps:', e.message); }
}

function fbSubscribeConversations() {
  try {
    const convRef = window.FB.rtRef('conversations');
    window.FB.rtOnValue(convRef, snap => {
      if (!snap.exists()) return;
      const data = snap.val();
      convs = Object.entries(data).map(([id, v]) => ({
        id,
        aId:      v.participantAId   || '',
        bId:      v.participantBId   || '',
        aName:    v.participantAName || 'User A',
        bName:    v.participantBName || 'User B',
        land:     v.landTitle        || '',
        lastMsg:  v.lastMessage      || '',
        ts:       v.lastMessageTimestamp || Date.now(),
        msgs:     [], // loaded on demand
      }));
      convs.sort((a, b) => b.ts - a.ts);
      console.log(`[Admin] ${convs.length} conversations from RTDB`);
      renderConvs();
      renderMsgFeed();
      updateBadges();
      animCount('sc-msgs', convs.length);
    });
  } catch (e) { console.warn('[Admin] fbSubscribeConversations:', e.message); }
}

/* ════════════════════════════════════════════════════════
   NAVIGATION
════════════════════════════════════════════════════════ */
const SECTION_IDS = ['overview','users','kyc','lands','applications','messages','analytics','support','settings'];
const SECTION_LABELS = {
  overview:'Overview', users:'Users', kyc:'KYC Verification',
  lands:'Land Listings', applications:'Applications',
  messages:'Messages', analytics:'Analytics',
  support:'Support Messages', settings:'Settings',
};

function nav(id, linkEl) {
  SECTION_IDS.forEach(s => {
    document.getElementById('s-' + s)?.classList.toggle('d-none', s !== id);
  });
  document.querySelectorAll('.sidebar-link').forEach(l => l.classList.remove('active'));
  if (linkEl) {
    linkEl.classList.add('active');
  } else {
    document.querySelector(`.sidebar-link[onclick*="'${id}'"]`)?.classList.add('active');
  }
  document.getElementById('pageTitle').textContent  = SECTION_LABELS[id] || id;
  document.getElementById('breadcrumb').textContent = SECTION_LABELS[id] || id;

  if (id === 'analytics') renderAnalytics();
  if (id === 'messages')  renderConvs();
  if (id === 'support')   { renderSupport(); if (firebaseReady && !supportMsgs.length) fbLoadSupportMessages(); }
  return false;
}

function toggleSidebar() {
  document.getElementById('sidebar').classList.toggle('open');
}

function refreshAll() {
  if (firebaseReady && currentUser) loadAllFirebase();
  else renderAll();
  showToast('Refreshed', 'success');
}

/* ════════════════════════════════════════════════════════
   STAT CARDS & BADGES
════════════════════════════════════════════════════════ */
function updateStatCards() {
  animCount('sc-users',  users.length);
  animCount('sc-kyc',    users.filter(u => u.kycStatus === 'pending').length);
  animCount('sc-lands',  lands.filter(l => l.status === 'active').length);
  animCount('sc-msgs',   convs.length || apps.length);
  // Pending action cards
  animCount('sc-pending-kyc',     users.filter(u => u.kycStatus === 'pending').length);
  animCount('sc-pending-lands',   lands.filter(l => l.status === 'pending').length);
  animCount('sc-pending-apps',    apps.filter(a => a.status === 'pending').length);
  animCount('sc-pending-support', supportMsgs.filter(m => m.status === 'open').length);
}

function animCount(id, target) {
  const el = document.getElementById(id);
  if (!el) return;
  const start = parseInt(el.textContent) || 0;
  const steps = 25;
  let i = 0;
  const t = setInterval(() => {
    i++;
    el.textContent = Math.round(start + (target - start) * (i / steps));
    if (i >= steps) { el.textContent = target; clearInterval(t); }
  }, 20);
}

function updateBadges() {
  badge('nbUsers', users.length);
  badge('nbKyc',   users.filter(u => u.kycStatus === 'pending').length);
  badge('nbApps',  apps.filter(a => a.status === 'pending').length);
  badge('nbMsgs',  convs.length);
  badge('nbSupport', supportMsgs.filter(m => m.status === 'open').length);
}

function badge(id, n) {
  const el = document.getElementById(id);
  if (!el) return;
  el.textContent = n;
  el.classList.toggle('d-none', n === 0);
}

/* ════════════════════════════════════════════════════════
   OVERVIEW PANELS
════════════════════════════════════════════════════════ */
function renderOverviewPanels() {
  renderRecentUsers();
  renderQuickKyc();
  renderMsgFeed();
}

function renderRecentUsers() {
  const el = document.getElementById('recentUsers');
  if (!el) return;
  const list = [...users]
    .sort((a, b) => new Date(b.joined) - new Date(a.joined))
    .slice(0, 6);
  el.innerHTML = list.map(u => `
    <div class="user-row">
      <div class="user-ava" style="background:${avaColor(u.name)}">${u.name[0]}</div>
      <div class="flex-grow-1 overflow-hidden">
        <div class="fw-600 small text-truncate">${esc(u.name)}</div>
        <div class="x-small text-muted text-truncate">${esc(u.email)}</div>
      </div>
      <span class="badge rounded-pill ${roleTag(u.role)} flex-shrink-0">${u.role === 'farmer' ? 'Farmer' : 'Owner'}</span>
      <span class="badge rounded-pill ${kycTag(u.kycStatus)} flex-shrink-0">${cap(u.kycStatus)}</span>
    </div>`).join('');
}

function renderQuickKyc() {
  const el = document.getElementById('quickKyc');
  if (!el) return;
  const pending = users.filter(u => u.kycStatus === 'pending').slice(0, 5);
  if (!pending.length) {
    el.innerHTML = '<div class="text-muted small text-center py-3">✓ All KYC reviewed</div>';
    return;
  }
  el.innerHTML = pending.map(u => `
    <div class="user-row">
      <div class="user-ava" style="background:${avaColor(u.name)}">${u.name[0]}</div>
      <div class="flex-grow-1 overflow-hidden">
        <div class="fw-600 small text-truncate">${esc(u.name)}</div>
        <div class="x-small text-muted">${esc(u.phone)}</div>
      </div>
      <button class="btn btn-success btn-icon btn-sm" onclick="approveKyc('${u.id}')" title="Approve">
        <i class="bi bi-check-lg"></i>
      </button>
      <button class="btn btn-outline-danger btn-icon btn-sm" onclick="rejectKyc('${u.id}')" title="Reject">
        <i class="bi bi-x-lg"></i>
      </button>
    </div>`).join('');
}

function renderMsgFeed() {
  const el = document.getElementById('msgFeed');
  if (!el) return;
  const list = [...convs].sort((a, b) => b.ts - a.ts).slice(0, 8);
  if (!list.length) {
    el.innerHTML = '<div class="text-muted small text-center py-3">No messages yet.</div>';
    return;
  }
  el.innerHTML = list.map(c => `
    <div class="msg-feed-card" onclick="openMsgSection('${c.id}')">
      <div class="mfc-avatar" style="background:${avaColor(c.aName)}">${c.aName[0]}</div>
      <div class="flex-grow-1 overflow-hidden">
        <div class="d-flex justify-content-between align-items-center mb-1">
          <div class="fw-600 small text-truncate">${esc(c.aName)} ↔ ${esc(c.bName)}</div>
          <div class="x-small text-muted ms-2 flex-shrink-0">${relTime(c.ts)}</div>
        </div>
        <div class="x-small text-muted text-truncate">${esc(c.land)}</div>
        <div class="small text-truncate mt-1">${esc(c.lastMsg)}</div>
      </div>
    </div>`).join('');
}

function openMsgSection(id) {
  nav('messages');
  setTimeout(() => selectConv(id), 60);
}

/* ════════════════════════════════════════════════════════
   LIVE ACTIVITY TICKER
════════════════════════════════════════════════════════ */
function startLiveFeed() {
  liveItems = LIVE_FEED_POOL.slice(0, 4).map((text, i) => ({
    text, color: LIVE_COLORS[i % LIVE_COLORS.length], ts: Date.now() - i * 90000,
  }));
  renderLiveFeed();
  liveTimer = setInterval(() => {
    const text  = LIVE_FEED_POOL[Math.floor(Math.random() * LIVE_FEED_POOL.length)];
    const color = LIVE_COLORS[Math.floor(Math.random() * LIVE_COLORS.length)];
    liveItems.unshift({ text, color, ts: Date.now() });
    if (liveItems.length > 10) liveItems.pop();
    renderLiveFeed();
  }, 4500);
}

function renderLiveFeed() {
  const el = document.getElementById('liveActivity');
  if (!el) return;
  el.innerHTML = liveItems.map(item => `
    <div class="activity-item">
      <div class="activity-dot" style="background:${item.color}"></div>
      <div>
        <div class="small" style="line-height:1.3">${item.text}</div>
        <div class="x-small text-muted">${relTime(item.ts)}</div>
      </div>
    </div>`).join('');
}

/* ════════════════════════════════════════════════════════
   USERS
════════════════════════════════════════════════════════ */
function renderUsers() {
  const q  = (document.getElementById('uSearch')?.value || '').toLowerCase();
  const rf = document.getElementById('uRoleF')?.value || '';
  const kf = document.getElementById('uKycF')?.value  || '';

  const list = users.filter(u =>
    (!q  || u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q)) &&
    (!rf || u.role === rf) &&
    (!kf || u.kycStatus === kf)
  );

  const tb = document.getElementById('usersBody');
  if (!tb) return;

  tb.innerHTML = list.length ? list.map((u, i) => `
    <tr>
      <td class="text-muted small text-center">${i + 1}</td>
      <td>
        <div class="d-flex align-items-center gap-2">
          <div class="user-ava" style="background:${avaColor(u.name)};width:34px;height:34px;font-size:.8rem">${u.name[0]}</div>
          <div>
            <div class="fw-600">${esc(u.name)}</div>
            <div class="x-small text-muted">${esc(u.email)}</div>
          </div>
        </div>
      </td>
      <td><span class="badge rounded-pill ${roleTag(u.role)}">${u.role === 'farmer' ? 'Farmer' : 'Land Owner'}</span></td>
      <td class="text-muted small">${esc(u.phone)}</td>
      <td><span class="badge rounded-pill ${kycTag(u.kycStatus)}">${kycIcon(u.kycStatus)}${cap(u.kycStatus)}</span></td>
      <td class="text-muted small">${u.joined}</td>
      <td><span class="badge rounded-pill ${u.isActive ? 'tag-active' : 'tag-inactive'}">${u.isActive ? 'Active' : 'Disabled'}</span></td>
      <td>
        <div class="d-flex gap-1">
          <button class="btn btn-sm btn-outline-primary btn-icon" onclick="viewUser('${u.id}')" title="View Details">
            <i class="bi bi-eye"></i>
          </button>
          ${u.kycStatus === 'pending' ? `
            <button class="btn btn-sm btn-outline-success btn-icon" onclick="approveKyc('${u.id}')" title="Approve KYC">
              <i class="bi bi-patch-check"></i>
            </button>` : ''}
          <button class="btn btn-sm ${u.isActive ? 'btn-outline-danger' : 'btn-outline-success'} btn-icon"
            onclick="toggleUser('${u.id}')" title="${u.isActive ? 'Disable' : 'Enable'} User">
            <i class="bi bi-person-${u.isActive ? 'slash' : 'check'}"></i>
          </button>
        </div>
      </td>
    </tr>`) .join('')
    : '<tr><td colspan="8" class="text-center py-5 text-muted">No users match the current filters.</td></tr>';

  const cEl = document.getElementById('uCount');
  if (cEl) cEl.textContent = `${list.length} of ${users.length} users`;
}

function viewUser(id) {
  const u = users.find(x => x.id === id);
  if (!u) return;
  document.getElementById('modalUserBody').innerHTML = `
    <div class="d-flex align-items-center gap-3 mb-4">
      <div class="user-ava" style="background:${avaColor(u.name)};width:56px;height:56px;font-size:1.4rem;border-radius:16px;flex-shrink:0">${u.name[0]}</div>
      <div>
        <div class="fw-800 fs-6">${esc(u.name)}</div>
        <div class="text-muted small">${esc(u.email)}</div>
        <div class="d-flex gap-2 mt-2 flex-wrap">
          <span class="badge rounded-pill ${roleTag(u.role)}">${u.role === 'farmer' ? 'Farmer' : 'Land Owner'}</span>
          <span class="badge rounded-pill ${kycTag(u.kycStatus)}">${kycIcon(u.kycStatus)}${cap(u.kycStatus)}</span>
          <span class="badge rounded-pill ${u.isActive ? 'tag-active' : 'tag-inactive'}">${u.isActive ? 'Active' : 'Disabled'}</span>
        </div>
      </div>
    </div>
    <hr class="my-3"/>
    <div class="row g-3 small">
      <div class="col-6"><div class="text-muted">User ID</div><div class="fw-600 text-truncate">${esc(u.id)}</div></div>
      <div class="col-6"><div class="text-muted">Phone</div><div class="fw-600">${esc(u.phone || '—')}</div></div>
      <div class="col-6"><div class="text-muted">Joined</div><div class="fw-600">${u.joined}</div></div>
      <div class="col-6"><div class="text-muted">Applications</div><div class="fw-600">${apps.filter(a => a.applicant === u.name).length}</div></div>
    </div>`;

  document.getElementById('modalUserFooter').innerHTML = `
    <button class="btn btn-sm btn-light rounded-3 px-3" data-bs-dismiss="modal">Close</button>
    ${u.kycStatus === 'pending' ? `
      <button class="btn btn-sm btn-outline-danger rounded-3" onclick="rejectKyc('${u.id}')" data-bs-dismiss="modal">
        <i class="bi bi-x-circle me-1"></i>Reject KYC
      </button>
      <button class="btn btn-sm btn-success rounded-3" onclick="approveKyc('${u.id}')" data-bs-dismiss="modal">
        <i class="bi bi-patch-check me-1"></i>Approve KYC
      </button>` : ''}`;

  new bootstrap.Modal(document.getElementById('modalUser')).show();
}

function toggleUser(id) {
  const u = users.find(x => x.id === id);
  if (!u) return;
  confirmDo(
    `${u.isActive ? 'Disable' : 'Enable'} User`,
    `Are you sure you want to ${u.isActive ? 'disable' : 'enable'} ${u.name}?`,
    async () => {
      u.isActive = !u.isActive;
      if (firebaseReady) {
        try { await window.FB.updateDoc(window.FB.docRef('users', id), { isActive: u.isActive }); }
        catch (e) { console.warn('[Admin] toggleUser FB:', e.message); }
      }
      renderAll();
      showToast(`User ${u.isActive ? 'enabled' : 'disabled'}.`, 'success');
    }
  );
}

function openAddUser() {
  // Admin can create users by directing them to the app's sign-up.
  // Show a helpful modal instead of a dead toast.
  confirmDo(
    'Create New User',
    'Users register themselves through the AgriPortal mobile app. To manually create an admin user, add their UID to the Firestore "admins" collection via Firebase Console.',
    () => window.open('https://console.firebase.google.com/project/agriportal-9ee3d/firestore/data/~2Fadmins', '_blank')
  );
  // Override the confirm button label
  setTimeout(() => {
    const btn = document.getElementById('confirmOk');
    if (btn) { btn.textContent = 'Open Firebase Console'; btn.className = 'btn btn-sm btn-success rounded-3 px-3'; }
  }, 10);
}

/* ════════════════════════════════════════════════════════
   KYC
════════════════════════════════════════════════════════ */
function renderKyc() {
  const status = document.querySelector('input[name="kycTab"]:checked')?.value ?? 'pending';
  const q      = (document.getElementById('kSearch')?.value || '').toLowerCase();

  const list = users.filter(u =>
    (!status || u.kycStatus === status) &&
    (!q || u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q))
  );

  const el = document.getElementById('kycGrid');
  if (!el) return;

  el.innerHTML = list.length ? list.map(u => `
    <div class="col-sm-6 col-xl-4">
      <div class="kyc-card kyc-${u.kycStatus}">
        <div class="d-flex align-items-center gap-3 mb-3">
          <div class="user-ava" style="background:${avaColor(u.name)};width:48px;height:48px;font-size:1.1rem;border-radius:14px;flex-shrink:0">${u.name[0]}</div>
          <div class="overflow-hidden">
            <div class="fw-700 text-truncate">${esc(u.name)}</div>
            <div class="small text-muted text-truncate">${esc(u.email)}</div>
          </div>
        </div>
        <div class="d-flex gap-2 mb-3 flex-wrap">
          <span class="badge rounded-pill ${roleTag(u.role)}">${u.role === 'farmer' ? 'Farmer' : 'Land Owner'}</span>
          <span class="badge rounded-pill ${kycTag(u.kycStatus)}">${kycIcon(u.kycStatus)}${cap(u.kycStatus)}</span>
        </div>
        <div class="row g-1 small text-muted mb-3">
          <div class="col-12"><i class="bi bi-phone me-1"></i>${esc(u.phone)}</div>
          <div class="col-12"><i class="bi bi-calendar3 me-1"></i>Joined ${u.joined}</div>
        </div>
        ${u.kycDocuments ? `
        <div class="kyc-docs mb-3">
          <div class="x-small text-muted fw-600 mb-2">UPLOADED DOCUMENTS</div>
          <div class="d-flex gap-2 flex-wrap">
            ${u.kycDocuments.citizenshipFront ? `<a href="${u.kycDocuments.citizenshipFront}" target="_blank" class="kyc-doc-thumb" title="ID Front Side"><img src="${u.kycDocuments.citizenshipFront}" alt="ID Front" /><span>ID Front</span></a>` : ''}
            ${u.kycDocuments.citizenshipBack  ? `<a href="${u.kycDocuments.citizenshipBack}"  target="_blank" class="kyc-doc-thumb" title="ID Back Side"><img src="${u.kycDocuments.citizenshipBack}" alt="ID Back" /><span>ID Back</span></a>` : ''}
            ${u.kycDocuments.selfie           ? `<a href="${u.kycDocuments.selfie}"           target="_blank" class="kyc-doc-thumb" title="Selfie"><img src="${u.kycDocuments.selfie}" alt="Selfie" /><span>Selfie</span></a>` : ''}
          </div>
        </div>` : u.kycStatus === 'pending' ? `<div class="alert alert-warning-subtle border border-warning-subtle rounded-3 small py-2 mb-3"><i class="bi bi-exclamation-triangle me-1"></i>No documents uploaded yet.</div>` : ''}
        ${u.kycAddress ? `
        <div class="x-small text-muted mb-3">
          <i class="bi bi-geo-alt me-1"></i>${[u.kycAddress.street, u.kycAddress.city, u.kycAddress.district, u.kycAddress.province].filter(Boolean).join(', ')}
        </div>` : ''}
        ${u.kycStatus === 'pending' ? `
          <div class="d-flex gap-2">
            <button class="btn btn-success btn-sm flex-fill rounded-3" onclick="approveKyc('${u.id}')">
              <i class="bi bi-patch-check me-1"></i>Approve
            </button>
            <button class="btn btn-outline-danger btn-sm flex-fill rounded-3" onclick="rejectKyc('${u.id}')">
              <i class="bi bi-x-circle me-1"></i>Reject
            </button>
          </div>` : `
          <button class="btn btn-sm btn-outline-secondary w-100 rounded-3" onclick="resetKyc('${u.id}')">
            <i class="bi bi-arrow-counterclockwise me-1"></i>Reset to Pending
          </button>`}
      </div>
    </div>`) .join('')
    : '<div class="col-12 text-center py-5 text-muted">No KYC records match this filter.</div>';
}

async function approveKyc(id) {
  const u = users.find(x => x.id === id);
  if (!u) return;
  u.kycStatus = 'verified';
  if (firebaseReady) {
    try {
      // Update kycStatus
      await window.FB.updateDoc(window.FB.docRef('users', id), {
        kycStatus: 'verified',
        kycReviewedAt: window.FB.serverTimestamp(),
      });
      // Write in-app notification so the user sees it in the app
      await window.FB.addDoc(
        window.FB.col(`users/${id}/notifications`),
        {
          title: 'KYC Verified ✓',
          body: 'Your KYC has been verified! You can now apply for land listings.',
          type: 'kyc',
          isRead: false,
          createdAt: window.FB.serverTimestamp(),
        }
      );
    } catch (e) { console.warn('[Admin] approveKyc FB:', e.message); }
  }
  renderAll();
  showToast(`KYC approved for ${u.name}.`, 'success');
}

function rejectKyc(id) {
  const u = users.find(x => x.id === id);
  if (!u) return;
  confirmDo('Reject KYC', `Reject KYC for ${u.name}? They will lose verified access.`, async () => {
    u.kycStatus = 'rejected';
    if (firebaseReady) {
      try {
        await window.FB.updateDoc(window.FB.docRef('users', id), {
          kycStatus: 'rejected',
          kycReviewedAt: window.FB.serverTimestamp(),
        });
        await window.FB.addDoc(
          window.FB.col(`users/${id}/notifications`),
          {
            title: 'KYC Not Approved',
            body: 'Your KYC was not approved. Please resubmit with clearer documents.',
            type: 'kyc',
            isRead: false,
            createdAt: window.FB.serverTimestamp(),
          }
        );
      } catch (e) { console.warn('[Admin] rejectKyc FB:', e.message); }
    }
    renderAll();
    showToast(`KYC rejected for ${u.name}.`, 'warning');
  });
}

async function resetKyc(id) {
  const u = users.find(x => x.id === id);
  if (!u) return;
  u.kycStatus = 'pending';
  if (firebaseReady) {
    try { await window.FB.updateDoc(window.FB.docRef('users', id), { kycStatus: 'pending' }); }
    catch (e) { console.warn('[Admin] resetKyc FB:', e.message); }
  }
  renderAll();
  showToast(`KYC reset to pending for ${u.name}.`, 'info');
}

/* ════════════════════════════════════════════════════════
   LAND LISTINGS
════════════════════════════════════════════════════════ */
function renderLands() {
  const q  = (document.getElementById('lSearch')?.value  || '').toLowerCase();
  const sf = document.getElementById('lStatusF')?.value  || '';

  const list = lands.filter(l =>
    (!q  || l.title.toLowerCase().includes(q) || l.location.toLowerCase().includes(q) || l.owner.toLowerCase().includes(q)) &&
    (!sf || l.status === sf)
  );

  const tb = document.getElementById('landsBody');
  if (!tb) return;

  tb.innerHTML = list.length ? list.map((l, i) => `
    <tr>
      <td class="text-muted small text-center">${i + 1}</td>
      <td>
        <div class="fw-600">${esc(l.title)}</div>
        <div class="x-small text-muted">${esc(l.province)}</div>
      </td>
      <td class="small">${esc(l.owner)}</td>
      <td class="small text-muted"><i class="bi bi-geo-alt text-success me-1"></i>${esc(l.location)}</td>
      <td class="small fw-600">${l.area} Bigha</td>
      <td class="small fw-600">Rs ${Number(l.price).toLocaleString()}</td>
      <td><span class="badge rounded-pill ${landTag(l.status)}">${cap(l.status)}</span></td>
      <td>
        <div class="d-flex gap-1">
          <button class="btn btn-sm btn-outline-primary btn-icon" onclick="viewLand('${l.id}')" title="View">
            <i class="bi bi-eye"></i>
          </button>
          ${l.status === 'pending' ? `
            <button class="btn btn-sm btn-outline-success btn-icon" onclick="setLandStatus('${l.id}','active')" title="Approve">
              <i class="bi bi-check-lg"></i>
            </button>
            <button class="btn btn-sm btn-outline-danger btn-icon" onclick="setLandStatus('${l.id}','inactive')" title="Reject">
              <i class="bi bi-x-lg"></i>
            </button>` :
          l.status !== 'active' ? `
            <button class="btn btn-sm btn-outline-success btn-icon" onclick="setLandStatus('${l.id}','active')" title="Activate">
              <i class="bi bi-check-lg"></i>
            </button>` : `
            <button class="btn btn-sm btn-outline-warning btn-icon" onclick="setLandStatus('${l.id}','inactive')" title="Deactivate">
              <i class="bi bi-pause-circle"></i>
            </button>`}
          <button class="btn btn-sm btn-outline-danger btn-icon" onclick="deleteLand('${l.id}')" title="Delete">
            <i class="bi bi-trash"></i>
          </button>
        </div>
      </td>
    </tr>`) .join('')
    : '<tr><td colspan="8" class="text-center py-5 text-muted">No listings match the current filters.</td></tr>';

  const cEl = document.getElementById('lCount');
  if (cEl) cEl.textContent = `${list.length} of ${lands.length} listings`;
}

function viewLand(id) {
  const l = lands.find(x => x.id === id);
  if (!l) return;
  document.getElementById('modalLandBody').innerHTML = `
    <div class="row g-3">
      <div class="col-md-8"><div class="text-muted small">Title</div><div class="fw-700 fs-6">${esc(l.title)}</div></div>
      <div class="col-md-4"><div class="text-muted small">Status</div>
        <span class="badge rounded-pill ${landTag(l.status)}">${cap(l.status)}</span></div>
      <div class="col-md-4"><div class="text-muted small">Owner</div><div class="fw-600">${esc(l.owner)}</div></div>
      <div class="col-md-4"><div class="text-muted small">Location</div><div class="fw-600">${esc(l.location)}</div></div>
      <div class="col-md-4"><div class="text-muted small">Province</div><div class="fw-600">${esc(l.province)}</div></div>
      <div class="col-md-4"><div class="text-muted small">Area</div><div class="fw-600">${l.area} Bigha</div></div>
      <div class="col-md-4"><div class="text-muted small">Price / Bigha</div><div class="fw-600">Rs ${Number(l.price).toLocaleString()}</div></div>
      <div class="col-md-4"><div class="text-muted small">Applications</div><div class="fw-600">${apps.filter(a => a.land === l.title).length}</div></div>
    </div>`;
  document.getElementById('modalLandFooter').innerHTML = `
    <button class="btn btn-sm btn-light rounded-3 px-3" data-bs-dismiss="modal">Close</button>
    ${l.status === 'pending' ? `
      <button class="btn btn-sm btn-outline-danger rounded-3" onclick="setLandStatus('${l.id}','inactive')" data-bs-dismiss="modal">
        <i class="bi bi-x-lg me-1"></i>Reject
      </button>
      <button class="btn btn-sm btn-success rounded-3" onclick="setLandStatus('${l.id}','active')" data-bs-dismiss="modal">
        <i class="bi bi-check-lg me-1"></i>Approve
      </button>` :
    l.status !== 'active' ? `
      <button class="btn btn-sm btn-success rounded-3" onclick="setLandStatus('${l.id}','active')" data-bs-dismiss="modal">
        <i class="bi bi-check-lg me-1"></i>Activate
      </button>` : `
      <button class="btn btn-sm btn-outline-warning rounded-3" onclick="setLandStatus('${l.id}','inactive')" data-bs-dismiss="modal">
        <i class="bi bi-pause me-1"></i>Deactivate
      </button>`}
    <button class="btn btn-sm btn-outline-danger rounded-3" onclick="deleteLand('${l.id}')" data-bs-dismiss="modal">
      <i class="bi bi-trash me-1"></i>Delete
    </button>`;
  new bootstrap.Modal(document.getElementById('modalLand')).show();
}

async function setLandStatus(id, status) {
  const l = lands.find(x => x.id === id);
  if (!l) return;
  l.status = status;
  if (firebaseReady) {
    try {
      await window.FB.updateDoc(window.FB.docRef('lands', id), { status });
      // Notify the land owner
      const landDoc = await window.FB.getDoc(window.FB.docRef('lands', id));
      const ownerId = landDoc.data()?.ownerId;
      if (ownerId) {
        const isApproved = status === 'active' || status === 'approved';
        await window.FB.addDoc(
          window.FB.col(`users/${ownerId}/notifications`),
          {
            title:     isApproved ? 'Land Listing Approved ✓' : 'Land Listing Update',
            body:      isApproved
              ? `"${l.title}" has been approved and is now live on AgriPortal.`
              : `"${l.title}" status changed to ${status}.`,
            type:      'land',
            isRead:    false,
            createdAt: window.FB.serverTimestamp(),
          }
        );
      }
    } catch (e) { console.warn('[Admin] setLandStatus FB:', e.message); }
  }
  renderLands();
  updateStatCards();
  showToast(`"${l.title}" is now ${status}.`, 'success');
}

function deleteLand(id) {
  const l = lands.find(x => x.id === id);
  if (!l) return;
  confirmDo('Delete Listing', `Permanently delete "${l.title}"? This cannot be undone.`, async () => {
    lands = lands.filter(x => x.id !== id);
    if (firebaseReady) {
      try { await window.FB.deleteDoc(window.FB.docRef('lands', id)); }
      catch (e) { console.warn('[Admin] deleteLand FB:', e.message); }
    }
    renderLands();
    updateStatCards();
    showToast('Listing deleted.', 'warning');
  });
}

function openAddLand() {
  // Land listings are created by land owners through the Flutter app.
  // Admin can manually add via Firestore Console.
  confirmDo(
    'Add Land Listing',
    'Land listings are submitted by land owners through the AgriPortal app. To manually add a listing, use Firebase Console → Firestore → lands collection.',
    () => window.open('https://console.firebase.google.com/project/agriportal-9ee3d/firestore/data/~2Flands', '_blank')
  );
  setTimeout(() => {
    const btn = document.getElementById('confirmOk');
    if (btn) { btn.textContent = 'Open Firebase Console'; btn.className = 'btn btn-sm btn-success rounded-3 px-3'; }
  }, 10);
}

/* ════════════════════════════════════════════════════════
   APPLICATIONS
════════════════════════════════════════════════════════ */
function renderApps() {
  const q  = (document.getElementById('aSearch')?.value  || '').toLowerCase();
  const sf = document.getElementById('aStatusF')?.value  || '';

  const list = apps.filter(a =>
    (!q  || a.applicant.toLowerCase().includes(q) || a.land.toLowerCase().includes(q)) &&
    (!sf || a.status === sf)
  );

  const tb = document.getElementById('appsBody');
  if (!tb) return;

  tb.innerHTML = list.length ? list.map((a, i) => `
    <tr>
      <td class="text-muted small text-center">${i + 1}</td>
      <td>
        <div class="d-flex align-items-center gap-2">
          <div class="user-ava" style="background:${avaColor(a.applicant)};width:30px;height:30px;font-size:.75rem;flex-shrink:0">${a.applicant[0]}</div>
          <div class="fw-600 small">${esc(a.applicant)}</div>
        </div>
      </td>
      <td class="small fw-600">${esc(a.land)}</td>
      <td class="small text-muted">${esc(a.owner)}</td>
      <td class="small text-muted">${a.applied}</td>
      <td><span class="badge rounded-pill ${appTag(a.status)}">${cap(a.status)}</span></td>
      <td>
        ${a.status === 'pending' ? `
          <div class="d-flex gap-1">
            <button class="btn btn-sm btn-outline-success btn-icon" onclick="setAppStatus('${a.id}','approved')" title="Approve">
              <i class="bi bi-check-lg"></i>
            </button>
            <button class="btn btn-sm btn-outline-danger btn-icon"  onclick="setAppStatus('${a.id}','rejected')" title="Reject">
              <i class="bi bi-x-lg"></i>
            </button>
          </div>` : '<span class="x-small text-muted">—</span>'}
      </td>
    </tr>`) .join('')
    : '<tr><td colspan="7" class="text-center py-5 text-muted">No applications match the current filters.</td></tr>';

  const cEl = document.getElementById('aCount');
  if (cEl) cEl.textContent = `${list.length} of ${apps.length} applications`;
}

async function setAppStatus(id, status) {
  const a = apps.find(x => x.id === id);
  if (!a) return;
  a.status = status;
  if (firebaseReady) {
    try { await window.FB.updateDoc(window.FB.docRef('applications', id), { status }); }
    catch (e) { console.warn('[Admin] setAppStatus FB:', e.message); }
  }
  renderApps();
  updateBadges();
  showToast(`Application ${status}.`, status === 'approved' ? 'success' : 'warning');
}

/* ════════════════════════════════════════════════════════
   MESSAGES
════════════════════════════════════════════════════════ */
function renderConvs() {
  const q = (document.getElementById('convSearch')?.value || '').toLowerCase();
  const list = convs.filter(c =>
    !q ||
    c.aName.toLowerCase().includes(q) ||
    c.bName.toLowerCase().includes(q) ||
    c.land.toLowerCase().includes(q)
  );
  const el = document.getElementById('convList');
  if (!el) return;

  el.innerHTML = list.length ? list.map(c => `
    <div class="conv-item ${activeConvId === c.id ? 'active' : ''}" onclick="selectConv('${c.id}')">
      <div class="user-ava" style="background:${avaColor(c.aName)};width:38px;height:38px;flex-shrink:0">${c.aName[0]}</div>
      <div class="flex-grow-1 overflow-hidden">
        <div class="fw-600 small text-truncate">${esc(c.aName)} ↔ ${esc(c.bName)}</div>
        <div class="x-small text-muted text-truncate">${esc(c.land)}</div>
        <div class="x-small text-truncate mt-1">${esc(c.lastMsg)}</div>
      </div>
      <div class="x-small text-muted ms-1 flex-shrink-0">${relTime(c.ts)}</div>
    </div>`) .join('')
    : '<div class="text-center py-4 text-muted small">No conversations yet.</div>';
}

function filterConvs() { renderConvs(); }

function selectConv(id) {
  activeConvId = id;
  renderConvs();

  const c = convs.find(x => x.id === id);
  if (!c) return;

  document.getElementById('msgHeader').innerHTML = `
    <div class="msg-header-inner">
      <div class="user-ava" style="background:${avaColor(c.aName)};width:40px;height:40px;flex-shrink:0">${c.aName[0]}</div>
      <div class="flex-grow-1">
        <div class="fw-700">${esc(c.aName)} ↔ ${esc(c.bName)}</div>
        <div class="x-small text-muted">${esc(c.land)}</div>
      </div>
      <span class="live-pill small"><span class="live-dot"></span>Live</span>
    </div>`;

  const body = document.getElementById('msgBody');
  body.innerHTML = '';

  if (firebaseReady) {
    // Subscribe to real-time messages from RTDB
    const msgRef = window.FB.rtQuery(
      window.FB.rtRef(`messages/${id}`),
      window.FB.rtOrderBy('timestamp')
    );
    window.FB.rtOnValue(msgRef, snap => {
      if (!snap.exists()) {
        body.innerHTML = '<div class="text-center py-4 text-muted small">No messages in this conversation yet.</div>';
        return;
      }
      const msgs = [];
      snap.forEach(child => msgs.push({ key: child.key, ...child.val() }));
      body.innerHTML = `<div class="d-flex flex-column gap-2">${
        msgs.map(m => {
          const isRight = c.aId ? m.senderId !== c.aId : false;
          const name = m.senderName || (isRight ? c.bName : c.aName);
          const time = m.timestamp
            ? new Date(m.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
            : '';
          return `
            <div class="bubble-row ${isRight ? 'right' : 'left'}">
              <div class="x-small text-muted mb-1">${esc(name)} · ${time}</div>
              <div class="bubble ${isRight ? 'right' : 'left'}">${esc(m.text || '')}</div>
            </div>`;
        }).join('')
      }</div>`;
      body.scrollTop = body.scrollHeight;
    });
  } else {
    // Demo messages
    body.innerHTML = `<div class="d-flex flex-column gap-2">${
      (c.msgs || []).map(m => `
        <div class="bubble-row ${m.from === 'b' ? 'right' : 'left'}">
          <div class="x-small text-muted mb-1">${m.from === 'a' ? esc(c.aName) : esc(c.bName)} · ${fmtTime(m.ts)}</div>
          <div class="bubble ${m.from === 'b' ? 'right' : 'left'}">${esc(m.text)}</div>
        </div>`).join('')
    }</div>`;
    body.scrollTop = body.scrollHeight;
  }
}

/* ════════════════════════════════════════════════════════
   SUPPORT MESSAGES
════════════════════════════════════════════════════════ */
let supportMsgs = [];
let activeSupId = null;

async function fbLoadSupportMessages() {
  if (!firebaseReady) return;
  try {
    const snap = await window.FB.getDocs(window.FB.col('supportMessages'));
    supportMsgs = snap.docs.map(d => {
      const v = d.data();
      return {
        id:        d.id,
        name:      v.name      || 'Unknown',
        email:     v.email     || '',
        category:  v.category  || 'General',
        message:   v.message   || '',
        status:    v.status    || 'open',
        uid:       v.uid       || null,
        createdAt: tsToDate(v.createdAt),
        ts:        v.createdAt?.seconds ? v.createdAt.seconds * 1000 : Date.now(),
      };
    });
    supportMsgs.sort((a, b) => b.ts - a.ts);
    renderSupport();
    updateSupportBadge();
    showToast(`${supportMsgs.length} support messages loaded`, 'success');
  } catch (e) { console.warn('[Admin] fbLoadSupportMessages:', e.message); }
}

function updateSupportBadge() {
  const open = supportMsgs.filter(m => m.status === 'open').length;
  badge('nbSupport', open);
}

function renderSupport() {
  const status = document.querySelector('input[name="supTab"]:checked')?.value ?? 'open';
  const q      = (document.getElementById('supSearch')?.value || '').toLowerCase();

  const list = supportMsgs.filter(m =>
    (!status || m.status === status) &&
    (!q || m.name.toLowerCase().includes(q) || m.email.toLowerCase().includes(q) ||
          m.message.toLowerCase().includes(q) || m.category.toLowerCase().includes(q))
  );

  const el = document.getElementById('supList');
  if (!el) return;

  document.getElementById('supCount').textContent = list.length;

  el.innerHTML = list.length ? list.map(m => `
    <div class="support-msg-item ${activeSupId === m.id ? 'active' : ''} ${m.status === 'open' ? 'unread' : ''}"
         onclick="selectSupport('${m.id}')">
      <div class="sm-ava" style="background:${avaColor(m.name)}">${m.name[0]}</div>
      <div class="flex-grow-1 overflow-hidden">
        <div class="d-flex align-items-center justify-content-between">
          <div class="sm-name">${esc(m.name)}</div>
          <div class="x-small text-muted">${m.createdAt}</div>
        </div>
        <div class="sm-cat">${esc(m.category)} · ${esc(m.email)}</div>
        <div class="sm-prev">${esc(m.message)}</div>
      </div>
      ${m.status === 'open' ? '<div class="unread-dot"></div>' : ''}
    </div>`).join('')
    : '<div class="text-center py-5 text-muted small">No messages match this filter.</div>';
}

function selectSupport(id) {
  activeSupId = id;
  renderSupport();

  const m = supportMsgs.find(x => x.id === id);
  if (!m) return;

  const panel = document.getElementById('supDetail');
  panel.innerHTML = `
    <div class="support-detail-header">
      <div class="d-flex align-items-center gap-3">
        <div class="sm-ava" style="background:${avaColor(m.name)};width:46px;height:46px;font-size:1.1rem">${m.name[0]}</div>
        <div>
          <div class="fw-800 fs-6">${esc(m.name)}</div>
          <div class="small text-muted">${esc(m.email)}</div>
          <div class="d-flex gap-2 mt-1 flex-wrap">
            <span class="badge rounded-pill tag-${m.status === 'open' ? 'open' : 'resolved'}">${cap(m.status)}</span>
            <span class="badge rounded-pill bg-light text-muted border">${esc(m.category)}</span>
          </div>
        </div>
      </div>
      <div class="d-flex gap-2 flex-wrap">
        ${m.status === 'open' ? `
          <button class="btn btn-sm btn-success rounded-3" onclick="resolveSupport('${m.id}')">
            <i class="bi bi-check-circle me-1"></i>Mark Resolved
          </button>` : `
          <button class="btn btn-sm btn-outline-secondary rounded-3" onclick="reopenSupport('${m.id}')">
            <i class="bi bi-arrow-counterclockwise me-1"></i>Reopen
          </button>`}
        <button class="btn btn-sm btn-outline-danger rounded-3" onclick="deleteSupport('${m.id}')">
          <i class="bi bi-trash"></i>
        </button>
      </div>
    </div>
    <div class="support-detail-body">
      <div class="support-meta-grid mb-4">
        <div class="support-meta-item">
          <div class="label">Received</div>
          <div class="value">${m.createdAt}</div>
        </div>
        <div class="support-meta-item">
          <div class="label">Category</div>
          <div class="value">${esc(m.category)}</div>
        </div>
        <div class="support-meta-item">
          <div class="label">Email</div>
          <div class="value">${esc(m.email)}</div>
        </div>
        <div class="support-meta-item">
          <div class="label">Status</div>
          <div class="value"><span class="badge rounded-pill tag-${m.status === 'open' ? 'open' : 'resolved'}">${cap(m.status)}</span></div>
        </div>
      </div>
      <div class="fw-700 small mb-2">Message</div>
      <div class="support-msg-bubble mb-4">${esc(m.message)}</div>
      ${m.uid ? `
      <div class="alert alert-success-subtle border border-success-subtle rounded-3 small">
        <i class="bi bi-person-circle me-1 text-success"></i>
        Sent by a registered user — UID: <code>${m.uid}</code>
      </div>` : `
      <div class="alert alert-light border rounded-3 small text-muted">
        <i class="bi bi-info-circle me-1"></i>Sent as a guest (not signed in).
      </div>`}
    </div>`;
}

async function resolveSupport(id) {
  const m = supportMsgs.find(x => x.id === id);
  if (!m) return;
  m.status = 'resolved';
  if (firebaseReady) {
    try { await window.FB.updateDoc(window.FB.docRef('supportMessages', id), { status: 'resolved' }); }
    catch (e) { console.warn('[Admin] resolveSupport:', e.message); }
  }
  renderSupport();
  updateSupportBadge();
  selectSupport(id);
  showToast('Message marked as resolved.', 'success');
}

async function reopenSupport(id) {
  const m = supportMsgs.find(x => x.id === id);
  if (!m) return;
  m.status = 'open';
  if (firebaseReady) {
    try { await window.FB.updateDoc(window.FB.docRef('supportMessages', id), { status: 'open' }); }
    catch (e) { console.warn('[Admin] reopenSupport:', e.message); }
  }
  renderSupport();
  updateSupportBadge();
  selectSupport(id);
  showToast('Message reopened.', 'info');
}

function deleteSupport(id) {
  confirmDo('Delete Message', 'Permanently delete this support message?', async () => {
    supportMsgs = supportMsgs.filter(x => x.id !== id);
    if (firebaseReady) {
      try { await window.FB.deleteDoc(window.FB.docRef('supportMessages', id)); }
      catch (e) { console.warn('[Admin] deleteSupport:', e.message); }
    }
    activeSupId = null;
    document.getElementById('supDetail').innerHTML = `
      <div class="support-detail-header">
        <div class="text-muted small d-flex align-items-center gap-2 p-3">
          <i class="bi bi-envelope fs-4 text-success"></i>
          Select a message to view details
        </div>
      </div>`;
    renderSupport();
    updateSupportBadge();
    showToast('Message deleted.', 'warning');
  });
}

/* ════════════════════════════════════════════════════════
   ANALYTICS
════════════════════════════════════════════════════════ */
function renderAnalytics() {
  animCount('at-users',    users.length);
  animCount('at-verified', users.filter(u => u.kycStatus === 'verified').length);
  animCount('at-listings', lands.length);
  animCount('at-apps',     apps.length);

  const total   = users.length || 1;
  const farmers = users.filter(u => u.role === 'farmer').length;
  const owners  = users.filter(u => u.role === 'landOwner').length;

  const el1 = document.getElementById('chartRoles');
  if (el1) el1.innerHTML = [
    { label: 'Farmers',     count: farmers, color: '#22c55e' },
    { label: 'Land Owners', count: owners,  color: '#6366f1' },
  ].map(r => barRow(r.label, r.count, total, r.color)).join('');

  const verified = users.filter(u => u.kycStatus === 'verified').length;
  const pending  = users.filter(u => u.kycStatus === 'pending').length;
  const rejected = users.filter(u => u.kycStatus === 'rejected').length;

  const el2 = document.getElementById('chartKyc');
  if (el2) el2.innerHTML = [
    { label: 'Verified', count: verified, color: '#22c55e' },
    { label: 'Pending',  count: pending,  color: '#f59e0b' },
    { label: 'Rejected', count: rejected, color: '#ef4444' },
  ].map(r => barRow(r.label, r.count, total, r.color)).join('');

  const pMap = {};
  lands.forEach(l => { pMap[l.province] = (pMap[l.province] || 0) + 1; });
  const maxP = Math.max(...Object.values(pMap), 1);

  const el3 = document.getElementById('chartProvinces');
  if (el3) el3.innerHTML = Object.entries(pMap)
    .sort((a, b) => b[1] - a[1])
    .map(([p, n]) => barRow(p, n, maxP, '#06b6d4'))
    .join('');
}

function barRow(label, count, total, color) {
  const pct = ((count / total) * 100).toFixed(1);
  return `
    <div class="chart-row">
      <div class="chart-label"><span>${esc(label)}</span><span>${count}</span></div>
      <div class="chart-track">
        <div class="chart-bar" style="width:${pct}%;background:${color}"></div>
      </div>
    </div>`;
}

/* ════════════════════════════════════════════════════════
   UI HELPERS
════════════════════════════════════════════════════════ */
function showToast(msg, type = 'success') {
  const el   = document.getElementById('toast');
  const body = document.getElementById('toastBody');
  if (!el || !body) return;
  body.textContent = msg;
  const map = { success: 'text-bg-success', warning: 'text-bg-warning', danger: 'text-bg-danger', info: 'text-bg-primary' };
  el.className = `toast align-items-center border-0 rounded-3 shadow ${map[type] || 'text-bg-success'}`;
  new bootstrap.Toast(el, { delay: 3000 }).show();
}

function confirmDo(title, body, callback) {
  document.getElementById('confirmTitle').textContent = title;
  document.getElementById('confirmBody').textContent  = body;
  document.getElementById('confirmOk').onclick = callback;
  new bootstrap.Modal(document.getElementById('modalConfirm')).show();
}

function setGreeting() {
  const h    = new Date().getHours();
  const g    = h < 12 ? 'morning' : h < 17 ? 'afternoon' : 'evening';
  const name = document.getElementById('adminName')?.textContent || 'Admin';
  const el   = document.getElementById('welcomeMsg');
  if (el) el.textContent = `Good ${g}, ${name.charAt(0).toUpperCase() + name.slice(1)} 👋`;
}

function setDate() {
  const el = document.getElementById('todayDate');
  if (el) el.textContent = new Date().toLocaleDateString('en-GB', {
    weekday: 'short', day: 'numeric', month: 'long', year: 'numeric',
  });
}

/* ── Formatters ─────────────────────────────────────── */
function esc(s) {
  return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function cap(s) { return s ? s.charAt(0).toUpperCase() + s.slice(1) : '—'; }
function fmtTime(ts) { return new Date(ts).toLocaleTimeString([], { hour:'2-digit', minute:'2-digit' }); }
function relTime(ts) {
  const d = Date.now() - ts;
  if (d < 60000)    return 'just now';
  if (d < 3600000)  return `${Math.round(d / 60000)}m ago`;
  if (d < 86400000) return `${Math.round(d / 3600000)}h ago`;
  return `${Math.round(d / 86400000)}d ago`;
}
function tsToDate(ts) {
  if (!ts) return '—';
  try {
    const d = ts.toDate ? ts.toDate() : ts.seconds ? new Date(ts.seconds * 1000) : new Date(ts);
    return d.toISOString().split('T')[0];
  } catch { return '—'; }
}
function avaColor(s) { let h = 0; for (const c of String(s)) h = c.charCodeAt(0) + ((h << 5) - h); return AVATAR_COLORS[Math.abs(h) % AVATAR_COLORS.length]; }

/* ── Badge class helpers ──────────────────────────── */
function roleTag(r) { return r === 'landOwner' ? 'tag-owner'   : 'tag-farmer'; }
function kycTag(s)  { return { verified:'tag-verified', pending:'tag-pending', rejected:'tag-rejected' }[s] || 'tag-inactive'; }
function landTag(s) { return { active:'tag-active', pending:'tag-pending', inactive:'tag-inactive' }[s]      || 'tag-inactive'; }
function appTag(s)  { return { approved:'tag-approved', pending:'tag-pending', rejected:'tag-rejected' }[s]  || 'tag-inactive'; }
function kycIcon(s) {
  return { verified:'<i class="bi bi-patch-check-fill me-1"></i>', pending:'<i class="bi bi-hourglass-split me-1"></i>', rejected:'<i class="bi bi-x-circle-fill me-1"></i>' }[s] || '';
}
