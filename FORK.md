# Fork notes

This fork follows [Legends of Azeroth Pandaria 5.4.8](https://github.com/Legends-of-Azeroth/Legends-of-Azeroth-Pandaria-5.4.8)
and adds work that is not (yet) upstream. Fixes that are small and generic are sent upstream as pull requests; this branch keeps
the rest in one place. The [README](README.md) gives the overview; this file lists the changes by area.

## Bot life system

`modules/mod_playerbots/src/BotLife`

- A life cycle for random bots: questing, grinding, looting, resting, travelling, professions, archaeology, the auction house,
  guild activities and battlegrounds.
- Dungeon, raid and scenario runs through the dungeon finder. A player who queues gets the missing roles from the bots right away.
- Quest play beyond kill and collect: game objects, quest items used on creatures or on the spot, vehicles a bot rides or steers,
  escorts, timed events, defence events, emotes at a creature, creatures called up at accept, and spawns that only exist in a
  phase.
- Recovery: a bot that dies twice to the same creature revives at the graveyard, a dungeon party that hangs in a fight without a
  victim is released, and a quest that makes no progress is put aside with a reason.
- Gear: a bot wears what its level and specialization can use; a bot of level 86 or higher whose armor has fallen far behind gets
  a fitting set at login.

## Test tooling

`modules/mod_playerbots/src/cs_playerbots.cpp`

- `.botlife walk add|remove|clear|status`: pins a bot to a zone or a quest chain. Walkers are never drafted into parties and are
  never randomized or teleported by the random bot manager.
- `.botlife qt ...`: a bot does what a client does, through the session handlers of the client packets: accept, hand in, gossip
  hello and gossip option, click a creature or a game object, take the loot of a chest, use an item, open a
  container, step into an area trigger, cast a spell, do a text emote.
- `.botlife lfgtest queue <dungeonId>|status`: five bots queue for a dungeon and play it.

## Core

- Crash fixes: use-after-free in chain spell targets and in pending auctions, recursion in area dependent auras, a threat redirect
  loop between a personal vehicle and its owner, a combo target that has left the map, the player sets of an outdoor PvP zone
  (reached from several map threads).
- Quests: the accept hook of a script class runs for a player on every accept path, credit at accept, a completion check for shared
  and scripted quests.
- Creatures: EscortAI and SmartAI clear their state when the creature respawns; neutral creatures fight back against ranged
  attackers; a script can ask for the level of a creature within its level range.
- Maps and tools: missing WMO groups in vmaps and mmaps, custom visibility objects when a grid unloads.

## Scripts

- Starter zones: Gilneas (From the Shadows), Echo Isles (An Ancient Enemy), Tirisfal Glades (Recruitment) and the Death Knight
  start.
- Ulduar: a wipe at the Assembly of Iron no longer recurses between the resets of the three bosses.
- Hallow's End: the Headless Horseman has his patch 5.4 abilities (Conflagrated Weapon, Fiery Cleave, Summon Flaming Heads) and
  his dungeon no longer holds inhabitants of the Scarlet Monastery; Stink Bombs Away; The Collector's Agent (the Unleashed Void is
  one level below its player and starts the attack); innkeepers no longer offer the hourly trick or treat, which left the game in
  2011.

## Status

Work in progress. Everything here is tested with automated bots on a test realm and then on a public realm; expect rough edges.
The new configuration options are documented in `modules/mod_playerbots/config/playerbots.conf.dist` (section `BotLife.*`).

## Building

As upstream. The branch is based on upstream commit `e3267ed` and is brought up to date with upstream `master` from time to time.

## Credits

Some core and dungeon fixes are taken from the fork of ingussuveiks-dev
(https://github.com/ingussuveiks-dev/Legends-of-Azeroth-Pandaria-5.4.8, same upstream, GPL v2), adapted to this tree where
needed. This branch is published as one commit per sync, so the commit message of each sync lists the changes that were taken.

## License

GPL v2, like upstream.
