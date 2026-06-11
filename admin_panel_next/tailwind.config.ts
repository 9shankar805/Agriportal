import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './context/**/*.{js,ts,jsx,tsx,mdx}',
    './lib/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      colors: {
        green: {
          dark:  '#1b5e20',
          mid:   '#2e7d32',
          light: '#4caf50',
          pale:  '#e8f5e9',
        },
      },
      borderRadius: {
        xl:  '12px',
        '2xl': '16px',
      },
      boxShadow: {
        sm: '0 1px 4px rgba(0,0,0,.06), 0 2px 8px rgba(0,0,0,.04)',
        md: '0 4px 16px rgba(0,0,0,.08), 0 1px 4px rgba(0,0,0,.04)',
        xl: '0 16px 48px rgba(0,0,0,.14)',
      },
    },
  },
  plugins: [],
};

export default config;
