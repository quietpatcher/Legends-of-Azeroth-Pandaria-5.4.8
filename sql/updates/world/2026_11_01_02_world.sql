-- Silverpine Forest, creature_text 44882 group 0 (Agatha/Crowley scene, to-do 436): "Crowly" is a typo; the 5.4.8 client broadcast_text 44951 and the rest of the scene say "Crowley".
-- Source: broadcast_text ID 44951 (client DB2 build 18414): "We haven't got much time. Crowley will be arriving shortly. Let's go!"
-- Rollback: UPDATE `creature_text` SET `Text` = REPLACE(`Text`, "Crowley", "Crowly") WHERE `CreatureID` = 44882 AND `GroupID` = 0 AND `ID` = 0;
UPDATE `creature_text` SET `Text` = REPLACE(`Text`, "Crowly", "Crowley") WHERE `CreatureID` = 44882 AND `GroupID` = 0 AND `ID` = 0 AND `Text` LIKE "%Crowly%";
