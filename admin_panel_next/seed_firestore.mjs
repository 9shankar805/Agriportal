/**
 * AgriPortal — Firestore Seed Script
 * Run from admin_panel_next folder:  node seed_firestore.mjs
 */

import { initializeApp } from 'firebase/app';
import {
  getAuth,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  updateProfile,
} from 'firebase/auth';
import {
  getFirestore,
  collection,
  doc,
  setDoc,
  addDoc,
  Timestamp,
} from 'firebase/firestore';

// ── Firebase config ───────────────────────────────────────────────────────────
const firebaseConfig = {
  apiKey:            'AIzaSyAwR5a3W2jZEzB0Piz5Qc7oP_aTFwdVYRA',
  authDomain:        'agriportal-9ee3d.firebaseapp.com',
  databaseURL:       'https://agriportal-9ee3d-default-rtdb.firebaseio.com',
  projectId:         'agriportal-9ee3d',
  storageBucket:     'agriportal-9ee3d.firebasestorage.app',
  messagingSenderId: '312069394942',
  appId:             '1:312069394942:web:08d4b4026fbafa425cf0af',
};

const app  = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db   = getFirestore(app);

// ── Helpers ───────────────────────────────────────────────────────────────────
const ts = (daysAgo = 0) =>
  Timestamp.fromDate(new Date(Date.now() - daysAgo * 86_400_000));

async function ensureUser(email, password, displayName, extraData = {}) {
  let uid;
  try {
    const cred = await createUserWithEmailAndPassword(auth, email, password);
    uid = cred.user.uid;
    await updateProfile(cred.user, { displayName });
    console.log(`  ✔ Created: ${email}  (${uid})`);
  } catch (e) {
    if (e.code === 'auth/email-already-in-use') {
      const cred = await signInWithEmailAndPassword(auth, email, password);
      uid = cred.user.uid;
      console.log(`  ↩ Existing: ${email}  (${uid})`);
    } else {
      throw e;
    }
  }

  const { daysAgo, ...rest } = extraData;
  await setDoc(doc(db, 'users', uid), {
    name:      displayName,
    email,
    isActive:  true,
    createdAt: ts(daysAgo ?? 10),
    ...rest,
  }, { merge: true });

  return uid;
}

// ── Seed definitions ──────────────────────────────────────────────────────────

const USERS = [
  { email: 'ram.sharma@example.com',   password: 'Pass1234!', name: 'Ram Sharma',   role: 'landOwner', kycStatus: 'verified', phone: '9801234567', daysAgo: 30 },
  { email: 'sita.thapa@example.com',   password: 'Pass1234!', name: 'Sita Thapa',   role: 'farmer',    kycStatus: 'verified', phone: '9812345678', daysAgo: 25 },
  { email: 'bishnu.oli@example.com',   password: 'Pass1234!', name: 'Bishnu Oli',   role: 'landOwner', kycStatus: 'verified', phone: '9823456789', daysAgo: 20 },
  { email: 'maya.gurung@example.com',  password: 'Pass1234!', name: 'Maya Gurung',  role: 'farmer',    kycStatus: 'pending',  phone: '9834567890', daysAgo: 15 },
  { email: 'dipak.rai@example.com',    password: 'Pass1234!', name: 'Dipak Rai',    role: 'farmer',    kycStatus: 'verified', phone: '9845678901', daysAgo: 12 },
  { email: 'laxmi.poudel@example.com', password: 'Pass1234!', name: 'Laxmi Poudel', role: 'landOwner', kycStatus: 'rejected', phone: '9856789012', daysAgo: 8  },
  { email: 'hari.bk@example.com',      password: 'Pass1234!', name: 'Hari BK',      role: 'farmer',    kycStatus: 'pending',  phone: '9867890123', daysAgo: 5  },
  { email: 'sunita.kc@example.com',    password: 'Pass1234!', name: 'Sunita KC',    role: 'farmer',    kycStatus: 'verified', phone: '9878901234', daysAgo: 3  },
];

const LAND_TEMPLATES = [
  {
    title: 'Fertile Paddy Land in Chitwan', province: 'Bagmati', district: 'Chitwan', municipality: 'Bharatpur',
    areaBigha: 3.5, soilType: 'Alluvial', waterSource: 'River', hasIrrigation: true, pricePerBigha: 8000,
    status: 'active', category: 'Paddy', isVerified: true, ownerRating: 4.7,
    latitude: 27.6744, longitude: 84.4294,
    description: 'Prime paddy land with year-round river access and excellent alluvial soil. Perfect for rice and wheat rotation.',
    imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
    imageUrls: ['https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800'],
    landFeatures: ['Flat terrain', 'Road access', 'Electricity nearby'],
    suggestedCrops: ['Rice', 'Wheat', 'Mustard'],
    ownerIndex: 0, daysAgo: 25,
  },
  {
    title: 'Hilly Tea Garden Land — Ilam', province: 'Koshi', district: 'Ilam', municipality: 'Ilam Municipality',
    areaBigha: 5.0, soilType: 'Loamy', waterSource: 'Spring', hasIrrigation: false, pricePerBigha: 12000,
    status: 'active', category: 'Tea', isVerified: true, ownerRating: 4.9,
    latitude: 26.9122, longitude: 87.9249,
    description: 'Scenic hillside tea garden with established tea plants. Ideal for organic tea production.',
    imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
    imageUrls: ['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800'],
    landFeatures: ['Sloped terrain', 'Existing tea plants', 'Spring water'],
    suggestedCrops: ['Tea', 'Cardamom', 'Ginger'],
    ownerIndex: 0, daysAgo: 20,
  },
  {
    title: 'Vegetable Farm in Kavre District', province: 'Bagmati', district: 'Kavrepalanchok', municipality: 'Banepa Municipality',
    areaBigha: 2.0, soilType: 'Sandy Loam', waterSource: 'Borehole', hasIrrigation: true, pricePerBigha: 6500,
    status: 'active', category: 'Vegetable', isVerified: false, ownerRating: 4.3,
    latitude: 27.6336, longitude: 85.5243,
    description: 'Productive vegetable farm with established irrigation, close to Banepa market.',
    imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800',
    imageUrls: ['https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800'],
    landFeatures: ['Flat', 'Borehole irrigation', 'Market nearby'],
    suggestedCrops: ['Tomato', 'Cauliflower', 'Spinach', 'Cabbage'],
    ownerIndex: 2, daysAgo: 18,
  },
  {
    title: 'Mango Orchard Land — Nawalpur', province: 'Gandaki', district: 'Nawalpur', municipality: 'Kawasoti Municipality',
    areaBigha: 4.0, soilType: 'Clay Loam', waterSource: 'Canal', hasIrrigation: true, pricePerBigha: 9000,
    status: 'pending', category: 'Orchard', isVerified: false, ownerRating: 4.1,
    latitude: 27.6985, longitude: 84.1234,
    description: 'Established mango orchard with canal irrigation and existing tree infrastructure.',
    imageUrl: 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=800',
    imageUrls: ['https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=800'],
    landFeatures: ['Existing mango trees', 'Canal access', 'Storage shed'],
    suggestedCrops: ['Mango', 'Banana', 'Lemon'],
    ownerIndex: 2, daysAgo: 10,
  },
  {
    title: 'Wheat & Mustard Field — Banke', province: 'Lumbini', district: 'Banke', municipality: 'Nepalgunj Sub-Metropolitan',
    areaBigha: 6.0, soilType: 'Alluvial', waterSource: 'Tubewell', hasIrrigation: true, pricePerBigha: 5500,
    status: 'active', category: 'Paddy', isVerified: true, ownerRating: 4.5,
    latitude: 28.0508, longitude: 81.6156,
    description: 'Large flat Terai farmland, tubewell irrigation, excellent for grain crops year round.',
    imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800',
    imageUrls: ['https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800'],
    landFeatures: ['Flat Terai land', 'Tubewell', 'Motorable road'],
    suggestedCrops: ['Wheat', 'Mustard', 'Lentils'],
    ownerIndex: 5, daysAgo: 7,
  },
  {
    title: 'Rice Paddy Fields — Morang', province: 'Koshi', district: 'Morang', municipality: 'Biratnagar Metropolitan',
    areaBigha: 4.5, soilType: 'Alluvial', waterSource: 'River', hasIrrigation: true, pricePerBigha: 7500,
    status: 'active', category: 'Paddy', isVerified: true, ownerRating: 4.6,
    latitude: 26.4525, longitude: 87.2718,
    description: 'Fertile paddy fields near Biratnagar with river access and good road connectivity.',
    imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
    imageUrls: ['https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800'],
    landFeatures: ['River frontage', 'Flat terrain', 'Road access'],
    suggestedCrops: ['Rice', 'Jute', 'Maize'],
    ownerIndex: 2, daysAgo: 5,
  },
];

const APPLICATIONS = [
  { landIdx: 0, applicantIdx: 1, ownerIdx: 0, message: 'I am an experienced paddy farmer with 10 years experience. I would love to lease this land for two growing seasons.', status: 'pending',  daysAgo: 5  },
  { landIdx: 0, applicantIdx: 4, ownerIdx: 0, message: 'Looking to expand my rice farming operations. Your land looks perfect for my plans.',                                   status: 'approved', daysAgo: 8  },
  { landIdx: 2, applicantIdx: 7, ownerIdx: 2, message: 'I specialise in organic vegetable farming and would like to lease this plot for one year.',                             status: 'pending',  daysAgo: 3  },
  { landIdx: 1, applicantIdx: 4, ownerIdx: 0, message: 'I have experience managing tea estates and am interested in a 2-year lease.',                                           status: 'rejected', daysAgo: 15 },
  { landIdx: 4, applicantIdx: 1, ownerIdx: 5, message: 'Interested in wheat and mustard cultivation. I have the necessary equipment.',                                          status: 'pending',  daysAgo: 2  },
];

const WALLETS = [
  { userIdx: 0, balance: 150.0, txns: [{ amount: 200, type: 'credit', desc: 'Added to wallet', daysAgo: 20 }, { amount: 20, type: 'debit', desc: 'Listing fee — Fertile Paddy Land in Chitwan', daysAgo: 19 }, { amount: 20, type: 'debit', desc: 'Listing fee — Hilly Tea Garden Land', daysAgo: 18 }, { amount: 20, type: 'debit', desc: 'Listing fee — Rice Paddy Fields — Morang', daysAgo: 10 }] },
  { userIdx: 1, balance: 80.0,  txns: [{ amount: 100, type: 'credit', desc: 'Added to wallet', daysAgo: 10 }, { amount: 20, type: 'debit', desc: 'Application fee', daysAgo: 9 }] },
  { userIdx: 2, balance: 40.0,  txns: [{ amount: 100, type: 'credit', desc: 'Added to wallet', daysAgo: 15 }, { amount: 20, type: 'debit', desc: 'Listing fee — Vegetable Farm in Kavre', daysAgo: 14 }, { amount: 20, type: 'debit', desc: 'Listing fee — Mango Orchard Land', daysAgo: 8 }, { amount: 20, type: 'debit', desc: 'Listing fee — Rice Paddy Fields', daysAgo: 4 }] },
  { userIdx: 4, balance: 40.0,  txns: [{ amount: 40,  type: 'credit', desc: 'Added to wallet', daysAgo: 5  }] },
  { userIdx: 7, balance: 120.0, txns: [{ amount: 120, type: 'credit', desc: 'Added to wallet', daysAgo: 3  }] },
];

const NOTIFICATIONS = [
  { userIdx: 1, title: 'Application Approved ✓', body: 'Your application for "Fertile Paddy Land in Chitwan" has been approved! Contact the owner to proceed.', type: 'application', daysAgo: 8  },
  { userIdx: 4, title: 'Application Update',     body: 'Your application for "Hilly Tea Garden Land — Ilam" was not approved this time.',                        type: 'application', daysAgo: 15 },
  { userIdx: 0, title: 'New Application',        body: 'Sita Thapa has applied for "Fertile Paddy Land in Chitwan".',                                            type: 'land',        daysAgo: 5  },
  { userIdx: 7, title: 'KYC Verified ✓',         body: 'Your KYC has been verified! You can now apply for land listings.',                                        type: 'kyc',         daysAgo: 2  },
  { userIdx: 3, title: 'Welcome to AgriPortal',  body: 'Your account is set up. Please complete KYC verification to start applying for land listings.',           type: 'system',      daysAgo: 15 },
  { userIdx: 5, title: 'KYC Not Approved',       body: 'Your KYC was not approved. Please resubmit with clearer documents.',                                     type: 'kyc',         daysAgo: 6  },
];

const SUPPORT_MESSAGES = [
  { name: 'Maya Gurung',  email: 'maya.gurung@example.com',  category: 'KYC Issue',     message: 'I submitted my KYC documents 3 days ago but still see "pending" status. Please review.',             status: 'open',     daysAgo: 4 },
  { name: 'Hari BK',      email: 'hari.bk@example.com',      category: 'Payment Issue', message: 'I added money to my wallet but the balance is not reflecting correctly.',                              status: 'resolved', daysAgo: 7 },
  { name: 'Laxmi Poudel', email: 'laxmi.poudel@example.com', category: 'Land Listing',  message: 'My land listing was rejected without a clear reason. Can you explain the rejection criteria?',        status: 'open',     daysAgo: 2 },
];

// ── Main ──────────────────────────────────────────────────────────────────────
async function main() {
  console.log('\n🌱  AgriPortal — Firestore Seed\n');

  // Sign in or create the seed admin account
  console.log('── Authenticating seed user ────────────────────────');
  const SEED_EMAIL    = 'seed@agriportal.np';
  const SEED_PASSWORD = 'Seed@Agri2024!';
  let adminUid;
  try {
    const cred = await createUserWithEmailAndPassword(auth, SEED_EMAIL, SEED_PASSWORD);
    adminUid   = cred.user.uid;
    console.log(`  ✔ Created seed auth user (${adminUid})`);
  } catch (e) {
    if (e.code === 'auth/email-already-in-use') {
      const cred = await signInWithEmailAndPassword(auth, SEED_EMAIL, SEED_PASSWORD);
      adminUid   = cred.user.uid;
      console.log(`  ↩ Signed in as seed user (${adminUid})`);
    } else {
      throw e;
    }
  }
  // Write seed user into admins collection (allowed since we own the doc)
  await setDoc(doc(db, 'users', adminUid), {
    name: 'Seed Admin', email: SEED_EMAIL, role: 'admin', isActive: true, createdAt: ts(0),
  }, { merge: true });
  console.log(`  ✔ Auth ready\n`);

  // ── Users ─────────────────────────────────────────────────────────────────
  console.log('── Creating users ──────────────────────────────────');
  const uids = [];
  for (const u of USERS) {
    const uid = await ensureUser(u.email, u.password, u.name, {
      phone: u.phone, role: u.role, kycStatus: u.kycStatus, daysAgo: u.daysAgo,
    });
    uids.push(uid);
  }
  console.log(`\n  ✔ ${uids.length} users ready\n`);

  // ── Lands ─────────────────────────────────────────────────────────────────
  console.log('── Creating land listings ──────────────────────────');
  const landIds = [];
  for (const lt of LAND_TEMPLATES) {
    const ownerUid  = uids[lt.ownerIndex];
    const ownerName = USERS[lt.ownerIndex].name;
    const { ownerIndex, daysAgo, ...landData } = lt;
    const ref = await addDoc(collection(db, 'lands'), {
      ...landData, ownerId: ownerUid, ownerName, createdAt: ts(daysAgo),
    });
    landIds.push(ref.id);
    console.log(`  ✔ "${lt.title}"`);
  }
  console.log(`\n  ✔ ${landIds.length} lands ready\n`);

  // ── Applications ──────────────────────────────────────────────────────────
  console.log('── Creating applications ───────────────────────────');
  for (const a of APPLICATIONS) {
    await addDoc(collection(db, 'applications'), {
      landId:        landIds[a.landIdx],
      landTitle:     LAND_TEMPLATES[a.landIdx].title,
      ownerId:       uids[a.ownerIdx],
      ownerName:     USERS[a.ownerIdx].name,
      applicantId:   uids[a.applicantIdx],
      applicantName: USERS[a.applicantIdx].name,
      message:       a.message,
      status:        a.status,
      appliedAt:     ts(a.daysAgo),
    });
    console.log(`  ✔ ${USERS[a.applicantIdx].name} → "${LAND_TEMPLATES[a.landIdx].title}"  [${a.status}]`);
  }
  console.log(`\n  ✔ ${APPLICATIONS.length} applications ready\n`);

  // ── Wallets ───────────────────────────────────────────────────────────────
  console.log('── Creating wallets ────────────────────────────────');
  for (const w of WALLETS) {
    const uid = uids[w.userIdx];
    await setDoc(doc(db, 'users', uid, 'wallet', 'balance'), {
      balance: w.balance, updatedAt: ts(0),
    });
    for (const t of w.txns) {
      await addDoc(collection(db, 'users', uid, 'walletTransactions'), {
        amount: t.amount, type: t.type, description: t.desc, createdAt: ts(t.daysAgo),
      });
    }
    console.log(`  ✔ ${USERS[w.userIdx].name}: Rs ${w.balance}  (${w.txns.length} txns)`);
  }
  console.log(`\n  ✔ ${WALLETS.length} wallets ready\n`);

  // ── Notifications ─────────────────────────────────────────────────────────
  console.log('── Creating notifications ──────────────────────────');
  for (const n of NOTIFICATIONS) {
    await addDoc(collection(db, 'users', uids[n.userIdx], 'notifications'), {
      title: n.title, body: n.body, type: n.type, isRead: false, createdAt: ts(n.daysAgo),
    });
    console.log(`  ✔ ${USERS[n.userIdx].name} ← "${n.title}"`);
  }
  console.log(`\n  ✔ ${NOTIFICATIONS.length} notifications ready\n`);

  // ── Support messages ──────────────────────────────────────────────────────
  console.log('── Creating support messages ───────────────────────');
  for (const s of SUPPORT_MESSAGES) {
    await addDoc(collection(db, 'supportMessages'), {
      name: s.name, email: s.email, category: s.category,
      message: s.message, status: s.status, uid: null, createdAt: ts(s.daysAgo),
    });
    console.log(`  ✔ ${s.name}: "${s.category}"  [${s.status}]`);
  }
  console.log(`\n  ✔ ${SUPPORT_MESSAGES.length} support messages ready\n`);

  console.log('✅  Seed complete!\n');
  process.exit(0);
}

main().catch(err => {
  console.error('\n❌  Seed failed:', err.message ?? err);
  process.exit(1);
});
