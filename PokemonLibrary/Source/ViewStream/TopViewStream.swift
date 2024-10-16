import Foundation
import RxRelay
import RxSwift
import UseCase

public protocol TopViewStreamType {
    var input: TopViewStreamModel.ViewStreamInput { get }
    var state: TopViewStreamModel.ViewStreamState { get }
    var output: TopViewStreamModel.ViewStreamOutput { get }
}

public enum TopViewStreamModel {
    public struct ViewStreamInput {
        public let didScrollCollectionView: PublishRelay<[IndexPath]> = .init()
        public let didLoadImage: PublishRelay<(Data, Int)> = .init()
        public let didTapItem: PublishRelay<IndexPath> = .init()
    }

    public struct ViewStreamState {
        public let pokemonCards = BehaviorRelay<[TopViewStreamDataModel.Item]>(value: [])
    }

    public struct ViewStreamOutput {
        public let pokemonCards: Observable<[TopViewStreamDataModel.Item]>
        public let isLoadingViewHidden: Observable<Bool>
        public let tappedID: Observable<Int>
    }
}

public final class TopViewStream: TopViewStreamType {
    public let input: TopViewStreamModel.ViewStreamInput
    public let state: TopViewStreamModel.ViewStreamState
    public let output: TopViewStreamModel.ViewStreamOutput

    private let useCase: TopViewUseCaseType
    private let disposeBag = DisposeBag()

    public init(useCase: TopViewUseCaseType) {
        let input = TopViewStreamModel.ViewStreamInput()
        let state = TopViewStreamModel.ViewStreamState()

        let tappedID = input.didTapItem
            .map { indexPath in
                let item = state.pokemonCards.value[indexPath.row]
                return item.number
            }

        input.didLoadImage
            .subscribe { (imageData, id) in
                useCase.setLoadedImageData(id: id, data: imageData)
            }
            .disposed(by: disposeBag)

        let displayResult = input.didScrollCollectionView.asObservable()
            .map { $0.max()?.last ?? 0 }
            .distinctUntilChanged()
            .filter { $0 > state.pokemonCards.value.count - 2 }
            .flatMap { [useCase] indexPaths -> Observable<TopViewUseCaseModel.DisplayResult> in
                let offset = state.pokemonCards.value.count
                return useCase.display(offset: offset)
            }
            .share()

        displayResult
            .map { displayResult -> [TopViewStreamDataModel.Item] in
                guard case let .loaded(pokemons) = displayResult else { return [] }
                return pokemons
                    .enumerated()
                    .map { offset, pokemon -> TopViewStreamDataModel.Item in
                        .init(
                            offset: offset + state.pokemonCards.value.count,
                            number: pokemon.id,
                            name: pokemon.name,
                            imageUrl: pokemon.imageUrl,
                            imageData: pokemon.imageData
                        )
                    }
            }
            .map { items in
                state.pokemonCards.value + items
            }
            .bind(to: state.pokemonCards)
            .disposed(by: disposeBag)

        let isLoadingViewHidden = displayResult
            .map { $0 != .loading }

        self.useCase = useCase
        self.input = input
        self.state = state
        self.output = .init(
            pokemonCards: state.pokemonCards.asObservable(),
            isLoadingViewHidden: isLoadingViewHidden,
            tappedID: tappedID
        )
    }
}

public enum TopViewStreamDataModel {
    public enum Section {
        case identity
    }

    public struct Item: Hashable {
        private let offset: Int
        public let number: Int
        public let name: String
        public let imageUrl: URL?
        public let imageData: Data?

        public init(offset: Int, number: Int, name: String, imageUrl: URL?, imageData: Data?) {
            self.offset = offset
            self.number = number
            self.name = name
            self.imageUrl = imageUrl
            self.imageData = imageData
        }
    }
}
