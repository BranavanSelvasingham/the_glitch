import UIKit

enum BoosterStyle: Int, CaseIterable {
    case blueComet
    case jungleJet
    case candyBurst
    case royalRocket

    var name: String {
        switch self {
        case .blueComet: "BLUE COMET"
        case .jungleJet: "JUNGLE JET"
        case .candyBurst: "CANDY BURST"
        case .royalRocket: "ROYAL ROCKET"
        }
    }

    var unlockCost: Int {
        switch self {
        case .blueComet: 0
        case .jungleJet: 20
        case .candyBurst: 50
        case .royalRocket: 100
        }
    }

    var bodyColor: UIColor {
        switch self {
        case .blueComet: UIColor(red: 0.42, green: 0.20, blue: 0.84, alpha: 1)
        case .jungleJet: UIColor(red: 0.12, green: 0.55, blue: 0.24, alpha: 1)
        case .candyBurst: UIColor(red: 0.96, green: 0.20, blue: 0.56, alpha: 1)
        case .royalRocket: UIColor(red: 0.28, green: 0.18, blue: 0.58, alpha: 1)
        }
    }

    var trailColor: UIColor {
        switch self {
        case .blueComet: UIColor(red: 0.10, green: 0.92, blue: 1, alpha: 1)
        case .jungleJet: UIColor(red: 0.72, green: 0.94, blue: 0.28, alpha: 1)
        case .candyBurst: UIColor(red: 0.30, green: 0.94, blue: 0.92, alpha: 1)
        case .royalRocket: UIColor(red: 1, green: 0.76, blue: 0.20, alpha: 1)
        }
    }
}

enum Achievement: String, CaseIterable {
    case firstFlight
    case chipCollector
    case worldTraveler
    case highFlyer
    case glitchBuster

    var title: String {
        switch self {
        case .firstFlight: "FIRST FLIGHT"
        case .chipCollector: "CHIP COLLECTOR"
        case .worldTraveler: "WORLD TRAVELER"
        case .highFlyer: "HIGH FLYER"
        case .glitchBuster: "GLITCH BUSTER"
        }
    }

    var description: String {
        switch self {
        case .firstFlight: "Begin Aidan's adventure"
        case .chipCollector: "Save 25 Spark Chips"
        case .worldTraveler: "Reach all four worlds"
        case .highFlyer: "Score 750 points"
        case .glitchBuster: "Defeat The Glitch boss"
        }
    }
}

enum ProgressStore {
    private static let selectedBoosterKey = "AidanGameRush.selectedBooster"
    private static let dailyDateKey = "AidanGameRush.dailyDate"
    private static let dailyProgressKey = "AidanGameRush.dailyProgress"
    private static let dailyRewardKey = "AidanGameRush.dailyRewardClaimed"

    static let dailyTarget = 15

    static var selectedBooster: BoosterStyle {
        get {
            BoosterStyle(
                rawValue: UserDefaults.standard.integer(forKey: selectedBoosterKey)
            ) ?? .blueComet
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: selectedBoosterKey)
        }
    }

    static func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        UserDefaults.standard.bool(forKey: achievementKey(achievement))
    }

    @discardableResult
    static func unlock(_ achievement: Achievement) -> Bool {
        guard !isAchievementUnlocked(achievement) else { return false }
        UserDefaults.standard.set(true, forKey: achievementKey(achievement))
        return true
    }

    static var unlockedAchievementCount: Int {
        Achievement.allCases.filter(isAchievementUnlocked).count
    }

    static var dailyProgress: Int {
        prepareDailyState()
        return UserDefaults.standard.integer(forKey: dailyProgressKey)
    }

    static func addDailyChip() -> (progress: Int, completedNow: Bool) {
        prepareDailyState()
        let defaults = UserDefaults.standard
        let oldProgress = defaults.integer(forKey: dailyProgressKey)
        let newProgress = min(dailyTarget, oldProgress + 1)
        defaults.set(newProgress, forKey: dailyProgressKey)

        let completedNow = newProgress >= dailyTarget && !defaults.bool(forKey: dailyRewardKey)
        if completedNow {
            defaults.set(true, forKey: dailyRewardKey)
        }
        return (newProgress, completedNow)
    }

    private static func achievementKey(_ achievement: Achievement) -> String {
        "AidanGameRush.achievement.\(achievement.rawValue)"
    }

    private static func prepareDailyState() {
        let defaults = UserDefaults.standard
        let today = dayIdentifier()
        guard defaults.string(forKey: dailyDateKey) != today else { return }
        defaults.set(today, forKey: dailyDateKey)
        defaults.set(0, forKey: dailyProgressKey)
        defaults.set(false, forKey: dailyRewardKey)
    }

    private static func dayIdentifier() -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }
}

