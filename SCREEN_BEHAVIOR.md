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

# 1. Global Interaction Rules

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
* favorite buttons should toggle local visual state
* buttons can print/log or update simple local UI state if no real functionality exists yet
* navigation buttons can use placeholder destinations if needed

Do not add real persistence or networking unless explicitly requested.

---

# 2. Home Screen Behavior

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

The top menu must not be decorative or static.

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
* each card should have a title, metadata, favorite button, image placeholder, and creator overlay

Sample placeholder recipes:

* Pesto Primavera
* Hearty Lentil Soup
* Fudgy Brownie
* Roasted Veggie Bowl
* Lemon Ricotta Toast
* Spiced Chickpea Stew

Sample placeholder creator labels:

* `@marina.cooks`
* `@homechef.anna`
* `@bakewithleo`
* `@freshkitchen`
* `@chef.luna`
* `@tableandthyme`

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
* position this section below Top Picks so it is not visible in the initial entry viewport

Sample placeholder recipes:

* Pantry Pasta
* 20-Minute Green Curry
* High-Protein Breakfast Bowl
* Cozy Lentil Dal
* Salmon Rice Plate
* Quick Citrus Chicken

---

# 3. Home Interaction Corrections

## Favorite Heart Behavior

Recipe heart buttons must have local placeholder interactivity.

When the user taps a recipe heart:

* the heart state must toggle locally
* the heart icon must stay visually selected after tapping
* selected state should use a red or warm-red filled heart
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

## Bottom Content Safety

Home scroll content must include enough bottom spacing so the final visible carousel/card row is not hidden or cropped behind the tab bar.

The bottom tab bar remains fixed.

The scrollable content must account for the tab bar height using bottom padding or a bottom safe-area inset.

## Recipe Title Behavior

The Featured hero recipe title may use up to two lines.

Compact carousel card titles must use one line only.

For compact carousel cards:

* use consistent title font size
* show as much of the title as possible
* keep the title readable
* use `lineLimit(1)`
* use `truncationMode(.tail)`
* truncate only when necessary
* do not shrink the font on individual cards
* do not allow title wrapping
* do not allow compact cards to become taller because of title wrapping

This applies to:

* Community carousel
* Top Picks carousel
* AI Recommend carousel

## Community Creator Overlay Behavior

Community cards should show creator metadata as an image overlay.

This overlay is visual placeholder metadata only.

The overlay should include:

* tiny circular avatar placeholder
* muted username text

The overlay should appear near the lower edge of the image area, similar to the reference.

Do not place the creator username as a separate full line below the recipe title.

Do not add real user profiles, networking, or navigation yet.

## Menu Icon Behavior

The hamburger/menu icon is visual only for now unless navigation drawer behavior is explicitly requested.

It must visually appear as three horizontal lines.

---

# 4. Home Buttons and Placeholder Behavior

Buttons should have placeholder behavior only unless real functionality is requested.

Examples:

* `View Recipe` can navigate to a placeholder recipe detail screen later, or be left as a button with a TODO comment.
* Favorite heart buttons should toggle local visual state.
* `See all` can be present but does not need full navigation yet unless requested.
* Top menu items must update selected state and scroll to the corresponding section.

Do not add real persistence or backend behavior.

---

# 5. Home Acceptance Criteria

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
* all image placeholders in the same carousel use consistent sizing
* compact carousel card titles stay on one line
* compact carousel card titles use consistent font size
* long compact titles truncate only when needed
* Community recipe cards include creator overlays on the image area
* favorite hearts remain highlighted after tapping
* hamburger/menu icon has three horizontal lines
* header/title stays visually stable at the top
* AI Recommend exists but starts below the initial viewport
* bottom carousel/card rows are not cropped by the tab bar
* the app does not add an AI Kitchen tab
* no networking is added
* no persistence is added
* no reference image is used as an app asset

## Home Entry Viewport Behavior

The initial Home viewport must show the Top Picks carousel fully enough that the user understands it is an available section.

The Home layout must not use excessive vertical spacing that hides Top Picks unnecessarily.

`AI Recommend` must remain below the initial viewport and should be reachable by scrolling or tapping its top menu item.

## Compact Carousel Title Behavior Update

Compact carousel titles must be smaller and consistent to maximize visible recipe names.

Rules:

- one line only
- consistent font size across all compact carousel cards
- recommended size: 12-13 pt
- tail truncation only when necessary
- no per-card font shrinking
- no two-line compact titles
- no card height changes caused by title wrapping

---

# 6. Future Screen Behavior Template

For each future screen, define behavior before implementation.

Every future screen behavior section should answer:

1. What can the user tap?
2. What should change visually after tapping?
3. What should scroll horizontally?
4. What should scroll vertically?
5. What sections should exist beyond the static reference image?
6. What mock data is required to test the layout?
7. What controls are placeholder-only?
8. What should not be implemented yet?

Future screen behavior should be added before Codex implements that screen.

---

# 7. Universal Behavior Acceptance Criteria

For every screen:

* visual controls should not be fake/static unless explicitly decorative
* top selectors should update selected state
* horizontal carousels should scroll
* lists should contain enough mock data to test scrolling
* favorite/save buttons should visually toggle if shown
* input fields can be static or local-only until real functionality is requested
* no networking unless explicitly requested
* no persistence unless explicitly requested
* no subscriptions/payments unless explicitly requested
* no reference images used as app assets
* no hidden clipped content behind the tab bar
* screen behavior should match `SCREEN_BEHAVIOR.md`

# Explore Screen Behavior

Reference:

`Reference_Images/02_Explore_reference.png`

## Explore Purpose

Explore helps the user search, browse, and discover recipes by category, cuisine, and curated groups.

The reference image is a static snapshot. It does not show all search/filter states or all categories.

## Explore Data Rules

Explore must use centralized recipe data:

- `Recipe`
- `RecipeCategory`
- `SampleRecipes`
- `RecipeRepository`

Do not define local recipe arrays directly inside `ExploreView.swift`.

## Required Explore Sections

Explore should include:

1. Header / app identity area
2. Search bar
3. Filter/category chips
4. Visual cuisine/category browsing area
5. Recommended or trending recipe carousel
6. Popular or recently added recipe carousel if shown by the reference or needed to test scrolling

## Search Behavior

The search bar should use local UI state only.

When the user types:

- update local `searchText`
- filter displayed mock recipes if practical
- if filtering is not implemented yet, keep the UI stable and add a TODO comment

Do not add networking or backend search.

## Filter Chip Behavior

Filter/category chips should be state-driven.

When the user taps a chip:

- update selected chip/category
- visually update selected state
- filter mock recipe/category content if practical

Do not create static fake chips.

## Category Card Behavior

Category/cuisine cards should be tappable placeholder controls.

When tapped:

- update local selected category state or print/log placeholder action
- do not implement full Category List navigation unless explicitly requested in the task

## Carousel Behavior

Explore horizontal recipe rows must:

- use `HorizontalCarousel`
- contain enough mock recipes to test horizontal scrolling
- avoid clipping first/last cards
- use consistent compact recipe card title behavior
- use centralized recipe data

## Explore Acceptance Criteria

Explore is acceptable only if:

- it visually follows `02_Explore_reference.png`
- it uses shared design primitives
- it uses centralized recipe data
- search field uses local state
- filter chips update selected state
- recipe carousels scroll horizontally
- category cards are visually consistent
- no reference image is used as an app asset
- no networking is added
- no persistence is added
- no new main tab is added

# Explore Screen Behavior

Reference:

`Reference_Images/02_Explore_reference.png`

## Search Behavior

The search bar should use local state.

When the user types:

- update `searchText`
- filter visible mock recipes and/or categories if practical
- do not add backend search
- do not add networking

## Filter Chip Behavior

Filter chips must be tappable and state-driven.

When a filter chip is tapped:

- update selected filter state
- visually update selected chip
- filter mock recipe/category content if practical

Do not create static fake chips.

## Category Selection Behavior

Category/cuisine cards should be tappable placeholders.

When tapped:

- update selected category state
- selected category may show a subtle selected border or background
- do not show a selected border on a random category unless it reflects state
- do not navigate to Category List yet unless explicitly requested

## Explore Carousel Behavior

Recommended recipe rows must:

- use `HorizontalCarousel`
- scroll horizontally
- contain enough mock recipes to test scrolling
- avoid clipping first and last cards
- avoid being hidden behind the tab bar
- use compact one-line title truncation

## Explore Bottom Content Safety

Explore scroll content must include enough bottom inset so recipe cards are not cropped behind the fixed bottom tab bar.

## Explore Category Browser Behavior

The main Explore screen is a category/cuisine browser.

It should not show a bottom rectangular `Recommended Recipes` carousel.

The main content should consist of category sections with circular category tiles.

Required sections:

1. World Cuisine
2. Meat & Seafood
3. Vegetarian
4. Chicken
5. Bakery
6. High Protein

Each category tile should be tappable as a placeholder control.

When tapped:

- update local selected category state
- visually show the selected category if practical
- do not navigate to Category List yet unless explicitly requested

## Explore Category Recipe Data

Every category represented on the Explore screen must have at least 6 placeholder recipes available in centralized sample data.

This is required so later Category List and carousel functionality can be tested.

Required examples:

- Italian: at least 6 recipes
- Mexican: at least 6 recipes
- Korean: at least 6 recipes
- Fish: at least 6 recipes
- Meat: at least 6 recipes
- Seafood: at least 6 recipes
- Tofu & Tempeh: at least 6 recipes
- Beans & Lentils: at least 6 recipes
- Mushrooms: at least 6 recipes
- Chicken: at least 6 recipes
- Bakery: at least 6 recipes
- High Protein: at least 6 recipes

Recipe data must live in centralized sample data/repository files, not inside `ExploreView.swift`.

Use:

- `Recipe`
- `RecipeCategory`
- `SampleRecipes`
- `RecipeRepository`

Do not add networking or persistence yet.