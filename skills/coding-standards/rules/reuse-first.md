# Reuse First — Extend, Don't Reinvent

## Core Belief

The component, type, or constant you need probably already exists. Your job is to find it, not create a new one.

## The Reuse Hierarchy (check in this order)

```
1. Does an IDENTICAL thing already exist?
   -> Import and use it. Done.

2. Does a SIMILAR thing exist that covers 70%+ of the need?
   -> Add a variant, prop, or field to the existing one.
      Never fork it into a new file.

3. Can you COMPOSE existing pieces?
   -> Card + Badge + Button = new card layout (not a new component)
   -> SectionWrapper + SectionHeading + custom content = new section

4. Nothing fits?
   -> THEN create something new.
      But first: is it a brick (DLS) or a building (app-specific)?
```

## Adding a Variant vs Creating a New Component

```typescript
// WRONG: New file for a visual variation
// components/ui/accent-badge.tsx
function AccentBadge({ color, children }) { ... }

// RIGHT: Add variant to existing Badge CVA
// In badge.tsx, add to variants:
"accent-navy": "bg-navy text-white font-serif italic ...",
```

A well-designed component with 20 variants is better than 20 separate components.

## Composing Instead of Creating

```typescript
// WRONG: New component that reimplements Card styling
function FeatureCard({ icon, title, description }) {
  return (
    <div className="rounded-card border border-border p-7 bg-surface shadow-card">
      ...
    </div>
  )
}

// RIGHT: Compose existing Card
<Card>
  <CardHeader>
    <div className="mb-1">{icon}</div>
    <CardTitle>{title}</CardTitle>
    <CardDescription>{description}</CardDescription>
  </CardHeader>
</Card>
```

## The Building Brick Philosophy

Components are generic building materials. Business logic lives in composition.

| Wrong (business-driven) | Right (building brick) | Why |
|---|---|---|
| `LoginCard` | `Card` + form inside | Login is a use case, Card is a brick |
| `WorkshopStatusBadge` | `Badge variant="outline"` | Workshop is a domain, Badge is a brick |
| `CourseProgressBar` | `Progress` with course data | Course is context, Progress is a brick |
| `PricingToggle` | `Switch` with pricing labels | Pricing is a page, Switch is a brick |
| `AdminUserTable` | `Table` + domain columns | Admin is a domain, Table is a brick |

### When Domain-Specific Components ARE Okay

A component becomes app-specific when it:
1. Composes 3+ DLS bricks into a domain pattern used in multiple places
2. Contains domain logic (data transformation, conditional rendering by role)
3. Is NOT reusable outside its domain

These live in `apps/.../components/{domain}/`.

**The test:** Could you rename this component and use it in a different domain?
- Yes -> too generic, should be in DLS or composed inline
- No -> domain-specific, belongs in `components/{domain}/`

## Duplicate Styling Detection

The agent/linter must flag when someone re-implements DLS patterns inline:

```typescript
// This IS a Card:
<div className="rounded-[24px] border border-[#E8DCC8] bg-white shadow-sm p-7">
// -> Use <Card><CardContent>{children}</CardContent></Card>

// This IS a SectionWrapper:
<section className="py-20 bg-[#FFF8E7]">
// -> Use <SectionWrapper bg="cream">

// This IS a Badge:
<span className="inline-flex items-center rounded-full bg-[#E8F0D8] px-2.5 py-1 text-xs font-semibold">
// -> Use <Badge variant="default">{label}</Badge>
```

## Know Your Inventory

Before creating anything, scan the project's component library:

```bash
# List all existing components
ls packages/dls/src/components/ui/          # UI primitives
ls packages/dls/src/components/layout/      # Layout components
ls packages/dls/src/components/sections/    # Section/LP components
ls packages/dls/src/hooks/                  # Animation/behavior hooks
ls apps/*/src/components/                   # App-specific compositions
ls apps/*/src/hooks/                        # App hooks
```

The specific inventory depends on the project. Check the project's CLAUDE.md or DLS package for the full list. The point is: **always search before creating.**

## "Already Exists" Search Patterns

| New file pattern | Likely exists as |
|---|---|
| `*-badge.tsx`, `*-tag.tsx`, `*-chip.tsx` | Badge (22 variants) |
| `*-card.tsx` with rounded/border/shadow | Card compound component |
| `*-button.tsx`, `*-cta.tsx` | Button (5 variants, 4 sizes) |
| `*-heading.tsx`, `*-title.tsx` | SectionHeading, ChapterHeading, HeroHeadline, CardTitle |
| `*-modal.tsx`, `*-popup.tsx` | Dialog, Sheet, AlertDialog |
| `*-section.tsx` without SectionWrapper | Should use SectionWrapper |
| `*-loader.tsx`, `*-spinner.tsx` | Skeleton, Progress, GoldenArc |
| `*-tabs.tsx` | Tabs, PlatformTabs |
| `*-quote.tsx` | EditorialQuote, PullQuote, SectionDividerQuote |
| `use-animation-*.ts` | 19 existing animation hooks |
| Any `useState + useEffect + fetch` | Should use Convex useQuery or Server Component |
