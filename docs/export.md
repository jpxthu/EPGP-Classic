# Export

Export details for backup, analysis, etc. It will be a TSV file. Here is an [example](export_example.tsv). I will explain each part.

## Timestamp

Seconds from 1970.1.1 (UTC time). You may need to get a local time manully, depends on the coding language. Example:

``` Python
# python
import time
ts = 1575026757
print(time.localtime(ts))
```

## Roster

One main character in each line. GP didn't contain BASE_GP. You can calculate PR by: `PR = EP / (GP + BASE_GP)`

See [class](#Class) for more details about the column "class".

## Log

There are 3 types: `EP`, `GP`, `BI`. `BI` means `GUILD_BANK`.

If reason is an item, there will be the 6th column - itemlink. See [itemlink](#Itemlink) for more details.

## Class

You can get **LOCAL** data in your language by type in the following code in game:

``` LUA
/run for i, v in pairs(RAID_CLASS_COLORS) do print(string.format("%s|%s|%s|%s|%s|%s|%s", i, LOCALIZED_CLASS_NAMES_MALE[i] or "", LOCALIZED_CLASS_NAMES_FEMALE[i] or "", v.colorStr, v.r, v.g, v.b)) end
```

Here is an example in zhCN:

|Class|Local Male|Local Female|Color Str|R|G|B|
|-|-|-|-|-|-|-|
HUNTER|猎人|猎人|ffaad372|0.67|0.83|0.45
WARRIOR|战士|战士|ffc69b6d|0.78|0.61|0.43
PALADIN|圣骑士|圣骑士|fff48cba|0.96|0.55|0.73
MAGE|法师|法师|ff3fc6ea|0.25|0.78|0.92
PRIEST|牧师|牧师|ffffffff|1|1|1
SHAMAN|萨满祭司|萨满祭司|ff0270dd|0.01|0.44|0.87
WARLOCK|术士|术士|ff8787ed|0.53|0.53|0.93
DEMONHUNTER|||ffa330c9|0.64|0.19|0.79
DEATHKNIGHT|||ffc41e3a|0.77|0.12|0.23
DRUID|德鲁伊|德鲁伊|ffff7c0a|1|0.49|0.04
MONK|||ff00ff96|0|1|0.59
ROGUE|潜行者|潜行者|fffff468|1|0.96|0.41

No local name because they are unavailable in Classic version.

**Reference**: [Class colors - WOW Wiki](https://wowwiki.fandom.com/wiki/Class_colors)

## Itemlink

An itemlink looks like:

```
|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r
```

- `9d9d9d` is color string
- `3299` is item ID
- `[Fractured Canine]` is item name

You can get what you want using regex:

``` LUA
color, id, name = string.match(link, "^|c..(......)|Hitem:(%d+).+|h(.+)|h|r$")
```

Try it in game:

``` LUA
/run local link = select(2, GetItemInfo(19360)); print(link); link = gsub(link, "\124", "\124\124"); print(link); print(string.format("color=%s, ID=%s, name=%s", string.match(link, "^|c..(......)|Hitem:(%d+).+|h(.+)|h|r$")))
```

More details on [itemLink - WOW Wiki](https://wowwiki.fandom.com/wiki/ItemLink).
