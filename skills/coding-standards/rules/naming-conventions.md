# Naming Conventions

## Everything Has a Pattern

| Thing | Pattern | Example |
|---|---|---|
| Files (components) | `kebab-case.tsx` | `hero-section.tsx` |
| Files (Convex) | `camelCase.ts` | `lessonProgress.ts` |
| Components | `PascalCase` | `HeroSection` |
| Sub-components | `ParentPart` | `CardHeader`, `TabsTrigger` |
| CVA functions | `camelCaseVariants` | `buttonVariants`, `badgeVariants` |
| Constants | `UPPER_SNAKE_CASE` | `COURSE_SLUG`, `MODULE_ORDER` |
| Hooks | `useCamelCase` | `useSidebarPill`, `useNavbarAnimation` |
| Types/Interfaces | `PascalCase` | `FAQEntry`, `CourseModule` |
| Boolean props | `is`/`has`/`can`/`needs` prefix | `isLoading`, `hasError`, `canSubmit`, `needsHelp` |
| Event handlers | `on` + action | `onChange`, `onRemove`, `onSubmit` |
| Data attributes | `data-slot`, `data-variant` | `data-sidebar-variant="dark"` |
| CSS variables | `--color-{name}`, `--radius-{name}` | `--color-navy`, `--radius-card` |

## Convex-Specific Naming

| Thing | Pattern | Example |
|---|---|---|
| Table names | Plural camelCase | `courses`, `workshopInvites`, `emailSendLog` |
| Fields | camelCase | `clerkUserId`, `accessExpiresAt` |
| Foreign keys | `{table}Id` | `courseId`, `workshopId` |
| Timestamps | `*At` suffix | `createdAt`, `deletedAt`, `emailSentAt` |
| Status fields | Descriptive name | `status`, `subscriptionStatus`, `syncMode` |
| Booleans | `is`/`has`/`needs`/`all` | `isPublished`, `hasAccess`, `allGreen` |
| Indexes | `by_{field}` | `by_user`, `by_user_course`, `by_workshop_and_email` |
| Query functions | `list*`, `get*` | `listPublished`, `getBySlug` |
| Mutation functions | `create*`, `update*`, `upsert*`, `delete*` | `upsertAccess`, `deleteFromClerk` |
| Action functions | `send*`, `sync*`, `fetch*` | `send`, `syncUserToBrevo` |
| Internal helpers | Prefix with `_` | `_logActivity`, `_clearTable` |

## Abbreviation Rules

**Allowed short names** (domain terms): `cta`, `bg`, `ref`, `src`, `alt`, `href`, `id`, `url`, `db`, `api`, `env`

**Banned abbreviations**: `btn`, `usr`, `val`, `desc`, `curr`, `prev`, `tmp`, `cb`, `fn`, `elem`, `param`, `cfg`, `req`, `res`, `err` (use `error`), `msg` (use `message`)

## Component Name Test

Before approving a new component name:

```
Does the name contain a DOMAIN word?
(login, signup, course, workshop, admin, billing, pricing, user, instructor)

YES -> Is it a composition of DLS bricks with domain logic?
  YES -> Allow in components/{domain}/, verify it uses DLS bricks inside
  NO  -> BLOCK: rename to generic version, consider adding to DLS

NO -> Is it reusable across the app?
  YES -> Should it be in the DLS?
  NO  -> Fine as app component
```

## Export Naming

- Named exports only: `export { Button, buttonVariants }`
- No `export default` except Next.js `page.tsx` and `layout.tsx`
- Export the CVA variants function alongside the component
- Deprecated aliases point to the main component: `/** @deprecated Use <Badge variant="xp"> */ const XPBadge = Badge`
