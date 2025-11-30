//
//  ViewController.swift
//  PlaytiniTest
//
//  Created by Alexandr Bahno on 29.11.2025.
//

import UIKit
import SnapKit

final class MenuViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let startGameButton = UIButton(type: .system)
    private let resultButton = UIButton(type: .system)
    private let containerStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        setupUI()
        setupActions()
    }

    private func setupActions() {
        startGameButton.addTarget(self, action: #selector(didTapGame), for: .touchUpInside)
        resultButton.addTarget(self, action: #selector(didTapResults), for: .touchUpInside)
    }
    
    @objc private func didTapGame() {
        let gameVC = GameViewController()
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    @objc private func didTapResults() {
        let vm = ResultViewModel()
        let resultsVC = ResultViewController(viewModel: vm)
        navigationController?.pushViewController(resultsVC, animated: true)
    }
}

// MARK: - Setup UI
private extension MenuViewController {
    func setupUI() {
        setupContainerStackView()
        setupTitleLabel()
        setupStartGameButton()
        setupResultButton()
    }
    
    func setupContainerStackView() {
        containerStackView.axis = .vertical
        containerStackView.spacing = 20
        containerStackView.distribution = .fillEqually
        
        view.addSubview(containerStackView)
        containerStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(250)
        }
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Mini Crossy Road"
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        
        containerStackView.addArrangedSubview(titleLabel)
    }
    
    func setupStartGameButton() {
        startGameButton.setTitle("Play", for: .normal)
        startGameButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        startGameButton.backgroundColor = .systemBlue
        startGameButton.setTitleColor(.white, for: .normal)
        startGameButton.layer.cornerRadius = 10
        
        containerStackView.addArrangedSubview(startGameButton)
    }
    
    func setupResultButton() {
        resultButton.setTitle("Results", for: .normal)
        resultButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        resultButton.backgroundColor = .systemGreen
        resultButton.setTitleColor(.white, for: .normal)
        resultButton.layer.cornerRadius = 10
        
        containerStackView.addArrangedSubview(resultButton)
    }
}
