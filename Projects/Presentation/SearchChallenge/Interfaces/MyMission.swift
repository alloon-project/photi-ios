//
//  MyMission.swift
//  LogInImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

public protocol MyMissionContainable: Containable {
  func coordinator(listener: MyMissionListener) -> Coordinating
}

public protocol MyMissionListener: AnyObject { }
