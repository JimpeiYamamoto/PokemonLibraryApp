import Foundation
import RxSwift
import ApiGateway
import Repository

public protocol TopViewUseCaseType {
    func display(offset: Int) -> Observable<TopViewUseCaseModel.DisplayResult>
    func setLoadedImageData(id: Int, data: Data)
}

public final class TopViewUseCase: TopViewUseCaseType {
    private let pokemonApiGateway: PokemonApiGatewayType
    private let pokemonRepository: PokemonRepositoryType

    public init(pokemonApiGateway: PokemonApiGatewayType, pokemonRepository: PokemonRepositoryType) {
        self.pokemonApiGateway = pokemonApiGateway
        self.pokemonRepository = pokemonRepository
    }

    public func setLoadedImageData(id: Int, data: Data) {
        guard let savedPokemon = pokemonRepository.get(id: id) else { return }

        pokemonRepository.set(
            .init(
                id: savedPokemon.id,
                name: savedPokemon.name,
                imageUrl: savedPokemon.imageUrl,
                image: data,
                weight: savedPokemon.weight,
                height: savedPokemon.height,
                abilities: savedPokemon.abilities,
                flavorText: savedPokemon.flavorText
            )
        )
    }

    public func display(offset: Int) -> Observable<TopViewUseCaseModel.DisplayResult> {
        if pokemonRepository.get().count > offset {
            return Observable<TopViewUseCaseModel.DisplayResult>.create { [weak self] observer in
                guard let me = self else { return Disposables.create() }

                observer.onNext(
                    .loaded(
                        me.pokemonRepository.get()
                            .sorted(by: { $0.id < $1.id })
                            .map { pokemon in
                                .init(
                                    id: pokemon.id,
                                    name: pokemon.name,
                                    imageUrl: pokemon.imageUrl,
                                    imageData: pokemon.image,
                                    weight: pokemon.weight,
                                    height: pokemon.height,
                                    abilities: pokemon.abilities
                                )
                            }
                    )
                )
                return Disposables.create()
            }
            .startWith(.loading)
        }
        return pokemonApiGateway.getPokemonNames(offset: offset)
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
                        imageUrl: imageUrl,
                        imageData: nil,
                        weight: pokemon.weight,
                        height: pokemon.height,
                        abilities: pokemon.abilities
                    )
                }
            }
            .do { [weak self] result in
                guard let me = self else { return }
                me.pokemonRepository.set(result.map { pokemon in
                    .init(
                        id: pokemon.id,
                        name: pokemon.name,
                        imageUrl: pokemon.imageUrl,
                        image: nil,
                        weight: pokemon.weight,
                        height: pokemon.height,
                        abilities: pokemon.abilities,
                        flavorText: nil
                    )
                })
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
        public let imageUrl: URL
        public let imageData: Data?
        public let weight: Int
        public let height: Int
        public let abilities: [String]

        public init(
            id: Int,
            name: String,
            imageUrl: URL,
            imageData: Data?,
            weight: Int,
            height: Int,
            abilities: [String]
        ) {
            self.id = id
            self.name = name
            self.imageUrl = imageUrl
            self.imageData = imageData
            self.weight = weight
            self.height = height
            self.abilities = abilities
        }
    }
}

extension TopViewUseCase {
    public static let shared = TopViewUseCase(
        pokemonApiGateway: PokemonApiGateway.shared,
        pokemonRepository: PokemonRepository.shared
    )
}
