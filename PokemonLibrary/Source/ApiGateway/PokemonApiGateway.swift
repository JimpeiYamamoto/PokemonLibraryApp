import Foundation

public protocol PokemonApiGatewayType {
    func getPokemonList(
        limit: Int,
        offset: Int,
        onSuccess: @escaping (PokemonApiGatewayModel.PokemonList) -> Void,
        onError: @escaping (Error?) -> Void
    )
}

public final class PokemonApiGateway: PokemonApiGatewayType {
    private let apiClient: ApiClientType

    public init(apiClient: ApiClientType) {
        self.apiClient = apiClient
    }

    public func getPokemonList(
        limit: Int,
        offset: Int,
        onSuccess: @escaping (PokemonApiGatewayModel.PokemonList) -> Void,
        onError: @escaping (Error?) -> Void
    ) {
        apiClient.request(
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/?limit=\(limit)&?offset=\(offset)")!,
            onSuccess: onSuccess,
            onError: onError
        )
    }
}

public enum PokemonApiGatewayModel {
    public struct PokemonList: Decodable {
        let count: Int?
        let next: String?
        let previous: String?
        let results: [PokemonListResult]

        init(count: Int, next: String, previous: String, results: [PokemonListResult]) {
            self.count = count
            self.next = next
            self.previous = previous
            self.results = results
        }

        struct PokemonListResult: Decodable {
            let name: String?
            let url: String?

            init(name: String, url: String) {
                self.name = name
                self.url = url
            }
        }
    }
}
