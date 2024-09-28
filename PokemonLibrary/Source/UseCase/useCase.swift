import Foundation
import RxSwift

public protocol UseCaseType {
    func display(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult>
}

public final class UseCase: UseCaseType {
    private let pokemonApi: PokemonApiType
    private let pokemonApiGateway: PokemonApiGatewayType

    public init(pokemonApi: PokemonApiType, pokemonApiGateway: PokemonApiGatewayType) {
        self.pokemonApi = pokemonApi
        self.pokemonApiGateway = pokemonApiGateway
    }

    public func display(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult> {
        Observable<UseCaseModel.DisplayResult>
            .create { [pokemonApiGateway] observer in
                pokemonApiGateway.getPokemonList(limit: limit, offset: offset)
                    .flatMap { pokemonList -> Observable<[(PokemonApiModel.PokemonSpecies, PokemonApiModel.Pokemon)]> in
                        let requests = pokemonList.results.compactMap { result -> Observable<(PokemonApiModel.PokemonSpecies, PokemonApiModel.Pokemon)>? in
                            guard let name = result.name else { return nil }

                            let species = pokemonApiGateway.getPokemonSpecies(name: name)
                            let pokemon = pokemonApiGateway.getPokemon(name: name)
                            return Observable.zip(species, pokemon)
                        }
                        return Observable.zip(requests)
                    }
                    .map { results in
                        results.compactMap { args -> UseCaseModel.DisplayResult.Pokemon? in
                            let (species, pokemon) = args
                            guard let url = URL(string: pokemon.sprites.front_default ?? ""),
                                  let id = species.id,
                                  let name = species.names.filter({ $0.language.name == "ja" }).first?.name
                            else { return nil }
                            return .init(id: id, name: name, imageUrl: url)
                        }
                    }
                    .subscribe { result in
                        observer.onNext(.loaded(result))
                    }
                return Disposables.create()
            }
            .startWith(.loading)
            .catchAndReturn(.showError)
    }
}

public enum UseCaseModel {
    public enum DisplayResult {
        case loading
        case loaded([Pokemon])
        case showError
    }
}

extension UseCaseModel.DisplayResult {
    public struct Pokemon: Equatable {
        public let id: Int
        public let name: String
        public let imageUrl: URL?

        public init(
            id: Int,
            name: String,
            imageUrl: URL?
        ) {
            self.id = id
            self.name = name
            self.imageUrl = imageUrl
        }
    }
}
