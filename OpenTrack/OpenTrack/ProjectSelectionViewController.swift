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
    
    var trackingIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.borderWidth = 2.0
        tableView.layer.borderColor = UIColor.orangeColor().CGColor
    }
}

extension ProjectSelectionViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellToDisplay = tableView.dequeueReusableCellWithIdentifier("Cell") else {
            fatalError("Bring a cell or gtfo")
        }
        return cellToDisplay
    }
}

extension ProjectSelectionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = projects[indexPath.row].rawValue
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectProjectToTrack(projects[indexPath.row], indexPath: trackingIndexPath)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol ProjectSelectionDelegate {
    func didSelectProjectToTrack(project: Project, indexPath: NSIndexPath?)
}