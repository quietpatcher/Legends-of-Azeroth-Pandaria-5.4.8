# Legends of Azeroth: Mists of Pandaria 5.4.8, with a life for its bots

This is a fork of [Legends of Azeroth Pandaria 5.4.8](https://github.com/Legends-of-Azeroth/Legends-of-Azeroth-Pandaria-5.4.8),
an open-source server emulator for World of Warcraft: Mists of Pandaria (5.4.8, build 18414).

The fork follows upstream and adds work that is not upstream yet:

- **BotLife**, a life cycle for random player bots: they quest, level, run dungeons and raids, trade and join guilds on their own;
- **test walkers**, bots that play a zone or a quest chain quest by quest, and test commands that send a bot down the same path
  as a player, through the handlers of the client packets;
- the **fixes** found by running hundreds of bots around the clock: crashes, quest scripts, boss encounters and world events.

Small, generic fixes are sent upstream as pull requests. Everything else is kept on the `custom` branch of this repository.

> **Work in progress.** The code is tested with automated bots and by a small group of players. Expect rough edges.

## At a glance

As of 31 October 2026:

| | |
|---|---|
| Our work on top of upstream | 360 files changed, about 40,000 added lines |
| Pull requests sent upstream | 44, of which 42 are merged and 2 are open |
| Bot life system | about 21,000 lines in `modules/mod_playerbots/src/BotLife` |
| Quests played by test walkers | 1,039 in the last full run (mid-October), of which 962 pass |
| Where it runs | a test realm with 300 bots and a public realm with 1,500 bots |

## What this fork adds

### BotLife: random bots that live in the world

The module `mod_playerbots` gives the server random bots. BotLife (`modules/mod_playerbots/src/BotLife`) decides what such a bot
does with its day:

- **Questing.** A bot picks up quests, travels to the objectives, plays them and hands them in. It handles kill and collect
  objectives, game objects, quest items, vehicles it has to ride or steer, escorts, timed events and creatures that only exist in a
  phase.
- **Dungeons, raids and scenarios.** Bots form parties, queue through the dungeon finder and play the instance boss by boss. A
  player who queues alone gets a tank, a healer and damage dealers from the bots right away.
- **Everything in between.** Grinding, looting, resting, repairing, travelling, professions, archaeology, the auction house,
  guilds and battlegrounds.
- **Gear that fits.** A bot wears what its level and specialization can use, and a bot whose armor has fallen far behind gets a
  fitting set.

The options are documented in `modules/mod_playerbots/config/playerbots.conf.dist`, in the section `BotLife.*`.

### Test walkers and player-path test commands

A quest that a bot can complete is not necessarily a quest that a player can complete: a bot may reach the credit another way.
Two tools close that gap.

- **Walkers** (`.botlife walk add|remove|status`) are bots pinned to a zone or a quest chain. They play it quest by quest and log
  every quest as completed, failed or stuck, together with the reason.
- **Player-path commands** (`.botlife qt ...`) let a bot do exactly what a client does, through the same session handlers: accept
  and hand in a quest at a creature or an object, pick a gossip option, click a creature or a game object and take its loot, use
  an item, open a container, step into an area trigger, cast a spell from a vehicle or do an emote at a creature.

A fix counts as proven only after it has been played along the path of a player.

### Core fixes

Found while the bots kept the server busy:

- crashes: use-after-free in chain spell targets and in the auction house, endless recursion in area auras and in boss resets, a
  threat loop between a vehicle and its rider, containers changed from several map threads at once;
- data integrity: thread-safe guid generators, group instance saves on MySQL 8, a deadlock retry that stops when it fails with
  another error;
- gameplay: neutral creatures that fight back against ranged attackers, PvP combat that ends when a player leaves the map, quest
  credit on every way of accepting a quest, escort and SmartAI creatures that work again after a respawn;
- tools: the map extractors no longer drop groups of world models, which left holes in line of sight and in the navigation
  meshes.

### Scripts, encounters and world events

- **Starter zones and chains**: quests in Gilneas, the Echo Isles, Mulgore, Tirisfal Glades and the Death Knight start.
- **Dungeons and raids**: fixes for fights that could not end or reset, such as the Assembly of Iron in Ulduar.
- **Hallow's End**: the Headless Horseman has his patch 5.4 abilities (Conflagrated Weapon, Fiery Cleave and Summon Flaming
  Heads), and the daily quests and the chain of the Creepy Crate are being played and corrected one by one.

Content is kept as close to the original game as the sources allow. When bots cannot beat an encounter, the bots are improved;
the encounter stays as it is.

## Sent upstream

The 29 merged pull requests cover, among other things:

- thread safety of the guid generators and of guild experience;
- use-after-free fixes in `Spell::SearchChainTargets` and in the pending auctions of the auction house;
- endless recursion in `UpdateAreaDependentAuras` and in the Assembly of Iron;
- missing WMO groups in vmaps and mmaps, and the mmap file name formats;
- the battle pet loadout across logins, engineering tinkers, guild member recipes and far teleport position data;
- the macOS arm64 build in CI.

The full list is on the
[upstream pull request page](https://github.com/Legends-of-Azeroth/Legends-of-Azeroth-Pandaria-5.4.8/pulls?q=is%3Apr+author%3Aquietpatcher).

## How it is tested

1. A change is built and deployed on a test realm with 300 bots and about 150 walkers.
2. The change is played along the path of a player with the test commands, and the realm has to run without a crash.
3. Only then does it go to the public realm.
4. A fix is offered upstream after it has proven itself there.

## Status and known gaps

- Of the 1,039 quests the walkers have played, 76 still fail. The most common reasons are no progress on an objective (23), an
  objective type the bots do not support yet (10) and a quest that continues on another map (10).
- Bot parties do not clear every dungeon. In a 24-hour sample they started 430 runs and cleared 171.
- Corrections to quest, creature and event data are made in our own world database. They are not part of this repository yet.

More detail on the changes is in [FORK.md](FORK.md).

## Building

Build this fork the same way as upstream. The `custom` branch is based on upstream commit `e3267ed` and is brought up to date
with upstream `master` from time to time.

### Requirements

+ Platform: Linux, Windows or Mac
+ AMD64 or AArch64 CPU architecture
+ MySQL = 5.7 / 8.0-8.1
+ CMake ≥ 3.27.2
+ OpenSSL = 1.1.1 / 3.0-3.1.1 (3.2.0 is not supported) (MySQL ≥ 8.0.33)
+ Boost ≥ 1.85.0 (MSVC 14.3 x64) on Windows / ≥ 1.81 on Linux
+ Windows SDK version 10.0.22621
+ MS Visual Studio (Community) ≥ 16.4 (2019) (Desktop) (no preview versions)
+ GCC ≥ 13.0, Clang ≥ 12.0

### Player bots

Playerbots is in an early stage of development; you may encounter bugs, crashes and other unexpected issues.
It is HIGHLY recommended to disable ELUNA when bots are enabled.

A few things are needed to get it working besides importing the databases:

+ copy `playerbots.conf` into your build directory or to where your executables are;
+ you MUST have the enUS DBC files for the bots to work;
+ add the following settings to your `worldserver.conf`:

  ```
  PlayerbotsDatabaseInfo = "127.0.0.1;3306;root;root;mop_playerbots"
  PlayerbotsDatabase.WorkerThreads = 1
  PlayerbotsDatabase.SynchThreads = 1
  Logger.playerbots=3,Console Server
  ```

+ the first start may take a while; be patient and let everything load and randomize.

For the upstream project, its documentation and its community, see the
[upstream repository](https://github.com/Legends-of-Azeroth/Legends-of-Azeroth-Pandaria-5.4.8).

## License and credits

License: GPL 2.0. Read the file [COPYING](COPYING.md).

This fork stands on the work of the Legends of Azeroth team and of the projects it builds on. Read the file [THANKS](THANKS.md).
