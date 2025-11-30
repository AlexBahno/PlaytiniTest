//
//  ResultViewController.swift
//  PlaytiniTest
//
//  Created by Alexandr Bahno on 30.11.2025.
//

import UIKit
import SnapKit

final class ResultViewController: UIViewController {
    
    // MARK: - UI Elements
    private let resultTableView = UITableView()
    
    // MARK: - ViewModel
    private let viewModel: ResultViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Init`s
    init(viewModel: ResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Logic
    private func loadData() {
        resultTableView.reloadData()
    }
}

// MARK: - Setup UI
private extension ResultViewController {
    func setupUI() {
        setupTitle()
        setupResultTableView()
    }
    
    func setupTitle() {
        self.title = "Results"
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    func setupResultTableView() {
        resultTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        
        resultTableView.dataSource = self
        resultTableView.delegate = self
        
        self.view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: - UITableViewDataSource
extension ResultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count <= 20 ? viewModel.results.count : 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        let result = viewModel.results[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        let timeString = String(format: "%.2f", result.timeElapsed)
        
        let rankEmoji: String
        switch indexPath.row {
        case 0: rankEmoji = "🥇"
        case 1: rankEmoji = "🥈"
        case 2: rankEmoji = "🥉"
        default: rankEmoji = "#\(indexPath.row + 1)"
        }
        
        content.text = "\(rankEmoji)  \(timeString)"
        content.textProperties.font = .monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
        
        content.secondaryText = dateFormatter.string(from: result.date)
        content.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        
        return cell
    }
}
