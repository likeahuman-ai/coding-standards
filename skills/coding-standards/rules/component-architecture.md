# Component Architecture

## The Standard Component Skeleton

```typescript
// kebab-case-name.tsx

// Imports: React/Next -> External libs -> DLS/Internal -> Types
import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "../../lib/utils"       // DLS: relative
import { cn } from "@likeahuman-ai/dls/utils" // App: package path
import { cn } from "@/lib/utils"           // App: alias

// CVA variants (if component has variants)
const buttonVariants = cva(
  "base classes as single string",
  {
    variants: { ... },
    defaultVariants: { ... },
    compoundVariants: [ ... ],  // only for size x variant overrides
  }
)

// Component — function declaration, NOT arrow function
function Button({
  className,
  variant = "primary",
  size = "default",
  asChild = false,
  ...props
}: React.ComponentProps<"button"> &
  VariantProps<typeof buttonVariants> & {
    asChild?: boolean
  }) {
  return (
    <button
      data-slot="button"
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  )
}

// Named exports — ALWAYS. Export variant function too.
export { Button, buttonVariants }
```

## Props Interface — The 3 Patterns

### Pattern A: Inline Composition (most common, DLS components)

```typescript
function Badge({
  className, variant, icon, onRemove, ...props
}: React.ComponentProps<"span"> &
  VariantProps<typeof badgeVariants> & {
    icon?: React.ReactNode
    onRemove?: () => void
  })
```

### Pattern B: Omit for Conflicts

```typescript
function Checkbox({
  checked, onChange, label, ...props
}: {
  checked?: boolean
  onChange?: (checked: boolean) => void
  label?: string
} & Omit<React.ComponentProps<"div">, "onChange">)
```

### Pattern C: Data-Driven Sections (landing page components)

```typescript
function FAQSection({
  label, heading, items, className, ...props
}: {
  label?: string
  heading: string
  items: FAQEntry[]
} & Omit<React.ComponentProps<"section">, "children">)
```

### Rules for All Props

- Never `interface XProps` as a separate declaration — inline in function signature
- Always spread `...props` onto the root element
- Always accept `className` for style extension
- Destructure with defaults in signature, not inside body

## Compound Components

Sub-components are sibling functions in the same file, NOT dot-notation:

```typescript
function Card({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="card" className={cn("rounded-card border ...", className)} {...props} />
}

function CardHeader({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="card-header" className={cn("flex flex-col gap-1.5 p-7", className)} {...props} />
}

function CardTitle({ className, ...props }: React.ComponentProps<"h3">) {
  return <h3 data-slot="card-title" className={cn("font-serif text-xl", className)} {...props} />
}

export { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter }
```

For shared state across sub-components, use React Context:

```typescript
const TabsContext = React.createContext<TabsContextValue | null>(null)

function useTabsContext() {
  const context = React.use(TabsContext)  // React 19
  if (!context) throw new Error("Must be used within <Tabs>")
  return context
}
```

## CVA — When and How

| Situation | Pattern |
|---|---|
| 3+ visual variants | CVA with `variants` object |
| Size x variant combos need overrides | Add `compoundVariants` |
| 1-2 conditional classes | `cn(condition && "class")` |
| Boolean toggle | `cn(isActive ? "bg-navy" : "bg-surface")` inside `cn()` |

Export the variants function alongside the component — consumers need it for `asChild` patterns.

## forwardRef — Only When Needed

- DLS layout components needing DOM refs (Navbar, Sidebar): use `React.forwardRef` + `displayName`
- DLS UI components (Button, Card, Badge): no forwardRef, use `React.ComponentProps<"element">`
- App components: never forwardRef

## File Size Limits

| Type | Ideal | Max | Hard limit |
|---|---|---|---|
| UI component | <60 lines | 100 lines | 200 lines |
| Section component | <100 lines | 150 lines | 250 lines |
| Page | <150 lines | 200 lines | 250 lines |

When exceeding: extract sub-components, hooks, constants, or types.

## Data Attributes

Use `data-slot` on root elements for styling hooks and testing:

```typescript
<button data-slot="button" data-variant={variant} ... />
<div data-slot="card-header" ... />
```
