import Foundation

struct Template: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var text: String
}
