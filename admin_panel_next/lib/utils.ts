export const AVATAR_COLORS = [
  '#22c55e','#6366f1','#f59e0b','#06b6d4',
  '#ec4899','#8b5cf6','#14b8a6','#f97316',
];

export function avatarColor(name: string): string {
  let h = 0;
  for (const c of String(name)) h = c.charCodeAt(0) + ((h << 5) - h);
  return AVATAR_COLORS[Math.abs(h) % AVATAR_COLORS.length];
}

export function initials(name: string): string {
  return name ? name.charAt(0).toUpperCase() : '?';
}

export function relTime(ts: number): string {
  const d = Date.now() - ts;
  if (d < 60000)    return 'just now';
  if (d < 3600000)  return `${Math.round(d / 60000)}m ago`;
  if (d < 86400000) return `${Math.round(d / 3600000)}h ago`;
  return `${Math.round(d / 86400000)}d ago`;
}

export function fmtTime(ts: number): string {
  return new Date(ts).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

export function cap(s: string): string {
  return s ? s.charAt(0).toUpperCase() + s.slice(1) : '—';
}

export function tsToDate(ts: unknown): string {
  if (!ts) return '—';
  try {
    const t = ts as { toDate?: () => Date; seconds?: number };
    const d = t.toDate ? t.toDate() : t.seconds ? new Date(t.seconds * 1000) : new Date(ts as string);
    return d.toISOString().split('T')[0];
  } catch { return '—'; }
}

export function greeting(): string {
  const h = new Date().getHours();
  return h < 12 ? 'morning' : h < 17 ? 'afternoon' : 'evening';
}

export function formatCurrency(n: number): string {
  return `Rs ${Number(n).toLocaleString()}`;
}

export function todayString(): string {
  return new Date().toLocaleDateString('en-GB', {
    weekday: 'short', day: 'numeric', month: 'long', year: 'numeric',
  });
}
