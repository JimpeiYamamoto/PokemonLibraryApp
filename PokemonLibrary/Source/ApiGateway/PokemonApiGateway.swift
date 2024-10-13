import Foundation
import RxSwift
import Api

public protocol PokemonApiGatewayType {
    func getPokemonNames(offset: Int) -> Observable<[String]>
    func getPokemonSpecies(name: String) -> Observable<PokemonApiGatewayModel.Species?>
    func getPokemon(name: String) -> Observable<PokemonApiGatewayModel.Pokemon?>
}

public final class PokemonApiGateway: PokemonApiGatewayType {
    private let pokemonApi: Api.PokemonApiType

    public init(pokemonApi: Api.PokemonApiType) {
        self.pokemonApi = pokemonApi
    }

    public func getPokemonNames(offset: Int) -> Observable<[String]> {
        Observable<[String]>.create { [pokemonApi] observer in
            pokemonApi.getPokemonList(
                offset: offset,
                onSuccess: { response in
                    observer.onNext(response.results.compactMap(\.name))
                },
                onError: { error in
                    observer.onError(error ?? NSError())
                }
            )
            return Disposables.create()
        }
    }

    public func getPokemonSpecies(name: String) -> Observable<PokemonApiGatewayModel.Species?> {
        Observable<PokemonApiGatewayModel.Species?>.create { [pokemonApi] observer in
            pokemonApi.getPokemonSpecies(
                name: name,
                onSuccess: { response in
                    guard let id = response.id,
                          let name = response.names?.filter({ $0.language.name == "ja" }).first?.name,
                          let flavorText = response.flavor_text_entries?.filter({ $0.language.name == "ja" }).first?.flavor_text
                    else {
                        observer.onNext(nil)
                        return
                    }
                    observer.onNext(.init(id: id, name: name, flavorText: flavorText))
                },
                onError: { error in
                    observer.onNext(nil)
                }
            )
            return Disposables.create()
        }
    }

    public func getPokemon(name: String) -> Observable<PokemonApiGatewayModel.Pokemon?> {
        Observable<PokemonApiGatewayModel.Pokemon?>.create { [pokemonApi] observer in
            pokemonApi.getPokemon(
                name: name,
                onSuccess: { pokemon in
                    guard let id = pokemon.id,
                          let height = pokemon.height,
                          let weight = pokemon.weight,
                          let imageUrl = pokemon.sprites.front_default,
                          let crySoundUrl = pokemon.cries.latest
                    else {
                        observer.onNext(nil)
                        return
                    }
                    observer.onNext(
                        .init(
                            id: id,
                            height: height,
                            weight: weight,
                            imageUrl: imageUrl,
                            crySoundUrl: crySoundUrl
                        )
                    )
                },
                onError: { error in
                    observer.onNext(nil)
                }
            )
            return Disposables.create()
        }
    }
}

public enum PokemonApiGatewayModel {
    public struct Species {
        public let id: Int
        public let name: String
        public let flavorText: String
    }

    public struct Pokemon {
        public let id: Int
        public let height: Int
        public let weight: Int
        public let imageUrl: String
        public let crySoundUrl: String
    }
}

extension PokemonApiGateway {
    public static let shared = PokemonApiGateway(pokemonApi: PokemonApi.shared)
}
