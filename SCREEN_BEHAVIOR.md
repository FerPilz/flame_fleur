# SCREEN_BEHAVIOR.md

## Purpose

This document defines the expected user interactions and dynamic behavior for Flame & Fleur screens.

Reference images are static snapshots. They show visual direction, but they do not show all data states, carousel behavior, scroll behavior, or user interactions.

Codex must use this file together with:

* `AGENTS.md`
* `REFERENCE_MANIFEST.md`
* `DESIGN_TRANSLATION.md`
* `Reference_Images/`

For every screen, Codex must implement both:

1. the visual structure from the reference image
2. the functional behavior described here

Do not treat reference images as the full functionality of the screen.

---

# Global Interaction Rules

## Static Reference Images Are Partial

The reference images are snapshots in time.

If a reference image shows only three cards in a section, Codex should still create enough mock data to test scrolling and carousel behavior.

If a reference image shows only one selected tab/category, Codex should still create placeholder sections for the other tabs/categories if the UI suggests they exist.

## Mock Data Requirement

Until real backend/data is added:

* use local mock/sample data
* include enough items to test scrolling
* include enough items to test horizontal carousels
* include realistic placeholder titles and metadata
* do not add networking
* do not add persistence unless explicitly requested

## Carousel Requirement

Any horizontal carousel must:

* scroll horizontally
* contain more items than visible on screen
* avoid clipping the first and last cards
* use consistent spacing
* use the shared `HorizontalCarousel` component
* have realistic placeholder content
* work on modern iPhone screen sizes

## Section Linking Requirement

If a screen has a top menu or segmented category selector that corresponds to vertical content sections:

* tapping a top menu option should scroll vertically to the corresponding section
* the selected top menu option should update visually
* if the user scrolls manually, the selected state should remain reasonable
* use `ScrollViewReader` or an equivalent SwiftUI approach when practical
* do not create fake static top menu controls

## Do Not Fake Interactions

Controls that appear tappable should have at least placeholder behavior.

Examples:

* top menu items should update selected state
* carousel rows should actually scroll
* buttons can print/log or update simple local UI state if no real functionality exists yet
* navigation buttons can use placeholder destinations if needed
* favorite buttons can toggle local visual state if practical

Do not add real persistence or networking unless explicitly requested.

---

# Home Screen Behavior

Reference:

`Reference_Images/01_home_reference.png`

## Home Screen Purpose

Home is the main landing screen. It should show featured content and multiple recipe discovery sections.

The reference image shows a visual snapshot, not the full dynamic content.

## Top Menu Sections

The Home top menu should contain these options:

* Featured
* Community
* Top Picks
* AI Recommend

Each top menu item corresponds to a vertical content section on the Home screen.

## Required Vertical Sections

Home must include these vertical sections:

1. Featured
2. Community
3. Top Picks
4. AI Recommend

Even if the reference image only shows some of these sections fully, all four must exist as placeholder content.

## Top Menu Behavior

When the user taps:

* `Featured` → scroll to the Featured section
* `Community` → scroll to the Community section
* `Top Picks` → scroll to the Top Picks section
* `AI Recommend` → scroll to the AI Recommend section

The selected top menu item should update its active state.

Use `ScrollViewReader` or another clean SwiftUI method.

The top menu should not be decorative or static.

## Header and Top Menu Position

The header and top menu should remain visually stable at the top while the Home content scrolls.

Recommended structure:

* fixed `AppHeader`
* fixed `TopSegmentSelector`
* scrollable content below

Do not place the header and top selector inside the main vertical scroll if the design requires them to remain fixed.

## Home Carousel Requirements

Every content section that uses recipe cards should include enough items to test horizontal scrolling.

Minimum mock items:

* Featured: at least 4 featured recipes
* Community: at least 6 recipes
* Top Picks: at least 6 recipes
* AI Recommend: at least 6 recipes

If the design uses one large Featured hero card plus a carousel, keep the hero card visually close to the reference and still include enough data for carousel testing where appropriate.

## Home Section Details

### Featured

Purpose:

Show strong editorial featured recipes.

Required behavior:

* show the main featured card first
* include multiple featured recipes in the data model
* if implemented as a carousel, it must scroll horizontally
* if implemented as a hero card plus secondary featured cards, secondary cards must still be scrollable

Sample placeholder recipes:

* Creamy Lemon Herb Salmon
* Tuscan Tomato Gnocchi
* Golden Chicken Risotto
* Charred Peach Salad

### Community

Purpose:

Show community-inspired recipes.

Required behavior:

* display as a horizontal carousel
* include at least 6 mock recipe cards
* each card should have a title, metadata, favorite button, and image placeholder

Sample placeholder recipes:

* Pesto Primavera
* Hearty Lentil Soup
* Fudgy Brownie
* Roasted Veggie Bowl
* Lemon Ricotta Toast
* Spiced Chickpea Stew

### Top Picks

Purpose:

Show curated recommendations.

Required behavior:

* display as a horizontal carousel
* include at least 6 mock recipe cards
* each card should have a title, metadata, favorite button, and image placeholder

Sample placeholder recipes:

* Butter Chicken
* Garlic Parmesan Pasta
* Quinoa Power Bowl
* Miso Glazed Eggplant
* Crispy Fish Tacos
* Wild Mushroom Toast

### AI Recommend

Purpose:

Show personalized placeholder recommendations.

Required behavior:

* display as a horizontal carousel
* include at least 6 mock recipe cards
* make it visually consistent with other sections
* do not create a separate AI Kitchen tab
* do not add real AI/networking yet

Sample placeholder recipes:

* Pantry Pasta
* 20-Minute Green Curry
* High-Protein Breakfast Bowl
* Cozy Lentil Dal
* Salmon Rice Plate
* Quick Citrus Chicken

## Home Buttons

Buttons should have placeholder behavior only unless real functionality is requested.

Examples:

* `View Recipe` can navigate to a placeholder recipe detail screen later, or be left as a button with a TODO comment.
* Favorite heart buttons can optionally toggle local visual state.
* `See all` can be present but does not need full navigation yet unless requested.

## Home Acceptance Criteria

Home is acceptable only if:

* the visual layout remains close to `01_home_reference.png`
* top menu contains Featured, Community, Top Picks, AI Recommend
* each top menu item scrolls to its matching vertical section
* selected top menu state updates when tapped
* Community has at least 6 mock cards
* Top Picks has at least 6 mock cards
* AI Recommend has at least 6 mock cards
* carousels actually scroll horizontally
* cards are not clipped horizontally
* images/placeholders do not overflow their containers
* header/title stays visually stable at the top
* the app does not add an AI Kitchen tab
* no networking is added
* no persistence is added
* no reference image is used as an app asset

# Home Interaction Corrections

Use these interaction rules for `Reference_Images/01_home_reference.png`.

## Favorite Heart Behavior

Recipe heart buttons must have local placeholder interactivity.

When the user taps a recipe heart:

* the heart state must toggle locally
* the heart icon must stay visually selected after tapping
* selected state should use a red or warm-red heart fill
* unselected state should use an outline heart
* this behavior should work for Featured, Community, Top Picks, and AI Recommend recipe cards
* do not add persistence yet
* do not add backend saving yet

This is local UI state only.

## Home Top Menu Scroll Behavior

The top menu must remain linked to the corresponding vertical Home sections:

* `Featured` scrolls to the Featured section
* `Community` scrolls to the Community section
* `Top Picks` scrolls to the Top Picks section
* `AI Recommend` scrolls to the AI Recommend section

The selected top menu item must update when tapped.

`AI Recommend` must exist as a real section below Top Picks, but it should not be visible in the initial entry viewport. It should become visible through vertical scrolling or by tapping the `AI Recommend` top menu item.

## Home Carousel Data Requirements

Each carousel must include enough placeholder recipes to test horizontal scrolling.

Minimum counts:

* Featured: at least 4 recipes
* Community: at least 6 recipes
* Top Picks: at least 6 recipes
* AI Recommend: at least 6 recipes

All cards in the same carousel must use consistent sizing.

Community cards must include placeholder creator/user information.

## Home Acceptance Additions

Home is not acceptable unless:

* favorite hearts remain highlighted after tapping
* Community recipe cards include placeholder creator labels
* recipe image placeholders are consistently sized within each carousel
* the Featured card is tall enough to visually match the reference
* AI Recommend exists but is below the initial viewport
* top menu selection scrolls to the correct section

