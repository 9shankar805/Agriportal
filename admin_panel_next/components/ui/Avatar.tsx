'use client';
import { useState } from 'react';
import { avatarColor, initials } from '@/lib/utils';

interface AvatarProps {
  name: string;
  photoUrl?: string | null;
  size?: number;
  radius?: string;
  className?: string;
}

export default function Avatar({ name, photoUrl, size = 36, radius = '50%', className = '' }: AvatarProps) {
  const [imgError, setImgError] = useState(false);

  if (photoUrl && !imgError) {
    return (
      <img
        src={photoUrl}
        alt={name}
        onError={() => setImgError(true)}
        className={`object-cover flex-shrink-0 ${className}`}
        style={{ width: size, height: size, borderRadius: radius }}
        aria-label={name}
      />
    );
  }

  return (
    <div
      className={`flex items-center justify-center font-bold text-white flex-shrink-0 ${className}`}
      style={{ width: size, height: size, borderRadius: radius, background: avatarColor(name), fontSize: size * 0.38 }}
      aria-label={name}
    >
      {initials(name)}
    </div>
  );
}
