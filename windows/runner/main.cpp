#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <iostream>
#include <string>
#include <dwmapi.h>

#include "flutter_window.h"
#include "utils.h"

#ifndef DWMWA_EXCLUDED_FROM_CAPTURE
#define DWMWA_EXCLUDED_FROM_CAPTURE 25
#endif

// Function to check if another instance of the app is running
bool IsAppAlreadyRunning() {
    HANDLE mutex = CreateMutex(nullptr, TRUE, L"easy_player_app_mutex");
    if (mutex == nullptr) {
        // Handle error if mutex creation fails
        return false;
    }

    if (GetLastError() == ERROR_ALREADY_EXISTS) {
        // Another instance is running
        CloseHandle(mutex); // Release the mutex
        return true;
    }

    // Mutex created successfully, no other instance is running
    // Do not close the mutex here; it will be released when the app exits
    return false;
}

// Function to bring the existing window to the foreground and pass the deep link URL
void BringExistingWindowToForeground(const std::wstring& url) {
    HWND hwnd = FindWindow(nullptr, L"easy_player_app");
    if (hwnd) {
        // Send the URL to the existing instance using WM_COPYDATA
        COPYDATASTRUCT cds;
        cds.dwData = 1; // Custom identifier
        cds.cbData = static_cast<DWORD>((url.size() + 1) * sizeof(wchar_t));
        cds.lpData = (void*)url.c_str();
        SendMessage(hwnd, WM_COPYDATA, 0, (LPARAM)&cds);

        // Bring the existing window to the foreground
        SetForegroundWindow(hwnd);
        ShowWindow(hwnd, SW_RESTORE);
    }
}

// Function to disable screenshots for the app
void DisableScreenshots(HWND hwnd) {
    SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE);
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
        _In_ wchar_t *command_line, _In_ int show_command) {
// Attach to console when present (e.g., 'flutter run') or create a
// new console when running with a debugger.
if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
CreateAndAttachConsole();
}

// Initialize COM, so that it is available for use in the library and/or
// plugins.
::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

// Check if another instance is already running
if (IsAppAlreadyRunning()) {
// Pass the command line (deep link URL) to the existing instance
BringExistingWindowToForeground(command_line);
return EXIT_SUCCESS; // Exit the new instance
}

flutter::DartProject project(L"data");

std::vector<std::string> command_line_arguments = GetCommandLineArguments();
project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

FlutterWindow window(project);
Win32Window::Point origin(10, 10);
Win32Window::Size size(1280, 720);
if (!window.Create(L"easy_player_app", origin, size)) {
return EXIT_FAILURE;
}

// Disable screenshots
DisableScreenshots(window.GetHandle());

window.SetQuitOnClose(true);

::MSG msg;
while (::GetMessage(&msg, nullptr, 0, 0)) {
::TranslateMessage(&msg);
::DispatchMessage(&msg);
}

::CoUninitialize();
return EXIT_SUCCESS;
}
