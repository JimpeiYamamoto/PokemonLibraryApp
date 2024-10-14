import Foundation
import RxRelay
import RxSwift
import UseCase

public protocol DetailPokemonViewStreamType {
    var input: DetailPokemonViewStreamModel.ViewStreamInput { get }
    var state: DetailPokemonViewStreamModel.ViewStreamState { get }
    var output: DetailPokemonViewStreamModel.ViewStreamOutput { get }
}

public enum DetailPokemonViewStreamModel {
    public struct ViewStreamInput {
        public let viewDidLoad: PublishRelay<Void> = .init()
        public let didLoadImage: PublishRelay<(Data)> = .init()
    }

    public struct ViewStreamState {
        public let selectedPokemonID: BehaviorRelay<Int>
    }

    public struct ViewStreamOutput {
        public let detailInformation: Observable<DetailPokemonViewStreamModel.DetailInformation>
        public let isLoadingViewHidden: Observable<Bool>
    }
}

public final class DetailPokemonViewStream: DetailPokemonViewStreamType {
    public var input: DetailPokemonViewStreamModel.ViewStreamInput
    public var state: DetailPokemonViewStreamModel.ViewStreamState
    public var output: DetailPokemonViewStreamModel.ViewStreamOutput
    
    private let useCase: DetailPokemonViewUseCaseType

    private let disposeBag = DisposeBag()

    public init(
        useCase: DetailPokemonViewUseCaseType,
        state: DetailPokemonViewStreamModel.ViewStreamState
    ) {
        let input = DetailPokemonViewStreamModel.ViewStreamInput()
        let state = state

        input.didLoadImage
            .subscribe { imageData in
                useCase.setLoadedImageData(id: state.selectedPokemonID.value, data: imageData)
            }
            .disposed(by: disposeBag)

        let displayResult = input.viewDidLoad
            .flatMap { () -> Observable<DetailPokemonViewUseCaseModel.DisplayResult> in
                useCase.display(id: state.selectedPokemonID.value)
            }
            .share()

        let isLoadingViewHidden = displayResult
            .map { $0 != .loading }

        let detailInformation = displayResult
            .compactMap { result -> DetailPokemonViewStreamModel.DetailInformation? in
                guard case let .loaded(pokemon) = result else { return nil }
                return .init(
                    id: pokemon.id,
                    name: pokemon.name,
                    weight: pokemon.weight,
                    height: pokemon.height,
                    flavorText: pokemon.flavorText,
                    imageUrl: pokemon.imageUrl,
                    imageData: pokemon.imageData,
                    abilities: pokemon.abilities
                )
            }

        self.useCase = useCase
        self.input = input
        self.state = state
        self.output = .init(
            detailInformation: detailInformation,
            isLoadingViewHidden: isLoadingViewHidden
        )
    }
}

extension DetailPokemonViewStreamModel {
    public struct DetailInformation {
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
