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

let settings = Settings(
    movement: MovementSettings (
        defaultVerticalSpeed: 2,
        fastVerticalSpeed: 10,
        gravitySpeed: 10
    ),
    debug: DebugSettings (
        showCells: false,
        showRowColumnNumbers: false,
        showGroupNumber: false,
        printGameState: false
    )
)
