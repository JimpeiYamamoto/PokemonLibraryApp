import Foundation
import RxSwift

public protocol TopViewUseCaseType {
    func display(offset: Int) -> Observable<TopViewUseCaseModel.DisplayResult>
}

public final class TopViewUseCase: TopViewUseCaseType {
    private let pokemonApiGateway: PokemonApiGatewayType
    private let disposeBag = DisposeBag()

    public init(pokemonApiGateway: PokemonApiGatewayType) {
        self.pokemonApiGateway = pokemonApiGateway
    }

    public func display(offset: Int) -> Observable<TopViewUseCaseModel.DisplayResult> {
        Observable<TopViewUseCaseModel.DisplayResult>
            .create { [disposeBag, pokemonApiGateway] observer in
                pokemonApiGateway.getPokemonList(offset: offset)
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
                        results.compactMap { args -> TopViewUseCaseModel.DisplayResult.Pokemon? in
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
                    .disposed(by: disposeBag)
                return Disposables.create()
            }
            .startWith(.loading)
            .catchAndReturn(.showError)
    }
}

public enum TopViewUseCaseModel {
    public enum DisplayResult: Equatable {
        case loading
        case loaded([Pokemon])
        case showError
    }
}

extension TopViewUseCaseModel.DisplayResult {
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

extension TopViewUseCase {
    public static let shared = TopViewUseCase(pokemonApiGateway: PokemonApiGateway.shared)
}
