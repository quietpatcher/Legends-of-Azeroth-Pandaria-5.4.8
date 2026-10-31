-- To-do 430 (Provisioner Elda, Brill: two identical "browse goods" gossip options):
-- Cause: creature 46271 has npcflag 66177 (gossip + vendor 128 + vendor-food 512 + innkeeper), so both menu 12101 option 2 (Let me browse your goods., broadcast 2823, flag 512)
-- and option 3 (I want to browse your goods., no broadcast text, flag 128) are shown; both open the same vendor window.
-- Change: remove the duplicate option 3 (no broadcast text = not a client-data text); option 2 stays and still matches via flag 512.
-- Source: functional change; no retail sniff of this menu available. Gossip menu 12101 is the only menu in the DB with this option pair.
-- Rollback: INSERT INTO gossip_menu_option (MenuID,OptionID,OptionIcon,OptionText,OptionBroadcastTextID,OptionType,OptionNpcflag,ActionMenuID,ActionPoiID,BoxCoded,BoxMoney,BoxText,BoxBroadcastTextID,VerifiedBuild) VALUES (12101,3,1,"I want to browse your goods.",0,3,128,0,0,0,0,"",0,0);
DELETE FROM gossip_menu_option WHERE MenuID = 12101 AND OptionID = 3;
