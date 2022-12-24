cd ..
cd "crash handler/"
lime build windows
cd ..
lime build windows
copy "crash handler/export/windows/bin/OccurrenceCrashHandler.exe" "export/release/windows/bin/OccurrenceCrashHandler.exe"
cd "export/release/windows/bin/"
Occurrence.exe
cd ../../../../
explorer "./export/release/windows/bin/"