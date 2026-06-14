'use client';

import { ChevronsUpDown, ChevronUp, ChevronDown } from 'lucide-react';

export type SortDirection = 'asc' | 'desc';

interface SortableHeaderProps {
  label: string;
  column: string;
  activeColumn: string;
  direction: SortDirection;
  onSort: (column: string) => void;
  align?: 'left' | 'center' | 'right';
}

export default function SortableHeader({
  label,
  column,
  activeColumn,
  direction,
  onSort,
  align = 'left',
}: SortableHeaderProps) {
  const active = activeColumn === column;
  const Icon = active ? (direction === 'asc' ? ChevronUp : ChevronDown) : ChevronsUpDown;
  const headingAlign = align === 'right' ? 'text-right' : align === 'center' ? 'text-center' : 'text-left';
  const buttonAlign = align === 'right' ? 'justify-end' : align === 'center' ? 'justify-center' : 'justify-start';

  return (
    <th className={`admin-table-heading ${headingAlign}`}>
      <button
        type="button"
        onClick={() => onSort(column)}
        className={`admin-sort-button ${buttonAlign} ${active ? 'text-green-700' : ''}`}
        aria-label={`Sort by ${label}`}
      >
        <span>{label}</span>
        <Icon size={13} strokeWidth={active ? 2.5 : 1.8} />
      </button>
    </th>
  );
}
