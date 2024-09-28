import Foundation
import RxSwift

public protocol UseCaseType {
    func display(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult>
}

public final class UseCase {
    private let pokemonApi: PokemonApiType

    public init(pokemonApi: PokemonApiType) {
        self.pokemonApi = pokemonApi
    }

    func display(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult> {
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
}
