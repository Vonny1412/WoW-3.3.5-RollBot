
# Changelog

## 4.0.4

- Epic equippable raid items are no longer treated as a special protected case.
- Added an option to disable tooltip requirement checks for automatic Need rolls.
- Roll decisions for learnable items such as recipes, mounts, and pets are now remembered and reused automatically.
- Rare mounts and pets are now handled as protected items instead of being saved as automatic roll decisions.
- Added an option to enable/disable automatic Pass rolls.
- Added an option to include learnable items in BoE handling.
- BoE items now require a manual roll decision before automatic rolling can occur.
- Token items now require a manual roll decision before automatic rolling can occur.
- Saved BoE item rolls are no longer removed automatically after winning an item.
- Added separate BoE handling options for recipes, mounts, and pets.

## 4.0.3

- Fixed an issue in raids where unusable equippable items could still appear as valid Need items.
- Learnable items such as recipes, mounts, and pets are now treated as BoE items when applicable.
- BoE items with red tooltip requirements are no longer automatically excluded from Need rolls.
- Added support for raid and tier token items.
- Token items are always shown for manual roll selection and are never saved automatically.
- Needed token items are automatically removed from the saved roll list after being won.

## 4.0.2

- Need settings now apply consistently to all item types, not just equipment
- Added protection against automatic disenchant rolls on BoE items.
- Added an option to allow automatic disenchant rolls on BoE items.
- Reworked the core loot decision logic for improved consistency and clarity.
- Added a warning when manually saving item roll rules that override default behavior.
- Winning always-ask items no longer removes them from the saved rolls list.

## 4.0.1

- Added "Book of Glyph Mastery (WotLK Random Drop)" to always-ask list
- Added "Formula: Enchant Weapon - Mongoose" to always-ask list
- Added "Formula: Enchant Weapon - Executioner" to always-ask list
- Added "Primordial Saronite (ICC)" to always-ask list
- Added "Fragment of Val'anyr (Ulduar)" to always-ask list

## 4.0

- Re-released as "Rollbot"
