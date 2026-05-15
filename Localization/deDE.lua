local ADDON_NAME, ADDON = ...
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale(ADDON_NAME, "deDE")
if ( not L ) then return end
-----------------------------------------------------------------------------------

-- ä \195\164
-- ö \195\182
-- ü \195\188
-- Ä \195\132
-- Ö \195\150
-- Ü \195\156
-- ß \195\159

L["tooltip_icon_left_click"] = "Linksklick: Status umschalten"
L["tooltip_icon_right_click"] = "Rechtsklick: Men\195\188 \195\182ffnen"

L["state_active"] = "Aktiviert"
L["state_inactive"] = "Inaktiv"
L["state_learning"] = "Lernmodus"

L["menu_history"] = "Verlauf"
L["menu_last_saved_items"] = "Zuletzt gespeichert"
L["menu_last_saved_items_header"] = "Zuletzt gespeicherte Gegenst\195\164nde (max %d)"
L["menu_clear_saved_items"] = "L\195\182sche alle %d gespeicherten Gegenst\195\164nde"
L["menu_settings"] = "Einstellungen"
L["menu_set_item"] = "Gegenstand festlegen"
L["menu_roll_need"] = "Bedarf (manuell)"
L["menu_roll_greed"] = "Gier"
L["menu_roll_greed_only_sellable"] = "Nur Verkaufbares"
L["menu_expansion"] = "Erweiterung:"
L["menu_quality"] = "Qualit\195\164t:"
L["menu_roll_need_boe"] = "Bedarf (auf BoE)"
L["menu_roll_de"] = "Entzaubern"
L["menu_roll_de_boe"] = "Entzaubere BoE"
L["menu_show_rnd_frame"] = "Zeige /rnd Fenster"
L["menu_show_rnd_test_frame"] = "Ausprobieren"
L["menu_filter_messages"] = "Meldungen filtern"
L["menu_behavior"] = "Verhalten"
L["menu_behavior_header"] = "Fest eingebaute Schutzregeln:"

L["behavior_ignore_unknown_items"] = "Unbekannte Items werden ignoriert (Benutzer entscheidet)."
L["behavior_special_items_manual"] = "Besondere Items werden ignoriert (Benutzer entscheidet)."
L["behavior_legendary_items_manual"] = "Legend\195\164re Items werden ignoriert (Benutzer entscheidet)."
L["behavior_learnable_items_manual"] = "Erlernbare Items werden ignoriert (Benutzer entscheidet)."
L["behavior_epic_equip_in_raid_manual"] = "Epische Ausr\195\188stung wird im Schlachtzug ignoriert (Benutzer entscheidet)."
L["behavior_roll_fallback"] = "Gespeicherte, jedoch eingeschr\195\164nkte W\195\188rfeloptionen fallen sicher zur\195\188ck."
L["behavior_remove_won_relevant_items"] = "Gewonnene relevante Bedarfs-Items werden aus Liste entfernt."

L["dialog_enter_item_id_or_name"] = "ID oder Name eingeben"
L["dialog_clear_all_rolls_question"] = "Wirklich?"
L["dialog_manual_save_warning"] = "Manuelle Item-Regeln haben Vorrang vor Rollbots Standardverhalten. Nutze sie mit Bedacht."

L["common_yes"] = "Ja"
L["common_no"] = "Nein"
L["common_ok"] = "OK"
L["common_cancel"] = "Abbrechen"

L["reason_you_won"] = "Ihr habt diesen Gegenstand gewonnen"
L["reason_no_interest"] = "Kein Interesse an diesem Gegenstand"
L["reason_in_auto_list"] = "In Liste gespeichert"
L["reason_item_is_boe"] = "Gegenstand ist BoE"
L["reason_in_raid"] = "Ihr seid in einem Schlachtzug"
L["reason_legendary_item"] = "Legend\195\164rer Gegenstand"
L["reason_item_is_needed"] = "Gegenstand wird noch ben\195\182tigt"
L["reason_not_qualified"] = "Nicht f\195\188r diesen Gegenstand qualifiziert"
L["reason_special_item"] = "Spezieller Gegenstand"
L["reason_item_skill_known"] = "Bereits erlernt"
L["reason_item_unknown"] = "Gegenstand ist unbekannt"
L["reason_added_by_user"] = "Vom Benutzer hinzugef\195\188gt"
L["reason_removed_by_user"] = "Vom Benutzer entfernt"
L["reason_skill_too_low"] = "Erforderliche F\195\164higkeit zu niedrig"
L["reason_learnable_item"] = "Erlernbarer Gegenstand"

L["rolling_on_item"] = "%1$s f\195\188r %2$s"
L["rolling_ignored"] = "Ignoriere %s"

L["status_ignored"] = "Ignoriert"
L["status_removed"] = "Entfernt"

L["unknown_item"] = "Unbekannter Gegenstand"

L["message_item_is_unknown"] = "Unbekannter Gegenstand: %s"
L["message_item_quality_too_low"] = "Die Qualit\195\164t von %s ist zu niedrig."

L["message_requesting_item_info"] = "Erfrage Gegenstandsinformationen für #%s vom Server."
L["message_requesting_item_info_failed"] = "Keine Gegenstandsinformationen f\195\188r #%s verf\195\188gbar."
L["message_requesting_item_info_failed_with_reason"] = "Server-Anfrage für Gegenstand #%1$s fehlgeschlagen: %2$s"

L["message_updating_database"] = "Datenbank-Update auf Version %d"

L["message_item_saved"] = "Gespeichert: %s f\195\188r %s"
L["message_item_removed"] = "Entfernt: %s"

----------------------------------------------------------
