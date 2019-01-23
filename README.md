# WoW-Custom-Class

## Creating a custom class ##

This repository documents my findings when creating a custom class for WoW. I am doing this using TrinityCore 3.3.5a.

Initially I will be dumping information on here without documenting it properly, however I will periodically revisit this and clean it up.

## 2019-01-13 ##

My initial goal is to get the shell of a class in. Once I have that process fully figured out I will start adding more specific features for my class (Engineer).

The first file to modify is `ChrClasses.dbc`. I have added a new row using MyDBCEditor:

https://wowdev.wiki/DB/ChrClasses
![ChrClasses.dbc modified with MyDBCEditor](https://i.imgur.com/KYF1c8X.png)

Next we need to modify `CharBaseInfo.dbc` which maps which races are allowed to play which classes. I have made warrior able to play Engineer. MyDBCEditor and DBCUtil didn't seem to be able to open this file for me, but Tallis was able to.

https://wowdev.wiki/DB/CharBaseInfo
![CharBaseInfo.dbc modified with Tallis](https://i.imgur.com/1Feg8Xm.png)

At this stage you will be getting this error in the Character Create screen:

![Char Creation Screen Error](https://i.imgur.com/PmTWSJQ.png)

To resolve this we need to add a new button for the new class in `Interface\GlueXML\CharacterCreate.xml`. We also need to modify the `CharacterCreate.lua` file in the same directory to add the texcoord offset for "ENGINEER" and increment the MAX_CLASSES_PER_RACE variable. Also add all the strings needed for engineer in `GlueStrings.lua`, also within the GlueXML directory. You can search 'WARRIOR' and copy all these strings renaming them.

I also modified `Interface\GLUES\CHARACTERCREATE\UI-CHARACTERCREATE-CLASSES.blp` to add the new icon. This is what the texcoord offset targets.

Now we can see our class in the character creation screen:

![Char Creation Screen With Engineer](https://i.imgur.com/rV7WT36.jpg)

Now I add the basic server side database data to get the character created. I only add data for level 1.

```sql
INSERT INTO playercreateinfo (race, class, map, zone, position_x, position_y, position_z, orientation) VALUES (1, 12, 0, 12, -8949.95, -132.493, 83.5312, 0);
INSERT INTO player_levelstats (race, class, LEVEL, str, agi, sta, inte, spi) VALUES (1, 12, 1, 17, 20, 21, 23, 25);
INSERT INTO player_classlevelstats (class, LEVEL, basehp, basemana) VALUES (12, 1, 20, 0);
```

Trying to create the class now gives you this error:

![Error when creating class](https://i.imgur.com/BTkuW2S.png)

So we need to update the emulator code to handle the new class. Luckily this is quite simple:

![Emulator code modification for new class](https://i.imgur.com/A1oNId4.png)

We can now login with the new custom class but when you open the talent or character panel the client crashes. This is because we are missing gt DBC data for the new class.

I wrote a little program to automate adding this data to the DBC files. Doing it manually would have been a slow tedious task and very error prone. I have included this program in this repository.

![Screenshot of program code for adding gt DBC data](https://i.imgur.com/1H3FjcP.png)

Now we can open the character panel without the client crashing:

![Character panel open without client crash](https://i.imgur.com/a46e3BW.png)

## 2019-01-14 ##

Carrying on from where we left off, next we need to fix the who list. The Friends Frame does not know how to handle our new class.

![Who list in Friends Frame showing error](https://i.imgur.com/7INPxvK.jpg)

Inspecting the code shows that the table RAID_CLASS_COLORS does not contain our class. This is defined in `Interface\FrameXML\Constants.lua`, along with a couple of other bits of data indexed by class. Update all of these and we see some improvements:

![Who list in Friends Frame working with custom class](https://i.imgur.com/ckpmCCQ.png)

At this point I wanted to level myself up to test the talent and achievement frames but this happened:

![Error trying to input levelup command](https://i.imgur.com/HAxew1h.png)

To be able to speak and perform basic actions you need to have the right spells and skills. Some of these are hidden client side but neccessary server side. Time to get these off a existing class, but first I need to figure out where this data is coming from.

Last time I had to do something similar I hacked it by adding in some fixed server side structure and adding that: https://github.com/stoneharry/ZombiesProjectEmulator/commit/6ea7daf10d123f24fc1a960e474d8c43b4b3d1c8

## 2019-01-15 ##

So I found out that the starting spells are contained in `SkillLineAbility.dbc`. Again, I don't want to be handling these files manually so I have started writing a little program to automate this task.

First step is making sure I can read and write the file back without impacting the integrity of the file.

![File hash of read/writing DBC](https://i.imgur.com/r6F5TPt.png)

Then input some very basic text controls to read and write data:

![Writing new SkillLineAbility.dbc data](https://i.imgur.com/xu1U0er.png)

Unfortunately I leave it here for today, I only have limited time after work.

## 2019-01-17 ##

Not much to report over the last couple of days as I have not had much free time. I realised I also needed to modify the `SkillRaceClassInfo.dbc` and needed to load in the `Spell.dbc` in order to properly resolve references for debugging purposes. I have added these features to the program I am writing and done some more debugging.

I logged all the records found with a matching classmask to debug what was being added:

![Debug log of SkillLineAbility records](https://i.imgur.com/EVSnk9P.png)

Everything seemed to be right. I'm going to copy over a lot more data than I want on this new class, but I can filter it out after getting replicating another class automatically working. Unfortunately I soon discovered I had completely borked the DBC at some point, as creating a rogue resulted in this:

![Broken rogue class](https://i.imgur.com/6jeXRKY.jpg)

I'm getting closer though, just need to iron out the kinks in this program.

## 2019-01-23 ##

I spent some time messing around with modifying the character creation and character selection backgrounds for Engineer. I'm not quite there yet but here's some sample code from my machinations:

![Sample model creation on character creation screen](https://i.imgur.com/rAUgz6c.png)

I also spent some time trying to port Mordred's model tool for the account login screen to instead interact with the character create screen: http://www.modcraft.io/index.php?topic=8694.0

![Mordred's tool on character creation](https://i.imgur.com/VSDgEBL.png)

I also returned to trying to get our new class to talk. It turned out to be a pretty simple problem, I was modifying the existing records instead of writing new ones. A bit of debugging later and we got there:

![Debugging the CharRaceClassInfo DBC writing](https://i.imgur.com/A9OYtdg.png)
![Now able to talk in game with our custom class](https://i.imgur.com/LmhABxh.jpg)

It's hard to know what to work on next. I am bouncing between different parts at the moment when I find free time. There is still a lot of work to do.

