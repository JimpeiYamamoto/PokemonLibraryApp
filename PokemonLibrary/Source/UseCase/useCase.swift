import Foundation
import RxSwift

public protocol UseCaseType {
    func display(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult>
}

public final class UseCase {
    private let pokemonApiGateway: PokemonApiGatewayType

    public init(pokemonApiGateway: PokemonApiGatewayType) {
        self.pokemonApiGateway = pokemonApiGateway
    }

    func display(offset: Int, limit: Int) -> Observable<UseCaseModel.DisplayResult> {
        Observable<UseCaseModel.DisplayResult>
            .create { [weak self] observer in
                self?.pokemonApiGateway.getPokemonList(
                    limit: limit,
                    offset: offset,
                    onSuccess: { pokemonList in
                        sleep(1)
                        observer.onNext(
                            .loaded(
                                pokemonList.results
                                    .compactMap { $0.name }
                                    .joined(separator: "\n")
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
