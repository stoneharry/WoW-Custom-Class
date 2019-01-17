using SpellEditor.Sources.DBC;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;

namespace SpellEditor.Sources.DBC
{
    class SkillRaceClassInfoDBC : AbstractDBC
    {
        protected string _exportPath;

        public SkillRaceClassInfoDBC(string path, string exportPath)
        {
            _exportPath = exportPath;
            ReadDBCFile<SkillRaceClassInfoStruct>(path);
        }

        public Dictionary<string, object>[] GetAllRecords()
        {
            return Body.RecordMaps;
        }

        public void AddNewRecords(List<Dictionary<string, object>> records)
        {
            var existing = Body.RecordMaps.ToList();
            records.ToList().ForEach(record => existing.Add(record));
            Header.RecordCount += (uint)records.Count();
            Body.RecordMaps = existing.ToArray();
        }

        public void SaveChanges()
        {
            // Write the dbc file
            string path = _exportPath;
            Directory.CreateDirectory(Path.GetDirectoryName(path));
            if (File.Exists(path))
                File.Delete(path);
            using (FileStream fileStream = new FileStream(path, FileMode.Create))
            {
                using (BinaryWriter writer = new BinaryWriter(fileStream))
                {
                    int count = Marshal.SizeOf(typeof(DBCHeader));
                    byte[] buffer = new byte[count];
                    GCHandle handle = GCHandle.Alloc(buffer, GCHandleType.Pinned);
                    Marshal.StructureToPtr(Header, handle.AddrOfPinnedObject(), true);
                    writer.Write(buffer, 0, count);
                    handle.Free();

                    for (uint i = 0; i < Header.RecordCount; ++i)
                    {
                        count = Marshal.SizeOf(typeof(SkillRaceClassInfoStruct));
                        buffer = new byte[count];
                        handle = GCHandle.Alloc(buffer, GCHandleType.Pinned);
                        SkillRaceClassInfoStruct record = new SkillRaceClassInfoStruct();
                        FieldInfo[] fields = record.GetType().GetFields();
                        foreach (var f in fields)
                        {
                            f.SetValueForValueType(ref record, (uint)Body.RecordMaps[i][f.Name]);
                        }
                        Marshal.StructureToPtr(record, handle.AddrOfPinnedObject(), true);
                        writer.Write(buffer, 0, count);
                        handle.Free();
                    }

                    writer.Write(Encoding.UTF8.GetBytes("\0"));
                }
            }
        }
    }

    static class Hlp
    {
        public static void SetValueForValueType<T>(this FieldInfo field, ref T item, object value) where T : struct
        {
            field.SetValueDirect(__makeref(item), value);
        }
    }
    
    [Serializable]
    public struct SkillRaceClassInfoStruct
    {
        // These fields are used through reflection, disable warning
#pragma warning disable 0649
#pragma warning disable 0169
        public uint Id;
        public uint skillId; // SkillLine.dbc
        public uint raceMask; // bitmask to ChrRaces.dbc
        public uint classMask; // bitmask to ChrClasses.dbc
        public uint flags;
        public uint reqLevel;
        public uint skillTierId; // SkillTiers.dbc
        public uint skillCostId; // SkillCostsData.dbc
#pragma warning restore 0649
#pragma warning restore 0169
    }
}
