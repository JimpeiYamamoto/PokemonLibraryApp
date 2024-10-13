import Foundation

public struct Pokemon: Equatable {
    public let id: Int
    public let name: String
    public let imageUrl: URL
    public let image: Data?
    public let weight: Int?
    public let abilities: [String]
    public let flavorText: String?

    public init(
        id: Int,
        name: String,
        imageUrl: URL,
        image: Data?,
        weight: Int?,
        abilities: [String],
        flavorText: String?
    ) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.image = image
        self.weight = weight
        self.abilities = abilities
        self.flavorText = flavorText
    }
}
