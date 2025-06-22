//
//  SpeechToTextView.swift
//  SpeechPractice
//
//  Created by JiJooMaeng on 6/21/25.
//


import SwiftUI


struct SpeechToTextView: View {
    @StateObject private var recognizer = SpeechRecognizer()
    
    var body: some View {
        VStack(spacing: 30) {
            Text(recognizer.transcribedText)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            
            Button(action: {
                if recognizer.isRecording {
                    recognizer.stopRecording()
                } else {
                    recognizer.startRecording()
                }
            }) {
                Text(recognizer.isRecording ? "🎙️ 녹음 중지" : "🎤 녹음 시작")
                    .font(.title2)
                    .padding()
                    .background(recognizer.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
