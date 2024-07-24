//
//  Swift2TextApp.swift
//  Swift2Text
//
//  Created by Kyle Peterson on 7/23/24.
//

import SwiftUI

@main
struct Swift2TextApp: App {
    @AppStorage("defaultAppDirectory") private var defaultAppDirectory: String = ""
    @AppStorage("defaultExportDirectory") private var defaultExportDirectory: String = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, idealWidth: 300, maxWidth: 600, minHeight: 200, idealHeight: 200, maxHeight: 600)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                            Button("Select Default App Directory") {
                                selectDefaultAppDirectory()
                            }
                            .keyboardShortcut("A", modifiers: [.command])

                            Button("Select Default Export Directory") {
                                selectDefaultExportDirectory()
                            }
                            .keyboardShortcut("E", modifiers: [.command])
                        }
        }
    }
    
    func selectDefaultAppDirectory() {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.allowsMultipleSelection = false

            if panel.runModal() == .OK, let url = panel.url {
                defaultAppDirectory = url.path
                print("Default App Directory selected: \(defaultAppDirectory)")
            }
        }

        func selectDefaultExportDirectory() {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.allowsMultipleSelection = false

            if panel.runModal() == .OK, let url = panel.url {
                defaultExportDirectory = url.path
                print("Default Export Directory selected: \(defaultExportDirectory)")
            }
        }
}
