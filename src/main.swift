// GeForce NOW Anti-Lag
// Native launcher: opens GeForce NOW and keeps awdl0 disabled while it runs.
// Being a real NSApplication means the Dock icon stops bouncing once launched
// (a plain shell script as CFBundleExecutable never "checks in", so it bounces).

import Cocoa

let gfnPath = "/Applications/GeForceNOW.app"

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var timer: Timer?
    private var missingTicks = 0
    private var seenRunning = false
    private var startTime = Date()

    func applicationDidFinishLaunching(_ notification: Notification) {
        startTime = Date()
        let url = URL(fileURLWithPath: gfnPath)
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Could not launch GeForce NOW"
                    alert.informativeText = error.localizedDescription
                    alert.runModal()
                    NSApp.terminate(nil)
                }
            }
        }

        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    // Opening our app again (e.g. clicking the Dock icon) brings GeForce NOW forward.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        gfnApps().first?.activate()
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        runIfconfig("up")
    }

    private func gfnApps() -> [NSRunningApplication] {
        NSWorkspace.shared.runningApplications.filter {
            $0.bundleURL?.path == gfnPath || $0.executableURL?.lastPathComponent == "GeForceNOW"
        }
    }

    private func tick() {
        if !gfnApps().isEmpty {
            seenRunning = true
            missingTicks = 0
            if awdl0Active() { runIfconfig("down") }
            return
        }
        // Not running: give it up to 60s to start, then tolerate short gaps (relaunch/update).
        if !seenRunning {
            if Date().timeIntervalSince(startTime) > 60 { NSApp.terminate(nil) }
            return
        }
        missingTicks += 1
        if missingTicks >= 3 { NSApp.terminate(nil) }
    }

    private func awdl0Active() -> Bool {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/sbin/ifconfig")
        p.arguments = ["awdl0"]
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return false }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return String(decoding: data, as: UTF8.self).contains("status: active")
    }

    private func runIfconfig(_ state: String) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        p.arguments = ["-n", "/sbin/ifconfig", "awdl0", state]
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.nullDevice
        do { try p.run(); p.waitUntilExit() } catch {}
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)

// Restore awdl0 on SIGTERM/SIGINT/SIGHUP too (e.g. Activity Monitor "Quit").
var signalSources: [DispatchSourceSignal] = []
for sig in [SIGTERM, SIGINT, SIGHUP] {
    signal(sig, SIG_IGN)
    let src = DispatchSource.makeSignalSource(signal: sig, queue: .main)
    src.setEventHandler { NSApp.terminate(nil) }
    src.resume()
    signalSources.append(src)
}

app.run()
