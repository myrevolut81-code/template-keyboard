# TemplateKeyboard

A minimal personal iOS keyboard extension for inserting predefined text templates instantly.

No login. No cloud. No sync. Local storage only.

---

## Requirements

- Mac with Xcode 15 or later
- iPhone running iOS 17+
- Free Apple ID (no paid developer account required for personal use / sideloading)
- USB cable to connect iPhone to Mac

---

## One-time setup on Mac

### 1. Install XcodeGen

```bash
brew install xcodegen
```

If you don't have Homebrew: https://brew.sh

---

### 2. Copy the project to your Mac

Copy the entire project folder (containing `project.yml`, `Shared/`, `TemplateKeyboard/`, `KeyboardExtension/`) to your Mac.

---

### 3. Configure your Bundle ID and Team ID

Open `project.yml` in any text editor and replace the two placeholders:

| Placeholder | Replace with |
|---|---|
| `com.yourname` | Any reverse-domain string, e.g. `com.johndoe` |
| `YOUR_TEAM_ID` | Your Apple Team ID (see below) |

**Finding your Team ID:**
1. Go to https://developer.apple.com/account
2. Sign in with your Apple ID
3. Click "Membership Details"
4. Copy the "Team ID" (10-character alphanumeric string)

> If you use a **free** Apple ID (no paid membership), your Team ID is still shown in Xcode under Signing & Capabilities after you sign in. You do not need to pay.

---

### 4. Register the App Group

The keyboard extension reads data written by the main app via a **shared App Group container**. You must register this identifier:

1. Go to https://developer.apple.com/account/resources/identifiers/list/applicationGroup
2. Click **+** and register: `group.templatekeyboard.shared`

> With a free Apple ID you can register App Groups but cannot publish to the App Store.

---

### 5. Generate the Xcode project

In Terminal, `cd` into the project folder and run:

```bash
xcodegen generate
```

This creates `TemplateKeyboard.xcodeproj`.

---

### 6. Open in Xcode and configure signing

```bash
open TemplateKeyboard.xcodeproj
```

For **each of the two targets** (TemplateKeyboard and KeyboardExtension):

1. Click the target in the left sidebar
2. Go to **Signing & Capabilities**
3. Check **Automatically manage signing**
4. Select your personal team from the Team dropdown
5. Verify the App Group `group.templatekeyboard.shared` appears under the **App Groups** capability

If the App Group capability is missing on either target:
- Click **+ Capability**
- Add **App Groups**
- Enable `group.templatekeyboard.shared`

---

### 7. Build and install on your iPhone

1. Connect your iPhone via USB
2. Select your iPhone as the run destination in Xcode (top toolbar)
3. Press **Cmd+R** to build and run

The first time, your iPhone may show "Untrusted Developer". Fix this:
- On iPhone: **Settings → General → VPN & Device Management → [Your Apple ID] → Trust**

---

### 8. Enable the keyboard on your iPhone

1. **Settings → General → Keyboard → Keyboards → Add New Keyboard**
2. Find and tap **TemplateKeyboard**
3. Tap it again in the list and enable **Allow Full Access**

> Allow Full Access is required so the keyboard extension can read data from the shared App Group container. Without it, templates will not load.

---

## How to use

### Add templates (in the app)

1. Open the **TemplateKeyboard** app
2. Create a category (e.g. "Greetings")
3. Tap into the category, then add templates

### Use the keyboard

1. Tap in any text field in any app
2. Switch to **TemplateKeyboard** using the globe button on the system keyboard
3. Tap a category button in the top row
4. Tap a template — it is inserted instantly into the text field
5. Tap **← Back** to return to the category list
6. Tap the **globe** button to switch back to the system keyboard

---

## Project structure

```
project.yml                          XcodeGen spec

Shared/
  AppGroupStorage.swift              App Group identifier and UserDefaults accessor
  Category.swift                     Category model (shared between both targets)
  Template.swift                     Template model (shared between both targets)

TemplateKeyboard/                    Main app target
  TemplateKeyboardApp.swift
  Storage/
    TemplateStore.swift              ObservableObject — CRUD + persistence
  Views/
    CategoryListView.swift           Root screen
    TemplateListView.swift           Templates inside a category
    AddTemplateView.swift            Add / edit template sheet
  Info.plist
  TemplateKeyboard.entitlements

KeyboardExtension/                   Keyboard extension target
  KeyboardViewController.swift       UIInputViewController host
  KeyboardView.swift                 SwiftUI keyboard UI
  KeyboardTemplateStore.swift        Read-only store, reloads on viewWillAppear
  Info.plist
  KeyboardExtension.entitlements
```

---

## Troubleshooting

**Templates do not appear in the keyboard**
- Ensure Allow Full Access is enabled for the keyboard in Settings
- Add at least one template in the main app, then raise the keyboard again (it reloads on every appearance)

**Build error: "No such module"**
- Make sure both targets include the `Shared/` source group (visible in Xcode's file navigator, and already configured in `project.yml`)

**Keyboard not visible in the keyboard list**
- Rebuild and reinstall the app, then re-add the keyboard in Settings

**"Untrusted Developer" on iPhone**
- Settings → General → VPN & Device Management → [Your Apple ID] → Trust

**App Group not working (data not shared)**
- Confirm the App Group `group.templatekeyboard.shared` is registered in your developer account
- Confirm it is enabled under Signing & Capabilities for both targets in Xcode
- Confirm Allow Full Access is on for the keyboard
