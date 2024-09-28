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
    }
}

public final class ViewStream: ViewStreamType {
    public let input: ViewStreamModel.ViewStreamInput
    public let state: ViewStreamModel.ViewStreamState
    public let output: ViewStreamModel.ViewStreamOutput

    public convenience init() {
        let useCase = UseCase(pokemonApiGateway: PokemonApiGateway(apiClient: ApiClient()))

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

        self.init(
            input: input,
            state: state,
            output: .init(
                nameLabelText: output
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

