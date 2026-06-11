import type { AppUser, Land, Application, Conversation, SupportMessage } from './types';

export const SEED_USERS: AppUser[] = [
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

export const SEED_LANDS: Land[] = [
  { id:'l1', title:'Fertile Paddy Fields',   owner:'Sita Thapa',      location:'Chitwan',   province:'Bagmati', area:12, price:45000, status:'active'   },
  { id:'l2', title:'Vegetable Garden Plot',  owner:'Bikram Shrestha', location:'Kavre',     province:'Bagmati', area:5,  price:32000, status:'active'   },
  { id:'l3', title:'Apple Orchard Land',     owner:'Anita Rai',       location:'Mustang',   province:'Gandaki', area:20, price:15000, status:'pending'  },
  { id:'l4', title:'Tea Garden Lease',       owner:'Sita Thapa',      location:'Ilam',      province:'Koshi',   area:30, price:20000, status:'active'   },
  { id:'l5', title:'Rice Farmland',          owner:'Laxmi Karki',     location:'Dang',      province:'Lumbini', area:8,  price:28000, status:'pending'  },
  { id:'l6', title:'Maize Growing Plots',    owner:'Bikram Shrestha', location:'Rupandehi', province:'Lumbini', area:15, price:22000, status:'active'   },
  { id:'l7', title:'Wheat Fields — Terai',   owner:'Anita Rai',       location:'Bara',      province:'Madhesh', area:25, price:18000, status:'active'   },
  { id:'l8', title:'Organic Farm Plots',     owner:'Laxmi Karki',     location:'Lalitpur',  province:'Bagmati', area:6,  price:55000, status:'inactive' },
];

export const SEED_APPS: Application[] = [
  { id:'a1', applicant:'Ramesh Sharma',  land:'Fertile Paddy Fields',  owner:'Sita Thapa',      applied:'2024-07-01', status:'approved' },
  { id:'a2', applicant:'Hari Magar',     land:'Tea Garden Lease',      owner:'Sita Thapa',      applied:'2024-07-03', status:'rejected' },
  { id:'a3', applicant:'Dorje Gurung',   land:'Apple Orchard Land',    owner:'Anita Rai',       applied:'2024-07-05', status:'pending'  },
  { id:'a4', applicant:'Puja Tamang',    land:'Vegetable Garden Plot', owner:'Bikram Shrestha', applied:'2024-07-08', status:'pending'  },
  { id:'a5', applicant:'Ram Bahadur KC', land:'Maize Growing Plots',   owner:'Bikram Shrestha', applied:'2024-07-10', status:'approved' },
  { id:'a6', applicant:'Nabin Pokhrel',  land:'Wheat Fields — Terai',  owner:'Anita Rai',       applied:'2024-07-12', status:'pending'  },
];

export const SEED_CONVS: Conversation[] = [
  {
    id:'c1', aName:'Ramesh Sharma', bName:'Sita Thapa',
    land:'Fertile Paddy Fields — Chitwan',
    lastMsg:'The land is available from next month.', ts: Date.now()-3600000,
    msgs:[
      { from:'a', text:'Hello! Is the paddy field still available?', ts: Date.now()-7200000 },
      { from:'b', text:'Yes! What lease duration are you looking for?', ts: Date.now()-6900000 },
      { from:'a', text:'I am looking for a 2-year lease.', ts: Date.now()-6600000 },
      { from:'b', text:'That works. Irrigation is fully functional.', ts: Date.now()-6300000 },
      { from:'b', text:'The land is available from next month.', ts: Date.now()-3600000 },
    ],
  },
  {
    id:'c2', aName:'Dorje Gurung', bName:'Anita Rai',
    land:'Apple Orchard — Mustang',
    lastMsg:'Yes, I can arrange a site visit this weekend.', ts: Date.now()-86400000,
    msgs:[
      { from:'a', text:'I am interested in the apple orchard.', ts: Date.now()-90000000 },
      { from:'b', text:'Great! The soil is very fertile for apples.', ts: Date.now()-89000000 },
      { from:'a', text:'Can we arrange a visit?', ts: Date.now()-88000000 },
      { from:'b', text:'Yes, I can arrange a site visit this weekend.', ts: Date.now()-86400000 },
    ],
  },
  {
    id:'c3', aName:'Puja Tamang', bName:'Bikram Shrestha',
    land:'Vegetable Garden — Kavre',
    lastMsg:'Please submit your KYC first.', ts: Date.now()-172800000,
    msgs:[
      { from:'a', text:'I want to apply for the vegetable plot.', ts: Date.now()-180000000 },
      { from:'b', text:'Please submit your KYC first.', ts: Date.now()-172800000 },
    ],
  },
];

export const SEED_SUPPORT: SupportMessage[] = [
  { id:'s1', name:'Ramesh Sharma', email:'ramesh@email.np', category:'Land Issue', message:'I cannot find my submitted land listing in the app. It was submitted 3 days ago.', status:'open', uid:'u1', createdAt:'2024-07-14', ts: Date.now()-86400000 },
  { id:'s2', name:'Puja Tamang', email:'puja@email.np', category:'KYC Problem', message:'My KYC documents were uploaded but the status still shows pending after 5 days.', status:'open', uid:'u6', createdAt:'2024-07-13', ts: Date.now()-172800000 },
  { id:'s3', name:'Guest User', email:'guest@example.np', category:'General', message:'How do I register as a land owner on AgriPortal?', status:'resolved', uid:null, createdAt:'2024-07-10', ts: Date.now()-432000000 },
];

export const LIVE_FEED_POOL = [
  'New user registered — Sagun Karki',
  'KYC submitted by Maya Bista',
  'New listing added: Tea Garden, Ilam',
  'Message sent by Hari Thapa',
  'KYC approved for Raju Yadav',
  'Application from Sunita Lama',
  'Listing activated: Paddy Fields, Chitwan',
  'New user: Binod Tiwari (Land Owner)',
];
