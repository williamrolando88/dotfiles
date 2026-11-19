# UI/UX Design Specification: <ticket-title>

- **Ticket / RFC:** `<rfc-id>`
- **Author:** `ui-ux-designer`
- **Reviewed by:** `lead-architect`, `frontend-architect`
- **Format:** [ ] Storybook Stories (`*.stories.tsx`) | [x] Markdown Spec (`UI_SPEC.md`)

---

## 1. Ergonomía Mobile-First & Touch Targets
- **Target mínimo táctil:** $\ge 44\text{px}$ en botones e interactivos principales.
- **Zona de pulgar (Thumb zone):** Acciones primarias ancladas abajo (Bottom navigation / Bottom sheets).
- **Safe Area Insets:** Padding preventivo `pb-[env(safe-area-inset-bottom)]` / `pt-[env(safe-area-inset-top)]`.

---

## 2. Jerarquía Visual y Tokens Tailwind
- **Tipografía:** Tamaños, pesos (`font-semibold`, `text-sm`, `text-lg`) y contraste accesible (WCAG AA).
- **Colores/Tokens:** Paleta de diseño y estados temáticos (Dark/Light).
- **Espaciado y Layout:** Flexbox / Grid móvil responsivo.

---

## 3. Estados de la Interfaz (Edge Cases Obligatorios)
- **Default / Populate:** Estado óptimo con datos reales.
- **Loading / Skeleton:** Aspecto visual mientras cargan datos asíncronos.
- **Empty State:** Ilustración o mensaje cuando no hay resultados/datos.
- **Error State:** Mensaje contextual claro sin romper el layout.

---

## 4. Mockup Visual (JSX + Tailwind Puro)

```tsx
// Visual Prototype / Anatomy Contract for implementer-frontend
export function ComponentMockup() {
  return (
    <div className="flex flex-col gap-4 p-4 min-h-[44px]">
      {/* Component layout spec */}
    </div>
  );
}
```

---

## 5. Criterios de Aceptación Visual
- [ ] Responsive en 360px–430px (Mobile viewport).
- [ ] Touch targets auditados $\ge 44\text{px}$.
- [ ] Accesibilidad: Roles ARIA y foco visible presentes.
