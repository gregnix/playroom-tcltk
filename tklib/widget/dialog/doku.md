A documentation for `widget::dialog`, explaining its options, methods, and practical usage.

---

# **Detailed Documentation for `widget::dialog`**

The `widget::dialog` is part of the **Tklib's widget package**. It provides a customizable and reusable dialog window. This widget can be used to create modal or non-modal dialogs, display information, collect user input, or confirm actions.

---

## **Syntax**

```tcl
widget::dialog pathName ?options?
```

- **`pathName`**: The widget path name for the dialog (e.g., `.dlg`).
- **`options`**: A set of configuration options to customize the dialog's behavior and appearance.

---

## **Options**

### 1. **Behavior and Interaction**
| Option         | Description                                                                                                                                                                       | Default Value         |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
| `-command`     | A callback that is executed when a button is clicked. The callback receives the dialog path and the reason (`ok`, `cancel`, etc.).                                                | `{}`                 |
| `-modal`       | Specifies whether other windows are accessible while the dialog is displayed. Options: `none`, `local`, `global`.                                                                | `none`               |
| `-synchronous` | If set to `1`, the dialog blocks further script execution until the user closes it. If `0`, the dialog is non-blocking.                                                           | `1`                  |
| `-timeout`     | Timeout duration for auto-closing the dialog (active only when `-synchronous` is `1`).                                                                                           | `0`                  |

### 2. **Appearance**
| Option         | Description                                                                                                                                                                       | Default Value         |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
| `-padding`     | Padding around the dialog's content. This is delegated to the underlying `ttk::frame`.                                                                                           | `0`                  |
| `-separator`   | Whether to display a horizontal separator between the content and the button area (`1`: show, `0`: hide).                                                                         | `1`                  |
| `-title`       | The title text of the dialog window.                                                                                                                                              | `" "`                |
| `-transient`   | If `1`, the dialog behaves like a transient window (cannot be minimized or maximized).                                                                                            | `1`                  |

### 3. **Placement**
| Option         | Description                                                                                                                                                                       | Default Value         |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
| `-place`       | Specifies the dialog's position relative to the parent window. Options: `center`, `left`, `right`, `over`, `above`, `below`, `pointer`, `none`.                                   | `center`             |
| `-parent`      | Specifies the parent widget for the dialog.                                                                                                                                       | `""` (no parent)     |

### 4. **Custom Buttons**
| Option         | Description                                                                                                                                                                       | Default Value         |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
| `-type`        | Specifies the set of buttons to display. Options: `ok`, `okcancel`, `okcancelapply`, or `custom`.                                                                                 | `custom`             |

---

## **Methods**

### Core Methods
| Method           | Description                                                                                     |
|------------------|-------------------------------------------------------------------------------------------------|
| `add`            | Adds a new component to the dialog. Usage: `$dialog add $what $args`.                           |
| `setwidget`      | Specifies the main widget (e.g., a `frame`) to display inside the dialog.                       |
| `getframe`       | Returns the name of the frame widget inside the dialog.                                         |
| `display`        | Displays the dialog and, if `-synchronous` is `1`, waits for the user's interaction.            |
| `cancel`         | Simulates a user clicking the "Cancel" button.                                                  |
| `withdraw`       | Hides the dialog window without destroying it.                                                  |

### Bindings
- **Escape Key (ESC)**: Closes the dialog and invokes the cancel handler.
- **`WM_DELETE_WINDOW`**: Invoked when the user closes the window via the window manager. Calls the cancel handler.

---

## **Usage Example**

### **Basic Dialog with OK and Cancel**
```tcl
package require widget::dialog

proc showDialog {} {
    # Create the dialog widget
    set dlg [widget::dialog .dlg -modal local -type okcancel -title "Confirm Action"]

    # Add content
    set frame [frame $dlg.f]
    label $frame.lbl -text "Are you sure you want to continue?"
    grid $frame.lbl -sticky ew
    $dlg setwidget $frame

    # Display dialog and handle user response
    set response [$dlg display]
    if {$response eq "ok"} {
        puts "User confirmed the action."
    } else {
        puts "User canceled the action."
    }

    # Destroy the dialog
    destroy $dlg
}

# Show the dialog when a button is clicked
pack [button .btn -text "Open Dialog" -command showDialog]
```

---

### **Dialog with Custom Input**
```tcl
package require widget::dialog

proc showInputDialog {} {
    # Create dialog
    set dlg [widget::dialog .inputDlg -title "User Input" -type okcancel -modal local]

    # Add a frame with a label and entry field
    set frame [frame $dlg.f]
    label $frame.lbl -text "Enter your name:"
    entry $frame.ent -textvariable userName
    grid $frame.lbl $frame.ent -sticky ew
    $dlg setwidget $frame

    # Display dialog and retrieve user input
    set response [$dlg display]
    if {$response eq "ok"} {
        puts "User entered: $::userName"
    } else {
        puts "User canceled input."
    }

    destroy $dlg
}

# Trigger the input dialog
pack [button .btn -text "Get Input" -command showInputDialog]
```

---

### **Advanced Example with CSV File Picker**
```tcl

#https://tclcsv.magicsplat.com/#_widgets

```

---

## **Key Points to Remember**
1. **Custom Widgets**: Use `setwidget` to embed any custom content inside the dialog.
2. **Blocking Behavior**: The `-synchronous` option ensures that no other part of the script runs until the dialog is closed.
3. **Modal Types**: Use `-modal local` for application-specific locking or `-modal global` for full-screen blocking.
4. **Custom Buttons**: You can define custom buttons using the `add` method.

---
