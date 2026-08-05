import SpriteKit
import UIKit

enum GamePhase: Equatable {
    case title
    case story(page: Int)
    case gear
    case playing
    case paused
    case gameOver
}

enum WorldTheme: Int, CaseIterable {
    case cloudKingdom
    case dinoJungle
    case candyCanyon
    case storybookCastle

    var backdropAssetName: String {
        switch self {
        case .cloudKingdom: "CloudBackdrop"
        case .dinoJungle: "DinoBackdrop"
        case .candyCanyon: "CandyBackdrop"
        case .storybookCastle: "CastleBackdrop"
        }
    }

    var hazardAssetName: String {
        switch self {
        case .cloudKingdom: "CloudHazard"
        case .dinoJungle: "DinoHazard"
        case .candyCanyon: "CandyHazard"
        case .storybookCastle: "CastleHazard"
        }
    }

    var barrierAssetName: String {
        switch self {
        case .cloudKingdom: "CloudBarrier"
        case .dinoJungle: "DinoBarrier"
        case .candyCanyon: "CandyBarrier"
        case .storybookCastle: "CastleBarrier"
        }
    }

    var enemyKind: EnemyKind {
        switch self {
        case .cloudKingdom: .cloudSwooper
        case .dinoJungle: .jungleSnapper
        case .candyCanyon: .candyBouncer
        case .storybookCastle: .castleGargoyle
        }
    }

    var name: String {
        switch self {
        case .cloudKingdom: "CLOUD KINGDOM"
        case .dinoJungle: "DINO JUNGLE"
        case .candyCanyon: "CANDY CANYON"
        case .storybookCastle: "STORYBOOK CASTLE"
        }
    }

    var subtitle: String {
        switch self {
        case .cloudKingdom: "Race above the floating islands"
        case .dinoJungle: "Dodge vines and ancient beasts"
        case .candyCanyon: "Fly through a land of giant treats"
        case .storybookCastle: "Break the curse over the royal towers"
        }
    }

    var skyColor: UIColor {
        switch self {
        case .cloudKingdom:
            UIColor(red: 0.30, green: 0.75, blue: 0.98, alpha: 1)
        case .dinoJungle:
            UIColor(red: 0.20, green: 0.62, blue: 0.46, alpha: 1)
        case .candyCanyon:
            UIColor(red: 0.98, green: 0.58, blue: 0.73, alpha: 1)
        case .storybookCastle:
            UIColor(red: 0.42, green: 0.40, blue: 0.82, alpha: 1)
        }
    }

    var horizonColor: UIColor {
        switch self {
        case .cloudKingdom:
            UIColor(red: 0.82, green: 0.94, blue: 1, alpha: 1)
        case .dinoJungle:
            UIColor(red: 0.10, green: 0.35, blue: 0.22, alpha: 1)
        case .candyCanyon:
            UIColor(red: 1, green: 0.82, blue: 0.48, alpha: 1)
        case .storybookCastle:
            UIColor(red: 0.20, green: 0.18, blue: 0.48, alpha: 1)
        }
    }

    var groundColor: UIColor {
        switch self {
        case .cloudKingdom:
            UIColor(red: 0.42, green: 0.68, blue: 0.32, alpha: 1)
        case .dinoJungle:
            UIColor(red: 0.22, green: 0.42, blue: 0.12, alpha: 1)
        case .candyCanyon:
            UIColor(red: 0.62, green: 0.26, blue: 0.42, alpha: 1)
        case .storybookCastle:
            UIColor(red: 0.24, green: 0.22, blue: 0.42, alpha: 1)
        }
    }

    var accentColor: UIColor {
        switch self {
        case .cloudKingdom: UIColor(red: 1, green: 0.86, blue: 0.24, alpha: 1)
        case .dinoJungle: UIColor(red: 0.72, green: 0.94, blue: 0.28, alpha: 1)
        case .candyCanyon: UIColor(red: 0.42, green: 0.94, blue: 0.92, alpha: 1)
        case .storybookCastle: UIColor(red: 1, green: 0.72, blue: 0.28, alpha: 1)
        }
    }

    var secondaryColor: UIColor {
        switch self {
        case .cloudKingdom: UIColor(red: 0.95, green: 0.98, blue: 1, alpha: 1)
        case .dinoJungle: UIColor(red: 0.08, green: 0.28, blue: 0.14, alpha: 1)
        case .candyCanyon: UIColor(red: 1, green: 0.32, blue: 0.52, alpha: 1)
        case .storybookCastle: UIColor(red: 0.85, green: 0.68, blue: 1, alpha: 1)
        }
    }
}

enum EnemyKind: String, CaseIterable {
    case cloudSwooper
    case jungleSnapper
    case candyBouncer
    case castleGargoyle

    var assetName: String {
        switch self {
        case .cloudSwooper: "CloudSwooperEnemy"
        case .jungleSnapper: "JungleSnapperEnemy"
        case .candyBouncer: "CandyBouncerEnemy"
        case .castleGargoyle: "CastleGargoyleEnemy"
        }
    }

    var displayName: String {
        switch self {
        case .cloudSwooper: "CLOUD SWOOPER"
        case .jungleSnapper: "JUNGLE SNAPPER"
        case .candyBouncer: "CANDY BOUNCER"
        case .castleGargoyle: "CASTLE GARGOYLE"
        }
    }
}

enum PowerUpKind: String {
    case shield
    case magnet
}

enum PhysicsCategory {
    static let player: UInt32 = 1 << 0
    static let hazard: UInt32 = 1 << 1
    static let chip: UInt32 = 1 << 2
    static let powerUp: UInt32 = 1 << 3
    static let heroShot: UInt32 = 1 << 4
    static let boss: UInt32 = 1 << 5
}

enum GameConstants {
    static let bestScoreKey = "AidanGameRush.bestScore"
    static let lifetimeChipsKey = "AidanGameRush.lifetimeChips"
    static let worldDuration: TimeInterval = 24
    static let initialObstacleDelay: TimeInterval = 1.8
    static let initialPowerUpDelay: TimeInterval = 8.2
    static let minimumObstacleGap: CGFloat = 245
    static let playerCollisionRadius: CGFloat = 35
    static let maximumRushCharge: CGFloat = 100
    static let starRushDuration: TimeInterval = 2.65
    static let flowComboWindow: TimeInterval = 2.4
}
