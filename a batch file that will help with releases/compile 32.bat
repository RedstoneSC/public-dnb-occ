cd ..
cd "crash handler/"
lime build windows -clean -D 32bits -D HXCPP_M32 -32
cd ..
lime build windows -clean -Drelease -D 32bits -D HXCPP_M32 -32
copy "../crash handler/export/windows/bin/OccurrenceCrashHandler.exe" "../export/release/windows/bin/OccurrenceCrashHandler.exe"
cd "export/release/windows/bin/"
Occurrence.exe