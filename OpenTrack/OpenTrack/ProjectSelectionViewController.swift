//
//  ProjectSelectionViewController.swift
//  OpenTrack
//
//  Created by Cole Herzog on 9/28/16.
//  Copyright © 2016 Spensa. All rights reserved.
//

import UIKit

class ProjectSelectionViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var delegate: ProjectSelectionDelegate?
    var projects: [Project] = [.AdvantageAcre,
                               .Simplot,
                               .OpenScout,
                               .ZTrap,
                               .ZHub,
                               .Bayer,
                               .NSF,
                               .ZTrapNet,
                               .ZNose,
                               .Training,
                               .NonProjPest,
                               .NonProjPlatform,
                               .NonProjCompany]
    
    var trackingIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.borderWidth = 2.0
        tableView.layer.borderColor = UIColor.orange.cgColor
    }
}

extension ProjectSelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellToDisplay = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            fatalError("Bring a cell or gtfo")
        }
        return cellToDisplay
    }
}

extension ProjectSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = projects[indexPath.row].rawValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectProjectToTrack(projects[indexPath.row], indexPath: trackingIndexPath)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

protocol ProjectSelectionDelegate {
    func didSelectProjectToTrack(_ project: Project, indexPath: IndexPath?)
}
