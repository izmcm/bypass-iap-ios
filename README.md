# Longitudinal Analysis of iOS In-App Purchase Implementation Vulnerabilities

Scripts developed for the paper "Longitudinal Analysis of iOS In-App Purchase Implementation Vulnerabilities" are in this repository. The code tests vulnerabilities in any app available on the App Store as long as the following steps are followed for the initial setup.

This code was developed for educational and scientific purposes. Do not use this code to harm others or institutions. The indiscriminate use of this material is not my responsibility. Please read [Disclaimer of Damages](##-Disclaimer-of-Damages) for more details.

## README Structure
* [Repository organization](#repository-organization)
* [Considered Badges](#considered-badges)
* [Required Materials](#required-materials)
* [Step-by-Step Jailbroken iPhone](#step-by-step-jailbroken-iphone)
* [Step-by-Step Security Research Device](#step-by-step-security-research-device)
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

## Required Materials
* An iPhone with jailbreak and SSH access OR a Security Research Device
  * The [experiments] section was tested using an [iPhone 7 iOS 15.8.8 with Dopamine](https://ios.cfw.guide/installing-dopamine-trollstore/), but it may work with any jailbroke iPhone. A collection of tutorials to jailbroke different iPhone's is [here](https://ios.cfw.guide/)
* A MacOS device. The computer should have:
  * SSH access ([iPhoneTunnel](https://code.google.com/archive/p/iphonetunnel-mac/downloads), [iProxy](https://command-not-found.com/iproxy), etc.)
  * [Theos](https://theos.dev/) build system installed
 
## Step-by-Step Jailbroken iPhone
1. Establish an SSH connection between your computer and your iPhone.
2. Download the app you want to test (usually from the App Store).
3. Check the Makefile and ensure that the variables `THEOS_DEVICE_IP` and `THEOS_DEVICE_PORT` are correctly set for your iPhone.
4. Verify the bypassIAPiOS.plist the file and make sure the bundle ID of the target app is listed.
5. Build and install the script on your iPhone using `make package install`.

## Step-by-Step Security Research Device
1. Configure your SRD with `srdtool` according Apple's repository
2. Run `build-install.sh` script

⚠️ You can check the logs using the Console app on your macOS to identify new vulnerable keys and update the script. However, using the Console app affects the performance of your iPhone.

⚠️ All script modifications should be made in the `Tweak.x` or `bypass-iap.m` files.

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
