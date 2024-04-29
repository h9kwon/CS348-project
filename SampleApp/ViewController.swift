//
//  ViewController.swift
//  SampleApp
//
//  Created by 권현구 on 1/19/24.
//

import UIKit
import SnapKit
import SQLite3

class ViewController: UIViewController {
    
    var items: [Item] = []
    var categories: [String] = []
    var selectedCategory: String?
    
    private lazy var label = {
        let label = UILabel()
        label.text = "this is label"
        label.backgroundColor = .blue
        return label
    }()
    
    private lazy var nameTextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "name"
        return textField
    }()
    
    private lazy var categoryTextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "category"
        return textField
    }()
    
    private lazy var quantityTextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "quantity"
        return textField
    }()
    
    private lazy var noteTextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "note"
        return textField
    }()
    
    private lazy var inputStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, categoryTextField, quantityTextField, noteTextField, addButton, deleteAllButton])
        stackView.backgroundColor = .yellow
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var addButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(onAddButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteAllButton = {
        let button = UIButton()
        button.setTitle("Delete All", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(onDeleteAllButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var filterStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(filterButton)
        stackView.addArrangedSubview(pickerView)
        return stackView
    }()
    
    private lazy var filterButton = {
        let button = UIButton(type: .system)
        button.setTitle("Category", for: .normal)
        button.addTarget(self, action: #selector(onFilterBtnTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var pickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        return pickerView
    }()
    
    @objc func onAddButtonTap() {
        DatabaseManager.shared.insertItem(name: nameTextField.text ?? "", category: categoryTextField.text ?? "", quantity: (quantityTextField.text as! NSString).integerValue, note: noteTextField.text ?? "")
        items = DatabaseManager.shared.getAllItems()
        categories = DatabaseManager.shared.getAllCategories()
        tableView.reloadData()
    }
    
    @objc func onDeleteAllButtonTap() {
        DatabaseManager.shared.deleteAllItems()
        items = DatabaseManager.shared.getAllItems()
        categories = DatabaseManager.shared.getAllCategories()
        tableView.reloadData()
    }
    
    @objc func onFilterBtnTap() {
        if !pickerView.isHidden {
            let row = pickerView.selectedRow(inComponent: 0)
            selectedCategory = row == 0 ? nil : categories[row - 1]
            filterButton.setTitle(selectedCategory ?? "Category", for: .normal)
            
            filterData()
        }
        togglePickerView()
    }
    
    @objc private func togglePickerView() {
        pickerView.isHidden = !pickerView.isHidden
    }
    
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        registerCells()
        items = DatabaseManager.shared.getAllItems()
        categories = DatabaseManager.shared.getAllCategories()
        print("viewDidLoad")
    }

    private func setupLayout() {
        view.addSubview(inputStackView)
        inputStackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        view.addSubview(filterStackView)
        filterStackView.snp.makeConstraints { make in
            make.top.equalTo(inputStackView.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterStackView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
    }
    
    func registerCells() {
        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseIdentifier)
    }
    
    private func filterData() {
        items = DatabaseManager.shared.getFilteredItems(category: selectedCategory)
        tableView.reloadData()
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseIdentifier, for: indexPath) as! ItemCell
        let item = items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Category"
        }
        return categories[row - 1]
    }
    
}
