//
//  Settings.swift
//  beanbean
//
//  Created by Skylar Jones on 3/22/24.
//

struct MovementSettings {
    let defaultVerticalSpeed: Double
    let fastVerticalSpeed: Double
    let gravitySpeed: Double
}

struct DebugSettings {
    let showCells: Bool
    let showRowColumnNumbers: Bool
    let showGroupNumber: Bool
    let printGameState: Bool
}

struct Settings {
    let movement: MovementSettings
    let debug: DebugSettings
}

fileprivate let movementSettings = MovementSettings(
    defaultVerticalSpeed: 2,
    fastVerticalSpeed: 10,
    gravitySpeed: 10
)

fileprivate let debugSettings = DebugSettings(
    showCells: false,
    showRowColumnNumbers: false,
    showGroupNumber: false,
    printGameState: false
)

let settings = Settings(
    movement: movementSettings,
    debug: debugSettings
)
