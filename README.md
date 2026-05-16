# Rollbot

A lightweight loot rolling addon for **World of Warcraft 3.3.5a**.

Automatically filters and handles loot rolls based on your class, settings, and previous roll decisions while keeping important items visible.

---

## Installation

Supported client: Wrath of the Lich King (Legacy 3.3.5a)
Supported languages: English (enUS/enGB), German (deDE)

1. Download and extract the addon.
2. Place the `Rollbot` folder into your `World of Warcraft/Interface/AddOns` directory.
3. Start the game and make sure the addon is enabled in the addon list.

Required libraries are included.

---

## Features

- **Automatic rolling**  
  Automatically rolls on loot based on your class, settings, and saved decisions.

- **Learning mode**  
  Temporarily re-shows saved items so roll decisions can easily be reviewed and updated.

- **Manual item assignment**  
  Manually assign items to Need, Greed, or Disenchant, or remove saved roll decisions.

- **Safe roll fallback behavior**  
  Prevents invalid or unsafe automatic rolls and falls back to safer options when necessary.

- **Loot history**  
  Keeps track of recently learned, saved, and removed item roll decisions.

- **Raid warning roll helper**  
  Detects item links in raid warnings and opens a roll frame with item icon, tooltip, and one-click `/rnd` buttons.

- **Protected item handling**  
  Certain special items are always shown to the player instead of being handled automatically.

- **Unknown item protection**  
  Items with unavailable item data are ignored until the client has fully loaded them.

---

## How to Use

Rollbot works automatically once enabled.

Whenever an item can be rolled on, Rollbot checks your class, settings, saved roll decisions, and item safety rules before deciding how to roll.

Unknown or protected items are never handled automatically, are always shown to the player, and the selected roll is never saved to the roll list.

While learning mode is enabled, saved items are shown again instead of being rolled automatically, allowing you to review and update your roll decisions without clearing the whole roll list.

The minimap button provides quick access to settings, loot history, manual item assignment, and mode switching between active, inactive, and learning modes.

---

## Modes

The current mode can be changed by left-clicking the minimap icon.

### Active Mode (green icon)

Rollbot automatically handles loot rolls based on your class, settings, saved roll decisions, and item safety rules.

Protected items and unknown items are always shown to the player instead of being handled automatically.

If a saved roll type is unavailable, Rollbot safely falls back to other allowed roll types when possible.

### Inactive Mode (red icon)

Rollbot is completely disabled and does not interact with loot rolls in any way.

### Learning Mode (yellow icon)

Learning mode temporarily re-shows saved items instead of rolling automatically.

This allows you to review and update roll decisions for specific dungeons, raids, or farming sessions without clearing the entire saved roll list.

Once an item has been reviewed during the current learning session, Rollbot resumes normal automatic behavior for that item.

### Automatic Cleanup

When you win token, equippable or learnable Need-items, Rollbot automatically removes them from the saved roll list.

---

## Minimap Menu

All Rollbot features are accessible through the minimap icon.

Left-click changes the current Rollbot mode.  
Right-click opens the Rollbot menu.

### History

The history menu shows recent Rollbot actions and explains why a specific roll decision was made.

This can be useful to understand automatic behavior or review recently learned items.

### Saved Items

The saved items menu shows the 20 most recently saved item decisions.

Left-clicking an item removes it from the saved roll list.

A button at the bottom allows clearing the entire saved roll list.

### Settings

Rollbot does not use a separate addon options window.

All settings are handled directly through the minimap menu for quick and easy access during gameplay.

Rollbot settings are based on item expansion (Classic, TBC, WotLK) and item quality (Uncommon, Rare, Epic, Legendary).

Each category can be enabled or disabled individually.

Available settings include:

- **Need (manually)**  
  Defines which items may be needed manually and shown to the player.

- **Need (BoE)**  
  Allows matching bind-on-equip items to be learned for automatic Need rolls.

- **Greed**  
  Use Greed as an automatic fallback roll.

- **Disenchant**  
  Use Disenchant as an automatic fallback roll before Greed when available.

- **Pass**  
  Use Pass as an automatic fallback roll when no other automatic roll applies.

- **Show /rnd frame**  
  Enables the raid warning roll helper and allows custom `/rnd` values.

- **Filter messages**  
  Controls which Rollbot chat messages are shown or filtered.

### Set Roll Manually

Manual item assignment is a powerful feature and should be used carefully.

Manually assigned item decisions are handled before Rollbot's normal automatic logic.

For example, manually assigning a legendary item to Need will cause Rollbot to automatically roll Need on that item, even if the normal safety logic would not do so.

You can assign items manually by using either the item name or the item ID.  
Using item IDs is recommended.  

If an item name is used and the item is not yet cached by the client, the item may not be recognized correctly.

When using an item ID, Rollbot can automatically request the missing item information from the server if necessary.

---

## Fair Use & Important Notes

Rollbot cannot know player intent.

The addon acts according to its current settings, saved roll decisions, and active mode.  
If you enter a situation where Rollbot should not make automatic decisions, you can quickly disable it by left-clicking the minimap icon.

Rollbot cannot know which items a player may want for transmogrification, style gear, off-spec collections, roleplay purposes, or for helping friends.

In such situations, it is recommended to temporarily disable Rollbot or manually assign roll decisions for specific items.

Rollbot is designed as a quality-of-life addon.  
It does not bypass protected game mechanics and operates entirely client-side.

Players remain responsible for their own loot decisions and how they use the addon.

### Protected Items

The following items are treated as protected items and are always shown manually:

- `52019` — Precious' Ribbon
- `50274` — Shadowfrost Shard
- `50379` — Battered Hilt (Alliance)
- `50380` — Battered Hilt (Horde)
- `49294` — Ashen Sack of Gems
- `34846` — Black Sack of Gems
- `43347` — Satchel of Spoils
- `43297` — Damaged Necklace
- `45912` — Book of Glyph Mastery
- `49908` — Primordial Saronite
- `45038` — Fragment of Val'anyr

Protected items are never rolled automatically and are never saved automatically.

However, players may still manually assign roll decisions to these items through the minimap menu if desired.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a full list of changes and release notes.

## License

This project is licensed under the MIT License.

See [LICENSE](LICENSE) for details.

---

*Created with ♥️ — and some AI assistance*
