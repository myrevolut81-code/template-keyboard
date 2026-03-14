import Foundation

struct Category: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var templates: [Template]
}
