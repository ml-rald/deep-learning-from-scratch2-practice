import Foundation

struct TokenInfo: Identifiable {
    let id = UUID()
    let word: String
    let partOfSpeech: String?
    let namedEntity: String?
}
