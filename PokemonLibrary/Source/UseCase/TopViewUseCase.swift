import Foundation
import RxSwift
import ApiGateway
import Repository

public protocol TopViewUseCaseType {
    func display(offset: Int) -> Observable<TopViewUseCaseModel.DisplayResult>
}

public final class TopViewUseCase: TopViewUseCaseType {
    private let pokemonApiGateway: PokemonApiGatewayType
    private let pokemonRepository: PokemonRepositoryType

    public init(pokemonApiGateway: PokemonApiGatewayType, pokemonRepository: PokemonRepositoryType) {
        self.pokemonApiGateway = pokemonApiGateway
        self.pokemonRepository = pokemonRepository
    }

    public func display(offset: Int) -> Observable<TopViewUseCaseModel.DisplayResult> {
        pokemonApiGateway.getPokemonNames(offset: offset)
            .flatMap { [weak self] names -> Observable<[(PokemonApiGatewayModel.Species?, PokemonApiGatewayModel.Pokemon?)]> in
                let requests = names.map { name -> Observable<(PokemonApiGatewayModel.Species?, PokemonApiGatewayModel.Pokemon?)> in
                    guard let me = self
                    else { return Observable.just((nil, nil)) }

                    let species = me.pokemonApiGateway.getPokemonSpecies(name: name)
                    let pokemon = me.pokemonApiGateway.getPokemon(name: name)
                    return Observable.zip(species, pokemon)
                }
                return Observable.zip(requests)
            }
            .map { results -> [TopViewUseCaseModel.DisplayResult.Pokemon] in
                results.compactMap { args -> TopViewUseCaseModel.DisplayResult.Pokemon? in
                    let (species, pokemon) = args
                    guard let species = species,
                          let pokemon = pokemon,
                          species.id == pokemon.id,
                          let imageUrl = URL(string: pokemon.imageUrl)
                    else { return nil }
                    return .init(
                        id: species.id,
                        name: species.name,
                        imageUrl: imageUrl
                    )
                }
            }
//            .do { result in
//                pokemonRepository.set(result.map {
//                    .init()
//                })
//            }
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
        public let imageUrl: URL

        public init(
            id: Int,
            name: String,
            imageUrl: URL
        ) {
            self.id = id
            self.name = name
            self.imageUrl = imageUrl
        }
    }
}

extension TopViewUseCase {
    public static let shared = TopViewUseCase(
        pokemonApiGateway: PokemonApiGateway.shared,
        pokemonRepository: PokemonRepository.shared
    )
}
