//
//  Levels.swift
//  Breakout
//
//  Created by Jeroen Schonenberg on 22/05/15.
//  Copyright (c) 2015 private. All rights reserved.
//

import Foundation

public class Levels {

static let levels = [levelOne, levelTwo, levelThree, levelFour]
    
static let levelOne: [[Int]] = [
    [1,0,1,0,1,0,1],
    [0,1,0,1,0,1,0],
    [1,0,1,0,1,0,1],
    [0,1,0,1,0,1,0],
    [1,0,1,0,1,0,1],
    [0,1,0,1,0,1,0],
    [1,0,1,0,1,0,1]
]

static let levelTwo: [[Int]]  = [
    [1,1,1,1,1,1,1],
    [1,1,1,1],
    [1,1,1],
    [1,1,1,1],
    [1,1,1,1,1,1,1]
]

static let levelThree: [[Int]] = [
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1]
]

static let levelFour: [[Int]] = [
        [1,1,0,1,1,0,1],
        [1,0,1,1,0,1,1],
        [0,1,1,0,1,1,0],
        [1,1,0,1,1,0,1],
        [1,0,1,1,0,1,1],
        [0,1,1,0,1,1,0],
        [1,1,0,1,1,0,1]
    ]


}