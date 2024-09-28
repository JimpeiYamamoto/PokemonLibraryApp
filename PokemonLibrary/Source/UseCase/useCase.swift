import Foundation
import RxSwift

public protocol UseCaseType {
    func display(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult>
    func display2(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult2>
}

public final class UseCase: UseCaseType {
    private let pokemonApi: PokemonApiType
    private let pokemonApiGateway: PokemonApiGatewayType

    public init(pokemonApi: PokemonApiType, pokemonApiGateway: PokemonApiGatewayType) {
        self.pokemonApi = pokemonApi
        self.pokemonApiGateway = pokemonApiGateway
    }

    public func display2(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult2> {
        Observable<UseCaseModel.DisplayResult2>
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
                        results.compactMap { args -> UseCaseModel.DisplayResult2.Pokemon? in
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

    public func display(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult> {
        Observable<UseCaseModel.DisplayResult>
            .create { [pokemonApi] observer in
                pokemonApi.getPokemon(
                    name: "bulbasaur",
//                pokemonApi.getPokemonSpecies(
//                    name: "bulbasaur",
//                pokemonApi.getPokemonList(
//                    limit: limit,
//                    offset: offset,
                    onSuccess: { pokemonList in
                        sleep(1)
//                        let id = pokemonList.names
//                        let flavorText = pokemonList.flavor_text_entries
//                            .filter { $0.language.name == "ja" }
//                            .first?
//                            .flavor_text ?? ""

                        observer.onNext(
                            .loaded(
                                pokemonList.sprites.front_default ?? ""
//                                pokemonList.flavor_text_entries
//                                    .filter { $0.language.name == "ja" }
//                                    .compactMap { $0.flavor_text }.first ?? ""
//                                pokemonList.results
//                                    .compactMap { $0.name }
//                                    .joined(separator: "\n")
                            )
                        )
                    },
                    onError: { error in
                        observer.onError(error ?? NSError())
                    }
                )
                return Disposables.create()
            }
            .startWith(.loading)
            .catchAndReturn(.showError)
    }
}

public enum UseCaseModel {
    public enum DisplayResult {
        case loading
        case loaded(String)
        case showError
    }

    public enum DisplayResult2 {
        case loading
        case loaded([Pokemon])
        case showError
    }
}

extension UseCaseModel.DisplayResult2 {
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
