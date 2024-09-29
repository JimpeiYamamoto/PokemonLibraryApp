import Foundation
import RxRelay
import RxSwift

public protocol TopViewStreamType {
    var input: TopViewStreamModel.ViewStreamInput { get }
    var state: TopViewStreamModel.ViewStreamState { get }
    var output: TopViewStreamModel.ViewStreamOutput { get }
}

public enum TopViewStreamModel {
    public struct ViewStreamInput {
        public let viewDidLoad: PublishRelay<Void> = .init()
    }

    public struct ViewStreamState {}

    public struct ViewStreamOutput {
        let pokemonCards: Observable<[TopViewDataModel.Item]>
    }
}

public final class ViewStream: TopViewStreamType {
    public let input: TopViewStreamModel.ViewStreamInput
    public let state: TopViewStreamModel.ViewStreamState
    public let output: TopViewStreamModel.ViewStreamOutput

    private let useCase: TopViewUseCaseType

    public convenience init(useCase: TopViewUseCaseType) {
        let input = TopViewStreamModel.ViewStreamInput()
        let state = TopViewStreamModel.ViewStreamState()

        let output = input.viewDidLoad
            .flatMap { [useCase] _ in
                return useCase.display(offset: 0, limit: 20)
            }
            .map { result -> [TopViewDataModel.Item] in
                switch result {
                case .loading:
                    return []
                case .loaded(let pokemons):
                    return pokemons
                        .enumerated()
                        .map { offset, pokemon -> TopViewDataModel.Item in
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
        input: TopViewStreamModel.ViewStreamInput,
        state: TopViewStreamModel.ViewStreamState,
        output: TopViewStreamModel.ViewStreamOutput,
        useCase: TopViewUseCaseType
    ) {
        self.input = input
        self.state = state
        self.output = output
        self.useCase = useCase
    }
}

