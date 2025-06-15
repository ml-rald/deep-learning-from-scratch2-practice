import Foundation
import NaturalLanguage

struct TextAnalyzer {
    static func analyze(text: String) -> [TokenInfo] {
        var results: [TokenInfo] = []
        
        let tagger = NLTagger(tagSchemes: [.tokenType, .lexicalClass, .nameType])
        tagger.string = text
        tagger.setLanguage(.english, range: text.startIndex..<text.endIndex)
        
        let options = NLTagger.Options([.omitWhitespace, .omitPunctuation, .joinNames])
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .word,
                             scheme: .tokenType,
                             options: options) { _, tokenRange in
            let word = String(text[tokenRange])
            
            let (posTag, _) = tagger.tag(at: tokenRange.lowerBound,
                                         unit: .word,
                                         scheme: .lexicalClass)
            
            let partOfSpeech = posTag?.rawValue
            
            let (entityTag, _) = tagger.tag(at: tokenRange.lowerBound,
                                            unit: .word,
                                            scheme: .nameType)
            let namedEntity = (entityTag != .other) ? entityTag?.rawValue : nil
            
            results.append(TokenInfo(word: word, partOfSpeech: partOfSpeech, namedEntity: namedEntity))
            return true
            
        }
        
        return results
    }
}
