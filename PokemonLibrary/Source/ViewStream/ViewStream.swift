import Foundation
import RxRelay
import RxSwift

public final class ViewStream {
    let input: PublishRelay<Void>
    let output: Observable<String>

    public convenience init() {
        let useCase = UseCase(pokemonApiGateway: PokemonApiGateway(apiClient: ApiClient()))

        let input: PublishRelay<Void> = .init()

        let output = input
            .flatMap { [useCase] _ in
                return useCase.display(offset: 0, limit: 20)
            }
            .map { displayResult in
                switch displayResult {
                case .loading:
                    return "loading"
                case .loaded(let value):
                    return value
                case .showError:
                    return "error"
                }
            }

        self.init(input: input, output: output)
    }

    public init(input: PublishRelay<Void>, output: Observable<String>) {
        self.input = input
        self.output = output
    }
}

