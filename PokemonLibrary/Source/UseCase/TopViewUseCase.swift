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
        pokemonApiGateway.getPokemonList(offset: offset)
            .flatMap { [weak self] pokemonList -> Observable<[(PokemonApiModel.PokemonSpecies?, PokemonApiModel.Pokemon?)]> in
                let requests = pokemonList.results.map { result -> Observable<(PokemonApiModel.PokemonSpecies?, PokemonApiModel.Pokemon?)> in
                    guard let name = result.name,
                          let me = self
                    else { return Observable.just((nil, nil)) }

                    let species = me.pokemonApiGateway.getPokemonSpecies(name: name)
                        .map(Optional.init)
                        .catchAndReturn(nil)
                    let pokemon = me.pokemonApiGateway.getPokemon(name: name)
                        .map(Optional.init)
                        .catchAndReturn(nil)
                    return Observable.zip(species, pokemon)
                }
                return Observable.zip(requests)
            }
            .map { results -> [TopViewUseCaseModel.DisplayResult.Pokemon] in
                results.compactMap { args -> TopViewUseCaseModel.DisplayResult.Pokemon? in
                    let (species, pokemon) = args
                    guard let species = species,
                          let pokemon = pokemon,
                          let url = URL(string: pokemon.sprites.front_default ?? ""),
                          let id = species.id,
                          let name = species.names.filter({ $0.language.name == "ja" }).first?.name
                    else { return nil }
                    return .init(id: id, name: name, imageUrl: url)
                }
            }
            .map { result -> TopViewUseCaseModel.DisplayResult in
                .loaded(result)
            }
            .startWith(.loading)
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
