cd ..
cd "crash handler/"
lime build windows -clean
cd ..
lime build windows -clean -Drelease
copy ".\crash handler\export\release\windows\bin\OccurrenceCrashHandler.exe" .\export\release\windows\bin\
cd "export/release/windows/bin/"
Occurrence.exe