import Foundation
import UserNotifications

class Notifier {
    let downloadsFolderURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    var source: DispatchSourceFileSystemObject?

    init() {
        monitorDownloadsFolder()
    }

    func monitorDownloadsFolder() {
        let fileDownloadDesc = open(downloadsFolderURL.path, O_EVTONLY)
        guard fileDownloadDesc != -1 else {
            print("Failed to open downloads folder for monitoring")
            return
        }

        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDownloadDesc, eventMask: .write, queue: .global())
        source?.setEventHandler {
            self.showNotification(title: "Download Complete", body: "New file has been downloaded successfully.")
        }
        source?.setCancelHandler {
            close(fileDownloadDesc)
        }
        source?.resume()
    }

    func showNotification(title: String, body: String) {
        let showScript = """
        osascript -e 'display notification "\(body)" with title "\(title)" sound name "default"'
        """
        shell(showScript)
    }

    private func shell(_ command: String) {
        let process = Process()
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", command]
        process.launch()
    }
}

