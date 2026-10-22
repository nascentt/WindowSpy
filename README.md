# Window Spy

Inspect native Windows windows and controls, change their text, manage visibility, and generate basic lookup code.

## Requirements

- Windows
- **AutoHotkey v1.1** to run `WindowSpy.ahk` (not AutoHotkey v2)
- The compiled `WindowSpy.exe` can run without a separate AutoHotkey installation. Recompile it after script changes to include those changes.

## Run

```bat
C:\Apps\AutoHotkey\AutoHotkey.exe C:\Apps\AutoHotkey\Scripts\WindowSpy\WindowSpy.ahk
```

Alternatively, double-click the script if `.ahk` files are associated with AutoHotkey v1.1.

## Selecting a target

1. Click **Pick Target Then Click It**.
2. Move the pointer over the desired window or control.
3. Click to capture it.

The picker selects a native child control when one is available; otherwise it selects the top-level window. This is a click-to-pick tool, not a drag-and-release picker. The target also receives your click.

Enable **Auto Mode** to inspect the window/control under the mouse continuously. Disable it to retain a selection before performing actions.

## Window details

The main panel displays the selected target's:

- Handle (HWND)
- Text/title
- Window class
- Parent class, text, and handle, when available

`[null]` indicates empty text; `N/A` indicates no parent.

Click a blue **+** beside a property to copy its value to the clipboard and the selection box. `Ctrl+C` while Window Spy is active copies the selection box value.

## Actions

| Button / option | Purpose |
| --- | --- |
| Set Window Text | Apply the adjacent text field to the selected window/control. |
| Set Parent Text | Apply the adjacent text field to the selected target's parent. |
| Hide Window / Show Window | Hide or show the selected target. |
| Hide Parent / Show Parent | Hide or show its parent. |
| Kill Window / Kill Parent | Send a close request (`WM_CLOSE`), not force-terminate the process. |
| Kill Prompt | Ask for confirmation before sending a close request. |
| Transparent | Set the selected target to approximately 70 percent opacity. |
| Opaque | Remove the selected target's transparency setting. |
| Keep On Top | Keep Window Spy above other windows. |
| Hidden List | Open the hidden-window list with a Restore action. |
| hWnd Scan | List current top-level windows and their native child controls. Select an entry to inspect it. |
| Code... | Open the code generator. |

The handle scanner enumerates existing windows rather than probing a numeric handle range. Click **Scan** to refresh or **Clear** to clear its list.

## Code generator

Select **AutoHotkey**, **Visual Basic**, or **C++**, then click **Generate**. **Copy** copies the output.

Generated code is a starting point and should be reviewed before use:

- AutoHotkey output uses v1-style lookup syntax. Child-target output currently provides parent lookup and child metadata rather than a complete child lookup.
- Visual Basic output uses classic VB6-style `Long` handles and assumes the required Win32 API declarations are already available. It is not ready-to-run VBA7/64-bit code.
- C++ output assumes the appropriate Windows headers and matching character-set configuration.
- Nested controls, duplicate classes/titles, and titles containing quotes may require manual adjustments.

## Limitations and safety

- Only controls exposed as native window handles can be selected individually. Browsers, modern Notepad, and other custom-drawn applications may require UI Automation for deeper inspection; this tool does not implement it.
- Applications may ignore or immediately overwrite text/title changes.
- Windows can block changes to elevated applications. Use matching elevation only when necessary.
- Transparency support varies by target, especially for child controls.
- A parent is the immediate Win32 parent/owner relationship, not necessarily the application's main window.
- Hidden List is a basic listing, not a persistent record of windows hidden by this tool. It may be incomplete.
- Hiding or closing controls/windows can disrupt applications. Save your work first. Do not close or hide critical system windows.

## Project files

- `WindowSpy.ahk` - editable AutoHotkey source
- `WindowSpy.exe` - compiled executable
- `Red-Bulb.ico` - project icon
- `Readme.md` - this documentation
