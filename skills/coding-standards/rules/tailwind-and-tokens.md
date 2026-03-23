# Tailwind CSS & Design Tokens

> **Scope:** This file applies to projects using Tailwind CSS. If your project uses CSS modules, styled-components, or another styling approach, the design token principles still apply (use semantic tokens, not hardcoded values) but the Tailwind-specific patterns (cn(), CVA) don't.

## className Rules — Non-Negotiable

### Always use `cn()` for conditional classes

```typescript
// WRONG: template literal
className={`text-lg ${isActive ? "font-bold" : ""}`}

// WRONG: raw clsx (no Tailwind conflict resolution)
className={clsx("text-lg", isActive && "font-bold")}

// RIGHT: cn() from @likeahuman-ai/dls/utils (wraps clsx + tailwind-merge)
className={cn("text-lg", isActive && "font-bold")}
```

### CVA for 3+ variants

```typescript
// If a component accepts variant/size props with 3+ options -> CVA
const cardVariants = cva("base-classes", {
  variants: { variant: { default: "...", elevated: "...", outlined: "..." } },
  defaultVariants: { variant: "default" },
})
```

### Never use dynamic class construction

```typescript
// WRONG: Tailwind can't detect these at build time
className={`bg-${color}-500`}
className={`text-[${size}px]`}

// RIGHT: complete class names
className={cn(
  color === "navy" && "bg-navy",
  color === "cream" && "bg-cream",
)}
```

## Design Token Rules — Non-Negotiable

### Colors — Semantic Tokens Only

ALL colors must use semantic Tailwind tokens (`bg-primary`, `text-destructive`, `border-muted`). NEVER hardcode hex values in component files.

- Define actual color values in CSS variables / `tailwind.config.ts` / `tokens.css` ONLY
- Components reference semantic names: `bg-surface`, `text-text-primary`, `border-border`
- Dark mode works by swapping CSS variable values — components never reference light/dark directly
- Every project establishes its color palette in token files during DLS setup

**Project-specific color catalogs belong in the project's CLAUDE.md or a project-level token reference — not here.**

Hex values are ONLY allowed in: `tokens.css`, `theme.css`, `tailwind.config.ts`.

### Typography Scale — Mandatory

All font sizes MUST be from this scale. No arbitrary sizes:

`12 — 14 — 16 — 18 — 20 — 24 — 28 — 32 — 36 — 40 — 48 — 56 — 64`

Tailwind mappings: `text-xs`(12), `text-sm`(14), `text-base`(16), `text-lg`(18), `text-xl`(20), `text-2xl`(24), `text-[28px]`, `text-[32px]`, `text-4xl`(36), `text-[40px]`, `text-5xl`(48), `text-[56px]`, `text-[64px]`

### Spacing Scale — 4px Rhythm

All spacing (margin, padding, gap) uses multiples of 4px:

`4 — 8 — 12 — 16 — 20 — 24 — 32 — 40 — 48 — 64`

### Radii Tokens

| Token | Value | Usage |
|---|---|---|
| `rounded-pill` | 100px | Buttons, tags |
| `rounded-card` | 24px | Cards, modals |
| `rounded-card-sm` | 20px | Smaller cards, toasts |
| `rounded-input` | 8px | Inputs, selects |
| `rounded-tab` | 14px | Tabs |
| `rounded-alert` | 14px | Alerts, banners |

### Shadow Tokens

- `shadow-button` — Buttons
- `shadow-soft` — Subtle elevation
- `shadow-card` — Cards
- `shadow-thumb` — Toggles, sliders

## Responsive Design Pattern

Mobile-first, each breakpoint on its own line:

```typescript
className={cn(
  "flex flex-col px-5",                    // mobile (default)
  "md:max-w-4xl md:px-8 md:pt-8",         // tablet
  "lg:max-w-[1400px] lg:flex-row lg:px-12" // desktop
)}
```

Never mix breakpoints on one line.

## Card Whitespace Rules

1. **Padding-to-gap ratio (3:1)** — card padding ~3x inner element spacing
2. **Outer > Inner** — space between cards < card padding
3. **Heading asymmetry** — more space below heading than above
4. **Never equal gaps** — if everything has same gap, nothing has hierarchy

### Text Element Spacing

| Relationship | Spacing |
|---|---|
| Label -> Heading | 4-8px |
| Badge -> Heading | 8px |
| Heading -> Subheading | 8px |
| Heading -> Body text | 12px |
| Body -> Body | 12-16px |
| Heading -> Cards/Content | 24-32px |
| Section -> Section | 48-96px |

## Anti-AI-Slop

- No excessive gradients, blurs, opacity stacking
- No animate-everything (spring on every div)
- Animations only for meaningful transitions (enter/exit, state change)
- Max 1 blur/backdrop-filter per viewport
- No generic AI aesthetics
