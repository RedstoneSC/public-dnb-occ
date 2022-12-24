package;

/*
	VS DAVE WINDOWS/LINUX/MACOS UTIL
	You can use this code while you give credit to it.
	65% of the code written by chromasen
	35% of the code written by Erizur (cross-platform and extra windows utils)

	Windows: You need the Windows SDK (any version) to compile.
	Linux: TODO
	macOS: TODO


	hi guys i added more coolested stuffs
	ill try to make cross platform but mostly for windows
	credit me alsos if you want to use the extra stuff
	100% of the extra by me
	uhh og stuff will have a comment next to it saying og
	eg
	// og thing
	ok bye
 */
#if windows
@:cppFileCode('
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <winuser.h>
#include <dwmapi.h>
#include <strsafe.h>
#include <shellapi.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <windef.h>
#include <synchapi.h>
#include <wingdi.h>

#pragma comment(lib, "gdi32.lib")
#pragma comment(lib, "Dwmapi")
#pragma comment(lib, "Shell32.lib")
')
#elseif linux
@:cppFileCode('
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdlib>
')
#end
class SystemUtils
{
	#if windows
	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(1, 1, 1), 0, LWA_COLORKEY);
        }
    ')
	#elseif linux
	/*
		REQUIRES IMPORTING X11 LIBRARIES (Xlib, Xutil, Xatom) to run, even tho it doesnt work
		@:functionCode('
			Display* display = XOpenDisplay(NULL);
			Window wnd;
			Atom property = XInternAtom(display, "_NET_WM_WINDOW_OPACITY", False);
			int revert;
			
			if(property != None)
			{
				XGetInputFocus(display, &wnd, &revert);
				unsigned long opacity = (0xff000000 / 0xffffffff) * 50;
				XChangeProperty(display, wnd, property, XA_CARDINAL, 32, PropModeReplace, (unsigned char*)&opacity, 1);
				XFlush(display);
			}
			XCloseDisplay(display);
		')
	 */
	#end
	static public function getWindowsTransparent(res:Int = 0) // Only works on windows, otherwise returns 0!, this is an og function
	{
		return res;
	}

	#if windows
	@:functionCode('
        NOTIFYICONDATA m_NID;

        memset(&m_NID, 0, sizeof(m_NID));
        m_NID.cbSize = sizeof(m_NID);
        m_NID.hWnd = GetForegroundWindow();
        m_NID.uFlags = NIF_MESSAGE | NIIF_WARNING | NIS_HIDDEN;

        m_NID.uVersion = NOTIFYICON_VERSION_4;

        if (!Shell_NotifyIcon(NIM_ADD, &m_NID))
            return FALSE;
    
        Shell_NotifyIcon(NIM_SETVERSION, &m_NID);

        m_NID.uFlags |= NIF_INFO;
        m_NID.uTimeout = 1000;
        m_NID.dwInfoFlags = NULL;

        LPCTSTR lTitle = title.c_str();
        LPCTSTR lDesc = desc.c_str();

        if (StringCchCopy(m_NID.szInfoTitle, sizeof(m_NID.szInfoTitle), lTitle) != S_OK)
            return FALSE;

        if (StringCchCopy(m_NID.szInfo, sizeof(m_NID.szInfo), lDesc) != S_OK)
            return FALSE;

        return Shell_NotifyIcon(NIM_MODIFY, &m_NID);
    ')
	#elseif linux
	@:functionCode('
        std::string cmd = "notify-send -u normal \'";
        cmd += title.c_str();
        cmd += "\' \'";
        cmd += desc.c_str();
        cmd += "\'";
        system(cmd.c_str());
    ')
	#end
	static public function sendNotification(title:String = "", desc:String = "", res:Int = 0) // TODO: Linux (found out how to do it so ill do it soon)
	{
		return res;
	} // og function

	#if windows
	@:functionCode('
        LPCSTR lwDesc = desc.c_str();

        res = MessageBox(
            NULL,
            lwDesc,
            NULL,
            MB_OK
        );
    ')
	#end
	static public function sendFakeMsgBox(desc:String = "", res:Int = 0) // TODO: Linux and macOS (will do soon)
	{
		return res; // og function part 2!
	}

	#if windows
	@:functionCode(' // what does this do??? (looks like just getWindowsTransparent();)
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(1, 1, 1), 1, LWA_COLORKEY);
        }
    ')
	#end
	static public function getWindowsbackward(res:Int = 0) // Only works on windows, otherwise returns 0!
	{
		return res; // woah og function
	}

	#if windows
	@:functionCode('
        std::string p(getenv("APPDATA"));
        p.append("\\\\Microsoft\\\\Windows\\\\Themes\\\\TranscodedWallpaper");

        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, (PVOID)p.c_str(), SPIF_UPDATEINIFILE);
    ')
	#end
	static public function updateWallpaper()
	{ // Only works on windows, otherwise returns 0!
		return null; // function that is og
	}

	#if windows
	@:functionCode('
	HWND hWnd = GetActiveWindow();
	res = SetWindowPos(hWnd, HWND_TOPMOST, 0,0,0,0, SWP_NOSIZE | SWP_NOMOVE);
	')
	#end
	static public function getWindowAlwaysOnTop(res:Int = 0) // coolnessedes
	{
		return res;
	}

	#if windows
	@:functionCode('
    INPUT inputs[4] = {};
    ZeroMemory(inputs, sizeof(inputs));

    inputs[0].type = INPUT_KEYBOARD;
    inputs[0].ki.wVk = 0x5B;
   
    inputs[1].type = INPUT_KEYBOARD;
    inputs[1].ki.wVk = 0x44;

    inputs[2].type = INPUT_KEYBOARD;
    inputs[2].ki.wVk = 0x44;
    inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;

    inputs[3].type = INPUT_KEYBOARD;
    inputs[3].ki.wVk = 0x5B;
    inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;

    UINT uSent = SendInput(ARRAYSIZE(inputs), inputs, sizeof(INPUT));
    if (uSent == ARRAYSIZE(inputs))
    {
       res = 1;
    } 
	')
	#end
	static public function sendToTheDesktop(res:Int = 0) // trolling (weak edition)
	{
		return res;
	}

	#if windows
	@:functionCode('
	width = GetSystemMetrics(SM_CXVIRTUALSCREEN);
	height = GetSystemMetrics(SM_CYVIRTUALSCREEN);
	')
	#end
	static public function getScreenSize(width:Int = 1920, height:Int = 1080) // 1920 x 1080 is fallback if not on windows
	{
		return [width, height];
	}

	#if windows
	@:functionCode('
	HDC desktop;
	HWND desktopHandle;
	RECT screenSize;
	screenSize.left = 0;
	screenSize.top = 0;
	screenSize.right = GetSystemMetrics(SM_CXVIRTUALSCREEN);
	screenSize.bottom = GetSystemMetrics(SM_CYVIRTUALSCREEN);
	desktopHandle = GetDesktopWindow();
	desktop = GetDC(desktopHandle);
	InvertRect(desktop, &screenSize);
	res = ReleaseDC(desktopHandle,desktop);
	')
	#end
	static public function invertScreenColor(res:Int = 0)
	{
		return res;
	}

	#if windows
	@:functionCode('
	res = GetSystemMetrics(SM_SLOWMACHINE);
	')
	#end
	static public function isSlowMachine(res:Int = 0)
	{
		return res != 0;
	}

	#if windows
	@:functionCode('
	HDC desktop;
    HWND desktopHandle;
    RECT screenSize;
    screenSize.left = 0;
    screenSize.top = 0;
    screenSize.right = GetSystemMetrics(SM_CXVIRTUALSCREEN);
    screenSize.bottom = GetSystemMetrics(SM_CYVIRTUALSCREEN);
    desktopHandle = GetDesktopWindow();
    desktop = GetDC(desktopHandle);
    StretchBlt(desktop, 0,0, screenSize.right / 2, screenSize.bottom / 2, desktop, 0, 0, screenSize.right, screenSize.bottom, SRCCOPY); // top-left
    StretchBlt(desktop, screenSize.right / 2,0, screenSize.right / 2, screenSize.bottom / 2, desktop, 0, 0, screenSize.right, screenSize.bottom, SRCCOPY); // top-right
    StretchBlt(desktop, 0,screenSize.bottom / 2, screenSize.right / 2, screenSize.bottom / 2, desktop, 0, 0, screenSize.right, screenSize.bottom, SRCCOPY); // bottom-left
    StretchBlt(desktop, screenSize.right / 2,screenSize.bottom / 2, screenSize.right / 2, screenSize.bottom / 2, desktop, 0, 0, screenSize.right, screenSize.bottom, SRCCOPY); // bottom-right
	res = ReleaseDC(desktopHandle, desktop);
	')
	#end
	static public function multiplyScreen(res:Int = 0) // doesnt do what i want, eh its fine
	{
		return res != 0;
	}

	#if windows
	@:functionCode('
	HDC focusedWindow; // should be expunged
	HWND focusedWindowHandle;
	HDC desktop;
    HWND desktopHandle;
	RECT windowRect;
    desktopHandle = GetDesktopWindow();
    desktop = GetDC(desktopHandle);
	focusedWindowHandle = FindWindow(NULL, "expunged.dat");
	if (focusedWindowHandle == NULL)
		return 0; // you messed it up  so we get out
	focusedWindow = GetWindowDC(focusedWindowHandle); // this was done as it seemed to get the titlebar but this doesnt? (if i remember correctly)
	GetWindowRect(focusedWindowHandle, &windowRect);
	switch (dir)
	{
		case 0: // left
		BitBlt(desktop, windowRect.left - space, windowRect.top, windowRect.right, windowRect.bottom, focusedWindow, 0,0, SRCCOPY);
		break;
		case 1: // down
		BitBlt(desktop, windowRect.left, windowRect.top + space, windowRect.right, windowRect.bottom, focusedWindow, 0,0, SRCCOPY);
		break;
		case 2: // up
		BitBlt(desktop, windowRect.left, windowRect.top - space, windowRect.right, windowRect.bottom, focusedWindow, 0,0, SRCCOPY);
		break;
		case 3: // right
		BitBlt(desktop, windowRect.left + space, windowRect.top, windowRect.right, windowRect.bottom, focusedWindow, 0,0, SRCCOPY);
		break;
	}
	ReleaseDC(focusedWindowHandle, focusedWindow);
	res = ReleaseDC(desktopHandle, desktop);
	')
	#end
	static public function cloneWindow(dir:Int = 0, space:Int = 25,
			res:Int = 0) // a bit unclean but eh + could be used but would need to transparent the desktop and that could be an issue (not actually doing it lol that's easy)
	{
		return res != 0;
	}
}
