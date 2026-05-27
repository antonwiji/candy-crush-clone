---
name: Sugar Glaze
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#554248'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#887178'
  outline-variant: '#dbc0c7'
  surface-tint: '#a33467'
  primary: '#a33467'
  on-primary: '#ffffff'
  primary-container: '#ff7eb3'
  on-primary-container: '#780e46'
  inverse-primary: '#ffb0cc'
  secondary: '#7644b5'
  on-secondary: '#ffffff'
  secondary-container: '#bb88fd'
  on-secondary-container: '#4c138a'
  tertiary: '#845400'
  on-tertiary: '#ffffff'
  tertiary-container: '#e29a2f'
  on-tertiary-container: '#583600'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9e4'
  primary-fixed-dim: '#ffb0cc'
  on-primary-fixed: '#3e0020'
  on-primary-fixed-variant: '#841a4f'
  secondary-fixed: '#eedcff'
  secondary-fixed-dim: '#d9b9ff'
  on-secondary-fixed: '#2a0054'
  on-secondary-fixed-variant: '#5d299b'
  tertiary-fixed: '#ffddb6'
  tertiary-fixed-dim: '#ffb95a'
  on-tertiary-fixed: '#2a1800'
  on-tertiary-fixed-variant: '#643f00'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-hero:
    fontFamily: Quicksand
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -1px
  headline-lg:
    fontFamily: Quicksand
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Quicksand
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  title-md:
    fontFamily: Quicksand
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Quicksand
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 26px
  body-md:
    fontFamily: Quicksand
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  label-caps:
    fontFamily: Quicksand
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 1px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  safe-margin: 20px
  gutter: 12px
---

## Brand & Style
The design system is engineered for a premium casual gaming experience, evoking feelings of joy, indulgence, and magical wonder. The target audience is broad—ranging from commuters seeking a quick dopamine hit to dedicated puzzle enthusiasts. 

The visual style is **Tactile / Skeuomorphic**, blending modern flat aesthetics with "squishy" physical metaphors. Every element should look edible, utilizing high-gloss finishes, inner glows, and soft-body physics cues. The interface mimics a collection of magical jellies and hard-shell candies resting on frosted glass planes, ensuring a high-fidelity "toy-like" feel that responds satisfyingly to touch.

## Colors
This design system utilizes a "Candy-Coated" palette. The colors are highly saturated but maintain a soft, pastel-adjacent quality through the use of white-mixed tints.

- **Candy Pink (Primary):** Used for main CTAs and heart/life indicators.
- **Magical Purple (Secondary):** Reserved for mystery items, level headers, and secondary progression paths.
- **Zesty Orange (Tertiary):** Highlights special offers, gold currency, and "Super" state feedback.
- **Sky Blue & Mint Green:** Used for environment accents, confirmation actions (Green), and info-heavy UI (Blue).
- **Backgrounds:** Use soft gradients (e.g., Sky Blue to White) to maintain a sense of airy, candy fantasy space.

## Typography
Typography is bold, rounded, and expressive. **Quicksand** is used exclusively to maintain a friendly and cohesive identity. 

- **Weighting:** Use Bold (700) for all interactive elements and numeric counters to ensure legibility against vibrant backgrounds.
- **Stroke/Outline:** Headlines in game modals should utilize a thick white stroke (4pt - 6pt) with a soft drop shadow to separate text from the colorful gameplay environment.
- **Hierarchy:** Display type is used for "Level Clear" and "Big Win" moments; Body-lg is the standard for dialogue and tutorials.

## Layout & Spacing
The layout follows a **Fluid Grid** model optimized for Android Portrait (390px width). 

- **Grid:** A 4-column layout for menus and a flexible 8x8 or 9x9 grid for the game board.
- **Rhythm:** Spacing is based on a 4px baseline, but large margins (20px+) are used at the edges of the screen to accommodate various Android bezel types and gesture navigation zones.
- **Layering:** The game board sits in a primary container with 16px padding. Modal overlays should have a 24px margin from the screen edge to create a sense of depth over the gameplay.

## Elevation & Depth
Depth is achieved through **Tonal Layers** and **Ambient Shadows** that feel "heavy" and "physical."

- **Shadows:** Use large blur radii (15px - 30px) with low-opacity tints of the underlying color (e.g., a Pink shadow under a Pink card) rather than pure black. This maintains color vibrancy.
- **Glossy Overlay:** Buttons and active cards feature a "crescent moon" white gradient at the top (20% opacity) to simulate a light source reflecting off a gelatinous surface.
- **Stacked Depth:** Modals use a backdrop blur of 10px and a 40% black overlay to push the game board into the background.

## Shapes
The shape language is strictly **Pill-shaped** and hyper-rounded. There are no sharp corners in the design system.

- **Buttons:** Always use pill shapes (fully rounded ends).
- **Cards/Modals:** Use a minimum corner radius of 24px (`rounded-xl` in this system).
- **Icons:** Enclosed in circular "bubbles" with a subtle inner glow to reinforce the candy theme.
- **Interactions:** When pressed, elements should scale down slightly (0.95x) to give a squishy, reactive feedback.

## Components
- **Bubbly Buttons:** High-gloss gradients (Top: Lighter Tint, Bottom: Base Color). They feature a 4px bottom "lip" of a darker shade to look like a physical 3D button.
- **Candy Cards:** Rounded white or pastel containers with a 1px inner border (white) to simulate a highlight.
- **Progress Bars:** Thick, pill-shaped tracks with a "liquid" fill that has a subtle wave animation.
- **Gems/Pieces:** These are the hero assets. They should include a primary highlight, a secondary bounce light at the bottom, and a soft shadow that scales with the piece's movement.
- **Currency Badges:** Horizontal pill containers with the icon (Gold/Gem) overlapping the left edge, breaking the container's silhouette for visual interest.
- **Lists:** Scrollable lists use "jelly tiles"—rounded cards with vertical spacing of 8px, using a slight bounce-back effect when scrolled to the end.