//
//  ContentView.swift
//  OpenELMPortingTest
//
//  Created by 임영택 on 6/29/25.
//

import SwiftUI
import Tokenizers
import CoreML

struct ContentView: View {
    @StateObject var openELMModel = OpenELMModel()
    @State var userInput: String = ""
    @State var isError: Bool = false
    @State var isPrepared: Bool = false
    @FocusState var textFieldIsFocused: Bool
    
    var body: some View {
        Group {
            if isPrepared {
                List {
                    Section {
                        TextField("입력하세요", text: $userInput)
                        .onSubmit {
                            runButtonDidTap()
                        }
                        .focused($textFieldIsFocused)
                        
                        Button {
                            runButtonDidTap()
                        } label: {
                            Text("추론")
                        }
                    }

                    Section {
                        Text("결과")
                        
                        if !openELMModel.generatedText.isEmpty {
                            Text(openELMModel.generatedText)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                try await openELMModel.loadTokenizer()
                isPrepared = true
            } catch {
                isError = true
            }
        }
    }
}

extension ContentView {
    private func runButtonDidTap() {
        textFieldIsFocused = false
        inference(for: userInput)
    }
    
    private func inference(for input: String) {
        isError = false
        Task.detached {
            do {
                let _ = try await openELMModel.generateText(input)
            } catch {
                print("error: \(error)")
                await MainActor.run {
                    isError = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
