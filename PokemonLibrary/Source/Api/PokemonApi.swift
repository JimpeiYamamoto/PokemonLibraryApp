import Foundation

public protocol PokemonApiType {
    func getPokemonList(
        offset: Int,
        onSuccess: @escaping (PokemonApiModel.PokemonList) -> Void,
        onError: @escaping (Error?) -> Void
    )

    func getPokemonSpecies(
        name: String,
        onSuccess: @escaping (PokemonApiModel.PokemonSpecies) -> Void,
        onError: @escaping (Error?) -> Void
    )

    func getPokemon(
        name: String,
        onSuccess: @escaping (PokemonApiModel.Pokemon) -> Void,
        onError: @escaping (Error?) -> Void
    )
}

public final class PokemonApi: PokemonApiType {
    private let apiClient: ApiClientType

    public init(apiClient: ApiClientType) {
        self.apiClient = apiClient
    }

    public func getPokemonList(
        offset: Int,
        onSuccess: @escaping (PokemonApiModel.PokemonList) -> Void,
        onError: @escaping (Error?) -> Void
    ) {
        apiClient.request(
            url: URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(offset)")!,
            onSuccess: onSuccess,
            onError: onError
        )
    }

    public func getPokemonSpecies(
        name: String,
        onSuccess: @escaping (PokemonApiModel.PokemonSpecies) -> Void,
        onError: @escaping ((any Error)?) -> Void
    ) {
        apiClient.request(
            url: URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(name)")!,
            onSuccess: onSuccess,
            onError: onError
        )
    }

    public func getPokemon(
        name: String,
        onSuccess: @escaping (PokemonApiModel.Pokemon) -> Void,
        onError: @escaping ((any Error)?) -> Void
    ) {
        apiClient.request(
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/\(name)")!,
            onSuccess: onSuccess,
            onError: onError
        )
    }
}

public enum PokemonApiModel {
    public struct PokemonList: Decodable {
        public let count: Int?
        public let next: String?
        public let previous: String?
        public let results: [PokemonListResult]

        public struct PokemonListResult: Decodable {
            public let name: String?
            public let url: String?
        }
    }

    public struct Pokemon: Decodable {
        public let id: Int?
        public let height: Int?
        public let weight: Int?
        public let sprites: PokemonSprites
        public let cries: PokemonCries
        public let abilities: [PokemonAbility]
        public let species: PokemonSpecies
    }

    public struct PokemonSpecies: Decodable {
        public let id: Int?
        public let names: [Name]?
        public let flavor_text_entries: [FlavorText]?
    }

    public struct PokemonCries: Decodable {
        public let latest: String?
        public let legacy: String?
    }

    public struct PokemonSprites: Decodable {
        public let front_default: String?
        public let back_default: String?
    }

    public struct PokemonAbility: Decodable {
        public let is_hidden: Bool?
        public let slot: Int?
        public let ability: Ability?
    }

    public struct Ability: Decodable {
        public let id: Int?
        public let name: String?
        public let names: [Name]?
        public let flavor_text_entries: [AbilityFlavorText]?
    }

    public struct AbilityFlavorText: Decodable {
        public let flavor_text: String?
        public let language: Language?
    }

    public struct Name: Decodable {
        public let language: Language
        public let name: String?
    }

    public struct FlavorText: Decodable {
        public let flavor_text: String?
        public let language: Language
    }

    public struct Language: Decodable {
        public let name: String?
        public let url: String?
    }
}

extension PokemonApi {
    public static let shared = PokemonApi(apiClient: ApiClient.shared)
}
