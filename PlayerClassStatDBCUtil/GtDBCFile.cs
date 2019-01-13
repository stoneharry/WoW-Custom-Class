using SpellEditor.Sources.DBC;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace PlayerClassStatDBCUtil
{
    class GtDBCFile : AbstractDBC
    {
        private string _exportPath;
        private bool HasIdColumn = false;

        public GtDBCFile(string path, string exportPath)
        {
            _exportPath = exportPath;
            ReadDBCFile<GtDBCStruct>(path);
        }

        public GtDBCFile(string path, string exportPath, bool hasIdColumn)
        {
            _exportPath = exportPath;
            if (!hasIdColumn)
            {
                ReadDBCFile<GtDBCStruct>(path);
                return;
            }
            ReadDBCFile<GtEntryDBCStruct>(path);
            HasIdColumn = hasIdColumn;
        }

        public Dictionary<string, object>[] GetAllRecords()
        {
            return Body.RecordMaps;
        }

        public void AddNewRecords(int startIndex, uint rangeToCopy)
        {
            if (HasIdColumn)
            {
                AddNewRecordsWithEntry(startIndex, rangeToCopy);
                return;
            }
            var data = new List<float>();
            for (int i = startIndex; i <= (startIndex + rangeToCopy); ++i)
                data.Add((float) Body.RecordMaps[i]["Value"]);
            var allRecords = Body.RecordMaps.ToList();
            foreach (var value in data)
            {
                var entry = new Dictionary<string, object>();
                entry["Value"] = value;
                allRecords.Add(entry);
            }
            Body.RecordMaps = allRecords.ToArray();
            Header.RecordCount += rangeToCopy;
        }

        private void AddNewRecordsWithEntry(int startIndex, uint rangeToCopy)
        {
            var maxId = Body.RecordMaps.Max((record) => (uint)record["Id"]);
            var data = new List<Dictionary<string, object>>();
            for (int i = startIndex; i <= (startIndex + rangeToCopy); ++i)
            {
                var newDict = new Dictionary<string, object>();
                newDict.Add("Id", ++maxId);
                newDict.Add("Value", Body.RecordMaps[i]["Value"]);
                data.Add(newDict);
            }
            var allRecords = Body.RecordMaps.ToList();
            foreach (var value in data)
                allRecords.Add(value);
            Body.RecordMaps = allRecords.ToArray();
            Header.RecordCount += rangeToCopy;
        }

        public void SaveChanges()
        {
            // Write spell.dbc file
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
                        if (HasIdColumn)
                        {
                            count = Marshal.SizeOf(typeof(GtEntryDBCStruct));
                            buffer = new byte[count];
                            handle = GCHandle.Alloc(buffer, GCHandleType.Pinned);
                            GtEntryDBCStruct toWrite;
                            toWrite.Id = (uint)Body.RecordMaps[i]["Id"];
                            toWrite.Value = (float)Body.RecordMaps[i]["Value"];
                            Marshal.StructureToPtr(toWrite, handle.AddrOfPinnedObject(), true);
                            writer.Write(buffer, 0, count);
                            handle.Free();
                        }
                        else
                        {
                            count = Marshal.SizeOf(typeof(GtDBCStruct));
                            buffer = new byte[count];
                            handle = GCHandle.Alloc(buffer, GCHandleType.Pinned);
                            GtDBCStruct toWrite;
                            toWrite.Value = (float)Body.RecordMaps[i]["Value"];
                            Marshal.StructureToPtr(toWrite, handle.AddrOfPinnedObject(), true);
                            writer.Write(buffer, 0, count);
                            handle.Free();
                        }
                    }

                    writer.Write(Encoding.UTF8.GetBytes("\0"));
                }
            }
        }
    }

    [Serializable]
    public struct GtDBCStruct
    {
        // These fields are used through reflection, disable warning
#pragma warning disable 0649
#pragma warning disable 0169
        public float Value;
#pragma warning restore 0649
#pragma warning restore 0169
    }

    [Serializable]
    public struct GtEntryDBCStruct
    {
        // These fields are used through reflection, disable warning
#pragma warning disable 0649
#pragma warning disable 0169
        public uint Id;
        public float Value;
#pragma warning restore 0649
#pragma warning restore 0169
    }
}
