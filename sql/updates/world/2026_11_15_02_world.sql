-- Silverpine Forest, quest 27045 "Waiting to Exsanguinate": four creature_text rows of the scene carry a text that differs
-- from the client text. A player does not see the difference today: for these rows the core takes the text of
-- broadcast_text (BroadcastTextId is set; `creature_text`.`Text` is only the fallback when the id does not exist). The
-- fallback should not carry a different text, so the rows are aligned.
-- Cause: the rows were typed in by hand and not copied from the broadcast texts.
-- Change: set `Text` to the client text for 44882 group 0 (" Let's go!" was missing) and group 1 ("shadow" -> "shadows"),
--   44883 group 3 ("So will you help?" -> "So you will help?") and 44884 group 5 (emote text with %s, as in the client).
-- Source: broadcast_text 44951 (44882 g0), 44955 (44882 g1), 44965 (44883 g3), 44967 (44884 g5) of the 5.4.8 client data.
--   44951 and 44955 have their text in the female column (Text1); the core falls back to it when the male column is empty.
-- Rollback:
--   UPDATE `creature_text` SET `Text`='We haven''t got much time. Crowley will be arriving shortly.' WHERE `CreatureID`=44882 AND `GroupID`=0 AND `ID`=0;
--   UPDATE `creature_text` SET `Text`='THERE! Hide in the armoire! I''ll hide in the shadow next to you.' WHERE `CreatureID`=44882 AND `GroupID`=1 AND `ID`=0;
--   UPDATE `creature_text` SET `Text`='So will you help?' WHERE `CreatureID`=44883 AND `GroupID`=3 AND `ID`=0;
--   UPDATE `creature_text` SET `Text`='Packleader Ivar Bloodfang sniffs the air.' WHERE `CreatureID`=44884 AND `GroupID`=5 AND `ID`=0;
UPDATE `creature_text` SET `Text`='We haven''t got much time. Crowley will be arriving shortly. Let''s go!' WHERE `CreatureID`=44882 AND `GroupID`=0 AND `ID`=0 AND `BroadcastTextId`=44951;
UPDATE `creature_text` SET `Text`='THERE! Hide in the armoire! I''ll hide in the shadows next to you.' WHERE `CreatureID`=44882 AND `GroupID`=1 AND `ID`=0 AND `BroadcastTextId`=44955;
UPDATE `creature_text` SET `Text`='So you will help?' WHERE `CreatureID`=44883 AND `GroupID`=3 AND `ID`=0 AND `BroadcastTextId`=44965;
UPDATE `creature_text` SET `Text`='%s sniffs at the air.' WHERE `CreatureID`=44884 AND `GroupID`=5 AND `ID`=0 AND `BroadcastTextId`=44967;
