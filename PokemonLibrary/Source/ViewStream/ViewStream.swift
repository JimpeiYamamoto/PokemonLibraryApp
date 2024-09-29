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
        let pokemonCards: Observable<[ViewDataModel.Item]>
    }
}

public final class ViewStream: ViewStreamType {
    public let input: ViewStreamModel.ViewStreamInput
    public let state: ViewStreamModel.ViewStreamState
    public let output: ViewStreamModel.ViewStreamOutput

    private let useCase: UseCaseType

    public convenience init(useCase: UseCaseType) {
        let input = ViewStreamModel.ViewStreamInput()
        let state = ViewStreamModel.ViewStreamState()

        let output = input.viewDidLoad
            .flatMap { [useCase] _ in
                return useCase.display(offset: 0, limit: 20)
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
                pokemonCards: output
            ),
            useCase: useCase
        )
    }

    public init(
        input: ViewStreamModel.ViewStreamInput,
        state: ViewStreamModel.ViewStreamState,
        output: ViewStreamModel.ViewStreamOutput,
        useCase: UseCaseType
    ) {
        self.input = input
        self.state = state
        self.output = output
        self.useCase = useCase
    }
}

