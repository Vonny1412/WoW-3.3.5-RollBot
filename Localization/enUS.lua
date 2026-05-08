local ADDON_NAME, ADDON = ...
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale(ADDON_NAME, "enUS", true)
if ( not L ) then return end
-----------------------------------------------------------------------------------

L["tooltip_icon_left_click"] = "Left click: Toggle status"
L["tooltip_icon_right_click"] = "Right click: Open menu"

L["state_active"] = "Activated"
L["state_inactive"] = "Inactive"
L["state_learning"] = "Learning"

L["menu_history"] = "History"
L["menu_last_saved_items"] = "Last saved"
L["menu_last_saved_items_header"] = "Last saved items (max %d)"
L["menu_clear_saved_items"] = "Remove all %d saved items"
L["menu_settings"] = "Settings"
L["menu_set_item"] = "Set roll manually"
L["menu_roll_need"] = "Need (manual)"
L["menu_roll_greed"] = "Greed"
L["menu_roll_greed_only_sellable"] = "Only sellable"
L["menu_expansion"] = "Expansion:"
L["menu_quality"] = "Quality:"
L["menu_roll_need_boe"] = "Need (on BoE)"
L["menu_roll_disenchant"] = "Disenchant"
L["menu_show_rnd_frame"] = "Show /rnd frame"
L["menu_show_rnd_test_frame"] = "Tryout"
L["menu_filter_messages"] = "Filter messages"
L["menu_behavior"] = "Behavior"
L["menu_behavior_header"] = "Built-in safety behaviors:"

L["behavior_ignore_unknown_items"] = "Unknown items are ignored (user decides)."
L["behavior_special_items_manual"] = "Special items are ignored (user decides)."
L["behavior_legendary_items_manual"] = "Legendary items are ignored (user decides)."
L["behavior_learnable_items_manual"] = "Learnable items are ignored (user decides)."
L["behavior_epic_equip_in_raid_manual"] = "Epic equipment ignored in raids (user decides)."
L["behavior_roll_fallback"] = "Saved but restricted rolls fall back safely."
L["behavior_remove_won_relevant_items"] = "Won relevant need-items are removed from list."

L["dialog_enter_item_id_or_name"] = "Enter ID or name"
L["dialog_clear_all_rolls_question"] = "Really?"

L["common_yes"] = "Yes"
L["common_no"] = "No"
L["common_ok"] = "OK"
L["common_cancel"] = "Cancel"

L["reason_you_won"] = "You won that item"
L["reason_no_interest"] = "No interest in that item"
L["reason_in_auto_list"] = "Saved in list"
L["reason_item_is_boe"] = "Item is BoE"
L["reason_in_raid"] = "You are in a raid"
L["reason_legendary_item"] = "Legendary item"
L["reason_item_is_needed"] = "Item is needed"
L["reason_not_qualified"] = "Not qualified for that item"
L["reason_special_item"] = "Special item"
L["reason_item_skill_known"] = "Already learned"
L["reason_item_unknown"] = "Item is unknown"
L["reason_added_by_user"] = "Added by user"
L["reason_removed_by_user"] = "Removed by user"
L["reason_skill_too_low"] = "Required skill too low"
L["reason_learnable_item"] = "Learnable item"

L["rolling_on_item"] = "%1$s on %2$s"
L["rolling_ignored"] = "Ignoring %s"

L["unknown_item"] = "Unknown item"

L["status_ignored"] = "Ignored"
L["status_removed"] = "Removed"

L["message_item_is_unknown"] = "Unknown item: %s"
L["message_item_quality_too_low"] = "The quality of %s is too low."

L["message_requesting_item_info"] = "Requesting item info for #%s from server."
L["message_requesting_item_info_failed"] = "No item info available for #%s."
L["message_requesting_item_info_failed_with_reason"] = "Server request for item #%1$s failed: %2$s"

L["message_updating_database"] = "Updating database to version %d."

L["message_item_saved"] = "Saved: %s on %s"
L["message_item_removed"] = "Removed: %s"

----------------------------------------------------------
