//
//  ReminderViewController.swift
//  Remindify
//
//  Created by PrashantDixit on 03/07/23.
//

import UIKit

class ReminderViewController: UICollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    var reminder: Reminder {
        didSet {
            onChange(reminder)
        }
    }
    var workingReminder: Reminder
    var isAddingNewReminder: Bool = false
    var onChange: (Reminder) ->  Void
    private var dataSource: DataSource!
    
    init(reminder: Reminder, onChange: @escaping (Reminder) -> Void) {
        self.reminder = reminder
        self.workingReminder = reminder
        self.onChange = onChange
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        listConfiguration.headerMode = .firstItemInSection
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        super.init(collectionViewLayout: listLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Always initialize ReminderViewController using init(reminder:)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView){
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Row) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        if #available(iOS 16, *) {
                    navigationItem.style = .navigator
        }
        navigationItem.title = NSLocalizedString("Reminder", comment: "Reminder view controller title")
        navigationItem.rightBarButtonItem = editButtonItem
        
        updateSnapshotForViewing()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
           prepareForEditing()
        } else {
            if isAddingNewReminder {
                onChange(workingReminder)
            } else {
                prepareForViewing()
            }
        }
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row)
    {
        let section = section(for: indexPath)
        switch (section, row) {
            // to show the section headers in edit mode (TITLE, DATE)
            case (_, .header(let title)):
                // this function is inside the extension for cell configuration
                cell.contentConfiguration = headerConfiguration(for: cell, with: title)
            
           // to show the normal detail view, default and when done is clicked
            case (.view, _):
                // this function is inside the extension for cell configuration
                cell.contentConfiguration = defaultConfiguration(for: cell, at: row)
        
            // when in edit mode, if we're in Section named title, then show this ui
            case (.title, .editableText(let title)):
                cell.contentConfiguration = titleConfiguration(for: cell, with: title)
            
            case (.date, .editableDate(let date)):
                cell.contentConfiguration = dateConfiguration(for: cell, with: date)
                
            case (.notes, .editableText(let notes)):
                cell.contentConfiguration = notesConfiguration(for: cell, with: notes)
            default:
               fatalError("Unexpected combination of section and row.")
        }
        cell.tintColor = .todayPrimaryTint
    }
    
    private func prepareForViewing() {
        navigationItem.leftBarButtonItem = nil
        if workingReminder != reminder {
            reminder = workingReminder
        }
        updateSnapshotForViewing()
    }
    
    private func updateSnapshotForViewing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.view])
        snapshot.appendItems([Row.header("") ,Row.title, Row.date, Row.time, Row.notes], toSection: .view)
        dataSource.apply(snapshot)
    }
    
    private func prepareForEditing() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(didCancelEdit)
        )
        updateSnapshotForEditing()
    }
    
    private func updateSnapshotForEditing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .date, .notes])
        snapshot.appendItems([.header(Section.title.name), .editableText(reminder.title)], toSection: .title)
        snapshot.appendItems([.header(Section.date.name), .editableDate(reminder.dueDate)], toSection: .date)
        snapshot.appendItems([.header(Section.notes.name), .editableText(reminder.notes)], toSection: .notes)
        dataSource.apply(snapshot)
     }
    
    private func section(for indexPath: IndexPath) -> Section {
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        guard let section = Section(rawValue: sectionNumber) else {
            fatalError("Unable to find matching section")
        }
        
        return section
    }
    
    @objc func didCancelEdit(){
        workingReminder = reminder
        setEditing(false, animated: false)
    }
}

