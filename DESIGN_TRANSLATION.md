# DESIGN_TRANSLATION.md

## Purpose

This document translates the selected Flame & Fleur reference images into concrete SwiftUI design instructions for Codex.

Use this file together with:

* `AGENTS.md`
* `REFERENCE_MANIFEST.md`
* `SCREEN_BEHAVIOR.md`
* `Reference_Images/`

The reference images are visual references only. They should not be used as app image assets.

The goal is to recreate the visual language, layout hierarchy, spacing, typography, card system, button system, navigation style, and overall premium cooking feel of the selected reference images in SwiftUI.

Some reference images may show previous branding such as `CookFlow`. Do not copy old brand names. The app being built is:

**Flame & Fleur**

---

# 1. Product and Visual Direction

Flame & Fleur is a premium SwiftUI cooking app.

The app should feel:

* warm
* elegant
* editorial
* culinary
* premium
* calm
* intelligent
* organized
* personal
* spacious
* inviting

The app should feel like a boutique recipe book with modern AI assistance and practical planning tools.

The app should not feel like:

* a generic recipe app
* a technical dashboard
* a default SwiftUI starter app
* a cold productivity app
* a dark-mode-first app
* a neon AI tool
* a cluttered meal tracker

## Core Design Statement

Build a white/light premium cooking app with warm editorial styling, olive-green navigation/action states, burnt-orange cooking CTAs, rounded cream cards, natural food photography, and spacious layouts.

---

# 2. Global Implementation Contract

All screens must use shared design primitives. Do not recreate layout rules manually inside each feature screen.

## Required Shared Layout Components

Codex should create and reuse these components:

* `AppScreen`: global screen wrapper, background, safe area, content margins
* `AppHeader`: app title/header with optional action icons
* `TopSegmentSelector`: state-driven top selector
* `HorizontalCarousel`: reusable horizontal scrolling card row
* `FoodImagePlaceholder`: all placeholder image treatments
* `SurfaceCard`: reusable rounded card surface
* `SectionHeaderView`: section title and optional trailing action
* `PrimaryButton`: orange/olive primary actions
* `IconCircleButton`: circular icon actions
* `BottomActionBar`: sticky bottom action area when needed

## Feature Screen Restrictions

Feature screens must not create their own:

* random horizontal margins
* random fonts
* random colors
* random image aspect ratios
* random carousel behavior
* random card radii
* random shadows

Feature screens should compose shared UI components.

## Color Rule

Use only `AppColors` in feature screens.

Do not use raw `Color` values inside feature screens.

## Typography Rule

Use only `AppTypography` in feature screens.

Do not use arbitrary `.font(.system(...))` in feature screens except inside approved shared components.

## Spacing Rule

Use only `AppSpacing` in feature screens.

Do not use arbitrary numeric padding values in feature screens unless there is a documented exception.

## Image Rule

Use `FoodImagePlaceholder` or approved image components for all image placeholders.

No placeholder image may overflow its container.

## Carousel Rule

Use `HorizontalCarousel` for all horizontal card rows.

No custom horizontal `ScrollView` should be created inside feature screens unless explicitly approved.

## Header Rule

Use `AppHeader` for top app identity areas.

If the header should remain stable while the screen scrolls, keep `AppHeader` outside the `ScrollView`.

## Visual QA Rule

Before a screen is accepted:

* no horizontal clipping
* no title wrapping unless the reference or this document allows wrapping
* no cropped placeholder images
* no static fake controls
* no random colors
* no random fonts
* no invented sections
* no reference images used as app assets

---

# 3. Color System

Create color tokens in `DesignSystem/AppColors.swift`.

Use role-based names, not one-off color names.

## Recommended Color Roles

| Token                    | Suggested Hex | Purpose                                         |
| ------------------------ | ------------: | ----------------------------------------------- |
| `appBackground`          |     `#FFFDF8` | Main app background. Warm ivory/white.          |
| `cardBackground`         |     `#F8F1E7` | Warm cream card background.                     |
| `elevatedCardBackground` |     `#FFFFFF` | Elevated inner cards and form fields.           |
| `primaryText`            |     `#1D1A15` | Main readable near-black text.                  |
| `secondaryText`          |     `#7C7466` | Metadata, subtitles, secondary descriptions.    |
| `tertiaryText`           |     `#A69B8B` | Small helper labels.                            |
| `olive`                  |     `#314B25` | Main green accent.                              |
| `darkOlive`              |     `#203617` | Strong green buttons and selected states.       |
| `softOlive`              |     `#EAF1E4` | Pale green chips and soft selected backgrounds. |
| `burntOrange`            |     `#D96F32` | Recipe/cooking/import primary CTA.              |
| `softOrange`             |     `#F7E1D3` | Pale orange chips or highlights.                |
| `warmBorder`             |     `#E8DED0` | Subtle dividers and card outlines.              |
| `premiumGold`            |     `#C89B3C` | Premium insight and premium teaser accents.     |
| `heartRed`               |     `#C94A3A` | Selected favorite heart.                        |
| `error`                  |     `#B94735` | Error state only.                               |
| `success`                |     `#3F6B32` | Positive completion state only.                 |

## Color Usage Rules

Use warm white/ivory as the default screen background.

Use warm cream for large grouped surfaces and cards.

Use white for elevated cards, form fields, and content panels.

Use olive green for:

* active tab state
* selected states
* positive actions
* planner actions
* shopping/cart actions
* profile accents
* subtle AI-related states when not recipe-specific

Use burnt orange for:

* recipe actions
* cooking actions
* import recipe actions
* save recipe actions
* start cooking
* add ingredients from recipe

Use premium gold only for:

* premium insights
* subscription teaser
* nutrition intelligence highlights
* upgrade badges

Use heart red only for selected favorite hearts.

Avoid:

* cold gray card backgrounds
* neon accent colors
* multiple competing greens
* random colors per screen
* black backgrounds
* heavy gradients unless used very subtly

---

# 4. Typography System

Use SwiftUI system fonts only.

Do not add custom font dependencies.

Create typography helpers in `DesignSystem/AppTypography.swift`.

## Recommended Type Roles

| Role           |  Size | Weight          | Usage                                                 |
| -------------- | ----: | --------------- | ----------------------------------------------------- |
| `brandTitle`   | 26-30 | Medium/Semibold | App title/header mark. Serif system design preferred. |
| `screenTitle`  | 28-34 | Bold/Semibold   | Main screen titles.                                   |
| `heroTitle`    | 20-26 | Bold/Semibold   | Hero card titles.                                     |
| `sectionTitle` | 16-20 | Semibold        | Section headers.                                      |
| `cardTitle`    | 13-16 | Semibold        | Compact recipe/category/card titles.                  |
| `body`         | 14-16 | Regular         | Body copy and descriptions.                           |
| `bodyEmphasis` | 14-16 | Semibold        | Emphasized body labels.                               |
| `metadata`     | 10-13 | Medium/Regular  | Time, calories, servings, tags.                       |
| `button`       | 14-16 | Semibold        | Button labels.                                        |
| `tabLabel`     | 10-11 | Medium          | Tab bar labels.                                       |

## Typography Rules

Keep text readable.

Avoid decorative custom fonts.

Avoid overusing all caps.

Use short labels.

Use secondary text for metadata.

Use clear hierarchy:

1. Brand title or screen title
2. Hero title
3. Section header
4. Card title
5. Body/metadata

## Brand Title Rule

The app title should display on one line:

`Flame & Fleur`

Use an elegant serif-style system font when possible:

```swift
.system(size: 26-30, weight: .medium, design: .serif)
```

The title should be centered, visually close to the top header area, and must not wrap.

Use:

```swift
.lineLimit(1)
```

## Recipe Title Rules

The Featured hero recipe title may wrap to two lines if needed.

Compact carousel recipe titles must stay on one line.

Compact carousel recipe titles must use the same font size across all cards.

Do not shrink individual compact titles to fit.

Maximize the amount of visible title text while preserving readability.

Use the available card width efficiently.

Use:

```swift
.lineLimit(1)
.truncationMode(.tail)
```

Truncate only when the full title cannot fit naturally.

Do not allow compact cards to grow taller because of title wrapping.

This applies to:

* Community carousel
* Top Picks carousel
* AI Recommend carousel
* other compact horizontal recipe carousels

---

# 5. Spacing System

Create spacing tokens in `DesignSystem/AppSpacing.swift`.

## Recommended Spacing Tokens

| Token          | Value | Usage                                       |
| -------------- | ----: | ------------------------------------------- |
| `xxs`          |     4 | Tiny gaps between icon/text.                |
| `xs`           |     8 | Small internal gaps.                        |
| `sm`           |    12 | Row/card gaps.                              |
| `md`           |    16 | Common internal padding.                    |
| `lg`           |    20 | Main horizontal screen margin.              |
| `xl`           |    24 | Major internal card padding.                |
| `xxl`          |    32 | Section separation.                         |
| `section`      | 28-32 | Vertical space between sections.            |
| `screenTop`    | 16-24 | Top content padding below safe area/header. |
| `bottomAction` | 72-92 | Reserved bottom sticky action area.         |

## Spacing Rules

Most screens should use 20 pt horizontal padding.

Card internal padding should usually be 14-20 pt.

Section vertical gaps should usually be 24-32 pt.

Dense screens such as Planner and Shopping Cart can be tighter, but must remain readable.

Avoid edge-to-edge text.

Avoid cramped list rows.

Use sticky bottom action areas when the reference shows a strong bottom CTA.

Scrollable content must include enough bottom inset so lower content is not hidden behind the tab bar.

---

# 6. Radius, Shape, and Surface System

Create radius tokens in `DesignSystem/AppRadius.swift`.

## Recommended Radius Tokens

| Token        |   Value | Usage                           |
| ------------ | ------: | ------------------------------- |
| `small`      |       8 | Small tags, tiny image corners. |
| `medium`     |      12 | Form fields, small cards.       |
| `large`      |      16 | Standard cards/buttons.         |
| `extraLarge` |      24 | Main cards and panels.          |
| `hero`       |   28-32 | Hero cards and large panels.    |
| `pill`       | Capsule | Chips and primary buttons.      |

## Shape Rules

Use large rounded corners throughout.

Cards should feel soft and premium.

Buttons should be pill-shaped or large rounded rectangles.

Explore/category thumbnails should often be circular.

Recipe list images should be rounded rectangles.

Hero recipe images should be large, rounded, and visually dominant.

Avoid sharp corners.

Avoid generic rectangular dashboard blocks.

---

# 7. Card System

Cards are central to the visual language.

## Global Card Rules

Cards should use:

* warm cream or white backgrounds
* large rounded corners
* subtle beige borders
* minimal shadows
* strong internal spacing
* clear title/body hierarchy
* small metadata rows with icons where useful

## Recommended Card Types

### Hero Recipe Card

Used on Home and Recipe-related screens.

* Large rounded rectangle
* Image-forward if image assets are available
* Warm cream or white surface
* Strong title
* Metadata row
* Burnt-orange CTA if action-oriented
* Image area should be visually important
* Hero title may use two lines if needed

### Compact Recipe Card

Used in horizontal carousels.

* Rounded image area at top
* Title below image
* Optional creator overlay when used for community content
* Metadata row
* Favorite icon
* One-line title with tail truncation
* Consistent font size across all compact cards

### Circular Category Card

Used in Explore/category screens.

* Circular image/placeholder
* Short label below
* Minimal metadata
* No heavy card background unless needed

### Recipe List Row

Used in Category List.

* Rounded white/cream row
* Small rounded image left
* Text center
* Metadata row
* Favorite/save icon right

### Planner Day Card

Used in Meal Planner.

* Rounded card
* Day/date label
* Meal thumbnail or compact dish row
* Goal score or calorie/nutrition summary
* Olive active/positive accents

### Shopping Item Row

Used in Shopping Cart.

* Checkbox or completion indicator
* Item name and quantity
* Optional thumbnail/category icon
* Olive action/check states

### Settings Group Card

Used in Settings.

* Grouped rows
* White or warm cream background
* Subtle dividers
* Icons, labels, values, chevrons/toggles

### Premium Insight Card

Used in Premium Insights.

* White or cream surface
* Premium gold/olive highlights
* Macro bars, score circles, nutrition summaries
* Clear readable analytics

## Avoid

* heavy shadows
* cold gray surfaces
* sharp rectangles
* overly nested cards
* cluttered dashboard-style panels

---

# 8. Button System

Recommended files:

* `Shared/UI/PrimaryButton.swift`
* `Shared/UI/SecondaryButton.swift`
* `Shared/UI/IconCircleButton.swift`
* `Shared/UI/FilterChip.swift`

## Primary Button: Burnt Orange

Use for recipe/cooking actions:

* Start Cooking
* View Recipe
* Import Recipe
* Save Recipe
* Add Ingredients
* Create Recipe

Style:

* burnt orange background
* white text
* height around 44-56
* capsule or large rounded rectangle
* semibold label
* optional leading icon if useful

## Primary Button: Olive Green

Use for planning/cart/profile/positive actions:

* Add Item
* Add to Shopping List
* Plan Meal
* Save Preferences
* Continue
* Apply Changes

Style:

* deep olive background
* white text
* height around 48-56
* capsule or large rounded rectangle
* semibold label

## Secondary Button

Use for supporting actions.

Style:

* cream or white background
* olive or burnt orange text depending context
* thin warm border
* rounded shape
* height around 40-48

## Icon Circle Button

Use for:

* back
* share
* favorite
* settings
* menu
* close
* cart/profile actions

Style:

* circular
* size 32-44
* white or cream background
* subtle warm border
* olive or near-black icon

## Hamburger/Menu Icon Rule

The top-left hamburger/menu icon must use three horizontal lines.

Do not use a two-line menu icon.

The icon should stay compact and aligned with the reference.

## Favorite Heart Rule

Unselected favorite hearts should use an outline heart.

Selected favorite hearts should use a red or warm-red filled heart.

The selected state should remain visually highlighted after tapping.

---

# 9. Image Rules

Food imagery is essential to the app’s premium feel.

## Image Style

Food images and placeholders should feel:

* warm
* natural
* editorial
* appetizing
* softly lit
* premium

Do not use:

* cold stock photo style
* harsh shadows
* overly saturated fast-food colors
* distorted/stretch images
* screenshots as app UI assets

## Technical Rules

Use `scaledToFill`.

Always clip images to the intended shape.

Never stretch images.

Use placeholders until real assets are provided.

Reference images are not app assets.

## Image Shapes by Use

| Use                      | Shape                               |
| ------------------------ | ----------------------------------- |
| Home hero                | Large rounded rectangle             |
| Explore category/cuisine | Circle                              |
| Category grid            | Circle                              |
| Category recipe list     | Small rounded rectangle             |
| Recipe detail            | Large full-width hero image         |
| Ingredients state        | Same hero language as Recipe Detail |
| Shopping item            | Small rounded thumbnail or icon     |
| Profile favorite recipe  | Small circle or rounded thumbnail   |
| Planner meal card        | Small rounded thumbnail             |

## Placeholder Image Treatment

Until actual assets are provided:

* use warm gradient blocks
* use abstract food-like shapes only inside the allocated image container
* use soft cream/olive/orange backgrounds
* do not use plain gray placeholders
* do not import reference PNGs into `Assets.xcassets`

## Placeholder Sizing Rule

All recipe image placeholders/icons in the same carousel must use consistent sizing.

The placeholder artwork must fill its allocated image container consistently.

No placeholder artwork may overflow its container.

No card image may appear randomly smaller or larger than other cards in the same carousel.

---

# 10. Navigation Rules

Maintain the current foundation:

* Home
* Explore
* Planner
* Favorites
* Profile

Do not add new main tabs unless explicitly requested.

Do not rename Explore to Discover.

Do not add AI Kitchen as a tab yet.

AI Kitchen can later appear as:

* Home hero CTA
* Explore smart filter
* Planner meal generation action

## Screen Routing

Recipe Detail can be reached from:

* Home
* Explore
* Favorites
* Planner

Category List is reached from:

* Explore

Recipe Ingredients is part of:

* Recipe Detail

Shopping Cart can be reached from:

* Planner
* future shopping entry point

Add Shopping Item is reached from:

* Shopping Cart

Settings is reached from:

* Profile

Import Recipe and Add Recipe are secondary flows from:

* Home
* Explore

Premium Insights is a secondary visual screen from:

* Planner
* Profile
* premium teaser areas

## Navigation Style

Use:

* clean top bars
* simple back buttons
* circular icon buttons for top actions
* sticky bottom bars for primary bottom actions
* tab bar for main foundation

Avoid:

* deeply nested flows early
* adding extra tabs
* generic navigation bars when custom layout is required
* inconsistent back button styles

---

# 11. Home Screen Visual Specification

Reference:

`Reference_Images/01_home_reference.png`

## Purpose

Create a warm premium first impression and guide the user toward recipe discovery and AI-assisted cooking.

## Required Visual Elements

* top brand/header
* compact top action icons
* three-line hamburger/menu icon
* warm white background
* top category selector
* Featured section
* Community section
* Top Picks section
* AI Recommend section below the first viewport
* rounded food cards
* Home tab active

## Header

The title must display on one line:

`Flame & Fleur`

Use an elegant serif-style system font.

The title should be slightly larger and closer to the top header area than the first implementation, without pushing the top category selector downward.

The title must not wrap.

## Top Category Selector

The Home top selector must include:

* Featured
* Community
* Top Picks
* AI Recommend

Use compact icons and labels.

Featured should be active by default.

Use olive active state and subtle underline.

The top selector should be visually stable and not decorative.

## Featured Section

The Featured card should visually dominate the first content area.

The card should be taller than compact recipe cards.

The card should include:

* title: `Creamy Lemon Herb Salmon`
* subtitle: `Light, fresh & zesty`
* metadata: `30 min`, `650 cal`, `2 servings`
* burnt-orange `View Recipe` button
* image placeholder area on the right
* small favorite heart button

The Featured hero title may wrap to two lines if needed.

Do not force the Featured hero title to one line if it hurts readability.

## Community Section

Community should appear below Featured.

Community cards should include:

* image placeholder
* favorite heart button
* creator/user overlay near the lower edge of the image
* recipe title
* metadata row

The creator/user information should be an overlay on the image area, similar to the reference.

It should include:

* tiny circular avatar placeholder
* muted username text

Do not place the username as a separate full line below the title.

## Top Picks Section

Top Picks should appear below Community.

Top Picks cards should match the compact card system.

Card titles must be one line with tail truncation if needed.

## AI Recommend Section

AI Recommend must exist below Top Picks.

It should not be visible in the initial entry viewport.

It should become visible only through scrolling or tapping the `AI Recommend` top selector item.

Do not add an AI Kitchen tab.

## Bottom Tab Bar

Keep the app foundation:

* Home
* Explore
* Planner
* Favorites
* Profile

Home must be active.

The bottom tab bar should remain fixed.

The scrollable Home content must include enough bottom padding so lower carousel cards are not cropped behind the tab bar.


## Home Layout Density Rule

The Home screen should preserve the reference-like entry viewport composition.

The entry viewport should show:

- fixed header
- fixed top category selector
- Featured section
- Community section
- Top Picks section beginning clearly
- the Top Picks carousel should be fully visible enough to understand the section

To achieve this:

- reduce vertical spacing between Home sections
- keep section headers compact
- avoid excessive padding above and below carousels
- reduce carousel card vertical padding if needed
- keep the Featured card visually dominant but not so tall that it pushes Top Picks out of view
- do not let `AI Recommend` appear in the initial viewport

Recommended Home section spacing:

- spacing after top selector: 8-12
- spacing between section header and carousel/card: 6-8
- spacing between Home sections: 12-18
- bottom content inset: enough to avoid tab bar cropping

## Compact Carousel Title Size Rule

Compact carousel card titles should use a smaller, consistent font size to maximize visible text while preserving readability.

Recommended compact carousel title size:

- 10-11 pt
- semibold
- one line only
- `lineLimit(1)`
- `truncationMode(.tail)`

Do not shrink titles per-card individually.

All compact carousel card titles must use the same font size.

Use card width efficiently to show the maximum amount of recipe title text.

Do not allow compact title text to wrap to a second line.

---

# 12. Screen-by-Screen Visual Specs

## 02 Explore

Reference:

`Reference_Images/02_Explore_reference.png`

Purpose:

Allow users to search and browse recipes by cuisine, category, and filters.

Required elements:

* top brand/header
* search bar
* filter chips
* circular food category thumbnails
* sectioned browsing layout
* Explore tab active

Visual priorities:

* searchable
* visual
* organized
* editorial
* easy to scan

## 03 Import Recipe

Reference:

`Reference_Images/03_Import_recipe_reference.png`

Purpose:

Allow users to import a recipe from a link or source.

Required elements:

* Import Recipe title
* warm hero/import card
* URL or source input field
* large burnt-orange import button
* recent imports or import options
* warm cream grouped cards

Do not add real networking yet.

## 04 Add Recipe

Reference:

`Reference_Images/04_Add_recipe_reference.png`

Purpose:

Allow users to manually create a recipe.

Required elements:

* screen title
* image upload placeholder
* grouped form sections
* basic info fields
* ingredients list rows
* instructions list
* sticky bottom burnt-orange save button

Do not add persistence yet.

## 05 Explore Category

Reference:

`Reference_Images/05_Explore_category_reference.png`

Purpose:

Show a visual cuisine/category selection experience.

Required elements:

* large screen title
* subtitle or supporting text
* search or filter element if present
* circular food thumbnail grid
* short category labels
* Explore tab active

## 06 Category List

Reference:

`Reference_Images/06_Category_list_reference.png`

Purpose:

Show recipes inside a selected category.

Required elements:

* back button
* category title
* filter chips
* vertical recipe list rows
* small image left
* title and metadata center
* favorite/save icon right
* optional horizontal recommendation strip if present

## 07 Recipe Detail

Reference:

`Reference_Images/07_Recipe_reference.png`

Purpose:

Show the main recipe overview.

Required elements:

* large top hero food image area
* overlay circular back/share/favorite buttons
* white or warm rounded content panel below image
* recipe title
* metadata row for time, servings, difficulty, calories
* prep/cook information
* ingredient or instruction preview
* sticky bottom burnt-orange Start Cooking button

## 08 Recipe Ingredients

Reference:

`Reference_Images/08_Recipe_ingredients_reference.png`

Purpose:

Show the ingredient-focused recipe state.

Required elements:

* same visual header/hero language as Recipe Detail
* ingredients section title
* serving stepper/control
* ingredient rows with checkbox or icon
* quantity, unit, and item name
* sticky bottom action to add all ingredients

## 09 Shopping Cart

Reference:

`Reference_Images/09_Shopping_Cart_reference.png`

Purpose:

Show the organized shopping list/cart experience.

Required elements:

* shopping cart/list header
* summary stats card
* grouped shopping sections
* item rows with checkbox, thumbnail/icon, quantity, and optional price/status
* sticky bottom olive-green action area

## 10 Shopping Cart Add Item

Reference:

`Reference_Images/10_Shopping_Cart_Add_Item_reference.png`

Purpose:

Allow users to add items to the shopping list.

Required elements:

* Add Item title/card
* search or item input
* category chips
* suggested ingredient list
* green Add Item button

## 11 Meal Planner

Reference:

`Reference_Images/11_Meal_Planner_reference.png`

Purpose:

Help the user plan meals across days.

Required elements:

* Meal Planner title
* date/week selector
* day/calendar strip
* meal grid or day cards
* small dish thumbnails
* goal/nutrition summary
* premium insight teaser
* sticky bottom planning action if present

## 12 Profile

Reference:

`Reference_Images/12_Profile_reference.png`

Purpose:

Show personal cooking identity, preferences, progress, and saved context.

Required elements:

* avatar
* name
* short subtitle
* stats cards
* preference chips
* favorite cuisine or recipe carousel
* achievements/progress area
* Profile tab active

## 13 Settings

Reference:

`Reference_Images/13_Settings_reference.png`

Purpose:

Manage account and app preferences.

Required elements:

* back button
* Settings title
* profile/account row
* grouped setting sections
* rows with icons, labels, values, chevrons, or toggles
* white/warm card groups

## 14 Premium Insights

Reference:

`Reference_Images/14_Premium_Insights_reference.png`

Purpose:

Preview premium nutrition and planning intelligence.

Required elements:

* premium title
* nutrition summary
* circular score/progress component
* macro bars
* dish contribution list
* vitamin/mineral insight cards
* bottom premium CTA

Do not implement real subscriptions or payments yet.

---

# 13. Shared Components to Create

Codex should prefer reusable components when a pattern appears more than once.

Recommended shared UI files:

* `Shared/UI/AppScreen.swift`
* `Shared/UI/AppHeader.swift`
* `Shared/UI/TopSegmentSelector.swift`
* `Shared/UI/HorizontalCarousel.swift`
* `Shared/UI/FoodImagePlaceholder.swift`
* `Shared/UI/PrimaryButton.swift`
* `Shared/UI/SecondaryButton.swift`
* `Shared/UI/IconCircleButton.swift`
* `Shared/UI/SurfaceCard.swift`
* `Shared/UI/SectionHeaderView.swift`
* `Shared/UI/FilterChip.swift`
* `Shared/UI/RecipeMetadataRow.swift`
* `Shared/UI/BottomActionBar.swift`

Recommended feature-specific components:

Home:

* `HomeHeroCard.swift`
* `HomeRecipeCard.swift`

Explore:

* `ExploreCategoryCard.swift`
* `CategoryRecipeRow.swift`

Recipe:

* `RecipeHeroHeader.swift`
* `IngredientRow.swift`

Planner:

* `PlannerDayCard.swift`
* `MealPlannerSummaryCard.swift`

Shopping:

* `ShoppingItemRow.swift`

Profile:

* `ProfileStatCard.swift`
* `PreferenceChip.swift`

## Component Rules

One component per file.

Avoid catch-all files such as `Components.swift`.

Do not create excessive abstractions too early.

Only extract reusable components when they clearly support multiple screens or keep files readable.

---

# 14. Codex Universal Acceptance Criteria

For every implementation task, Codex must follow these criteria:

* Read `AGENTS.md`.
* Read `REFERENCE_MANIFEST.md`.
* Read `DESIGN_TRANSLATION.md`.
* Read `SCREEN_BEHAVIOR.md`.
* Use the correct reference image named in the task.
* Implement only the requested screen or foundation task.
* Maintain the foundation: Home, Explore, Planner, Favorites, Profile.
* Do not add new tabs.
* Do not rename the Xcode project.
* Do not rename root folders.
* Do not add dependencies.
* Do not add networking.
* Do not add persistence.
* Do not add subscription or payment logic.
* Use mock/sample data only.
* Use SwiftUI only.
* Use DesignSystem tokens for colors, typography, spacing, radius, and shadows.
* Do not use reference images as UI assets.
* Recreate the design in native SwiftUI.
* Keep one component per file.
* Avoid generic dashboard styling.
* Avoid default-looking SwiftUI UI.
* Keep layouts readable on modern iPhone sizes.
* Respect safe areas.
* Use sticky bottom actions where the reference shows them.
* Report all created and modified files.
* Report whether `project.pbxproj` changed.
* Report whether manual Xcode Target Membership is required.
* Report build risks.
* Run `git diff --stat` after changes.
* Run an Xcode build check when requested.

---

# 15. Recommended Implementation Order

Use this order to reduce rework:

1. Add and maintain `AGENTS.md`, `REFERENCE_MANIFEST.md`, `DESIGN_TRANSLATION.md`, and `SCREEN_BEHAVIOR.md`
2. Create DesignSystem files
3. Create shared UI primitives
4. Create AppShell with the five-tab foundation
5. Implement Home
6. Implement Explore
7. Implement Explore Category
8. Implement Category List
9. Implement Recipe Detail
10. Implement Recipe Ingredients
11. Implement Meal Planner
12. Implement Shopping Cart
13. Implement Add Shopping Item
14. Implement Profile
15. Implement Settings
16. Implement Import Recipe
17. Implement Add Recipe
18. Implement Premium Insights

Do not implement all screens in one Codex task.

Use one screen, one reference image, one build check, one commit.

---

# 16. Visual QA Process

After Codex implements each screen:

1. Open the screen in Xcode Preview or Simulator.
2. Take a screenshot of the implemented screen.
3. Compare it to the reference image.
4. Ask ChatGPT for a visual QA pass.
5. Create a focused Codex patch prompt.
6. Build again.
7. Commit.

Visual QA should compare:

* spacing
* typography
* color
* card radius
* image shape
* button shape
* hierarchy
* navigation
* missing elements
* unnecessary elements
* interaction behavior
* overall mood

Do not move to the next major screen until the current one is visually close enough and functionally coherent.

---

# 17. Final Design Rule

When in doubt, choose:

* warmer
* cleaner
* more spacious
* more rounded
* more editorial
* less cluttered
* fewer colors
* clearer hierarchy
* stronger food imagery
* simpler actions

The app should always feel like Flame & Fleur, not a generic generated app.
