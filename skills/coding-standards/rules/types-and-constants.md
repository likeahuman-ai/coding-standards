# Types & Constants — Reuse Hierarchy

## Type Lookup Order (check before creating)

```
Need a type?

1. Does it already exist in src/types/?
   (shared: User, Course, Module, Lesson, Workshop, etc.)
   -> Import it. Done.

2. Can you derive it from an existing type?
   -> Pick<Course, "title" | "slug">
   -> Omit<User, "password">
   -> Partial<WorkshopSettings>
   -> Use the utility type. Don't duplicate fields.

3. Does the same shape exist in a Convex schema?
   -> Use Doc<"tableName"> from convex/_generated/dataModel
   -> Or derive: Omit<Doc<"courses">, "_creationTime">

4. Does it exist in the same domain folder?
   -> components/course/ already has types.ts -> add there

5. Is it props for a single component?
   -> Inline in the function signature (standard pattern)
   -> Only extract to types.ts if file >40 lines AND type is complex

6. Nothing fits -> Create it.
   Where?
   - Used across 2+ domains -> src/types/{name}.ts
   - Used within one domain -> components/{domain}/types.ts
   - Used by one component only -> inline in function signature
```

## Key Principle: One types.ts Per Domain

```
// WRONG: one types file per component
components/course/
  course-card.types.ts      <- wasteful
  module-overview.types.ts  <- wasteful
  lesson-viewer.types.ts    <- wasteful

// RIGHT: one types file per domain
components/course/
  course-card.tsx
  module-overview.tsx
  lesson-viewer.tsx
  types.ts                  <- all course domain types
```

## Constants Lookup Order

```
Need a constant?

1. Does it exist in src/lib/constants.ts? (global)
2. Does it exist in the domain's constants.ts?
3. Does it exist in the DLS (tokens.css, component constants)?
4. Is it derivable from config? (env vars, Convex schema)

None found -> Create it.
  - Used across domains -> src/lib/constants.ts
  - Used within one domain -> components/{domain}/constants.ts
  - Used by one component, simple value -> inline for now
    (agent flags it if it later appears in a second file)
```

## Key Principle: One constants.ts Per Domain

```
// WRONG: scattered constants
components/course/
  course-card.constants.ts
  module-overview.constants.ts

// RIGHT: domain-level
components/course/
  constants.ts              <- COURSE_SLUG, MODULE_ORDER, etc.

// Global
src/lib/constants.ts        <- APP_NAME, DEFAULT_LOCALE, etc.
```

## TypeScript Patterns for Types

```typescript
// Use const assertions over enums
const STATUS = { ACTIVE: "active", EXPIRED: "expired" } as const
type Status = typeof STATUS[keyof typeof STATUS]  // "active" | "expired"

// Use utility types over redundant interfaces
type CoursePreview = Pick<Course, "title" | "slug" | "description">
type PartialSettings = Partial<WorkshopSettings>
type UserWithoutPassword = Omit<User, "password">

// Use Zod inference over manual types
const surveySchema = z.object({ name: z.string(), email: z.string().email() })
type SurveyData = z.infer<typeof surveySchema>

// Use Convex Doc type over manual interfaces
import { Doc } from "@convex/_generated/dataModel"
type Course = Doc<"courses">
```

## When NOT to Create a Type

- For a single object literal passed to one function -> just type inline
- For a simple union -> use inline: `variant: "primary" | "secondary"`
- When CVA provides the type -> use `VariantProps<typeof buttonVariants>`
- When React provides the type -> use `React.ComponentProps<"button">`
