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
        public let scrollToBottom: PublishRelay<Void> = .init()
    }

    public struct ViewStreamState {
        let pokemonCards = BehaviorRelay<[TopViewDataModel.Item]>(value: [])
    }

    public struct ViewStreamOutput {
        let pokemonCards: Observable<[TopViewDataModel.Item]>
        let isLoadingViewHidden: Observable<Bool>
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

        let displayResult = Observable
            .merge(
                input.viewDidLoad.asObservable(),
                input.scrollToBottom.asObservable()
            )
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .flatMap { [useCase] _ in
                let offset = state.pokemonCards.value.count
                return useCase.display(offset: offset)
            }

        _ = displayResult
            .debug("displayResult", trimOutput: true)
            .map { displayResult -> [TopViewDataModel.Item] in
                guard case let .loaded(pokemons) = displayResult else { return [] }
                return pokemons
                    .enumerated()
                    .map { offset, pokemon -> TopViewDataModel.Item in
                        .init(
                            offset: offset + state.pokemonCards.value.count,
                            number: pokemon.id,
                            name: pokemon.name,
                            imageUrl: pokemon.imageUrl
                        )
                    }
            }
            .map { items in
                state.pokemonCards.value + items
            }
            .bind(to: state.pokemonCards)

        let isLoadingViewHidden = displayResult
            .map { $0 != .loading }

        self.init(
            input: input,
            state: state,
            output: .init(
                pokemonCards: state.pokemonCards.asObservable(),
                isLoadingViewHidden: isLoadingViewHidden
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

