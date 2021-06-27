### v1.6.4-tbc (2021.6.28)

- Update the custom item list for TBC.

### v1.6.2-tbc (2021.6.9)

- Update raid/boss list for TBC.

### v1.6.1-tbc (2021.6.4)

- Update raid list for TBC.

### v1.6.0-alpha (2021.6.4)

- Upgrade libraries for TBC.
- Update suggested standard ilvl for TBC.

### v1.5.7 (2020.12.19)

- ep and gp command allowing short name without realm (#52)

### v1.5.6 (2020.12.2)

- Standard ilvl update for NAXX.

### v1.5.2 (2020.9.14)

- Remind to enable combatlog. Default off.

### v1.5.0 (2020.8.9)

- New feature: boss kill/wipe reward
- New feature: loot log (history)
- Update log sync website

### v1.4.9 (2020.5.10)

- Bug fix: can not get external EPGP (jpxthu/RCLootCouncil_EPGP_Classic#1)

### v1.4.8 (2020.5.10)

- Add option: decay BASE_GP or not

### v1.4.7 (2020.4.11)

- Disable profanity filter of zhCN client

### v1.4.6 (2020.3.28)

- Enable custom GP reason
- Update TOC version

### v1.4.5 (2020.3.15)

- Detail log adjust for new online EPGP system

### v1.4.4 (2020.2.29)

- Auto popup distribution frame when looting
- Items with 0 scale and blank comment won't display
- Export detail log
- Bug fix

### v1.4.3 (2020.2.15)

- Mass adjust GP
- Update standard ilvl of Phase 3
- Custom items UI improvement
- Bug fix

### v1.4.2 (2020.2.11)

- UI authority limitation
- Change UI layout to avoid buttons overlap (#21)

### v1.4.1 (2020.2.9)

- Add some popup tips to global vars (#18)
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
