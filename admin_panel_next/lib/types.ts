export interface AppUser {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: 'farmer' | 'landOwner';
  kycStatus: 'pending' | 'verified' | 'rejected';
  kycDocuments?: { citizenshipFront?: string; citizenshipBack?: string; selfie?: string } | null;
  kycAddress?: { street?: string; city?: string; district?: string; province?: string } | null;
  isActive: boolean;
  joined: string;
}

export interface Land {
  id: string;
  title: string;
  owner: string;
  ownerId?: string;
  location: string;
  province: string;
  area: number;
  price: number;
  status: 'active' | 'pending' | 'inactive';
  description?: string;
  images?: string[];
}

export interface Application {
  id: string;
  applicant: string;
  applicantId?: string;
  land: string;
  landId?: string;
  owner: string;
  applied: string;
  status: 'pending' | 'approved' | 'rejected';
  message?: string;
}

export interface Conversation {
  id: string;
  aId?: string;
  bId?: string;
  aName: string;
  bName: string;
  land: string;
  lastMsg: string;
  ts: number;
  msgs: Message[];
}

export interface Message {
  key?: string;
  from?: string;
  senderId?: string;
  senderName?: string;
  text: string;
  ts?: number;
  timestamp?: number;
}

export interface SupportMessage {
  id: string;
  name: string;
  email: string;
  category: string;
  message: string;
  status: 'open' | 'resolved';
  uid?: string | null;
  createdAt: string;
  ts: number;
}
