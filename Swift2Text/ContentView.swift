//
//  ContentView.swift
//  Swift2Text
//
//  Created by Kyle Peterson on 7/23/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("defaultAppDirectory") private var defaultAppDirectory: String = ""
    @AppStorage("defaultExportDirectory") private var defaultExportDirectory: String = ""
    @State private var directoryPath: String = ""
    @State private var combinedText: String = ""
    @State private var isProcessing: Bool = false
    @State private var includeSubdirectories: Bool = false

    var body: some View {
        VStack {
            Button("Select Directory") {
                selectDirectory()
            }
            .padding([.leading, .top, .trailing])
            .disabled(isProcessing)
            
            if !directoryPath.isEmpty {
                Text("Selected Directory: \(directoryPath)")
                    .padding([.leading, .top, .trailing])
            }
            
            Toggle("Include Subdirectories", isOn: $includeSubdirectories)
                .padding([.leading, .top, .trailing])
            
            
            HStack {
                Spacer()
                
                if isProcessing {
                    ProgressView()
                        .padding(.horizontal)
                        .progressViewStyle(.circular)
                        .controlSize(.mini)
                        .opacity(0.0)
                }
                
                Button("Combine and Export Text") {
                    combineAndExportText()
                }
                .disabled(isProcessing)
                
                if isProcessing {
                    ProgressView()
                        .padding(.horizontal)
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(width: 300, height: directoryPath.isEmpty ? 150 : 200) // Adjusted frame size
    }

    func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if !defaultAppDirectory.isEmpty {
            panel.directoryURL = URL(fileURLWithPath: defaultAppDirectory)
        }

        if panel.runModal() == .OK, let url = panel.url {
            directoryPath = url.path
            // Save to default app directory
            defaultAppDirectory = url.path
        }
    }

    func combineAndExportText() {
        guard !directoryPath.isEmpty else { return }

        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fileManager = FileManager.default
                var fileURLs: [URL] = []

                if includeSubdirectories {
                    let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: directoryPath), includingPropertiesForKeys: nil)
                    while let fileURL = enumerator?.nextObject() as? URL {
                        if fileURL.pathExtension == "swift" {
                            fileURLs.append(fileURL)
                        }
                    }
                } else {
                    fileURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: directoryPath), includingPropertiesForKeys: nil, options: .skipsHiddenFiles).filter { $0.pathExtension == "swift" }
                }

                var combinedText = ""
                
                for fileURL in fileURLs {
                    let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
                    combinedText += fileContents + "\n"
                }
                
                DispatchQueue.main.async {
                    self.combinedText = combinedText
                    self.isProcessing = false
                    saveCombinedTextToFile(combinedText)
                }
            } catch {
                print("Error reading files: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }
    }

    func saveCombinedTextToFile(_ text: String) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.text]
        savePanel.nameFieldStringValue = "CombinedText.txt"

        if !defaultExportDirectory.isEmpty {
            savePanel.directoryURL = URL(fileURLWithPath: defaultExportDirectory)
        }

        if savePanel.runModal() == .OK, let url = savePanel.url {
            do {
                try text.write(to: url, atomically: true, encoding: .utf8)
                print("File saved successfully!")
                // Save to default export directory
                defaultExportDirectory = url.deletingLastPathComponent().path
            } catch {
                print("Error saving file: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
