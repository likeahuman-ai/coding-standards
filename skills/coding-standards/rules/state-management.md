# State Management

## The Decision Matrix — Where Does State Live?

```
What kind of state is it?

Server/database state (users, courses, orders)
  -> Convex useQuery / useMutation (real-time, reactive)
  -> OR TanStack React Query (REST/GraphQL APIs)
  -> NEVER useState + useEffect + fetch

URL state (filters, tabs, search, pagination, sort)
  -> useSearchParams() / URL query params
  -> Keep UI linkable — if a user shares the URL, they see the same view
  -> NEVER useState for anything that should survive a page refresh

Client UI state (sidebar open, modal visible, theme, toast queue)
  -> Simple: useState in the component that owns it
  -> Shared across components: Zustand store
  -> NEVER prop drill past 2 levels

Form state (input values, validation, dirty/touched)
  -> React Hook Form + Zod
  -> FormProvider + useFormContext for nested form components
  -> NEVER manual useState per field

Derived state (totals, filtered lists, computed values)
  -> Compute during render — NO useState + useEffect
  -> useMemo only if computation is expensive AND profiling confirms it
```

## Zustand — The Default Client Store

### Store Design

```typescript
// src/stores/use-sidebar-store.ts
import { create } from "zustand"

interface SidebarState {
  isCollapsed: boolean
  toggle: () => void
  setCollapsed: (collapsed: boolean) => void
}

export const useSidebarStore = create<SidebarState>((set) => ({
  isCollapsed: false,
  toggle: () => set((state) => ({ isCollapsed: !state.isCollapsed })),
  setCollapsed: (collapsed) => set({ isCollapsed: collapsed }),
}))
```

### Rules

- **One store per concern** — not one giant store. `useSidebarStore`, `useThemeStore`, `useToastStore`
- **Actions inside the store** — not in components
- **Selectors for performance** — `useSidebarStore(state => state.isCollapsed)` not `useSidebarStore()`
- **No server state in Zustand** — server data belongs in Convex useQuery or React Query
- **Persist middleware** for state that should survive refresh (theme, preferences)

```typescript
import { persist } from "zustand/middleware"

export const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      theme: "light" as "light" | "dark",
      setTheme: (theme) => set({ theme }),
    }),
    { name: "theme-storage" }
  )
)
```

### When NOT to Use Zustand

- Data from the database -> Convex useQuery / React Query
- URL-representable state -> useSearchParams
- Form state -> React Hook Form
- State used by a single component -> useState
- Derived values -> compute during render

## URL State — Keep UI Linkable

```typescript
"use client"
import { useSearchParams, useRouter, usePathname } from "next/navigation"

function FilteredList() {
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const activeTab = searchParams.get("tab") ?? "all"
  const search = searchParams.get("q") ?? ""

  function setFilter(key: string, value: string) {
    const params = new URLSearchParams(searchParams.toString())
    if (value) params.set(key, value)
    else params.delete(key)
    router.replace(`${pathname}?${params.toString()}`)
  }

  return (
    <Tabs value={activeTab} onValueChange={(v) => setFilter("tab", v)}>
      ...
    </Tabs>
  )
}
```

**Rule:** If a user should be able to share or bookmark the current view, the state belongs in the URL.

## Server State — Convex vs React Query

### Convex (default for Convex projects)

```typescript
// Reading — reactive, auto-updates via WebSocket
const courses = useQuery(api.courses.listPublished)

// Writing — optimistic by default
const createCourse = useMutation(api.courses.create)
await createCourse({ title: "New Course" })

// Paginated
const { results, status, loadMore } = usePaginatedQuery(
  api.courses.listPaginated,
  {},
  { initialNumItems: 25 }
)
```

### TanStack React Query (for REST/GraphQL APIs)

```typescript
// Reading
const { data, isLoading, error } = useQuery({
  queryKey: ["courses"],
  queryFn: () => fetch("/api/courses").then(r => r.json()),
  staleTime: 5 * 60 * 1000, // 5 minutes
})

// Writing with optimistic update
const mutation = useMutation({
  mutationFn: (data) => fetch("/api/courses", { method: "POST", body: JSON.stringify(data) }),
  onMutate: async (newCourse) => {
    await queryClient.cancelQueries({ queryKey: ["courses"] })
    const previous = queryClient.getQueryData(["courses"])
    queryClient.setQueryData(["courses"], (old) => [...old, newCourse])
    return { previous }
  },
  onError: (err, newCourse, context) => {
    queryClient.setQueryData(["courses"], context.previous) // rollback
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ["courses"] })
  },
})
```

## Optimistic Updates — Always

UI reacts immediately, rolls back on failure:

1. Update UI optimistically (instant feedback)
2. Send mutation to server
3. On success: server state catches up, UI already correct
4. On failure: rollback + toast with explanation

```typescript
// Convex handles this automatically — mutations are optimistic by default
// React Query needs manual onMutate/onError (see above)
```

## Hydration & SSR

```typescript
// Server Component fetches, Client Component receives as props
// src/app/(platform)/learn/page.tsx (Server)
export default async function LearnPage() {
  const courses = await fetchQuery(api.courses.listPublished)
  return <CourseList initialCourses={courses} />
}

// components/course/course-list.tsx (Client)
"use client"
function CourseList({ initialCourses }: { initialCourses: Course[] }) {
  // Real-time updates after hydration
  const courses = useQuery(api.courses.listPublished) ?? initialCourses
  return courses.map(c => <CourseCard key={c._id} course={c} />)
}
```

## Anti-Patterns

| Wrong | Right | Why |
|---|---|---|
| `useState` + `useEffect` + `fetch()` | Convex `useQuery` or React Query | Manual fetching = no cache, no dedup, no retry |
| Giant Zustand store with server data | Separate stores per concern | Server state has different lifecycle than UI state |
| `useState` for URL-representable state | `useSearchParams()` | Not linkable, lost on refresh |
| Prop drilling form context 3 levels | `FormProvider` + `useFormContext` | Coupling, verbosity, maintenance |
| `useEffect` to sync derived state | Compute during render | Unnecessary re-render cycle |
| `useMemo` everywhere "just in case" | Only after profiling confirms need | Premature optimization adds complexity |
| Zustand for single-component state | `useState` | Over-engineering |
