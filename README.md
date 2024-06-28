# Bypass In-app Purchase in iOS apps

Script developed for the paper "Who’s Got My Money? An Analysis of Vulnerable In-app Purchases in iOS Apps." The code in this repository tests vulnerabilities in any app available on the App Store as long as the following steps are followed for the initial setup.

This code was developed for educational and scientific purposes. Do not use this code to harm others or institutions. The indiscriminate use of this material is not my responsibility. Please read [Disclaimer of Damages](##-Disclaimer-of-Damages) for more details.

## Required Materials
* 1 iPhone with jailbreak and SSH access
* A computer. The computer should have:
  * SSH access ([iPhoneTunnel](https://code.google.com/archive/p/iphonetunnel-mac/downloads), [iProxy](https://command-not-found.com/iproxy), etc.)
  * [Theos](https://theos.dev/) build system installed

## Step-by-Step
1. Establish an SSH connection between your computer and your iPhone.
2. Download the app you want to test normally from the App Store.
3. Check the Makefile and ensure that the variables `THEOS_DEVICE_IP` and `THEOS_DEVICE_PORT` are correctly set for your iPhone.
4. Verify the bypassIAPiOS.plist the file and make sure the bundle ID of the target app is listed.
5. Build and install the script on your iPhone using `make package install`.

⚠️ You can check the logs using the Console app on your macOS to identify new vulnerable keys and update the script. However, using the Console app affects the performance of your iPhone.

⚠️ All modifications to the script should be made in the Tweak.x file.

## Disclaimer of Damages
Use of this script is at all times "at your own risk". If you are dissatisfied with any aspect of any of these terms and conditions or any other policies, your sole remedy is to discontinue the use of the material. In no event will I or any contributors be liable to any user or third party for any damages resulting from the use or inability to use this material, whether based on warranty, contract, tort, or any other legal theory, and whether the site is or not advised of the possibility of such damages. I accept no responsibility for any loss, damage, or liability arising out of or in connection with this material. In no event will I be liable for any indirect, special, punitive, exemplary, incidental, or consequential damages. This limitation will apply whether or not the other party has been advised of the possibility of such damages.
