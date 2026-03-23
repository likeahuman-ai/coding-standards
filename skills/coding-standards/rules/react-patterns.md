# React & Next.js Patterns

## Server vs Client Components

- **Server Components are the default** — no `"use client"` unless required
- `"use client"` ONLY when: hooks, event handlers, browser APIs, or third-party client libs
- Never mix server-only logic (db calls, env secrets) into `"use client"` files
- Fetch data in async Server Components — don't defer to client-side when SSR works
- Use `<Suspense>` boundaries for streaming and progressive hydration
- Client components should be leaf nodes of the component tree

## Hook Rules

### useEffect — ONLY for:
- Event listeners (`addEventListener`)
- Third-party library initialization
- Window/DOM interactions
- Timers/intervals

### useEffect NEVER for:
- **Derived state** — if state B depends on state A, compute B during render
- **Data fetching** — use Server Components or Convex `useQuery`
- **Syncing state** — if `useState` + `useEffect` + `setState`, refactor

```typescript
// WRONG: useEffect for derived state
const [items, setItems] = useState([])
const [total, setTotal] = useState(0)
useEffect(() => { setTotal(items.reduce((sum, i) => sum + i.price, 0)) }, [items])

// RIGHT: compute during render
const total = items.reduce((sum, i) => sum + i.price, 0)
```

### Other hook rules:
- Max 3 `useEffect` calls per component — if more, split the component
- Don't wrap everything in `useCallback`/`useMemo` without profiling
- `useCallback`/`useMemo` only useful when child has `React.memo`
- `useTransition` for non-urgent state updates
- `useDeferredValue` for expensive renders

## Data Fetching Decision

```
Where does the data come from?
  Convex database -> useQuery(api.module.function) (real-time, reactive)
  External API on page load -> Server Component with async fetch
  External API on interaction -> Convex action or API route
  Static/rarely-changing -> ISR with revalidate in Server Component
```

```typescript
// Marketing pages — ISR (cached, revalidated)
export const revalidate = 300 // 5 minutes
export default async function LandingPage() {
  const courses = await fetchQuery(api.courses.listPublished)
  return <LandingContent courses={courses} />
}

// Platform pages — real-time
"use client"
export default function Dashboard() {
  const progress = useQuery(api.lessonProgress.getMyProgress)
  return <DashboardContent progress={progress} />
}
```

## Component Architecture

- Named exports only (except Next.js page/layout)
- No barrel files (`index.ts` re-exports)
- Semantic HTML (`section`, `article`, `nav`, `button`) — not div soup
- Components should be dumb — input/output, pure rendering
- Data fetching happens in pages or hooks, not inside components

## Anti-Patterns to Block

- `export default` in non-page files
- More than 3 `useEffect` in one component
- `useCallback`/`useMemo` without `React.memo` on children
- Prop drilling: `watch`, `setValue`, `errors`, `register` through levels
- Raw `<img>` tags — use `next/image` `<Image />`
- `"use client"` on components without hooks/events/browser APIs
- `useEffect` + `fetch()` pattern
