//
//  OpenELMModel.swift
//  OpenELMPortingTest
//
//  Created by 임영택 on 6/29/25.
//

import Foundation
import SwiftUI
import Tokenizers
import CoreML

class OpenELMModel: ObservableObject {
    private var tokenizer: Tokenizer?
    private let model = try! OpenELM(configuration: .init())
    
    @Published var generatedText = ""
    
    func loadTokenizer() async throws {
        tokenizer = try! await AutoTokenizer.from(pretrained: "meta-llama/Llama-2-7b-hf", hubApi: .init(hfToken: Configs.hfToken))
    }
    
    func encode(_ tokens: [Int]) throws -> OpenELMInput {
        let modelInput = try! MLMultiArray(shape: [1, NSNumber(value: tokens.count)], dataType: .int32)
        tokens.enumerated().forEach { (i, val) in
            modelInput[[0, NSNumber(value: i)]] = NSNumber(value: val)
        }
        return OpenELMInput(input_ids: modelInput)
    }
    
    func encodeText(_ input: String) throws -> [Int] {
        guard let tokenizer else {
            throw NSError(domain: "Tokenizer not loaded", code: 1)
        }
        return tokenizer.encode(text: input)
    }
    
    func decode(_ output: OpenELMOutput) throws -> Int {
        let nextTokenId = getNextTokenId(from: output.slice_180)
        return nextTokenId
    }
    
    func decodeTokens(_ tokens: [Int]) throws -> String {
        guard let tokenizer else {
            throw NSError(domain: "Tokenizer not loaded", code: 1)
        }
        return tokenizer.decode(tokens: tokens)
    }
    
    func getNextTokenId(from logits: MLMultiArray) -> Int {
        let shape = logits.shape.map { $0.intValue } // → [batch, sequence, vocab]
        
        guard shape.count == 3 else {
            fatalError("Unexpected shape for logits: \(shape)")
        }
        
        let sequenceLength = shape[1] // 현재 시퀀스 길이
        let vocabSize = shape[2]      // 어휘 크기 (예: 32000)
        
        // 파이썬의 [:, -1:] 부분 - 마지막 시퀀스 위치만 사용
        let lastSequenceIndex = sequenceLength - 1
        
        var maxLogit: Float = -Float.greatestFiniteMagnitude
        var maxTokenId: Int = 0
        
        // 파이썬의 np.argmax(logits, -1) 부분 - vocab 차원에서 최대값 찾기
        for vocabIndex in 0..<vocabSize {
            let logit = logits[[
                NSNumber(value: 0),                    // batch index (항상 0)
                NSNumber(value: lastSequenceIndex),    // 마지막 sequence position
                NSNumber(value: vocabIndex)            // vocab index
            ]].floatValue
            
            if logit > maxLogit {
                maxLogit = logit
                maxTokenId = vocabIndex
            }
        }
        
        return maxTokenId // 다음 토큰 ID 1개만 반환
    }
    
    @MainActor
    func generateText(_ prompt: String, maxSequenceLength: Int = Configs.maxSequenceLength) async throws -> String {
        guard let tokenizer else {
            throw NSError(domain: "Tokenizer not loaded", code: 1)
        }
        
        generatedText = ""
        
        // 초기 토큰화
        var inputIds = try encodeText(prompt)
        print("Initial tokens: \(inputIds)")
        print("Initial text: \(try decodeTokens(inputIds))")
        
        // 파이썬의 for i in range(max_sequence_length) 구현
        for i in 0..<maxSequenceLength {
            print("Generation step \(i + 1)/\(maxSequenceLength)")
            
            do {
                // 현재 토큰들로 모델 입력 생성
                let modelInput = try encode(inputIds)
                
                // 모델 추론 실행
                let modelOutput = try await model.prediction(input: modelInput)
                
                // 다음 토큰 결정 (파이썬의 np.argmax(logits, -1)[:, -1:])
                let nextToken = try decode(modelOutput)
                print("Next token: \(nextToken)")
                
                // 새 토큰을 시퀀스에 추가 (파이썬의 np.concat)
                inputIds.append(nextToken)
                
                // 현재까지 생성된 텍스트 디코딩
                let currentText = try decodeTokens(inputIds)
                generatedText = currentText
                print("Current text: \(currentText)")
                
                // 종료 조건 확인 (EOS 토큰이나 특별한 토큰)
                if nextToken == tokenizer.eosTokenId {
                    print("Found end token, stopping generation")
                    break
                }
                
            } catch {
                print("Error during generation step \(i): \(error)")
                break
            }
        }
        
        // 최종 텍스트 반환
        let finalText = try decodeTokens(inputIds)
        print("Final generated text: \(finalText)")
        return finalText
    }
}
