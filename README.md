# Longitudinal Analysis of iOS In-App Purchase Implementation Vulnerabilities

Scripts developed for the paper "Longitudinal Analysis of iOS In-App Purchase Implementation Vulnerabilities" are in this repository. The code tests vulnerabilities in any app available on the App Store, provided the following steps are followed during initial setup.

This code was developed for educational and scientific purposes. Do not use this code to harm others or institutions. The indiscriminate use of this material is not my responsibility. Please read [Disclaimer of Damages](##-Disclaimer-of-Damages) for more details.

## README Structure
* [Repository organization](#repository-organization)
* [Considered Badges](#considered-badges)
* [Required Materials](#required-materials)
* [Step-by-Step](#step-by-step)
* [Disclaimer of Damages](#disclaimer-of-damages)

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
└── tables/                      # LaTeX tables from the paper
    ├── app_agnostic_table.tex
    ├── app_agnostic_table.pdf
    ├── app_specific_table.tex
    └── app_specific_table.pdf
```

## Considered Badges
The considered badges are: Available, Functional, and Sustainable.
 
## Environment Setup
This guide walks you through setting up everything needed to reproduce the experiments described in the [experiments] section, starting from scratch. No prior jailbreaking experience is assumed. By the end, you will have a jailbroken iPhone that your Mac can connect to via SSH, along with the build tools needed to compile the tweaks used in this work.

### What you will end up with

- A jailbroken iPhone running an SSH server (so it can accept remote connections).
- A Mac that can open a command-line session directly on that iPhone through the USB cable.
- The Theos build system on your Mac, used to compile the tweaks.

### Before you start

- **Use a dedicated device.** Jailbreak the iPhone you are willing to experiment on, not your daily phone. Back it up first.
- **You must own the device.** These steps assume the iPhone and Mac are yours and used for research.
- Set aside about an hour for the first-time setup.

---

### Part 1 — Prepare the iPhone

#### Step 1. Jailbreak the iPhone

A *jailbreak* removes Apple's restrictions so you can install software (like an SSH server) that Apple normally blocks. Alternatively, if you have an official Apple **Security Research Device (SRD)**, you can skip the jailbreak — it already grants the needed access.

The [experiments] section was tested on an **iPhone 7 running iOS 15.8.8, jailbroken with Dopamine**, but the procedure should work on any jailbroken iPhone.

1. Follow the Dopamine walkthrough: <https://ios.cfw.guide/installing-dopamine-trollstore/>
2. If your device or iOS version is different, find the matching guide here: <https://ios.cfw.guide/>
3. When the jailbreak finishes, your iPhone will have a package manager app called **Sileo** on the Home Screen. You will use it in the next step.

Using Dopamine, you should be asked 

> Jailbreaks can occasionally fail or need to be reapplied after the phone restarts. If Sileo disappears or apps stop working after a reboot, simply re-run the jailbreak from the Dopamine app.

#### Step 2. Install OpenSSH

**OpenSSH** is the software that lets your Mac log into the iPhone remotely and type commands on it.

1. Open the **Sileo** app on the iPhone.
2. Tap the **Search** tab and type `openssh`.
3. Select the **OpenSSH** package and tap **Install** (or **Get** / **Modify**).
4. When prompted, tap to confirm, then let it **respring** (the screen goes black briefly and the Home Screen reloads). This is normal.

#### Step 3. Note your SSH password (important)

When jailbreaking with Dopamine, you are asked to set a password during the process. This is the same password you will use to log in over SSH, together with the username mobile. Keep it somewhere safe — you will type it every time you connect.

If you used a different jailbreak and were not asked to set a password, the default is the well-known `alpine`. 

---

### Part 2 — Prepare the Mac

#### Step 1. Install Homebrew

**Homebrew** is a tool that installs other command-line software on macOS with a single command.

1. Open the **Terminal** app (press `Cmd + Space`, type `Terminal`, press Enter).
2. Paste this line and press Enter, then follow the on-screen prompts:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### Step 2. Install the USB connection tool (iproxy)

`iproxy` (part of the **libimobiledevice** toolkit) lets your Mac talk to the iPhone's SSH server over the USB cable, so you don't need Wi-Fi.

```bash
brew install libimobiledevice
```

#### Step 3. Install the Theos build system

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

3. If you get stuck, the full instructions are here: <https://theos.dev/docs/installation-macos>

---

### Part 3 — Connect the Mac to the iPhone

#### Step 1. Plug in and start the tunnel

1. Connect the iPhone to the Mac with a USB cable. If the iPhone asks whether to **Trust This Computer**, tap **Trust** and enter your passcode.
2. In Terminal, start the tunnel:

   ```bash
   iproxy 2222 22
   ```

   This forwards port `2222` on your Mac to the iPhone's SSH port (`22`) through the cable. **Leave this Terminal window open** — closing it ends the connection.

#### Step 2. Log in to the iPhone

1. Open a **second** Terminal window (`Cmd + N`).
2. Connect over SSH:

   ```bash
   ssh -p 2222 mobile@127.0.0.1
   ```

3. The first time, you'll see a message asking whether to trust the device's identity. Type `yes` and press Enter.
4. Enter the password (`alpine` by default). You won't see the characters as you type — that's normal. Press Enter.

You are now logged into the iPhone. Any command you type runs on the phone.

---

### Troubleshooting

**"REMOTE HOST IDENTIFICATION HAS CHANGED!" / "Host key verification failed."**
This is expected if you re-jailbroke, reinstalled OpenSSH, or switched devices — the phone's identity key changed, so your Mac's saved copy no longer matches. Clear the old saved key and reconnect:

```bash
ssh-keygen -R '[127.0.0.1]:2222'
```

Then run the `ssh` command again and accept the new key. (Because you're connecting to `127.0.0.1` over your own USB cable, this warning is not a real man-in-the-middle attack here.)

**"Connection refused"**
The SSH server isn't reachable. Check that: (1) the `iproxy 2222 22` window is still open, (2) the USB cable is connected, and (3) the iPhone has finished respringing after installing OpenSSH. Rebooting the phone and re-running the jailbreak can also help.

**"Permission denied"**
Wrong username or password. The username can be `root` or `mobile` (it depends on the jailbreak you are using), and the password is `alpine` unless you changed it.

**iproxy: "No device found"**
Make sure the iPhone is unlocked, plugged in, and that you tapped **Trust** on the phone. Try a different cable or USB port if it persists.

## Run the Bypass


```
Notes:
⚠️ You can check the logs using the Console app on your macOS to identify new vulnerable keys and update the script.
However, using the Console app affects the performance of your iPhone.

⚠️ All script modifications should be made in the `Tweak.x` or `bypass-iap.m` files.
```
## Disclaimer of Damages
Use of this script is at all times "at your own risk". If you are dissatisfied with any aspect of any of these terms and conditions or any other policies, your sole remedy is to discontinue the use of the material. In no event will I or any contributors be liable to any user or third party for any damages resulting from the use or inability to use this material, whether based on warranty, contract, tort, or any other legal theory, and whether the site is or not advised of the possibility of such damages. I accept no responsibility for any loss, damage, or liability arising out of or in connection with this material. In no event will I be liable for any indirect, special, punitive, exemplary, incidental, or consequential damages. This limitation will apply whether or not the other party has been advised of the possibility of such damages.

## LICENSE
```
MIT License

Copyright (c) 2025 Luigi Luz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
