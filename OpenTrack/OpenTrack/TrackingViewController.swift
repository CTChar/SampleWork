//
//  TrackingViewController.swift
//  OpenTrack
//
//  Created by Cole Herzog on 9/28/16.
//  Copyright © 2016 Spensa. All rights reserved.
//

import UIKit

enum TrackingState: Int {
    case percentage = 0
    case hour = 1
}

class TrackingViewController: UIViewController{

    @IBOutlet var tableView: UITableView!
    var projects: [ProjectReport] = []
    let reportingType: [String] = ["Percentage", "Hours"]
    var firstName: String = "Steve"
    var lastName: String = "Woz"
    var trackingState: TrackingState = .percentage
    var previouslySelectedIndexPath: IndexPath?
    var insetController: ViewFrameKeyboardInsetController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TypeTableViewCell", bundle: nil), forCellReuseIdentifier: "Type")
        tableView.register(UINib(nibName: "TrackingTableViewCell", bundle: nil), forCellReuseIdentifier: "Track")
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "Comment")
        tableView.register(UINib(nibName: "HoursTableViewCell", bundle: nil), forCellReuseIdentifier: "Hours")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewHit))
        tapGesture.cancelsTouchesInView = false
        tapGesture.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(tapGesture)
        
        insetController = ViewFrameKeyboardInsetController(view: self.view, anchorView: tableView)
        insetController?.beginObserving()

        self.projects = [ProjectReport(time: 5, project: .AdvantageAcre), ProjectReport(time: 90, project: .OpenScout), ProjectReport(time: 5, project: .Simplot), ProjectReport(time: 0, project: .Blank)]
    }
    
    @IBAction func saveHit(_ sender: AnyObject) {
        if trackingState == .percentage {
            var totalNumber = 0
            for project in projects {
                totalNumber += project.time
            }
            
            if totalNumber != 100 {
                let alert = UIAlertController(title: "Math?", message: "I know it's difficult, and I know you're a special snowflake, but if you could please enter the civilized world and make sure your percentages add up to 100 it would be appreciated.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Sorry", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        let alert = UIAlertController(title: "Thanks willing participant", message: "We appreciate your forced participation. Your \"productivity report\" has been sent to the proper authorities. Read: authorities. We hope you have a wonderful day (big brother is watching).", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "I am happy", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "projectSegue" {
            guard let nextView = segue.destination as? ProjectSelectionViewController else {
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
    func numberOfSections(in tableView: UITableView) -> Int {
        switch trackingState {
        case .percentage:
            return 4
        case .hour:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cellToDisplay: TypeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Type", for: indexPath) as? TypeTableViewCell else {
                fatalError("No type cell go home")
            }
            
            return cellToDisplay
        case 1:
            guard let cellToDisplay: TrackingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Track", for: indexPath) as? TrackingTableViewCell else {
                fatalError("No tracking cell go home")
            }
            
            return cellToDisplay
        case 2:
            guard let cellToDisplay: CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Comment", for: indexPath) as? CommentTableViewCell else {
                fatalError("No tracking cell go home")
            }
            
            return cellToDisplay
        case 3:
            guard let cellToDisplay: HoursTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Hours", for: indexPath) as? HoursTableViewCell else {
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 200
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let cellToDisplay: TypeTableViewCell = cell as? TypeTableViewCell else {
                fatalError("ABC, EASY AS 1,2,... NOPE NO CELL GO HOME")
            }
            
            cellToDisplay.textLabel?.text = reportingType[indexPath.row]
            cellToDisplay.selectionStyle = .none
            if indexPath.row == trackingState.rawValue {
                cellToDisplay.accessoryType = .checkmark
            } else {
                cellToDisplay.accessoryType = .none
            }
        case 1:
            guard let cellToDisplay: TrackingTableViewCell = cell as? TrackingTableViewCell else {
                fatalError("NO CELL, NO GO")
            }
            
            cellToDisplay.delegate = self
            cellToDisplay.selectionStyle = .none
            cellToDisplay.projectReport = projects[indexPath.row]
        case 2:
            guard let cellToDisplay: CommentTableViewCell = cell as? CommentTableViewCell else {
                fatalError("COMMENTS ARE IMPORTANT OKAY? JUST LOOK AT ALL MY COMMENTED OUT CODE.")
            }
            
            cellToDisplay.selectionStyle = .none
        case 3:
            guard let cellToDisplay: HoursTableViewCell = cell as? HoursTableViewCell else {
                fatalError("HOURS CELL OR NO SHOWERINO TABLERINO")
            }
            
            cellToDisplay.selectionStyle = .none
        default:
            fatalError("Stop. Do not pass go. Do not track your time. Give up hope.")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let localState = TrackingState(rawValue: indexPath.row) {
                trackingState = localState
                tableView.reloadData()
            }
            return
        case 1:
            previouslySelectedIndexPath = indexPath
            performSegue(withIdentifier: "projectSegue", sender: self)
            // Throw up a project selection view controller
            return
        default:
            return
        }
    }
}

// TRACKING CELL
extension TrackingViewController: TrackingCellDelegate {
    func didChangeProjectReportForProject(_ trackingCell: TrackingTableViewCell, projectReport: ProjectReport) {
        if let projectRow = tableView.indexPath(for: trackingCell)?.row {
            projects[projectRow] = projectReport
        }
    }
    
    func didRemoveProjectReport(_ trackingCell: TrackingTableViewCell) {
        if projects.count > 2 {
            if let projectIndex = tableView.indexPath(for: trackingCell) {
                if projectIndex.row == projects.count - 1 {
                    return // TODO probably put an error up on the screen
                }
                
                self.projects.remove(at: projectIndex.row)
                self.tableView.deleteRows(at: [projectIndex], with: .right)
            }
        }
    }
}

extension TrackingViewController: ProjectSelectionDelegate {
    func didSelectProjectToTrack(_ project: Project, indexPath: IndexPath?) {
        if projects.contains(where: {$0 == project}) {
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
