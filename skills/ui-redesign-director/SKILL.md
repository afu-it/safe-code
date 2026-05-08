---
name: ui-redesign-director
description: redesign existing user interfaces, screenshots, dashboard cards, app screens, and product components into polished modern visuals. use when the user asks to redesign, improve, modernize, premiumize, clean up, or generate a better version of an existing ui. especially useful for saas dashboards, mobile app screens, widgets, progress cards, onboarding flows, settings pages, and components where layout, hierarchy, spacing, and visual quality need improvement.
---

# UI Redesign Director

Redesign existing UI into a cleaner, more polished, more usable version while preserving the original intent, information, and product context.

## Core objective

Transform rough, outdated, crowded, or plain UI into a high-quality modern interface that feels:

- clear
- premium
- consistent
- realistic
- production-ready

Preserve the **meaning** of the original design. Improve the **presentation**.

## Operating principles

When redesigning UI:

1. Identify the purpose of the screen or component.
2. Preserve core content, labels, numbers, and information hierarchy unless the user asks for structural changes.
3. Improve layout, spacing, typography, alignment, grouping, contrast, and overall usability.
4. Make the redesign feel like a real product interface, not a decorative poster.
5. Prefer clarity and hierarchy over unnecessary visual effects.
6. Use strong visual restraint. Add polish, not clutter.
7. Keep the output grounded in the original UI's purpose.

## Default redesign style

Use a modern premium SaaS/product design style unless the user requests a different one.

Default visual language:

- clean layout
- generous whitespace
- rounded corners
- soft shadows
- subtle depth
- restrained color palette
- strong typographic hierarchy
- clear sections and grouping
- high legibility
- polished iconography
- realistic product UI appearance

Default color direction:

- neutral or off-white background
- white or lightly tinted card surfaces
- dark navy or charcoal for primary text
- cool gray for secondary text
- one restrained accent color for emphasis
- subtle progress and status colors

## What to preserve

Preserve whenever possible:

- the product intent
- the metric meaning
- important labels
- the main structure of the information
- the key numbers and statuses
- any important CTA or interaction pattern
- recognizable domain context

Do **not** invent unrelated features or content unless the user asks for exploration.

## What to improve

Always look for opportunities to improve:

- spacing
- alignment
- padding and margins
- typography scale
- font weight hierarchy
- grouping and sectioning
- card structure
- visual rhythm
- icon consistency
- scannability
- readability
- progress/status visibility
- accessibility-minded contrast
- overall balance

## Redesign workflow

Follow this process:

### 1) Read the source

If the user provides a screenshot or image:

- treat it as the primary content reference
- identify the component type
- identify the most important information
- identify pain points in the current design

Common pain points:

- cramped layout
- weak hierarchy
- inconsistent spacing
- low contrast
- bland presentation
- awkward alignment
- poor grouping
- weak CTA emphasis
- outdated styling
- unclear progress or state

### 2) Decide redesign intent

Choose the most fitting redesign intent:

- **cleanup**: keep structure, improve polish
- **modernization**: make it contemporary and premium
- **information hierarchy upgrade**: improve readability and emphasis
- **component re-layout**: reorganize blocks while preserving content
- **dashboard refinement**: upgrade cards, charts, indicators, and spacing
- **mobile product polish**: improve usability and structure for small screens

### 3) Build the redesign

Create a redesign that:

- feels cleaner than the original
- has obvious hierarchy at a glance
- balances density and whitespace
- uses accent color intentionally
- looks realistic enough to belong in a live product

### 4) Verify the result

Before finalizing, verify:

- the key information is still present
- the main numbers remain correct
- the visual emphasis matches importance
- text is legible
- the design feels coherent
- the design is not overdecorated
- the result looks like a real interface

## Prompt construction rules

When writing an image-generation prompt for a redesign:

1. State that the provided image is the content and layout reference.
2. Explicitly say which parts to preserve.
3. Explicitly say what to improve.
4. Describe the desired visual style clearly.
5. Mention realism and production-ready quality.
6. Mention composition and cleanliness.
7. Mention text hierarchy and spacing.
8. Mention that the result should be a UI/product design mockup, not a poster or illustration.

## Default prompt pattern

Use a prompt structure like this:

> Redesign the provided UI as a polished modern product interface. Use the source image as a content reference and preserve the core information, labels, and metrics. Improve layout, spacing, hierarchy, alignment, typography, grouping, and visual balance. Use a premium SaaS aesthetic with clean card surfaces, rounded corners, subtle shadows, refined iconography, restrained color accents, dark primary text, and soft neutral backgrounds. Make the result minimal, elegant, realistic, and production-ready.

## Reference-image handling

When a reference image is provided:

- use it to preserve content and intent
- do not copy it literally if the design can be improved
- preserve the semantics
- upgrade the visual language
- keep the redesign faithful enough that the user recognizes it instantly

If multiple reference images are provided:

- identify which image defines content
- identify which image defines style
- identify which image defines layout or component behavior
- combine them coherently

## UI-specific heuristics

### For dashboard cards

Prefer:

- one strong headline or title
- one clear primary metric
- one clear secondary metric
- supporting subtext only if necessary
- clear dividers or grouping when needed
- a progress bar or indicator that is visually clean and easy to read

### For forms

Prefer:

- clearer field spacing
- stronger label hierarchy
- better affordances
- simpler grouping
- obvious primary action

### For mobile screens

Prefer:

- fewer competing elements
- larger touch-friendly components
- more breathing room
- stronger top-level hierarchy
- clearer navigation affordances

### For analytics screens

Prefer:

- simplified panels
- more readable charts
- obvious metric priority
- cleaner data grouping
- restrained use of color for state and emphasis

## Text rendering guidance

When the UI contains text:

- preserve important text accurately
- keep labels concise and clean
- avoid filler copy unless needed
- use short realistic product language
- keep headings stronger than labels
- keep supporting text visibly secondary

## Visual quality bar

Target output quality should feel like:

- a Dribbble-quality product UI concept, but more usable
- a clean startup SaaS interface
- a professional design-system-aligned mockup
- a premium but practical redesign

Avoid:

- excessive glassmorphism
- overuse of gradients
- noisy backgrounds
- unreadable tiny text
- poster-like stylization
- random decorative elements
- flashy effects that hurt clarity

## Response modes

Support these modes depending on the request:

### Mode A: direct redesign
Produce the redesigned image or image prompt directly.

### Mode B: redesign + rationale
Provide the redesign plus a short explanation of what changed and why.

### Mode C: multiple directions
Offer 2–3 redesign directions, such as:
- minimal premium
- bold startup
- enterprise clean
- soft modern
- dark mode product UI

## If the request is underspecified

If the user does not specify a style, default to:

- premium SaaS
- minimal
- light mode
- clean typography
- soft depth
- restrained accent color

If the user does not specify how much change is desired, default to:

- preserve content
- improve structure
- modernize styling
- keep the redesign recognizable

## Example use cases

### Example 1: progress card
If the user provides a simple progress widget, preserve:
- progress percentage
- timeline or week count
- supporting status text

Improve:
- layout
- icon treatment
- spacing
- card hierarchy
- progress indicator styling
- overall polish

### Example 2: dashboard section
If the user provides a rough admin dashboard, preserve:
- nav structure
- key data blocks
- chart intent
- labels

Improve:
- card system
- spacing rhythm
- typography scale
- information grouping
- visual emphasis

## Final instruction

Redesign UI to make it clearer, sharper, more elegant, and more useful.

Always preserve intent.
Always improve hierarchy.
Always make it feel like a real product.
