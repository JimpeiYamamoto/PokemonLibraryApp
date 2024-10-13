import Foundation
import RxSwift
import ApiGateway
import Repository

public protocol DetailPokemonViewUseCaseType {
    func display(id: Int) -> Observable<DetailPokemonViewUseCaseModel.DisplayResult>
    func setLoadedImageData(id: Int, data: Data)
}

public final class DetailPokemonViewUseCase: DetailPokemonViewUseCaseType {
    private let apiGateway: PokemonApiGatewayType
    private let repository: PokemonRepositoryType

    public init(
        apiGateway: PokemonApiGatewayType,
        repository: PokemonRepositoryType
    ) {
        self.apiGateway = apiGateway
        self.repository = repository
    }

    public func display(id: Int) -> Observable<DetailPokemonViewUseCaseModel.DisplayResult> {
        guard let pokemon = repository.get(id: id) else { return .just(.showError) }
        return Observable.zip(
            pokemon.enAbilities.map { ability -> Observable<PokemonApiGatewayModel.Ability?> in
                apiGateway.getPokemonAbility(name: ability)
            }
        )
        .compactMap { $0 }
        .map { abilities -> DetailPokemonViewUseCaseModel.DisplayResult.DetailInformation in
            .init(
                id: pokemon.id,
                name: pokemon.name,
                weight: pokemon.weight,
                height: pokemon.height,
                flavorText: pokemon.flavorText,
                imageUrl: pokemon.imageUrl,
                imageData: pokemon.image,
                abilities: abilities.map { $0!.name }
            )
        }
        .do { [weak self] information in
            self?.repository.set(
                .init(
                    id: information.id,
                    name: information.name,
                    imageUrl: information.imageUrl,
                    image: information.imageData,
                    weight: information.weight,
                    height: information.height,
                    enAbilities: pokemon.enAbilities,
                    jaAbilities: information.abilities,
                    flavorText: information.flavorText
                )
            )
        }
        .map { information in
            .loaded(information)
        }
        .startWith(.loading)
    }
    
    public func setLoadedImageData(id: Int, data: Data) {
        guard let pokemon = repository.get(id: id) else { return }
        repository.set(
            .init(
                id: pokemon.id,
                name: pokemon.name,
                imageUrl: pokemon.imageUrl,
                image: data,
                weight: pokemon.weight,
                height: pokemon.height,
                enAbilities: pokemon.enAbilities,
                jaAbilities: pokemon.jaAbilities,
                flavorText: pokemon.flavorText
            )
        )
    }
}

public enum DetailPokemonViewUseCaseModel {
    public enum DisplayResult: Equatable {
        case loading
        case loaded(DetailInformation)
        case showError

        public struct DetailInformation: Equatable {
            public let id: Int
            public let name: String
            public let weight: Int
            public let height: Int
            public let flavorText: String
            public let imageUrl: URL
            public let imageData: Data?
            public let abilities: [String]
        }
    }
}

extension DetailPokemonViewUseCase {
    public static let shared = DetailPokemonViewUseCase(
        apiGateway: PokemonApiGateway.shared,
        repository: PokemonRepository.shared
    )
}
