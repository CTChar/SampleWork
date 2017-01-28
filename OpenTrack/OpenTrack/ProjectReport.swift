//
//  ProjectReport.swift
//  OpenTrack
//
//  Created by Cole Herzog on 9/28/16.
//  Copyright © 2016 Spensa. All rights reserved.
//

import Foundation

enum Project: String {
    case AdvantageAcre = "Advantage Acre"
    case Simplot = "Simplot"
    case OpenScout = "OpenScout"
    case ZTrap = "Z-Trap Vertical"
    case ZHub = "Z-Hub"
    case Bayer = "Bayer ES"
    case NSF = "NSF SBIR Phase II"
    case ZTrapNet = "Z-Trap Network"
    case ZNose = "Z-Nose"
    case Training = "Training"
    case NonProjPest = "Non-Project Pest Unit Work"
    case NonProjPlatform = "Non-Project Platform Work"
    case NonProjCompany = "Non-Project General Company Work"
    case Blank = "Project Name"
}

class ProjectReport {
    var project: Project
    var time: Int
    
    init(time: Int, project: Project) {
        self.time = time
        self.project = project
    }
}

func ==(lhs: ProjectReport, rhs: Project) -> Bool {
    return lhs.project == rhs
}
