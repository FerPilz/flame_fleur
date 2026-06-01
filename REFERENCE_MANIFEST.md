REFERENCE_MANIFEST.md
Purpose
This file maps each visual reference image to the intended Flame & Fleur screen, flow, or app state.
The reference images are used to guide SwiftUI implementation. They are not app assets.
Codex should use this manifest together with:
•
•
•
AGENTS.md
DESIGN_TRANSLATION.md
Reference_Images/
Important Rules
•
•
•
•
•
•
•
•
•
•
•
•
Do not add the reference images to the app bundle.
Do not use the reference images as UI images inside the app.
Do not copy old visible branding from the references.
The reference images may show the old name CookFlow ; the app being built is Flame & Fleur .
Recreate the UI structure, styling, spacing, hierarchy, and component language in SwiftUI.
Use mock/sample data only unless explicitly requested otherwise.
Maintain the current app foundation:
Home
Explore
Planner
Favorites
Profile
Reference Image Folder
Reference images are stored in:
Reference_Images/
1
Reference Image Map
File
Intended
Screen /
Flow
App Area
Build
Priority
01_home_reference.png Home Home tab 1
02_Explore_reference.png Explore Explore
tab 2
03_Import_recipe_reference.png Import
Recipe
Secondary
flow from
Home or
Explore
10
04_Add_recipe_reference.png Add Recipe
Secondary
flow from
Home or
Explore
11
2
Notes
Main landing
screen.
Establishes
first
impression,
brand tone,
hero
content, and
premium
cooking feel.
Main
browsing/
search
screen. Use
this for the
primary
Explore tab
structure.
Import
recipe flow.
Do not add
networking
yet; use
placeholder
fields and
mock
behavior
only.
Manual
recipe
creation
flow. Do not
add
persistence
yet.
File
Intended
Screen /
Flow
05_Explore_category_reference.png
Explore
Category
Grid
06_Category_list_reference.png Category
Recipe List
07_Recipe_reference.png
Recipe
Detail
Overview
08_Recipe_ingredients_reference.png
Recipe
Ingredients
State
09_Shopping_Cart_reference.png
Shopping
Cart /
Shopping
List
3
App Area
Build
Priority
Explore
sub-state
or
category
browsing
screen
3
Explore
detail
screen
4
Shared
recipe
detail flow
5
Recipe
detail sub-
state
6
Planner or
future
shopping
flow
8
Notes
Visual
category/
cuisine grid.
Use circular
food
thumbnails
and short
labels.
Recipe list
after
selecting a
category.
Should use
compact
recipe rows
and filter
chips.
Main recipe
detail screen.
Can be
reached
from Home,
Explore,
Favorites, or
Planner.
Ingredient-
focused
recipe
screen/state.
Should share
visual
language
with Recipe
Detail.
Organized
shopping
list/cart
screen. Use
olive green
for primary
actions.
File
Intended
Screen /
Flow
App Area
Build
Priority
10_Shopping_Cart_Add_Item_reference.png
Add
Shopping
Item
Shopping
list
secondary
flow
9
11_Meal_Planner_reference.png Meal
Planner
Planner
tab 7
12_Profile_reference.png Profile Profile tab 12
13_Settings_reference.png Settings
Profile
secondary
flow
13
4
Notes
Add item
modal or
pushed
screen.
Should feel
connected to
Shopping
Cart.
Main Planner
tab screen.
Includes
weekly
planning,
meal cards,
and
nutrition/
goal
summary.
Main Profile
tab screen
with avatar,
stats,
preferences,
and personal
cooking
identity.
Settings
screen
reached
from Profile.
Use grouped
rows,
toggles,
chevrons,
and calm
layout.
File
Intended
Screen /
Flow
App Area
Build
Priority
Notes
14_Premium_Insights_reference.png Premium
Insights
Premium
visual
teaser /
Planner or
Profile
flow
14
Premium
insights
screen. Do
not
implement
real
subscriptions
or payment
logic yet.
Recommended Implementation Order
Implement the screens in this order:
1.
2.
3.
4.
5.
6.
7.
8.
9.
10.
11.
12.
13.
14.
15.
App foundation and design system
Home
Explore
Explore Category Grid
Category Recipe List
Recipe Detail Overview
Recipe Ingredients State
Meal Planner
Shopping Cart / Shopping List
Add Shopping Item
Profile
Settings
Import Recipe
Add Recipe
Premium Insights
Navigation Mapping
Main Tabs
Maintain exactly these main tabs unless explicitly requested otherwise:
•
•
•
•
•
Home
Explore
Planner
Favorites
Profile
5
Secondary Screens
•
•
•
•
•
•
•
•
•
•
Category Grid belongs under Explore.
Category Recipe List belongs under Explore.
Recipe Detail can be opened from Home, Explore, Favorites, or Planner.
Recipe Ingredients is part of Recipe Detail.
Shopping Cart can be reached from Planner or a future shopping entry point.
Add Shopping Item is a secondary screen/modal from Shopping Cart.
Settings is reached from Profile.
Import Recipe is a secondary flow from Home or Explore.
Add Recipe is a secondary flow from Home or Explore.
Premium Insights is a visual teaser/secondary screen from Planner or Profile.
Design Interpretation Notes
Codex should translate the references into SwiftUI using:
•
•
•
•
•
native SwiftUI layout
reusable components
design tokens
mock/sample data
placeholder image treatments until real app assets are added
The goal is to match:
•
•
•
•
•
•
•
•
•
layout hierarchy
spacing
typography scale
card shapes
button styles
color roles
navigation behavior
image treatment
overall premium cooking feel
The goal is not to copy:
•
•
•
•
•
old app name
old brand labels
exact image content
screenshots as image assets
implementation shortcuts
6
Acceptance Criteria
For any screen implemented from a reference image:
•
•
•
•
•
•
•
•
•
•
The correct reference file must be named in the Codex task.
The screen must follow the visual hierarchy of the reference.
The screen must use the shared design system.
The screen must use mock/sample data only.
The screen must not add networking.
The screen must not add persistence.
The screen must not add payment or subscription logic.
The screen must not use reference images as UI assets.
The screen must compile successfully.
The implementation must be limited to the requested screen or flow.


