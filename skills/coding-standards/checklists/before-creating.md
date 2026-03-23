# Before Creating Anything New

**MANDATORY** — answer these 5 questions before creating any new component, hook, type, constant, or utility file.

## 1. Does It Already Exist?

Search the codebase:
- Components: `ls packages/dls/src/components/` + `ls apps/*/src/components/`
- Hooks: `ls packages/dls/src/hooks/` + `ls apps/*/src/hooks/`
- Types: `grep -r "type {Name}" src/types/` + domain `types.ts` files
- Constants: `grep -r "{VALUE}" src/lib/constants.ts` + domain `constants.ts` files
- Utils: `ls src/lib/`

If it exists -> import and use it. Done.

## 2. Can I Extend What Exists?

- Add a **variant** to an existing CVA component (Badge has 22 — one more is fine)
- Add a **prop** to an existing component
- Add a **field** to an existing domain `types.ts`
- Add a **value** to an existing `constants.ts`
- **Derive** from existing type: `Pick<X, "a" | "b">`, `Omit<X, "c">`, `Partial<X>`

If extensible -> extend. Don't fork.

## 3. Can I Compose What Exists?

- `Card` + `Badge` + `Button` = feature card (not a new component)
- `SectionWrapper` + `SectionHeading` + content = new section
- `FormProvider` + existing inputs = new form

If composable -> compose. Don't create.

## 4. Is It a Brick or a Building?

- **Brick** (generic, reusable, no domain in the name) -> DLS package
- **Building** (domain-specific composition of 3+ bricks) -> `apps/.../components/{domain}/`

Test: could you rename it and use it in a different domain?
- Yes -> too generic for app, belongs in DLS
- No -> domain-specific, belongs in app

## 5. Where Does It Live?

| Thing | Shared across domains | Within one domain | Single component |
|---|---|---|---|
| Type | `src/types/` | `{domain}/types.ts` | Inline in function |
| Constant | `src/lib/constants.ts` | `{domain}/constants.ts` | Inline (flag if reused later) |
| Component | `packages/dls/` | `components/{domain}/` | — |
| Hook | `packages/dls/src/hooks/` | `apps/.../hooks/` | — |
| Util | `src/lib/` | `{domain}/utils.ts` | Inline |

## Red Flags — Stop and Reconsider

- File name contains a domain word (Login, Workshop, Admin) + a generic word (Card, Badge, Button)
  -> Probably should be composition, not a new component
- New `.types.ts` per component instead of per domain
- New `constants.ts` per component instead of per domain
- `useState` + `useEffect` + `fetch()` pattern
  -> Should be Convex useQuery, React Query, or Server Component
- Reimplementing DLS styling inline (rounded-card + border-border + shadow-card)
  -> Use the existing DLS component
