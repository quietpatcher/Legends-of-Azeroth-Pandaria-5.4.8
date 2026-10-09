# Fork notes

This fork follows [Legends of Azeroth Pandaria 5.4.8](https://github.com/Legends-of-Azeroth/Legends-of-Azeroth-Pandaria-5.4.8)
and adds work that is not (yet) upstream. Fixes that are small and generic are sent upstream as pull requests; this branch keeps
the rest in one place.

## What is in here

- **BotLife** (`modules/mod_playerbots/src/BotLife`): a life cycle for random bots: questing, grinding, looting, resting, travelling,
  guild activities, dungeon and raid runs through the dungeon finder, auction house and professions. Real players are never forced
  to wait for bots.
- **Test walkers**: a few bots can be pinned to a zone or a quest chain and walk it quest by quest (`.botlife walk ...`,
  `.botlife qt ...`), which is how quest data and scripts are checked.
- **Core fixes** found while running a few hundred bots: use-after-free and dangling pointer fixes, combat and threat fixes, guild
  and auction house fixes, mmap/vmap fixes.
- **Script fixes** for starter zones and chains (several Gilneas, Echo Isles, Mulgore and Death Knight quests).

## Status

Work in progress. Everything here is tested with automated bots on a private test server; expect rough edges. The new configuration
options are documented in `modules/mod_playerbots/config/playerbots.conf.dist` (section `BotLife.*`).

## Building

As upstream. The branch is based on upstream commit `e3267ed` and is rebased on upstream `master` from time to time.

## License

GPL v2, like upstream.
