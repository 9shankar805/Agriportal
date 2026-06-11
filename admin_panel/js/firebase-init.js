/**
 * firebase-init.js  — AgriPortal Admin Panel
 * Initialises Firebase and exposes services on window.FB.*
 * Fires "firebaseReady" on window when done.
 */
import { initializeApp }
  from "https://www.gstatic.com/firebasejs/10.14.1/firebase-app.js";
import {
  getAuth,
  signInWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
  signOut,
  onAuthStateChanged,
} from "https://www.gstatic.com/firebasejs/10.14.1/firebase-auth.js";
import {
  getDatabase,
  ref,
  onValue,
  query,
  orderByChild,
  limitToLast,
  push,
  set,
  update,
  remove,
} from "https://www.gstatic.com/firebasejs/10.14.1/firebase-database.js";
import {
  getFirestore,
  collection,
  doc,
  getDocs,
  getDoc,
  addDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  query  as fsQuery,
  where,
  orderBy,
  limit,
  onSnapshot,
  serverTimestamp,
} from "https://www.gstatic.com/firebasejs/10.14.1/firebase-firestore.js";

/* ── Firebase project config (agriportal-9ee3d — AgriPortalApp) ────────── */
const CONFIG = {
  apiKey:            "AIzaSyAwR5a3W2jZEzB0Piz5Qc7oP_aTFwdVYRA",
  authDomain:        "agriportal-9ee3d.firebaseapp.com",
  databaseURL:       "https://agriportal-9ee3d-default-rtdb.firebaseio.com",
  projectId:         "agriportal-9ee3d",
  storageBucket:     "agriportal-9ee3d.firebasestorage.app",
  messagingSenderId: "312069394942",
  appId:             "1:312069394942:web:08d4b4026fbafa425cf0af",
  measurementId:     "G-PVRLBRKXZ4",
};

const app = initializeApp(CONFIG);

/* ── Expose a single namespace ── */
window.FB = {
  auth:      getAuth(app),
  db:        getDatabase(app),
  fs:        getFirestore(app),

  // Auth helpers
  signIn:         (email, pw) => signInWithEmailAndPassword(getAuth(app), email, pw),
  signInGoogle:   ()          => signInWithPopup(getAuth(app), new GoogleAuthProvider()),
  signOut:        ()          => signOut(getAuth(app)),
  onAuth:         (cb)        => onAuthStateChanged(getAuth(app), cb),

  // Realtime DB helpers
  rtRef:     (path)      => ref(getDatabase(app), path),
  rtOnValue: onValue,
  rtQuery:   query,
  rtOrderBy: orderByChild,
  rtLimit:   limitToLast,
  rtPush:    push,
  rtSet:     set,
  rtUpdate:  update,
  rtRemove:  remove,

  // Firestore helpers
  col:       (name)      => collection(getFirestore(app), name),
  docRef:    (col, id)   => doc(getFirestore(app), col, id),
  getDocs,
  getDoc,
  addDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  fsQuery,
  where,
  orderBy,
  limit,
  onSnapshot,
  serverTimestamp,
};

console.log("[AgriPortal Admin] Firebase ready — project: agriportal-9ee3d");
window.dispatchEvent(new CustomEvent("firebaseReady"));
