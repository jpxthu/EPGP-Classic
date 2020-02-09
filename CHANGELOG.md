### v1.4.1 (2020.2.9)

- New tier guide and UI: reset/rescale GP

### v1.4.0 (2020.2.6)

- Add switch of showing ilvl. Default closed.
- Add settings sync feature
- UI improvement

### v1.3.2 (2020.2.4)

- Add GP multiplier for legendary items
- Add button to reset custom items list
- Add T2.5 and T3 items
- Show item level in tooltip
- Bug fixing and optimization

### v1.3.1-Beta (2020.2.3)

- Export bug fix

### v1.3.0-Beta (2020.2.3)

- UI in EPGP main frame
  - Custom items configuration
  - Guild global configuration (BASE_GP, etc.)
  - Decay for selected guild ranks
- Announce EP/GP/PR when raider need/greed/bid
- Bug fixing and optimization

### v1.2.2 (2020.1.5)

- Fix bug: nan PR with 0 GP + 0 base_gp (#9)  
  Thanks to guild "涟漪" in realm "匕首岭-zhCN" for reporting this bug and cooperate.

### v1.2.1 (2019.12.31)

- Bug fix: UI didn't update when raid roster update (#7)

### v1.2.0 (2019.12.30)

- Add loot tracking & distribution module.

### v1.1.4 (2019.12.13)

- Fix bug: guns and wands did not show GP on some Non-Chinese clients.
- Fix bug: standby and alts did not work.  
  The reason of this bug is Blizzard changed performance of API "[Ambiguate](https://wow.gamepedia.com/API_Ambiguate)" in 1.13.3.

### v1.1.3 (2019.12.13)

- Update TOC interface version

### v1.1.2 (2019.12.11)

- Args in GP equation could be float.
- Make text bigger in EPGP option frame.
- Export and upload to EPGP web is fixed.

### v1.1.1 (2019.12.6)

- Set EPGP main frame movable.
- Make it easy to distinguish someone is in raid or standby.

### v1.1.0-alpha (2019.11.27)

- Allow credit 0 GP for logging.
- You can enable/disable "epgp standby [name]".
- Members in standby list could get multiple EP awards in a short time if you set a protect time.
- GUI configuration page for GP points was added. Each slot has three chosen.

### v1.0.0-beta (2019.11.5)

- Release first available version for WOW Classic based on original "epgp (dkp reloaded)".
- Boss kill/wipe tracking is available using DBM. BigWigs and other addons are not tested.
