using System;

namespace PlayerClassStatDBCUtil
{
    class Program
    {
        static void Main(string[] args)
        {
            /*
            * 100 rows for each class, need to add new data for new class for all these DBC's:
            * Repeat for: 
            * - gtChanceToMeleeCrit.dbc
            * - gtChanceToSpellCrit.dbc
            * - gtOCTRegenHP.dbc
            * - gtOCTRegenMP.dbc
            * - gtRegenHPPerSpt.dbc
            * - gtRegenMPPerSpt.dbc
            * 
            * Now do the exact same for these files, but you only need to add 1 entry, so you should have 13 records at the end
            * - gtChanceToMeleeCritBase.dbc
            * - gtChanceToSpellCritBase.dbc
            * 
            * Now we open up "gtOCTClassCombatRatingScalar.dbc.csv"
            * Gonna have to do some basic math here because instead of 100, 1 or 10 entries per class it's 32. So to find yours just do this:
            */
            object[] paths = new object[]
            {
                // first lot have 100 entries each
                "D:/WoW Resources/2019_TrinityCore/DBC Temp/gtChanceToMeleeCrit.dbc", "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/gtChanceToMeleeCrit.dbc", 0, 100,
                "D:/WoW Resources/2019_TrinityCore/DBC Temp/gtChanceToSpellCrit.dbc", "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/gtChanceToSpellCrit.dbc", 0, 100,
                "D:/WoW Resources/2019_TrinityCore/DBC Temp/gtOCTRegenHP.dbc", "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/gtOCTRegenHP.dbc", 0, 100,
                "D:/WoW Resources/2019_TrinityCore/DBC Temp/gtOCTRegenMP.dbc", "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/gtOCTRegenMP.dbc", 0, 100,
                "D:/WoW Resources/2019_TrinityCore/DBC Temp/gtRegenHPPerSpt.dbc", "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/gtRegenHPPerSpt.dbc", 0, 100,
                "D:/WoW Resources/2019_TrinityCore/DBC Temp/gtRegenMPPerSpt.dbc", "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/gtRegenMPPerSpt.dbc", 0, 100,
                // these only have 1 entry each
                "D:/WoW Resources/2019_TrinityCore/DBC Temp/gtChanceToMeleeCritBase.dbc", "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/gtChanceToMeleeCritBase.dbc", 0, 1,
                "D:/WoW Resources/2019_TrinityCore/DBC Temp/gtChanceToSpellCritBase.dbc", "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/gtChanceToSpellCritBase.dbc", 0, 1,
                // to process the other file it has a ID column as well, so we have to load it slightly differently. Used after the for loop
            };
            Console.WriteLine($"Processing {paths.Length / 4} files");
            for (int i = 0; i < paths.Length; i += 4)
            {
                var path = (string)paths[i];
                var exportPath = (string)paths[i + 1];
                var startIndex = (int)paths[i + 2];
                var rangeToCopy = (int)paths[i + 3];
                Console.WriteLine($"Processing {path}...");

                var gtDbcFile = new GtDBCFile(path, exportPath);
                gtDbcFile.AddNewRecords(startIndex, (uint)rangeToCopy);
                gtDbcFile.SaveChanges();
            }
            {
                // process the odd file with a ID column
                var path = "D:/WoW Resources/2019_TrinityCore/DBC Temp/gtOCTClassCombatRatingScalar.dbc";
                var exportPath = "D:/WoW Resources/2019_TrinityCore/DBC Temp/Export/gtOCTClassCombatRatingScalar.dbc";
                var startIndex = 0;
                var rangeToCopy = 32;
                Console.WriteLine($"Processing {path}...");

                var gtDbcFile = new GtDBCFile(path, exportPath, true);
                gtDbcFile.AddNewRecords(startIndex, (uint)rangeToCopy);
                gtDbcFile.SaveChanges();
            }
            Console.WriteLine("Done");
        }
    }
}
