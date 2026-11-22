# GeForce NOW Anti-Lag

A macOS application that launches GeForce NOW and automatically disables the `awdl0` device to reduce network latency during gameplay.

## Overview

GeForce NOW Anti-Lag is a convenient dock-launchable app that:
- Automatically opens the GeForce NOW application
- Monitors and disables the `awdl0` network interface (Apple Wireless Direct Link) to reduce latency
- Automatically re-enables `awdl0` when GeForce NOW closes
- Runs seamlessly in the background

## Installation

0. **Build the launcher (requires Xcode Command Line Tools):**
   ```bash
   ./build.sh
   ```
   This compiles `src/main.swift` into the app bundle. The launcher is a native
   Cocoa app (a background agent without its own Dock icon), so the Dock icon no
   longer keeps bouncing after launch.

1. **Copy the app to Applications folder:**
   ```bash
   cp -r "GeForce NOW Anti-Lag.app" /Applications/
   ```

2. **Add to Dock (optional):**
   - Open the app once from Applications
   - Right-click its dock icon
   - Select "Keep in Dock"

## Required Setup: sudoers Configuration

This app requires passwordless `sudo` access to manage the `awdl0` network interface. You need to configure your sudoers file once.

### Edit sudoers file:

```bash
sudo visudo
```

Add these lines AT THE END of the file:

```
# Allow GeForce NOW Anti-Lag to manage awdl0 without password
YOUR_USERNAME ALL=(ALL) NOPASSWD: /sbin/ifconfig awdl0 down
YOUR_USERNAME ALL=(ALL) NOPASSWD: /sbin/ifconfig awdl0 up
```

**Replace `YOUR_USERNAME` with your actual macOS username.**

To find your username, run:
```bash
whoami
```

### Example:

If your username is `jojo`, add:

```
jojo ALL=(ALL) NOPASSWD: /sbin/ifconfig awdl0 down
jojo ALL=(ALL) NOPASSWD: /sbin/ifconfig awdl0 up
```

## Usage

1. Click the app in your dock or open it from Applications
2. GeForce NOW will launch automatically
3. The anti-lag service runs in the background
4. When you close GeForce NOW, the service exits automatically

## How It Works

The `awdl0` interface is Apple's Wireless Direct Link technology that can add latency to network connections. By disabling it while gaming and re-enabling it when done, you can achieve lower ping times in GeForce NOW.

## Troubleshooting

**"sudo: a password is required"** error:
- Make sure you've properly edited the sudoers file
- Run `sudo -l` to verify the passwordless entries are configured
- Ensure there are no syntax errors in sudoers (test with `sudo visudo -c`)

**App won't launch:**
- Verify GeForce NOW is installed at `/Applications/GeForceNOW.app`
- Rebuild the launcher with `./build.sh`

**Dock icon keeps bouncing:**
- Make sure you are running a build made with `./build.sh` (older versions used a shell script as the app executable, which never finishes launching from the Dock's point of view)

## Acknowledgments

This application uses the GeForce NOW icon from NVIDIA's official GeForce NOW application. The icon is used for identification purposes only. GeForce NOW is a trademark of NVIDIA Corporation.

## License

See LICENSE file for details.
