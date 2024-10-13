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
        public let didLoadImage: PublishRelay<(Data, Int)> = .init()
    }

    public struct ViewStreamState {}

    public struct ViewStreamOutput {
        public let detailInformation: Observable<DetailPokemonViewStreamModel.DetailInformation>
    }
}

extension DetailPokemonViewStreamModel {
    public struct DetailInformation {
        public let id: Int
        public let name: String
        public let weight: Int
        public let height: Int
        public let flavorText: String
        public let image: URL
        public let sound: URL
        public let abilities: [String]
    }
}
