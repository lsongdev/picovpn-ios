//
//  LogViewer.swift
//  PicoVPN
//
//  Created by Lsong on 2/12/25.
//
import SwiftUI

struct LogViewer: View {
    var filename: String
    @State private var logLines: [String] = []
    @State private var fileHandle: FileHandle?
    @State private var autoRefresh: Bool = false
    @State private var scrollToBottom: Bool = true
    @State private var showButtons: Bool = true
    
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(logLines.indices, id: \.self) { index in
                        Text(logLines[index])
                            .font(.system(size: 12, design: .monospaced))
                            .fontWidth(.standard)
                            .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    }
                    .listRowSeparator(.hidden)
                    
                    Color.clear
                        .frame(height: 0)
                        .id("bottom")
                        .listRowSeparator(.hidden)
                    
                    
                }
                .listStyle(.plain)
//                .onChange(of: logLines.count) {
//                    if scrollToBottom {
//                        withAnimation {
//                            proxy.scrollTo("bottom", anchor: .bottom)
//                        }
//                    }
//                }
            }
            
            // 悬浮按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        // 自动刷新按钮
                        Button {
                            autoRefresh.toggle()
                        } label: {
                            Image(systemName: autoRefresh ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle")
                                .font(.title2)
                                .foregroundColor(autoRefresh ? .accentColor : .gray)
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        // 自动滚动按钮
                        Button {
                            scrollToBottom.toggle()
                        } label: {
                            Image(systemName: scrollToBottom ? "arrow.down.circle.fill" : "arrow.down.circle")
                                .font(.title2)
                                .foregroundColor(scrollToBottom ? .accentColor : .gray)
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        // 清除按钮
                        Button {
                            clearLog()
                        } label: {
                            Image(systemName: "trash.circle")
                                .font(.title2)
                                .foregroundColor(.red)
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .shadow(radius: 2)
                    .padding()
                    .opacity(showButtons ? 1 : 0.3)
                }
            }
        }
        .navigationBarTitle(filename, displayMode: .inline)
        .onTapGesture {
            withAnimation {
                showButtons.toggle()
            }
        }
        
        .onAppear {
            openFile()
        }
        .onReceive(timer) { _ in
            if autoRefresh {
                readNewLines()
            }
        }
        .onDisappear {
            closeFile()
            timer.upstream.connect().cancel()
        }
    }
    
    private func openFile() {
        let logPath = Common.logPath.appendingPathComponent(filename)
        do {
            fileHandle = try FileHandle(forReadingFrom: logPath)
            readNewLines()
        } catch {
            logLines = ["Error opening log file: \(error.localizedDescription)"]
        }
    }
    
    private func readNewLines() {
        guard let fileHandle = fileHandle else { return }
        
        do {
            let data = try fileHandle.readToEnd() ?? Data()
            if !data.isEmpty {
                if let newContent = String(data: data, encoding: .utf8) {
                    let newLines = newContent.components(separatedBy: .newlines)
                    DispatchQueue.main.async {
                        logLines.append(contentsOf: newLines.filter { !$0.isEmpty })
                    }
                }
            }
        } catch {
            print("Error reading log: \(error)")
        }
    }
    
    private func closeFile() {
        try? fileHandle?.close()
        fileHandle = nil
    }
    
    private func clearLog() {
        let logPath = Common.logPath.appendingPathComponent(filename)
        do {
            try "".write(to: logPath, atomically: true, encoding: .utf8)
            logLines.removeAll()
            closeFile()
            openFile()
        } catch {
            print("Error clearing log: \(error)")
        }
    }
}
