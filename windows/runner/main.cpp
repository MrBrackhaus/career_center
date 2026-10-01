#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

// Muss mit "MyAppMutex" in windows/installer.iss uebereinstimmen.
constexpr const wchar_t kSingleInstanceMutexName[] =
    L"Bewerbungszentrale_SingleInstance_Mutex";
constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";
constexpr const wchar_t kWindowTitle[] = L"Career Center";

// Holt das Fenster einer bereits laufenden Instanz in den Vordergrund.
void ActivateExistingInstance() {
  HWND existing = ::FindWindowW(kWindowClassName, kWindowTitle);
  if (existing == nullptr) {
    return;
  }
  if (::IsIconic(existing) || !::IsWindowVisible(existing)) {
    ::ShowWindow(existing, SW_RESTORE);
  }
  ::SetForegroundWindow(existing);
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Single Instance: Laeuft die App bereits, deren Fenster aktivieren und
  // beenden. Zwei Instanzen wuerden sonst gleichzeitig auf dieselbe
  // Datenbank und denselben Companion-Port zugreifen.
  HANDLE instance_mutex =
      ::CreateMutexW(nullptr, TRUE, kSingleInstanceMutexName);
  if (instance_mutex != nullptr && ::GetLastError() == ERROR_ALREADY_EXISTS) {
    ActivateExistingInstance();
    ::CloseHandle(instance_mutex);
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(kWindowTitle, origin, size)) {
    if (instance_mutex != nullptr) {
      ::CloseHandle(instance_mutex);
    }
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  if (instance_mutex != nullptr) {
    ::ReleaseMutex(instance_mutex);
    ::CloseHandle(instance_mutex);
  }
  return EXIT_SUCCESS;
}

