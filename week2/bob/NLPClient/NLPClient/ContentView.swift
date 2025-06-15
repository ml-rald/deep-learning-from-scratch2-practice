//
//  ContentView.swift
//  NLPClient
//
//  Created by 임영택 on 6/16/25.
//

import SwiftUI

struct ContentView: View {
    @State var userInput: String = ""
    @State var morphsResult: String = ""
    @State var tags: [[String]] = []
    
    var body: some View {
        VStack {
            Text("입력")
            
            TextEditor(text: $userInput)
                .padding()
            
            List {
                Section {
                    Text("형태소 분석 결과")
                        .font(.subheadline)
                    
                    if morphsResult.isEmpty {
                        Text("분석할 문장을 입력하세요.")
                    } else {
                        Text(morphsResult)
                    }
                }
                
                Section {
                    Text("품사 태깅 결과")
                        .font(.subheadline)
                    
                    if tags.isEmpty {
                        Text("분석할 문장을 입력하세요.")
                    } else {
                        ForEach(tags, id: \.self) { morphAndTag in
                            HStack {
                                Text(morphAndTag[0])
                                Spacer()
                                Text(morphAndTag[1])
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: userInput) { _, newValue in
            print("userInput changed - \(newValue)")
            onInputChanged(newValue)
        }
    }
}

extension ContentView {
    static let baseURL = "http://172.30.1.20:8000" // ❯ ipconfig getifaddr en0
    
    func onInputChanged(_ input: String) {
        Task {
            let extractedMorphs = try await fetchMorphs(input: input)
            
            await MainActor.run {
                morphsResult = extractedMorphs.joined(separator: ", ")
            }
        }
        
        Task {
            let extractedTags = try await fetchTags(input: input)
            
            await MainActor.run {
                tags = extractedTags
            }
        }
    }
    
    func fetchMorphs(input: String) async throws -> [String] {
        // 1. 쿼리 파라미터 구성
        var components = URLComponents(string: "\(ContentView.baseURL)/morphs")!
        components.queryItems = [
            URLQueryItem(name: "input", value: input)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        // 2. URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 3. 비동기 요청
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 4. 응답 유효성 검사
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([String].self, from: data)
    }
    
    func fetchTags(input: String) async throws -> [[String]] {
        // 1. 쿼리 파라미터 구성
        var components = URLComponents(string: "\(ContentView.baseURL)/tags")!
        components.queryItems = [
            URLQueryItem(name: "input", value: input)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        // 2. URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 3. 비동기 요청
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 4. 응답 유효성 검사
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([[String]].self, from: data)
    }
}

#Preview {
    ContentView()
}
