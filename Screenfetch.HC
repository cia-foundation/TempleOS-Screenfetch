#define OS_NAME "$TX+CX,"TempleOS",D="DD_OS_NAME_VERSION"$"

U8 buf[256];
U8* screenfetch_dir = __DIR__;

U0 Line(U8* label=NULL, U8* value=NULL) {
  "                 ";

  if (label)
    "$FG,3$%s", label;

  if (label && value)
    "" ": ";

  if (value)
    "$FG,8$%s", value;

  '' '\n';
}

I64 GetNumFilesInDirectory(U8* dir) {
  CDirEntry* de;
  try {
    de = FilesFind(dir);
  }
  catch {
    de = NULL;
  }

  if (!de)
    return -1;

  I64 count = 0;

  CDirEntry* de2 = de;
  while (de2) {
    if (!(de2->attr & RS_ATTR_DIR)) {
      count++;
    }
    de2 = de2->next;
  }

  DirTreeDel(de);
  return count;
}

CHashFun* FindFunction(U8* name) {
  CHash* result = HashFind(name, Fs->hash_table, HTT_FUN);

  if (result && (result->type & HTT_FUN) != 0)
    return result(CHashFun *);
  else
    return NULL;
}

U8* DetectCPU() {
  StrPrint(buf, "%d core(s)", mp_cnt);
  return buf;
}

U8* DetectFont() {
  // FIXME: Actually detect - but how?
  // If there was something like a global hash-table,
  // we could use it to mark user Fonts & Palettes
  return "FontStd.HC";
}

U8* DetectNumPackages() {
  I64 num_packages = GetNumFilesInDirectory("::/Misc/Packages");

  if (num_packages < 0)
    num_packages = 0;

  StrPrint(buf, "%d", num_packages);
  return buf;
}

U8* DetectRAM() {
  I64 ram_used = sys_code_bp->used_u8s;
  I64 ram_total = sys_code_bp->alloced_u8s;
  if (sys_data_bp) {
    ram_used += sys_data_bp->used_u8s;
    ram_total += sys_data_bp->alloced_u8s;
  }
  StrPrint(buf, "%dMiB / %dMiB", ram_used / (1024 * 1024), ram_total / (1024 * 1024));
  return buf;
}

U8* DetectPalette() {
  // FIXME: Actually detect - but how?
  // See comment in DetectFont
  return "PalUbuntu.HC";
}

U8* DetectShell() {
  if (FindFunction("Lsh"))
    return "Lsh";
  else if (FindFunction("TempleShell"))
    return "TempleShell";
  else if (FindFunction("UserCmdLine"))
    return "UserCmdLine";
  else
    return "unknown";
}

U8* DetectUptime() {
  F64 uptime = tS;
  I64 uptime_min = ToI64(uptime) / 60;
  I64 uptime_sec = ToI64(uptime) % 60;
  StrPrint(buf, "%dm %ds", uptime_min, uptime_sec);
  return buf;
}

U0 Screenfetch() {
  Line();

  U8* logo_path = MStrPrint("%s/Logo128x152.bmp", screenfetch_dir);
  DocBMP(DocPut, logo_path);
  Free(logo_path);

  Line();
  Line();
  StrPrint(buf, "singleuser@%s", DirCur);
  Line(buf, "");
  Line();
  Line();
  Line("OS",          OS_NAME);
  Line("Kernel",      "TempleOS");
  Line("Uptime",      DetectUptime());
  Line("Packages",    DetectNumPackages());
  Line("Shell",       DetectShell());
  Line("Resolution",  "640x480");
  Line("DE",          "Not Present");
  Line("WM",          "Default");
  Line("Palette",     DetectPalette());
  Line("Font",        DetectFont());
  Line("CPU",         DetectCPU());
  Line("RAM",         DetectRAM());
  Line();
  Line();
  Line();
}
