# Tailwind → concrete value map

Convert Tailwind utility class names (from the frequency report) into the hex / rem / px values DESIGN.md requires. Only look up the values that actually appear in the report.

> **v3 vs v4:** Tailwind v4 defines colors in OKLCH; the hex below (Tailwind v3 defaults) are visually near-identical and are a fine canonical representation for DESIGN.md. If the project defines custom colors in `@theme` or `tailwind.config`, those override these defaults — always prefer the project's own values.

## Table of Contents
- [Opacity modifiers](#opacity-modifiers)
- [Font sizes](#font-sizes-text-)
- [Font weights](#font-weights-font-)
- [Border radius](#border-radius-rounded-)
- [Spacing](#spacing-p--m--gap--etc)
- [Color palette](#color-palette)

## Opacity modifiers
`bg-red-500/20` = base color at 20% alpha. Express in DESIGN.md as 8-digit hex (`#RRGGBBAA`) — e.g. `red-500/20` → `#EF444433` (0x33 ≈ 20%). Common alphas: `/10`→`1A`, `/20`→`33`, `/40`→`66`, `/50`→`80`, `/60`→`99`.

## Font sizes (`text-*`)
Format: class → fontSize / default lineHeight (unitless).
- `text-xs` → 0.75rem / 1.33
- `text-sm` → 0.875rem / 1.43
- `text-base` → 1rem / 1.5
- `text-lg` → 1.125rem / 1.56
- `text-xl` → 1.25rem / 1.4
- `text-2xl` → 1.5rem / 1.33
- `text-3xl` → 1.875rem / 1.2
- `text-4xl` → 2.25rem / 1.11
- `text-5xl` → 3rem / 1
- `text-6xl` → 3.75rem / 1

## Font weights (`font-*`)
thin 100 · extralight 200 · light 300 · normal 400 · medium 500 · semibold 600 · bold 700 · extrabold 800 · black 900

## Border radius (`rounded-*`)
- `rounded-none` → 0
- `rounded-sm` → 2px (0.125rem)
- `rounded` → 4px (0.25rem)
- `rounded-md` → 6px (0.375rem)
- `rounded-lg` → 8px (0.5rem)
- `rounded-xl` → 12px (0.75rem)
- `rounded-2xl` → 16px (1rem)
- `rounded-3xl` → 24px (1.5rem)
- `rounded-full` → 9999px

## Spacing (`p-*`, `m-*`, `gap-*`, etc.)
Base unit = 0.25rem = 4px. value × 4 = px.
- `0`→0 · `0.5`→2px · `1`→4px · `1.5`→6px · `2`→8px · `2.5`→10px · `3`→12px · `3.5`→14px · `4`→16px · `5`→20px · `6`→24px · `7`→28px · `8`→32px · `10`→40px · `12`→48px · `16`→64px · `20`→80px · `24`→96px

## Color palette
Each family: `50 100 200 300 400 500 600 700 800 900 950`.

**gray**: f9fafb f3f4f6 e5e7eb d1d5db 9ca3af 6b7280 4b5563 374151 1f2937 111827 030712
**slate**: f8fafc f1f5f9 e2e8f0 cbd5e1 94a3b8 64748b 475569 334155 1e293b 0f172a 020617
**zinc**: fafafa f4f4f5 e4e4e7 d4d4d8 a1a1aa 71717a 52525b 3f3f46 27272a 18181b 09090b
**neutral**: fafafa f5f5f5 e5e5e5 d4d4d4 a3a3a3 737373 525252 404040 262626 171717 0a0a0a
**stone**: fafaf9 f5f5f4 e7e5e4 d6d3d1 a8a29e 78716c 57534e 44403c 292524 1c1917 0c0a09
**red**: fef2f2 fee2e2 fecaca fca5a5 f87171 ef4444 dc2626 b91c1c 991b1b 7f1d1d 450a0a
**orange**: fff7ed ffedd5 fed7aa fdba74 fb923c f97316 ea580c c2410c 9a3412 7c2d12 431407
**amber**: fffbeb fef3c7 fde68a fcd34d fbbf24 f59e0b d97706 b45309 92400e 78350f 451a03
**yellow**: fefce8 fef9c3 fef08a fde047 facc15 eab308 ca8a04 a16207 854d0e 713f12 422006
**lime**: f7fee7 ecfccb d9f99d bef264 a3e635 84cc16 65a30d 4d7c0f 3f6212 365314 1a2e05
**green**: f0fdf4 dcfce7 bbf7d0 86efac 4ade80 22c55e 16a34a 15803d 166534 14532d 052e16
**emerald**: ecfdf5 d1fae5 a7f3d0 6ee7b7 34d399 10b981 059669 047857 065f46 064e3b 022c22
**teal**: f0fdfa ccfbf1 99f6e4 5eead4 2dd4bf 14b8a6 0d9488 0f766e 115e59 134e4a 042f2e
**cyan**: ecfeff cffafe a5f3fc 67e8f9 22d3ee 06b6d4 0891b2 0e7490 155e75 164e63 083344
**sky**: f0f9ff e0f2fe bae6fd 7dd3fc 38bdf8 0ea5e9 0284c7 0369a1 075985 0c4a6e 082f49
**blue**: eff6ff dbeafe bfdbfe 93c5fd 60a5fa 3b82f6 2563eb 1d4ed8 1e40af 1e3a8a 172554
**indigo**: eef2ff e0e7ff c7d2fe a5b4fc 818cf8 6366f1 4f46e5 4338ca 3730a3 312e81 1e1b4b
**violet**: f5f3ff ede9fe ddd6fe c4b5fd a78bfa 8b5cf6 7c3aed 6d28d9 5b21b6 4c1d95 2e1065
**purple**: faf5ff f3e8ff e9d5ff d8b4fe c084fc a855f7 9333ea 7e22ce 6b21a8 581c87 3b0764
**fuchsia**: fdf4ff fae8ff f5d0fe f0abfc e879f9 d946ef c026d3 a21caf 86198f 701a75 4a044e
**pink**: fdf2f8 fce7f3 fbcfe8 f9a8d4 f472b6 ec4899 db2777 be185d 9d174d 831843 500724
**rose**: fff1f2 ffe4e6 fecdd3 fda4af fb7185 f43f5e e11d48 be123c 9f1239 881337 4c0519

**white** = #FFFFFF · **black** = #000000

Example: `bg-gray-800` → `#1F2937`; `text-blue-400` → `#60A5FA`; `border-zinc-700` → `#3F3F46`.
