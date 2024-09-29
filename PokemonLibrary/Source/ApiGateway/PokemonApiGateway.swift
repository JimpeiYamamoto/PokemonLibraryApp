import Foundation
import RxSwift

public protocol PokemonApiGatewayType {
    func getPokemonList(limit: Int, offset: Int) -> Observable<PokemonApiModel.PokemonList>
    func getPokemonSpecies(name: String) -> Observable<PokemonApiModel.PokemonSpecies>
    func getPokemon(name: String) -> Observable<PokemonApiModel.Pokemon>
}

public final class PokemonApiGateway: PokemonApiGatewayType {
    private let pokemonApi: PokemonApiType

    public init(pokemonApi: PokemonApiType) {
        self.pokemonApi = pokemonApi
    }

    public func getPokemonList(limit: Int, offset: Int) -> Observable<PokemonApiModel.PokemonList> {
        Observable<PokemonApiModel.PokemonList>.create { [pokemonApi] observer in
            pokemonApi.getPokemonList(
                limit: limit,
                offset: offset,
                onSuccess: { pokemonList in
                    observer.onNext(pokemonList)
                },
                onError: { error in
                    observer.onError(error ?? NSError())
                }
            )
            return Disposables.create()
        }
    }

    public func getPokemonSpecies(name: String) -> Observable<PokemonApiModel.PokemonSpecies> {
        Observable<PokemonApiModel.PokemonSpecies>.create { [pokemonApi] observer in
            pokemonApi.getPokemonSpecies(
                name: name,
                onSuccess: { species in
                    observer.onNext(species)
                },
                onError: { error in
                    observer.onError(error ?? NSError())
                }
            )
            return Disposables.create()
        }
    }

    public func getPokemon(name: String) -> Observable<PokemonApiModel.Pokemon> {
        Observable<PokemonApiModel.Pokemon>.create { [pokemonApi] observer in
            pokemonApi.getPokemon(
                name: name,
                onSuccess: { pokemon in
                    observer.onNext(pokemon)
                },
                onError: { error in
                    observer.onError(error ?? NSError())
                }
            )
            return Disposables.create()
        }
    }
}

extension PokemonApiGateway {
    public static let shared = PokemonApiGateway(pokemonApi: PokemonApi.shared)
}
