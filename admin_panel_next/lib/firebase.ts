import { initializeApp, getApps } from 'firebase/app';
import {
  getAuth,
  signInWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
  signOut,
  onAuthStateChanged,
  User,
} from 'firebase/auth';
import {
  getFirestore,
  collection,
  doc,
  getDocs,
  getDoc,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
  onSnapshot,
  serverTimestamp,
  QueryConstraint,
} from 'firebase/firestore';
import {
  getDatabase,
  ref,
  onValue,
  query as rtQuery,
  orderByChild,
  push,
  update,
  remove,
} from 'firebase/database';

const firebaseConfig = {
  apiKey:            'AIzaSyAwR5a3W2jZEzB0Piz5Qc7oP_aTFwdVYRA',
  authDomain:        'agriportal-9ee3d.firebaseapp.com',
  databaseURL:       'https://agriportal-9ee3d-default-rtdb.firebaseio.com',
  projectId:         'agriportal-9ee3d',
  storageBucket:     'agriportal-9ee3d.firebasestorage.app',
  messagingSenderId: '312069394942',
  appId:             '1:312069394942:web:08d4b4026fbafa425cf0af',
  measurementId:     'G-PVRLBRKXZ4',
};

const app = getApps().length ? getApps()[0] : initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db   = getFirestore(app);
export const rtdb = getDatabase(app);

// Auth helpers
export const signIn         = (email: string, pw: string) => signInWithEmailAndPassword(auth, email, pw);
export const signInGoogle   = () => signInWithPopup(auth, new GoogleAuthProvider());
export const logOut         = () => signOut(auth);
export const onAuth         = (cb: (u: User | null) => void) => onAuthStateChanged(auth, cb);

// Firestore helpers
export {
  collection, doc, getDocs, getDoc, addDoc, updateDoc, deleteDoc,
  query, where, orderBy, limit, onSnapshot, serverTimestamp,
};
export type { QueryConstraint };

// RTDB helpers
export { ref as rtRef, onValue as rtOnValue, rtQuery, orderByChild, push as rtPush, update as rtUpdate, remove as rtRemove };
