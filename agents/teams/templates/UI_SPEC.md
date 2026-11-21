# UI/UX Design Specification: <ticket-title>

- **Ticket / RFC:** `<rfc-id>`
- **Author:** `ui-ux-designer`
- **Reviewed by:** `lead-architect`, `frontend-architect`
- **Target Viewport Posture:** [ ] Mobile-First | [ ] Desktop-First | [ ] Adaptive
- **Format:** [ ] Storybook Stories (`*.stories.tsx`) | [x] Markdown Spec (`UI_SPEC.md`)

---

## 1. Catalog Audit & Anti-Duplication Check (Step 0)
- **Existing Catalog Primitives Reused:**
  - `<ExistingComponent>` (from `@/ui/primitives/...` or `@/ui/composed/...`): Used for `<purpose>` via props/variants.
- **New Component Justification (if any):**
  - Why no existing component covered $\ge 80\%$ of visual intent: `<explanation or N/A>`.

---

## 2. Viewport Ergonomics & Touch Targets
- **Target Posture:** `<mobile-first | desktop-first | adaptive>`
- **Touch / Dimension Targets:** Minimum touch dimension $\ge 44\text{px}$ on interactive elements (when mobile or touch target).
- **Navigation Anchor & Safe Areas:** Bottom navigation / sheets and `pb-[env(safe-area-inset-bottom)]` (if mobile). Desktop grid layout and keyboard focus indicators (if desktop).

---

## 3. Visual Hierarchy & Theme Tokens
- **Typography:** Theme scale utilities or semantic tags (`type-h1`, `type-body`, etc.).
- **Colors & Tokens:** Semantic tokens only (`bg-background`, `text-muted-foreground`, `border-border`). Zero raw hex or arbitrary Tailwind sizes.
- **Spacing & Layout:** Theme scale tokens.

---

## 4. Contextual Component States (By Archetype)

### Archetype: `<Data View | Form Input | Trigger / Action | Indicator>`

| State | Visual Treatment / Behavior |
| :--- | :--- |
| **Default** | Standard populated / idle state |
| **Active / Focus** *(Inputs/Triggers)* | Focus ring / active feedback |
| **Loading / Skeleton** *(Data Views)* | Skeleton placeholder matching final shape |
| **Empty State** *(Data Views)* | Guidance text / CTA button |
| **Error / Invalid** *(Data Views / Inputs)* | Inline contextual message / recovery button |
| **Disabled** *(Inputs / Triggers)* | Visual opacity + disabled pointer |

---

## 5. Visual Mockup & Anatomy Contract (JSX + Pure Tailwind)

```tsx
// Visual Prototype / Anatomy Contract for implementer-frontend
import { StatusBadge } from '@/ui/composed/status-badge'; // Direct path import

export function ComponentMockup() {
  return (
    <div className="flex flex-col gap-4 p-4 min-h-[44px]">
      {/* Visual layout mock composed from catalog primitives */}
    </div>
  );
}
```

---

## 6. Review & Tree-Shaking Checklist
- [ ] Catalog search completed before creating new components.
- [ ] Direct path imports used (no barrel leakage).
- [ ] Responsive across target viewports (360px–430px for mobile; standard desktop grid if desktop).
- [ ] Minimum touch targets $\ge 44\text{px}$ verified for mobile/touch surfaces.
- [ ] Accessibility: WCAG AA contrast, ARIA roles, and visible focus rings.
