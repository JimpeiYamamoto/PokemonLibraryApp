import Foundation
import UIKit
import ViewStream
import RxSwift
import RxCocoa
import RxRelay

public final class DetailPokemonViewController: UIViewController {

    private let viewStream: DetailPokemonViewStreamType
    private let disposeBag = DisposeBag()

    private lazy var containerView: UIStackView = {
        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        let view = UIStackView(
            arrangedSubviews: [
                headerPokemonView,
                abilitiesView,
                flavorTextView,
                emptyView
            ]
        )
        view.axis = .vertical
        view.spacing = 12.0
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        return view
    }()

    private let pokemonCardView: PokemonCardView = {
        let view = PokemonCardView()
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 1.0
        return view
    }()

    private let weightLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let heightLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var headerPokemonView: UIStackView = {
        let descriptionView = UIStackView(
            arrangedSubviews: [
                weightLabel,
                heightLabel
            ]
        )
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.axis = .vertical
        descriptionView.spacing = 12.0
        descriptionView.alignment = .center

        let containerView = UIStackView(
            arrangedSubviews: [
                pokemonCardView,
                descriptionView
            ]
        )
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .horizontal
        containerView.alignment = .center
        return containerView
    }()

    private let flavorTextView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.sizeToFit()
        return view
    }()

    private let abilitiesView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8.0
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public init(viewStream: DetailPokemonViewStreamType) {
        self.viewStream = viewStream
        super.init(nibName: nil, bundle: nil)

        viewStream.output.isLoadingViewHidden
            .observe(on: MainScheduler.instance)
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)

        viewStream.output.detailInformation
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] info in
                self?.pokemonCardView.configure(
                    number: info.id,
                    name: info.name,
                    imageUrl: info.imageUrl,
                    imageData: info.imageData
                )
                self?.weightLabel.text = "重さ: \(Double(info.weight)/10.0) kg"
                self?.heightLabel.text = "高さ: \(Double(info.height)/10.0) m"
                self?.flavorTextView.text = info.flavorText
                info.abilities.forEach { ability in
                    let abilityView = AbilityView()
                    abilityView.translatesAutoresizingMaskIntoConstraints = false
                    abilityView.configure(abilityText: "  \(ability)  ")
                    self?.abilitiesView.addArrangedSubview(abilityView)
                }
            }
            .disposed(by: disposeBag)

        pokemonCardView.didLoadImage
            .subscribe { imageData in
                viewStream.input.didLoadImage.accept(imageData)
            }
            .disposed(by: disposeBag)

        closeButton.rx.controlEvent(.touchUpInside)
            .subscribe { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewStream.input.viewDidLoad.accept(())

        view.backgroundColor = .white
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
        ])

        NSLayoutConstraint.activate([
            pokemonCardView.widthAnchor.constraint(equalToConstant: 150),
            pokemonCardView.heightAnchor.constraint(equalToConstant: 150)
        ])

        NSLayoutConstraint.activate([
            headerPokemonView.heightAnchor.constraint(equalToConstant: 150),
            headerPokemonView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            flavorTextView.topAnchor.constraint(equalTo: abilitiesView.bottomAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            abilitiesView.heightAnchor.constraint(equalToConstant: 35)
        ])

        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 100),
            loadingView.widthAnchor.constraint(equalToConstant: 100),
        ])

        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
