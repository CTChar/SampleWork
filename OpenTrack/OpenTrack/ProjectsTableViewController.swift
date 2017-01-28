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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellToDisplay = tableView.dequeueReusableCellWithIdentifier("Cell") else {
            fatalError("Bring a cell or gtfo")
        }
        return cellToDisplay
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = projects[indexPath.row].rawValue
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectProjectToTrack(projects[indexPath.row])
    }

}

protocol ProjectsTableViewDelegate {
    func didSelectProjectToTrack(project: Project)
}