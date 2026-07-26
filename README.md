# Longitudinal Analysis of iOS In-App Purchase Implementation Vulnerabilities

This repository contains the code accompanying the paper *"Longitudinal Analysis of iOS In-App Purchase Implementation Vulnerabilities."* It provides a runtime tweak that demonstrates common weaknesses in iOS In-App Purchase (IAP) implementations and can be tested against any App Store app that ships these flaws, as well as against the included [BypassIAPTestApp](BypassIAPTestApp/) demo app. It supports two setups: a jailbroken iPhone (primary path) and an Apple Security Research Device.

This code is released strictly for educational and scientific research. Do not use it to harm people or organizations, or to access content you have not paid for. You are solely responsible for how you use this material. See the [Disclaimer of Damages](#disclaimer-of-damages) for details.

## README Structure
* [Repository organization](#repository-organization)
* [Considered Badges](#considered-badges)
* [Security Concerns](#security-concerns)
* [Jailbroken iPhone](#jailbroken-iphone)
  * [Environment Setup](#environment-setup)
  * [Building and Running the Tweak](#building-and-running-the-tweak)
  * [Everyday workflow](#everyday-workflow-after-the-first-time)
* [Security Research Device (SRD)](#security-research-device-srd)
* [Experiments](#experiments)
* [Troubleshooting](#troubleshooting)
* [License](#license)

## Repository organization
```
bypass-iap-ios/
│
├── tweak/                       # Theos tweak project used in the jailbroken iPhone setup
│   ├── Tweak.x                  # Tweak source code
│   ├── Makefile                 # Theos build configuration (THEOS_DEVICE_IP/PORT)
│   ├── control                  # Package metadata
│   └── bypassIAPiOS.plist       # Target app bundle IDs
│
├── srd-dylib/                   # dylib and build script used in the Security Research Device setup
│   ├── bypass-iap.m             # dylib source code
│   └── build-install.sh         # Build and install script
│
├── BypassIAPTestApp/            # Deliberately vulnerable SwiftUI demo app used to exercise the bypass
│   ├── BypassIAPTestApp.xcodeproj
│   └── BypassIAPTestApp/
│       ├── IAPManager.swift     # StoreKit purchase flow with no receipt validation
│       ├── EntitlementStore.swift  # UserDefaults-based entitlement flags and expiration
│       ├── ContentView.swift    # UI exposing each vulnerability
│       └── Products.storekit    # Local StoreKit product configuration
│
└── tables/                      # LaTeX tables from the paper
    ├── app_agnostic_table.tex
    ├── app_agnostic_table.pdf
    ├── app_specific_table.tex
    └── app_specific_table.pdf
```

## Considered Badges
The considered badges are: Available, Functional, Sustainable and Reproducible.

## Security Concerns

This artifact is a runtime bypass for iOS In-App Purchase checks. It is provided
solely for educational and scientific research. Read this before running it.

**What it does.** The tweak/dylib hooks the IAP logic of a target app at runtime
and forces entitlement checks to pass, demonstrating flaws in apps that ship
without server-side receipt validation. It does not exfiltrate data, contact any
network service, or persist beyond the app it is injected into.

**Safe-usage requirements.**
- **Use a dedicated, owned device.** Jailbreak and test on an iPhone you own and
  are willing to wipe — never your daily phone. Back it up first.
- **Only target apps you are authorized to test** (the included
  [BypassIAPTestApp](BypassIAPTestApp/) or apps you own/have permission to
  analyze). Do not use it to access paid content you have not paid for.
- **Jailbreaking lowers the device's security posture.** A jailbroken iPhone
  disables Apple's code-signing and sandbox protections and should not hold
  personal accounts or sensitive data while used for this research.
- The SRD path avoids jailbreaking by using Apple's official Security Research
  Device, which is the safer environment when available.

Use of this material is entirely at your own risk; see [License](#license) for
the full warranty and liability disclaimer.

## Jailbroken iPhone

This is the primary path, tested on an **iPhone 7 running iOS 15.8.8, jailbroken with Dopamine**. It covers the one-time environment setup, building and installing the tweak, and the everyday edit–test loop. If instead you have an official Apple **Security Research Device**, skip ahead to [Security Research Device (SRD)](#security-research-device-srd).

### Environment Setup

This guide walks you through setting up everything needed to run the code, starting from scratch. No prior jailbreaking experience is assumed. By the end, you will have a jailbroken iPhone that your Mac can connect to via SSH, along with the build tools needed to compile the tweaks used in this work.

**What you will end up with**
- A jailbroken iPhone running an SSH server (so it can accept remote connections).
- A Mac that can open a command-line session directly on that iPhone through the USB cable.
- The Theos build system on your Mac, used to compile the tweaks.

**Before you start**
- **Use a dedicated device.** Jailbreak the iPhone you are willing to experiment on, not your daily phone. Back it up first.
- **You must own the device.** These steps assume the iPhone and Mac are yours and used for research.
- Set aside about an hour for the first-time setup.


### Part 1 — Prepare the iPhone

**Step 1. Jailbreak the iPhone**

A *jailbreak* removes Apple's restrictions so you can install software (like an SSH server) that Apple normally blocks.

The [Experiments](#experiments) section was tested on an **iPhone 7 running iOS 15.8.8, jailbroken with Dopamine**, but the procedure should work on any jailbroken iPhone.

1. Follow the Dopamine walkthrough: <https://ios.cfw.guide/installing-dopamine-trollstore/>. If your device or iOS version is different, find the matching guide here: <https://ios.cfw.guide/>
2. When the jailbreak finishes, your iPhone will have a package manager app called **Sileo** on the Home Screen. You will use it in the next step.

During the jailbreak, Dopamine should ask you to set a password. This is the same password you will later use to log in over SSH (with the username `mobile`), so keep it somewhere safe. If you are not asked to set one, the default is the well-known `alpine`.

> Jailbreaks can occasionally fail or need to be reapplied after the phone restarts. If Sileo disappears or apps stop working after a reboot, simply re-run the jailbreak from the Dopamine app.

**Step 2. Install OpenSSH**

**OpenSSH** is the software that lets your Mac log into the iPhone remotely and type commands on it.

1. Open the **Sileo** app on the iPhone.
2. Tap the **Search** tab and type `openssh`.
3. Select the **OpenSSH** package and tap **Install** (or **Get** / **Modify**).
4. When prompted, tap to confirm, then let it **respring** (the screen goes black briefly and the Home Screen reloads). This is normal.

**Step 3. Install ElleKit**

**ElleKit** is the hooking engine that actually loads and runs tweaks on a rootless jailbreak (it replaces the old MobileSubstrate). The tweak in this repo depends on it. Dopamine usually installs it by default, but install it explicitly to be sure.

1. Open the **Sileo** app on the iPhone.
2. Tap the **Search** tab and type `ellekit`.
3. Select the **ElleKit** package and tap **Install** (if it's already installed, Sileo will show **Modify** / **Reinstall** — you can leave it as is).
4. If prompted, tap to confirm and let it **respring**.

> On a **rootful** jailbreak you'd install **Substrate** (MobileSubstrate) here instead — but you can usually skip this step because it comes pre-installed.

### Part 2 — Prepare the Mac

**Step 1. Install Homebrew**

**Homebrew** is a tool that installs other command-line software on macOS with a single command.

1. Open the **Terminal** app (press `Cmd + Space`, type `Terminal`, press Enter).
2. Paste this line and press Enter, then follow the on-screen prompts:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

**Step 2. Install the USB connection tool (iproxy)**

`iproxy` (part of the **libimobiledevice** toolkit) lets your Mac talk to the iPhone's SSH server over the USB cable, so you don't need Wi-Fi.

```bash
brew install libimobiledevice
```

**Step 3. Install the Theos build system**

**Theos** is what compiles the tweaks used in the experiments.

1. Install Xcode's command-line tools (needed by Theos):

   ```bash
   xcode-select --install
   ```

   A dialog will pop up — click **Install** and wait for it to finish.

2. Run the official Theos installer and follow the prompts:

   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
   ```

> If you get stuck, the full instructions are here: <https://theos.dev/docs/installation-macos>

### Part 3 — Connect the Mac to the iPhone

**Step 1. Plug in and start the tunnel**

1. Connect the iPhone to the Mac with a USB cable. If the iPhone asks whether to **Trust This Computer**, tap **Trust** and enter your passcode.
2. In Terminal, start the tunnel:

   ```bash
   iproxy 2222 22
   ```

   This forwards port `2222` on your Mac to the iPhone's SSH port (`22`) through the cable. **Leave this Terminal window open** — closing it ends the connection.

**Step 2. Log in to the iPhone**

1. Open a **second** Terminal window (`Cmd + N`).
2. Connect over SSH:

   ```bash
   ssh -p 2222 mobile@127.0.0.1
   ```

3. The first time, you'll see a message asking whether to trust the device's identity. Type `yes` and press Enter.
4. Enter the password (`alpine` by default). You won't see the characters as you type — that's normal. Press Enter.

> The first time you SSH into a fresh Dopamine device, zsh greets you with a **`zsh-newuser-install`** menu ("you have no zsh startup files…") asking to create a `~/.zshrc`. This is just zsh's first-run setup, unrelated to the tweak. Press **`0`** to create an empty `~/.zshrc` (so it stops asking on every login), or **`q`** to skip it — either way you land at a normal shell prompt where you can run the commands below.

You are now logged into the iPhone. Any command you type runs on the phone.

### Building and Running the Tweak
This guide assumes you already completed [Environment Setup](#environment-setup): your iPhone is jailbroken with OpenSSH, your Mac has Theos and `libimobiledevice`, and you can connect over SSH through the `iproxy` tunnel.

The ready-to-use tweak lives in the [tweak/](tweak/) folder of this repository. You do **not** need to write any code — you just build it on the Mac and install it on the iPhone. This section walks through exactly that.

The tweak hooks the in-app-purchase logic of the target app declared in [tweak/bypassIAPiOS.plist](tweak/bypassIAPiOS.plist) (by default `com.izmcm.BypassIAPTestApp`) and logs each bypass to the system log. To test a different app, replace that bundle ID with the one you want.

**What you will end up with**

- The repository's tweak compiled and installed on the iPhone.
- A way to confirm the tweak actually loaded.

### Part 1 — Open the tweak folder

In the build Terminal, move into the tweak project:

```bash
cd bypass-iap-ios/tweak
```

Everything below is run from inside this folder.

### Part 2 — The Makefile is preconfigured for Dopamine

The included [tweak/Makefile](tweak/Makefile) already ships ready to build and install on a **Dopamine (rootless)** iPhone reached over the `iproxy` tunnel. You normally don't need to change anything:

```make
THEOS_PACKAGE_SCHEME = rootless      # rootless jailbreak (Dopamine, palera1n rootless, …)
export THEOS_DEVICE_IP=127.0.0.1     # the iproxy tunnel
export THEOS_DEVICE_PORT=2222        # local port from `iproxy 2222 22`
export THEOS_DEVICE_USER=mobile      # Dopamine logs in as `mobile`, not root
TARGET := iphone:clang:latest:14.0   # arm64/arm64e (iPhone 7 and newer)
```

**Adjusting for a different setup:**

- **Rootful jailbreak** (unc0ver, Taurine, checkra1n rootful, older tools): **remove** the `THEOS_PACKAGE_SCHEME = rootless` line — a rootless package won't load there. On most rootful jailbreaks you also install as root, so change `THEOS_DEVICE_USER=mobile` to `THEOS_DEVICE_USER=root` (or delete the line; root is the default).
- **Different iproxy port:** if you started `iproxy` on another local port, update `THEOS_DEVICE_PORT` to match.
- **Very old 32-bit device (iPhone 5 / 5c or earlier):** those need an `armv7` build, so lower `TARGET` back to `7.0`. On any 64-bit iPhone leave it at `14.0` — an older target makes the toolchain try (and fail) to link a 32-bit slice.

### Part 3 — Allow passwordless install on the device (rootless only)

Because Dopamine installs as `mobile`, Theos runs the final install step with `sudo` over SSH — and a non-interactive SSH session can't type a `sudo` password, so the install fails with *"sudo: a terminal is required to read the password."* Grant `mobile` passwordless `sudo` **once**.

In that SSH session **on the iPhone** (logged in as `mobile`):

```bash
# 1. Make sure sudo actually reads the sudoers.d folder
sudo grep -q '^@includedir /var/jb/etc/sudoers.d' /var/jb/etc/sudoers || \
  echo '@includedir /var/jb/etc/sudoers.d' | sudo tee -a /var/jb/etc/sudoers

# 2. Add the passwordless rule
echo 'mobile ALL=(ALL) NOPASSWD: ALL' | sudo tee /var/jb/etc/sudoers.d/zz-mobile
sudo chmod 0440 /var/jb/etc/sudoers.d/zz-mobile
```

These commands are interactive, so `sudo` asks for the `mobile` password this first time (that works — you have a real terminal here).

**Verify it correctly** — this is the part that trips people up. Right after running the block, `sudo` still has your password cached for a few minutes, so a test *in the same session* passes even when the rule isn't really active. To test for real, **close the SSH session, reopen it, and make the very first command:**

```bash
sudo -n true && echo OK
```

If a freshly reopened session prints `OK` without asking for a password, the NOPASSWD rule is genuinely in effect and Theos will install without prompting. If it still asks for a password, check: step 1's `@includedir` line is present, the file is at `/var/jb/etc/sudoers.d/zz-mobile`, and no other file in that folder sorts after `zz-mobile` with a conflicting rule (`sudo ls /var/jb/etc/sudoers.d/`).

> **Rootful jailbreak?** Skip this part — you install as `root`, which never needs `sudo`.

### Part 4 — Build and install

1. Make sure the USB tunnel is running. If it isn't, open a **separate** Terminal window and start it (from the setup guide):

   ```bash
   iproxy 2222 22
   ```

   Leave that window open.

2. Back in your build Terminal (inside the `tweak/` folder), run:

   ```bash
   make package install
   ```

   This compiles the tweak, packages it, copies it to the iPhone, installs it, and resprings SpringBoard.

The iPhone's home screen will briefly reload — that means the tweak was installed.

### Part 5 — Confirm it actually loaded

You already have `idevicesyslog` (part of `libimobiledevice`), which streams the iPhone's system log to your Mac over USB.

1. In a Terminal window, run:

   ```bash
   idevicesyslog | grep -i bypass
   ```

2. On the iPhone, open the target app (the one from `bypassIAPiOS.plist`) and trigger its purchase / premium check. When the tweak intercepts it you'll see lines like:

   ```
   UserDefaults bypass called! Changing 0 to 1
   SKPaymentTransaction bypass called! Changing 0 to 1
   ```

If you see those lines, the tweak is loading and running correctly.

### Everyday workflow (after the first time)
Once everything is set up, each edit–test cycle is just:

1. Edit [tweak/Tweak.x](tweak/Tweak.x) (or `bypassIAPiOS.plist` to target a different app).
2. Make sure `iproxy 2222 22` is running.
3. Run `make package install` from inside `tweak/`.
4. Check behavior or the log.

> ⚠️ You can check the logs using the Console app on your Mac to identify new vulnerable keys and update the script. All script modifications should be made in the `Tweak.x` (jailbroken device) or `bypass-iap.m` (for SRD) files.

## Security Research Device (SRD)

An Apple [Security Research Device](https://security.apple.com/research-device/) grants the low-level access needed to run this research **without jailbreaking**, using Apple's own `srdtool`. Here the bypass ships as a dylib ([srd-dylib/bypass-iap.m](srd-dylib/bypass-iap.m)) instead of a Theos tweak, and a single script builds, signs, installs, and injects it.

> ⚠️ The script was tested on an **SRD running iOS 18**. Apple changes the SRD tooling and workflow fairly often between releases, so the exact `srdtool` commands may differ on your device — adapt as needed.

### Part 1 — Configure the SRD

Set up the device with `srdtool` by following the steps in Apple's official Security Research Device repository. Once it's configured and `srdtool` can reach the device, continue to the next part.

### Part 2 — Build and install

From the [srd-dylib/](srd-dylib/) folder, run the script:

```bash
cd srd-dylib
./build-install.sh
```

[srd-dylib/build-install.sh](srd-dylib/build-install.sh) does everything:

1. Compiles `bypass-iap.m` to `bypass-iap.dylib` (`xcrun clang`, linking Foundation and StoreKit).
2. Ad-hoc code-signs the dylib (`codesign -s -`).
3. Uninstalls any previous copy, then installs the new one (`srdtool research dylib install`).
4. Injects it into the target process (`srdtool research launchctl inject`).

To change what the bypass does, edit [srd-dylib/bypass-iap.m](srd-dylib/bypass-iap.m) and re-run the script.

## Experiments

To reproduce the bypasses end-to-end without touching a real App Store app, this repo ships a deliberately vulnerable demo app: [BypassIAPTestApp/](BypassIAPTestApp/). It is a small SwiftUI app whose three sections each reproduce exactly one vulnerability the tweak targets, and its bundle ID (`com.izmcm.BypassIAPTestApp`) is already the default target in [tweak/bypassIAPiOS.plist](tweak/bypassIAPiOS.plist), so the tweak hooks it out of the box.

| App section | Vulnerability | Hooked in [Tweak.x](tweak/Tweak.x) |
|---|---|---|
| 1. In-App Purchase | Receipt never validated — unlock trusts `transactionState` | `-[SKPaymentTransaction transactionState]` → forced to `1` (purchased) |
| 2. UserDefaults Boolean Flags | Entitlements stored as plain booleans under predictable keys | `-[NSUserDefaults boolForKey:]` → forced to `1` for premium-like keys |
| 3. UserDefaults Subscription Expiration | Expiration read as a timestamp with no signing | `-[NSUserDefaults doubleForKey:]` → forced to a huge value |

The steps below start with the tweak **off** so you get a clean baseline, then install the demo app, then enable the tweak and watch the same actions behave differently.

### Part 1 — Make sure the tweak is off

If you already built and installed the tweak from [Building and Running the Tweak](#building-and-running-the-tweak), disable it now so the baseline reflects the app's normal behavior. Pick either way (skip this part entirely if the tweak was never installed):

**Option A — uninstall the tweak (cleanest).** In the SSH session on the iPhone, remove the package and respring:

```bash
sudo dpkg -r com.im.bypassiapios
sbreload # or: killall -9 SpringBoard
```

**Option B — untarget the app (no uninstall).** In [tweak/bypassIAPiOS.plist](tweak/bypassIAPiOS.plist), comment out or delete the `com.izmcm.BypassIAPTestApp` bundle ID, then run `make package install`. The tweak stays installed but no longer injects into the demo app.

### Part 2 — Install the demo app and capture a baseline

The app must run on the **same jailbroken iPhone** you'll install the tweak on (the tweak only injects into on-device processes, not the Simulator).

1. On the Mac, open [BypassIAPTestApp/BypassIAPTestApp.xcodeproj](BypassIAPTestApp/BypassIAPTestApp.xcodeproj) in Xcode.
2. Select the project in the navigator → **Signing & Capabilities** → set your **Team** and let Xcode manage signing. Keep the bundle ID as `com.izmcm.BypassIAPTestApp` (if you need to change it, you also need to update [tweak/bypassIAPiOS.plist](tweak/bypassIAPiOS.plist) to match).
3. Plug in the iPhone, pick it as the run destination, and press **Run** (`Cmd + R`). The purchase flow is backed by the bundled StoreKit configuration [Products.storekit](BypassIAPTestApp/BypassIAPTestApp/Products.storekit), so no real App Store product or sandbox account is needed.

With the tweak off, take the baseline: Confirm all three sections read **Locked**: *Premium*, *Feature unlocked*, and *Subscription*. You can interact with them, such as tapping `Buy Premium` and confirming the purchase (don't worry, you will not being charged by that).

### Part 3 — Enable the tweak and observe each bypass

Build and install the tweak by following [Building and Running the Tweak](#building-and-running-the-tweak) (in short: `make package install` from the `tweak/` folder). If you used Option B in Part 1, restore the bundle ID in [tweak/bypassIAPiOS.plist](tweak/bypassIAPiOS.plist) first.

> The tweak is loaded into the app at launch by ElleKit, so after installing it **fully quit and reopen the demo app** — otherwise the hooks aren't injected.

Stream the log on the Mac while you drive the app (from [Part 5 of the tweak guide](#part-5--confirm-it-actually-loaded)):

```bash
idevicesyslog | grep -i bypass
```

Vulnerabilities #2 and #3 need **no interaction at all** — the tweak swaps the value the moment the app reads it, so both sections already read **Unlocked** as soon as the app launches (even right after a **Reset**). Vulnerability #1 is different: `transactionState` is only read when a transaction is processed, so you have to tap **Buy Premium** to trigger it.

**Vulnerability #1 — In-App Purchase (needs a purchase attempt).** In section *1. In-App Purchase*, tap **Buy Premium**. The app unlocks and shows *"Premium unlocked (no receipt check)"*, and the log prints:

```
SKPaymentTransaction bypass called! Changing 0 to 1
```

Because the tweak forces `transactionState` to `.purchased` when the payment queue reports the transaction, the entitlement flips regardless of whether a real payment ever completed. In fact, when you tap **Buy Premium** you can simply dismiss the App Store popup *without confirming the purchase* — the resulting cancellation is reported to the app as a transaction, and the tweak rewrites its state from cancelled/failed to `.purchased`, so premium unlocks anyway.

**Vulnerability #2 — UserDefaults Boolean Flags (automatic on launch).** Section *2. UserDefaults Boolean Flags* already shows **Unlocked** at launch, with every toggle off and without any action — the app reads the premium-like keys (`isPremium`, `removeAds`, `isPro`, `vipEnabled`, `subscribed`) with `boolForKey:`, and the tweak forces each of those reads to `1`. 

**Vulnerability #3 — UserDefaults Subscription Expiration (automatic on launch).** Section *3. UserDefaults Subscription Expiration* also shows **Unlocked** at launch, without ever tapping **Start 7-day Trial** — the app reads the expiration key (`subscriptionExpirationDate`, which matches `expirationdate`) with `doubleForKey:`, and the tweak returns a far-future timestamp for that read.

**Contrast these results with the tweak-off baseline from Part 2** 

## Troubleshooting
### "REMOTE HOST IDENTIFICATION HAS CHANGED!" / "Host key verification failed."
Expected if you re-jailbroke, reinstalled OpenSSH, or switched devices — the phone's identity key changed, so your Mac's saved copy no longer matches. Clear the old key and reconnect:

```bash
ssh-keygen -R '[127.0.0.1]:2222'
```

Then run `ssh` again and accept the new key. (You're connecting to `127.0.0.1` over your own USB cable, so this warning is not a real man-in-the-middle attack here.)

### "Connection refused" (SSH or `make package install`)
The SSH server isn't reachable. Check that: (1) the `iproxy 2222 22` window is still open and its local port matches `THEOS_DEVICE_PORT` in the Makefile, (2) the USB cable is connected, and (3) the iPhone has finished respringing after installing OpenSSH. Rebooting the phone and re-running the jailbreak can also help.

### "Permission denied" / wrong password
Wrong username or password. The username depends on the jailbreak — `mobile` on Dopamine, `root` on most rootful jailbreaks — and must match `THEOS_DEVICE_USER` in the Makefile. The password is the one you set in Dopamine, or `alpine` if you never changed it.

### iproxy: "No device found"
Make sure the iPhone is unlocked, plugged in, and that you tapped **Trust** on the phone. Try a different cable or USB port if it persists.

### The tweak installs but nothing happens / no log line appears.
On a rootless jailbreak, confirm `THEOS_PACKAGE_SCHEME = rootless` is still in the Makefile; on a rootful one, confirm you removed it. Then run `make clean` followed by `make package install` again. Also confirm the app you're testing matches the bundle ID in `bypassIAPiOS.plist`.

### "sudo: a terminal is required to read the password" during install.
Passwordless `sudo` for `mobile` isn't actually active. Redo [Part 3 from Building and Running the Tweak](#part-3--allow-passwordless-install-on-the-device-rootless-only). Two common traps: (1) the rule file must be under `/var/jb/etc/sudoers.d/` (rootless), not `/etc/sudoers.d/`; (2) Dopamine's own `procursus` file in that folder re-requires a password, so your file must sort *after* it — name it `zz-mobile`. Verify in a **freshly reopened** SSH session (not the one where you just typed a password, which is cached) that `sudo -n true && echo OK` prints `OK`.

### Linker errors: "missing required architecture armv7" / "symbol(s) not found for architecture armv7".
The Makefile is asking for a 32-bit build your SDK no longer ships. Make sure `TARGET` is `iphone:clang:latest:14.0` (not `7.0`), then `make clean && make package install`.

### "make: command not found" or Theos errors.
Your Theos environment isn't loaded. Close and reopen Terminal, or confirm the setup finished by running `echo $THEOS` — it should print a path, not an empty line.

### dpkg: "depends on mobilesubstrate … Package mobilesubstrate is not installed."
Modern rootless jailbreaks (Dopamine) use **ElleKit**, not the old MobileSubstrate, so a hard `mobilesubstrate` dependency fails. The shipped [tweak/control](tweak/control) uses `Depends: ellekit | mobilesubstrate` to satisfy both. If this error still happens, install **ElleKit** through Sileo.

### BypassIAPTestApp: "Product not available" / "Product not loaded yet" when tapping Buy Premium.
The demo app loads its product from the local [Products.storekit](BypassIAPTestApp/BypassIAPTestApp/Products.storekit) configuration, which Xcode only injects when that file is selected in the scheme. Open the app in Xcode, go to **Product > Scheme > Edit Scheme… > Run > Options**, set **StoreKit Configuration** to `Products.storekit`, then run again.

## License

Released under the MIT License. The full text, including the warranty and
liability disclaimer, is in the [LICENSE](LICENSE) file.
