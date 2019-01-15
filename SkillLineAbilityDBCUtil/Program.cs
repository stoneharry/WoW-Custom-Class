using System;
using System.Linq;

namespace SkillLineAbilityDBCUtil
{
    class Program
    {
        static SkillLineAbilityDBC DBC;

        static void Main(string[] args)
        {
            var path = "D:/WoW Resources/2019_TrinityCore/DBC Temp/SkillLineAbility.dbc";
            var exportPath = "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/SkillLineAbility.dbc";
            var startIndex = 0;
            var rangeToCopy = 32;

            Console.WriteLine($"Processing {path}...");
            DBC = new SkillLineAbilityDBC(path, exportPath);

            Console.WriteLine("Read entries (R) for classmask or write new data (W)?");
            int keyread = AcceptInput();
            if (keyread == -1)
                return;
            if (keyread == 0)
            {
                Console.WriteLine("Input classmask to read:");
                uint classMask = ReadClassMask();
                OutputClassMaskData(classMask);
            }
            else
            {
                Console.WriteLine("Input classmask to copy:");
                uint readMask = ReadClassMask();
                Console.WriteLine("Input classmask to write as instead:");
                uint writeMask = ReadClassMask();

                Console.WriteLine($"Reading mask {readMask} and writing a copy as mask {writeMask}...");
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
            }
            Console.WriteLine("Done, press any key to exit...");
            Console.ReadKey();
        }

        static void OutputClassMaskData(uint compareMask)
        {
            uint count = 0;
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
