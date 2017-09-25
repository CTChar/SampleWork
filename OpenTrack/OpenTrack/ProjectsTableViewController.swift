//
//  ProjectsTableViewController.swift
//  OpenTrack
//
//  Created by Cole Herzog on 9/28/16.
//  Copyright © 2016 Spensa. All rights reserved.
//

import UIKit

class ProjectsTableViewController: UITableViewController {
    
    var delegate: ProjectsTableViewDelegate?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellToDisplay = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            fatalError("Bring a cell or gtfo")
        }
        return cellToDisplay
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = projects[indexPath.row].rawValue
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectProjectToTrack(projects[indexPath.row])
    }

}

protocol ProjectsTableViewDelegate {
    func didSelectProjectToTrack(_ project: Project)
}
