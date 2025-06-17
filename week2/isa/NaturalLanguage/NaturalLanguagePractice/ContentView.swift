import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var analysisResults: [TokenInfo] = []
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("🔍Apple 문장 분석기")
                .font(.title)
                .fontWeight(.bold)
            
            Text("NLP 테스트를 위해 문장을 입력해주세요.")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextEditor(text: $inputText)
                .frame(height: 120)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.bottom, 8)
            
            
            Button("분석하기") {
                analysisResults = TextAnalyzer.analyze(text: inputText)
            }
            .buttonStyle(.borderedProminent)
            
            List(analysisResults) { token in
                VStack(alignment: .leading) {
                    Text("단어: \(token.word)")
                        .font(.subheadline)
                    Text("품사: \(token.partOfSpeech ?? "None")")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                    Text("개체명: \(token.namedEntity ?? "None")")
                        .font(.subheadline)
                        .foregroundStyle(.indigo)
                }
            }
            
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
