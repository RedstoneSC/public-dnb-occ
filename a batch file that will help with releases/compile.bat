cd ..
cd "crash handler/"
lime build windows -clean
cd ..
lime build windows -clean -Drelease
copy "../crash handler/export/windows/bin/OccurrenceCrashHandler.exe" "../export/release/windows/bin/OccurrenceCrashHandler.exe"
cd "export/release/windows/bin/"
Occurrence.exe