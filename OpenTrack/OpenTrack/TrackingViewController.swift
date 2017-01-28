//
//  TrackingViewController.swift
//  OpenTrack
//
//  Created by Cole Herzog on 9/28/16.
//  Copyright © 2016 Spensa. All rights reserved.
//

import UIKit

enum TrackingState: Int {
    case Percentage = 0
    case Hour = 1
}

class TrackingViewController: UIViewController{

    @IBOutlet var tableView: UITableView!
    var projects: [ProjectReport] = []
    let reportingType: [String] = ["Percentage", "Hours"]
    var firstName: String = "Steve"
    var lastName: String = "Woz"
    var trackingState: TrackingState = .Percentage
    var previouslySelectedIndexPath: NSIndexPath?
    var insetController: ViewFrameKeyboardInsetController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "TypeTableViewCell", bundle: nil), forCellReuseIdentifier: "Type")
        tableView.registerNib(UINib(nibName: "TrackingTableViewCell", bundle: nil), forCellReuseIdentifier: "Track")
        tableView.registerNib(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "Comment")
        tableView.registerNib(UINib(nibName: "HoursTableViewCell", bundle: nil), forCellReuseIdentifier: "Hours")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewHit))
        tapGesture.cancelsTouchesInView = false
        tapGesture.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(tapGesture)
        
        insetController = ViewFrameKeyboardInsetController(view: self.view, anchorView: tableView)
        insetController?.beginObserving()

        self.projects = [ProjectReport(time: 5, project: .AdvantageAcre), ProjectReport(time: 90, project: .OpenScout), ProjectReport(time: 5, project: .Simplot), ProjectReport(time: 0, project: .Blank)]
    }
    
    @IBAction func saveHit(sender: AnyObject) {
        if trackingState == .Percentage {
            var totalNumber = 0
            for project in projects {
                totalNumber += project.time
            }
            
            if totalNumber != 100 {
                let alert = UIAlertController(title: "Math?", message: "I know it's difficult, and I know you're a special snowflake, but if you could please enter the civilized world and make sure your percentages add up to 100 it would be appreciated.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Sorry", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
        }
        
        let alert = UIAlertController(title: "Thanks willing participant", message: "We appreciate your forced participation. Your \"productivity report\" has been sent to the proper authorities. Read: authorities. We hope you have a wonderful day (big brother is watching).", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "I am happy", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "projectSegue" {
            guard let nextView = segue.destinationViewController as? ProjectSelectionViewController else {
                fatalError("SEGUE WITHOUT A VIEW CONTROLLER? GARBAGE.")
            }
            nextView.delegate = self
            nextView.trackingIndexPath = previouslySelectedIndexPath
        }
    }
    
    func tableViewHit() {
        view.endEditing(true)
    }
    
}

// DATA SOURCE
extension TrackingViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch trackingState {
        case .Percentage:
            return 4
        case .Hour:
            return 3
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return projects.count
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "INPUT METHOD"
        case 1:
            return "PROJECTS"
        case 2:
            return "COMMENTS"
        case 3:
            return "ESTIMATED HOURS"
        default:
            return "Leave this place. Now."
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cellToDisplay: TypeTableViewCell = tableView.dequeueReusableCellWithIdentifier("Type", forIndexPath: indexPath) as? TypeTableViewCell else {
                fatalError("No type cell go home")
            }
            
            return cellToDisplay
        case 1:
            guard let cellToDisplay: TrackingTableViewCell = tableView.dequeueReusableCellWithIdentifier("Track", forIndexPath: indexPath) as? TrackingTableViewCell else {
                fatalError("No tracking cell go home")
            }
            
            return cellToDisplay
        case 2:
            guard let cellToDisplay: CommentTableViewCell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as? CommentTableViewCell else {
                fatalError("No tracking cell go home")
            }
            
            return cellToDisplay
        case 3:
            guard let cellToDisplay: HoursTableViewCell = tableView.dequeueReusableCellWithIdentifier("Hours", forIndexPath: indexPath) as? HoursTableViewCell else {
                fatalError("No hour cell no use table")
            }
            
            return cellToDisplay
        default:
            fatalError("Why are you looking for these cells? Stop it.")
        }
    }
}

// TABLE VIEW
extension TrackingViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 200
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            guard let cellToDisplay: TypeTableViewCell = cell as? TypeTableViewCell else {
                fatalError("ABC, EASY AS 1,2,... NOPE NO CELL GO HOME")
            }
            
            cellToDisplay.textLabel?.text = reportingType[indexPath.row]
            cellToDisplay.selectionStyle = .None
            if indexPath.row == trackingState.rawValue {
                cellToDisplay.accessoryType = .Checkmark
            } else {
                cellToDisplay.accessoryType = .None
            }
        case 1:
            guard let cellToDisplay: TrackingTableViewCell = cell as? TrackingTableViewCell else {
                fatalError("NO CELL, NO GO")
            }
            
            cellToDisplay.delegate = self
            cellToDisplay.selectionStyle = .None
            cellToDisplay.projectReport = projects[indexPath.row]
        case 2:
            guard let cellToDisplay: CommentTableViewCell = cell as? CommentTableViewCell else {
                fatalError("COMMENTS ARE IMPORTANT OKAY? JUST LOOK AT ALL MY COMMENTED OUT CODE.")
            }
            
            cellToDisplay.selectionStyle = .None
        case 3:
            guard let cellToDisplay: HoursTableViewCell = cell as? HoursTableViewCell else {
                fatalError("HOURS CELL OR NO SHOWERINO TABLERINO")
            }
            
            cellToDisplay.selectionStyle = .None
        default:
            fatalError("Stop. Do not pass go. Do not track your time. Give up hope.")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            if let localState = TrackingState(rawValue: indexPath.row) {
                trackingState = localState
                tableView.reloadData()
            }
            return
        case 1:
            previouslySelectedIndexPath = indexPath
            performSegueWithIdentifier("projectSegue", sender: self)
            // Throw up a project selection view controller
            return
        default:
            return
        }
    }
}

// TRACKING CELL
extension TrackingViewController: TrackingCellDelegate {
    func didChangeProjectReportForProject(trackingCell: TrackingTableViewCell, projectReport: ProjectReport) {
        if let projectRow = tableView.indexPathForCell(trackingCell)?.row {
            projects[projectRow] = projectReport
        }
    }
    
    func didRemoveProjectReport(trackingCell: TrackingTableViewCell) {
        if projects.count > 2 {
            if let projectIndex = tableView.indexPathForCell(trackingCell) {
                if projectIndex.row == projects.count - 1 {
                    return // TODO probably put an error up on the screen
                }
                
                self.projects.removeAtIndex(projectIndex.row)
                self.tableView.deleteRowsAtIndexPaths([projectIndex], withRowAnimation: .Right)
            }
        }
    }
}

extension TrackingViewController: ProjectSelectionDelegate {
    func didSelectProjectToTrack(project: Project, indexPath: NSIndexPath?) {
        if projects.contains({$0 == project}) {
            return
        }
        
        if let trackingIndexPath = indexPath {
            let localProject = projects[trackingIndexPath.row]
            projects[trackingIndexPath.row] = ProjectReport(time: localProject.time, project: project)
            
            if trackingIndexPath.row == projects.count - 1 {
                projects.append(ProjectReport(time: 0, project: .Blank))
            }
            
            tableView.reloadData()
        }
    }
}
