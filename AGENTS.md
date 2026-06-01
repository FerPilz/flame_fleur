AGENTS.md
Project Identity
Flame & Fleur is a premium SwiftUI cooking app.
The public app name is:
Flame & Fleur
The internal Xcode project/folder name is:
Flame_Fleur
Do not rename the Xcode project, root folder, bundle folder, or existing repository.
Product Direction
Flame & Fleur should feel like a premium cooking companion: elegant, warm, editorial, calm, culinary, intelligent, spacious, and personal.
The app should feel like a boutique recipe book with modern AI assistance and practical planning tools.
It should not feel like a generic recipe utility, a technical dashboard, or a default SwiftUI starter app.
Main Foundation
Maintain the current app foundation:
Home
Explore
Planner
Favorites
Profile
Do not rename Explore to Discover.
Do not add AI Kitchen as a tab unless explicitly requested.
AI Kitchen can later appear as a feature inside Home, Explore, or Planner.
Design Source of Truth
Use the reference images in:
Reference_Images/
The reference images are visual references only.
Do not add the reference images to the app bundle.
Do not use the reference images as UI assets inside the app.
Recreate the design in SwiftUI using native views, reusable components, design tokens, mock data, and placeholder image treatments until real assets are explicitly added.
Reference Image Map
01_home_reference.png: Home tab
02_Explore_reference.png: Explore tab
03_Import_recipe_reference.png: Import Recipe secondary flow
04_Add_recipe_reference.png: Add Recipe secondary flow
05_Explore_category_reference.png: Explore category grid state
06_Category_list_reference.png: Explore category recipe list
07_Recipe_reference.png: Recipe detail overview
08_Recipe_ingredients_reference.png: Recipe detail ingredients state
09_Shopping_Cart_reference.png: Shopping cart/list flow
10_Shopping_Cart_Add_Item_reference.png: Add shopping item flow
11_Meal_Planner_reference.png: Planner tab
12_Profile_reference.png: Profile tab
13_Settings_reference.png: Profile settings secondary flow
14_Premium_Insights_reference.png: Premium insights visual teaser
Global Visual Language
Use a white/light premium cooking style.
The visual language should be:
warm
elegant
editorial
culinary
premium
calm
clean
inviting
organized
spacious
Avoid:
cold gray backgrounds
dark mode styling
neon colors
heavy shadows
clutter
tiny unreadable text
generic dashboard UI
default-looking SwiftUI screens
random colors per screen
overly technical AI/chatbot visuals
Color System
Create and use DesignSystem color tokens.
Recommended color roles:
appBackground: warm white or ivory
cardBackground: warm off-white or cream
elevatedCardBackground: white
primaryText: warm near-black
secondaryText: muted warm gray/brown
tertiaryText: lighter warm gray
olive: deep olive green
darkOlive: darker olive for strong actions
softOlive: pale olive background for chips
burntOrange: recipe/cooking CTA color
softOrange: pale orange chip/background
warmBorder: subtle beige border
premiumGold: premium/insight accent
Usage rules:
Use warm white/ivory for the app background.
Use warm off-white/cream for cards.
Use olive green for navigation, active states, positive actions, planner/cart actions, and profile accents.
Use burnt orange for cooking and recipe CTAs such as Start Cooking, Import Recipe, Save Recipe, and Add Ingredients.
Use subtle beige borders and dividers.
Do not use cold gray as a main card/background color.
Do not randomly introduce new accent colors.
Typography System
Use SwiftUI system fonts only.
Do not add custom font dependencies.
Use large readable typography.
Recommended hierarchy:
Brand/header title: 20-24 pt, semibold
Screen title: 28-34 pt, bold or semibold
Hero title: 22-28 pt, semibold or bold
Section header: 18-21 pt, semibold
Card title: 15-17 pt, semibold
Body text: 14-16 pt, regular
Metadata text: 11-13 pt, regular or medium
Button text: 15-17 pt, semibold
Tab labels: 10-11 pt, medium
Rules:
Do not use unreadably small text.
Do not use decorative fonts.
Keep text hierarchy clear and consistent.
Use short labels where possible.
Use muted text for metadata and secondary information.
Spacing System
Create and use spacing tokens.
Recommended spacing:
xxs: 4
xs: 8
sm: 12
md: 16
lg: 20
xl: 24
xxl: 32
Layout rules:
Main horizontal screen padding should usually be 20.
Card internal padding should usually be 14-20.
Section vertical spacing should usually be 24-32.
Keep layouts breathable.
Avoid cramped rows.
Avoid excessive empty space.
Use sticky bottom action areas where the reference screen shows a primary bottom action.
Radius and Shape System
Create and use radius tokens.
Recommended radii:
small: 8
medium: 12
large: 16
extraLarge: 24
hero: 28-32
pill: capsule
Shape rules:
Cards should have large rounded corners.
Buttons should be pill-shaped or large rounded rectangles.
Food category thumbnails should often be circular.
Recipe list images should use rounded rectangles.
Hero recipe images should use large rounded corners or a full-width rounded transition.
Avoid sharp dashboard boxes.
Card System
Cards should use:
warm cream or white backgrounds
large rounded corners
subtle beige borders
minimal shadows
clear internal spacing
readable title/body hierarchy
small metadata rows with icons when useful
Card types:
Hero recipe card
Recipe grid card
Circular category card
Recipe list row
Planner day card
Shopping item row
Profile stat card
Settings group card
Premium insight card
Avoid:
heavy shadows
cold gray cards
hard rectangles
too many nested borders
overly dense dashboard cards
Button System
There are two main button styles.
Burnt Orange Buttons
Use for recipe and cooking actions:
Start Cooking
Import Recipe
Save Recipe
Add Ingredients
Create Recipe
Style:
burnt orange background
white text
height around 48-56
capsule or large rounded rectangle
semibold text
Olive Green Buttons
Use for planning/cart/profile/positive actions:
Add Item
Add to Shopping List
Plan Meal
Save Preferences
Continue
Style:
deep olive background
white text
height around 48-56
capsule or large rounded rectangle
semibold text
Secondary Buttons
Use:
cream or white background
olive or burnt orange text
thin warm border
rounded shape
Icon Buttons
Use:
circular shape
white or cream background
subtle warm border
olive or near-black icon
size usually 36-44
Image Rules
Food photography is central to the design.
Rules:
Food photos should feel warm, natural, appetizing, and editorial.
Use scaledToFill.
Clip images to rounded or circular masks.
Never stretch images.
Do not use reference images as app images.
Use placeholder gradients or color blocks only until real app assets are explicitly provided.
Keep image treatment consistent by screen type.
Image shapes by use:
Home hero: large rounded rectangle
Explore cuisine/category: circular thumbnails
Category grid: circular thumbnails
Category list: small rounded thumbnails
Recipe detail: large full-width hero image
Ingredients state: same recipe hero language
Shopping item: small rounded thumbnail
Profile favorites: small circular/rounded food thumbnails
Navigation Rules
Use the existing tab foundation:
Home
Explore
Planner
Favorites
Profile
Recipe Detail can be reached from Home, Explore, Favorites, or Planner.
Category List can be reached from Explore.
Settings can be reached from Profile.
Shopping Cart can be reached from Planner or a future shopping entry point.
Import Recipe and Add Recipe are secondary flows, not main tabs.
Premium Insights is a visual premium/insight screen. Do not implement subscriptions, payments, or real paywall logic unless explicitly requested.
Screen Specifications
Home
Reference: 01_home_reference.png
Purpose:
Create a warm premium first impression and guide the user toward recipe discovery and AI-assisted cooking.
Required design elements:
top brand/header
small top action icons
warm white background
large hero recipe card
burnt-orange recipe/cooking CTA
recipe/category sections
rounded food cards
Home tab active
Implementation notes:
Home should feel inspiring, not like a dashboard.
Use mock data only.
Keep the layout spacious and visual.
Explore
Reference: 02_Explore_reference.png
Purpose:
Allow users to search and browse recipes by cuisine, category, and filters.
Required design elements:
top brand/header
search bar
filter chips
circular food category thumbnails
sectioned browsing layout
Explore tab active
Implementation notes:
Use circular thumbnails consistently.
Keep labels short.
Avoid square-heavy recipe grids.
Import Recipe
Reference: 03_Import_recipe_reference.png
Purpose:
Allow users to import a recipe from a link or source.
Required design elements:
Import Recipe title
warm hero/import card
URL or source input
large burnt-orange import button
recent imports or import options
warm cream grouped cards
Implementation notes:
This is a secondary flow.
Do not add real networking yet.
Use mock fields and placeholder states.
Add Recipe
Reference: 04_Add_recipe_reference.png
Purpose:
Allow users to manually create a recipe.
Required design elements:
title
image upload placeholder
grouped form sections
basic info fields
ingredients list rows
instructions list
sticky bottom burnt-orange save button
Implementation notes:
Keep forms elegant and calm.
Do not implement persistence yet.
Use local state only if needed for UI behavior.
Explore Category
Reference: 05_Explore_category_reference.png
Purpose:
Show a visual cuisine/category selection experience.
Required design elements:
large centered title
subtitle
search or filter element
circular food thumbnail grid
short category labels
Explore tab active
Implementation notes:
This screen should feel visual and editorial.
Use as the category-browsing state or a sub-screen of Explore.
Category List
Reference: 06_Category_list_reference.png
Purpose:
Show recipes inside a selected category.
Required design elements:
back button
category title
filter chips
vertical recipe list rows
small image left
recipe title and metadata
favorite/save icon right
optional horizontal recommendation strip
Implementation notes:
Rows should be compact but readable.
Use warm card backgrounds and subtle dividers.
Recipe Detail
Reference: 07_Recipe_reference.png
Purpose:
Show the main recipe overview.
Required design elements:
large top hero food image
overlay circular back/share/favorite buttons
white rounded content panel below image
recipe title
metadata row for time, servings, difficulty, calories
prep/cook information
ingredient or instruction preview
sticky bottom burnt-orange Start Cooking button
Implementation notes:
This should be one of the most visually appetizing screens.
The food hero image should dominate the top.
Use mock recipe data.
Recipe Ingredients
Reference: 08_Recipe_ingredients_reference.png
Purpose:
Show the ingredient-focused recipe state.
Required design elements:
same recipe hero/header language as Recipe Detail
ingredients section title
serving stepper/control
ingredient rows with checkbox or icon
quantity, unit, and item name
sticky bottom action to add all ingredients
Implementation notes:
Ingredient rows must be clean and scannable.
Do not add real cart persistence yet.
Shopping Cart
Reference: 09_Shopping_Cart_reference.png
Purpose:
Show the organized shopping list.
Required design elements:
shopping cart/list header
summary stats card
grouped shopping sections
item rows with checkbox, thumbnail, quantity, and optional price/status
sticky bottom green action area
Implementation notes:
Olive green is the primary action color here.
Keep dense list content readable.
Add Shopping Item
Reference: 10_Shopping_Cart_Add_Item_reference.png
Purpose:
Allow users to add items to the shopping list.
Required design elements:
add item title/card
search or item input
category chips
suggested ingredient list
green Add Item button
Implementation notes:
This should feel connected to the Shopping Cart screen.
It can be a modal, sheet, or pushed screen depending current architecture.
Meal Planner
Reference: 11_Meal_Planner_reference.png
Purpose:
Help the user plan meals across days.
Required design elements:
Meal Planner title
date/week selector
day/calendar strip
meal grid or day cards
small dish thumbnails
goal/nutrition summary
premium insight teaser
sticky bottom planning action
Implementation notes:
Planner can be denser than other screens, but must remain organized.
Use olive green for planning actions and active states.
Profile
Reference: 12_Profile_reference.png
Purpose:
Show personal cooking identity, preferences, and progress.
Required design elements:
avatar
name
short subtitle
stats cards
preference chips
favorite cuisine or recipe carousel
achievements/progress area
Profile tab active
Implementation notes:
Profile should feel personal and warm.
It should not feel like only account administration.
Settings
Reference: 13_Settings_reference.png
Purpose:
Manage account and app preferences.
Required design elements:
back button
Settings title
profile/account row
grouped setting sections
rows with icons, labels, current values, chevrons, or toggles
white/warm card groups
Implementation notes:
Settings should be calm and organized.
Avoid visual clutter.
Premium Insights
Reference: 14_Premium_Insights_reference.png
Purpose:
Preview premium nutrition and planning intelligence.
Required design elements:
premium title
nutrition summary
circular score/progress component
macro bars
dish contribution list
vitamin/mineral insight cards
bottom premium CTA
Implementation notes:
Do not implement real subscriptions.
Do not implement real payment logic.
This is a visual premium insights screen only unless otherwise requested.
SwiftUI Implementation Rules
Use SwiftUI only.
Use the existing Xcode project.
Do not recreate the project.
Do not rename root folders.
Do not add dependencies unless explicitly requested.
Do not add networking unless explicitly requested.
Do not add persistence unless explicitly requested.
Use mock/sample data only until requested otherwise.
Keep one component per file.
Avoid catch-all files such as Components.swift.
Prefer reusable UI primitives.
Use DesignSystem files for colors, typography, spacing, radius, and shadows.
Keep main screens readable on modern iPhone sizes.
Preserve safe-area behavior.
Use sticky bottom bars where the reference screen uses bottom primary actions.
File Organization
Main app source folder:
Flame_Fleur/Flame_Fleur/
Preferred structure:
App/
DesignSystem/
Features/Home/
Features/Explore/
Features/Planner/
Features/Favorites/
Features/Profile/
Shared/UI/
Shared/Models/
Shared/SampleData/
Secondary screens should live near their parent feature unless they clearly become shared flows.
Examples:
Category list should live under Features/Explore/
Recipe detail can live under Features/Explore/ or Shared depending reuse
Settings should live under Features/Profile/
Shopping cart can live under Features/Planner/ unless a Shopping feature is created later
Project File Rules
Only edit project.pbxproj if required for Xcode target membership.
If project.pbxproj is edited, explain why.
If new files are added but project.pbxproj is not edited, clearly state whether manual Target Membership is required in Xcode.
Build and Reporting Rules
After every implementation task, report:
Files created
Files modified
Whether project.pbxproj changed
Whether manual Xcode Target Membership is needed
Any build risks
git diff –stat
When requested, run an Xcode build check.
If build errors occur, show the exact errors before making fixes.
Universal Acceptance Criteria
For every screen:
The screen must visually follow the selected reference image.
The screen must use shared DesignSystem tokens.
The screen must maintain the current app foundation.
The screen must not add new tabs.
The screen must not add networking.
The screen must not add persistence.
The screen must not add subscription/payment logic.
The screen must use mock/sample data only.
The screen must not use reference images as UI assets.
The screen must recreate the design in SwiftUI.
The screen must keep one component per file.
The screen must avoid generic dashboard styling.
The screen must compile successfully.
The implementation must be limited to the requested task.

## Behavior Source of Truth

Use `SCREEN_BEHAVIOR.md` for screen interaction rules.

Reference images are static snapshots. They do not represent the full functionality of each screen.

When implementing a screen, Codex must follow both:

- `DESIGN_TRANSLATION.md` for visual design
- `SCREEN_BEHAVIOR.md` for user interactions and dynamic behavior

## Data Architecture Rules

Recipe data must not be scattered inside feature views or UI components.

Use centralized models and sample data:

- `Shared/Models/Recipe.swift`
- `Shared/SampleData/SampleRecipes.swift`
- `Shared/Services/RecipeRepository.swift`

Feature screens should request recipe data from the repository or sample data layer.

UI components should accept model objects, such as `Recipe`, instead of many unrelated string parameters when practical.

Do not add networking, persistence, or a real database until explicitly requested.