import Foundation
import RxRelay
import RxSwift

public protocol ViewStreamType {
    var input: ViewStreamModel.ViewStreamInput { get }
    var state: ViewStreamModel.ViewStreamState { get }
    var output: ViewStreamModel.ViewStreamOutput { get }
}

public enum ViewStreamModel {
    public struct ViewStreamInput {
        public let viewDidLoad: PublishRelay<Void> = .init()
    }

    public struct ViewStreamState {}

    public struct ViewStreamOutput {
        let nameLabelText: Observable<String>
        let pokemonCards: Observable<[ViewDataModel.Item]>
    }
}

public final class ViewStream: ViewStreamType {
    public let input: ViewStreamModel.ViewStreamInput
    public let state: ViewStreamModel.ViewStreamState
    public let output: ViewStreamModel.ViewStreamOutput

    public convenience init() {
        let useCase = UseCase(pokemonApi: PokemonApi(apiClient: ApiClient()), pokemonApiGateway: PokemonApiGateway(pokemonApi: PokemonApi(apiClient: ApiClient())))

        let input = ViewStreamModel.ViewStreamInput()
        let state = ViewStreamModel.ViewStreamState()

        let output = input.viewDidLoad
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

        let output2 = input.viewDidLoad
            .flatMap { [useCase] _ in
                return useCase.display2(offset: 0, limit: 20)
            }
            .map { result -> [ViewDataModel.Item] in
                switch result {
                case .loading:
                    return []
                case .loaded(let pokemons):
                    return pokemons
                        .enumerated()
                        .map { offset, pokemon -> ViewDataModel.Item in
                            .init(
                                offset: offset,
                                number: pokemon.id,
                                name: pokemon.name,
                                imageUrl: pokemon.imageUrl
                            )
                        }
                case .showError:
                    return []
                }
            }

        self.init(
            input: input,
            state: state,
            output: .init(
                nameLabelText: output,
                pokemonCards: output2
            )
        )
    }

    public init(
        input: ViewStreamModel.ViewStreamInput,
        state: ViewStreamModel.ViewStreamState,
        output: ViewStreamModel.ViewStreamOutput
    ) {
        self.input = input
        self.state = state
        self.output = output
    }
}

