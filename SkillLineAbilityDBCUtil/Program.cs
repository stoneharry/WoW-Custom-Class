using SpellEditor.Sources.DBC;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace SkillLineAbilityDBCUtil
{
    class Program
    {
        static SkillLineAbilityDBC DBC;
        static SpellDBC SpellDBC;
        static SkillRaceClassInfoDBC RaceClassDBC;

        static void Main(string[] args)
        {
            var path = "D:/WoW Resources/2019_TrinityCore/DBC Temp/SkillLineAbility.dbc";
            var spellPath = "D:/WoW Resources/2019_TrinityCore/DBC Temp/Spell.dbc";
            var raceClassPath = "D:/WoW Resources/2019_TrinityCore/DBC Temp/SkillRaceClassInfo.dbc";
            var exportPath = "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/SkillLineAbility.dbc";
            var exportRaceClassPath = "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/SkillRaceClassInfo.dbc";
            bool useLogFile = true;
            var logFilePath = "D:/WoW Resources/2019_TrinityCore/DBC Temp/output.txt";

            Console.WriteLine($"Processing {path}...");
            DBC = new SkillLineAbilityDBC(path, exportPath);
            Console.WriteLine($"Processing {raceClassPath}...");
            RaceClassDBC = new SkillRaceClassInfoDBC(raceClassPath, exportRaceClassPath);
            Console.WriteLine($"Processing {spellPath}...");
            SpellDBC = new SpellDBC(spellPath);

            Console.WriteLine("Done loading DBC's.");

            Console.WriteLine("Read entries (R) for classmask or write new data (W)?");
            int keyread = AcceptInput();
            if (keyread == -1)
                return;
            if (keyread == 0)
            {
                Console.WriteLine("\nInput classmask to read:");
                uint classMask = ReadClassMask();
                Console.WriteLine("Program output redirected to output.txt");
                var ostrm = new FileStream(logFilePath, FileMode.Create, FileAccess.Write);
                var writer = new StreamWriter(ostrm);
                Console.SetOut(writer);
                OutputClassMaskData(classMask);
                writer.Dispose();
                ostrm.Dispose();
            }
            else
            {
                Console.WriteLine("\nInput classmask to copy:");
                uint readMask = ReadClassMask();
                Console.WriteLine("Input classmask to write as instead:");
                uint writeMask = ReadClassMask();
                Console.WriteLine("Program output redirected to output.txt");
                var ostrm = new FileStream(logFilePath, FileMode.OpenOrCreate, FileAccess.Write);
                var writer = new StreamWriter(ostrm);
                Console.SetOut(writer);

                Console.WriteLine($"Reading mask {readMask} and writing a copy as mask {writeMask}...");
                Console.WriteLine("Processing SkillLineAbility.dbc...");
                var records = DBC.GetAllRecords().Where(record => (((uint)record["ClassMask"]) & readMask) != 0);
                uint id = DBC.GetAllRecords().Max(record => (uint)record["Id"]);
                Console.WriteLine($"Read {records.Count()} records. Writing as new class mask {writeMask} starting with id {id}...");

                var list = records.ToList();
                foreach (var entry in list)
                {
                    entry["Id"] = ++id;
                    entry["ClassMask"] = writeMask;
                }

                DBC.AddNewRecords(list);
                DBC.SaveChanges();

                Console.WriteLine("Done. New max records: " + DBC.GetAllRecords().Max(record => (uint)record["Id"]));

                Console.WriteLine("Processing SkillRaceClassInfo...");
                records = RaceClassDBC.GetAllRecords().Where(record => (((uint)record["classMask"]) & readMask) != 0);
                id = DBC.GetAllRecords().Max(record => (uint)record["Id"]);
                Console.WriteLine($"Read {records.Count()} records. Writing as new class mask {writeMask} starting with id {id}...");

                var newList = new List<Dictionary<string, object>>(records.Count());
                list = records.ToList();
                foreach (var entry in list)
                {
                    var size = entry.Count();
                    if (size == 0)
                        continue;
                    var newRecord = new Dictionary<string, object>(size);
                    using (var enumer = entry.GetEnumerator())
                    {
                        while (enumer.MoveNext())
                        {
                            var pair = enumer.Current;
                            newRecord.Add(pair.Key, pair.Value);
                        }
                        newRecord["Id"] = ++id;
                        newRecord["classMask"] = writeMask;
                    }
                    newList.Add(newRecord);
                }

                RaceClassDBC.AddNewRecords(newList);
                RaceClassDBC.SaveChanges();

                Console.WriteLine("Done. New max records: " + RaceClassDBC.GetAllRecords().Max(record => (uint)record["Id"]));


                writer.Dispose();
                ostrm.Dispose();
            }
            if (!useLogFile)
            {
                Console.WriteLine("Done, press any key to exit...");
                Console.ReadKey();
            }
        }

        static void OutputClassMaskData(uint compareMask)
        {
            uint count = 0;
            Console.WriteLine("====== SkillRaceClassInfo =======");
            foreach (var record in RaceClassDBC.GetAllRecords())
            {
                uint classMask = (uint)record["classMask"];
                if ((classMask & compareMask) != 0)
                {
                    Console.WriteLine($"Count found {++count} ------------------");
                    using (var enumer = record.GetEnumerator())
                    {
                        do
                        {
                            var entry = enumer.Current;
                            var key = entry.Key;
                            var value = entry.Value;
                            Console.WriteLine($"[{key}]: {value}");
                        }
                        while (enumer.MoveNext());
                    }
                }
            }
            Console.WriteLine("====== SkillLineAbility =======");
            foreach (var record in DBC.GetAllRecords())
            {
                uint classMask = (uint) record["ClassMask"];
                if ((classMask & compareMask) != 0)
                {
                    Console.WriteLine($"Count found {++count} ------------------");
                    using (var enumer = record.GetEnumerator())
                    {
                        do
                        {
                            var entry = enumer.Current;
                            var key = entry.Key;
                            var value = entry.Value;
                            Console.WriteLine($"[{key}]: {value}");
                        }
                        while (enumer.MoveNext());
                    }
                }
            }
            foreach (var record in DBC.GetAllRecords())
            {
                uint classMask = (uint)record["ClassMask"];
                if ((classMask & compareMask) != 0)
                {
                    uint skillId = (uint)record["Id"];
                    uint spellEntry = (uint)record["SpellDbcRecord"];
                    var allSpells = SpellDBC.GetAllRecords().FirstOrDefault(r => ((uint)r["ID"]) == spellEntry);
                    string spellName = allSpells != null ? SpellDBC.LookupString(((uint[])allSpells["SpellName"])[0]) : "Spell Not Found";
                    Console.WriteLine($"SkillLineAbilityId: {skillId}, SpellId: {spellEntry}, Name: {spellName}");
                }
            }
        }

        static int AcceptInput()
        {
            var key = Console.ReadKey();
            if (key.Key == ConsoleKey.R)
                return 0;
            if (key.Key == ConsoleKey.W)
                return 1;
            Console.WriteLine("Press R or W to read or write. Press Q to quit.");
            if (key.Key == ConsoleKey.Q)
                return -1;
            return AcceptInput();
        }

        static uint ReadClassMask()
        {
            var line = Console.ReadLine();
            return uint.Parse(line); // throws exception if invalid uint
        }
    }
}
