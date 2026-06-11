const VARIANTS: Record<string, string> = {
  farmer:    'bg-green-100 text-green-700 border border-green-200',
  landOwner: 'bg-violet-100 text-violet-700 border border-violet-200',
  verified:  'bg-green-100 text-green-700 border border-green-200',
  pending:   'bg-amber-100  text-amber-700  border border-amber-200',
  rejected:  'bg-red-100   text-red-700   border border-red-200',
  active:    'bg-green-100 text-green-700 border border-green-200',
  inactive:  'bg-gray-100  text-gray-500  border border-gray-200',
  approved:  'bg-green-100 text-green-700 border border-green-200',
  open:      'bg-amber-100  text-amber-700  border border-amber-200',
  resolved:  'bg-green-100 text-green-700 border border-green-200',
  default:   'bg-gray-100  text-gray-500  border border-gray-200',
};

interface BadgeProps {
  variant?: string;
  children: React.ReactNode;
  className?: string;
}

export default function Badge({ variant = 'default', children, className = '' }: BadgeProps) {
  const cls = VARIANTS[variant] || VARIANTS.default;
  return (
    <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold ${cls} ${className}`}>
      {children}
    </span>
  );
}
