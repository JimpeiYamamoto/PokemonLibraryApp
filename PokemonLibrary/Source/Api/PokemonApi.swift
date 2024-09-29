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
        let count: Int?
        let next: String?
        let previous: String?
        let results: [PokemonListResult]

        struct PokemonListResult: Decodable {
            let name: String?
            let url: String?
        }
    }

    public struct PokemonSpecies: Decodable {
        let id: Int?
        let names: [Name]
        let flavor_text_entries: [FlavorText]
    }

    public struct Pokemon: Decodable {
        let height: Int?
        let sprites: PokemonSprites
    }

    public struct PokemonSprites: Decodable {
        let front_default: String?
        let back_default: String?
    }

    public struct Name: Decodable {
        let language: Language
        let name: String?
    }

    public struct FlavorText: Decodable {
        let flavor_text: String?
        let language: Language
    }

    public struct Language: Decodable {
        let name: String?
        let url: String?
    }
}

extension PokemonApi {
    public static let shared = PokemonApi(apiClient: ApiClient.shared)
}
