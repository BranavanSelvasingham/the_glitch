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

    var assetName: String {
        switch self {
        case .blueComet: "BlueCometBooster"
        case .jungleJet: "JungleJetBooster"
        case .candyBurst: "CandyBurstBooster"
        case .royalRocket: "RoyalRocketBooster"
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
            selectedBooster(in: .standard)
        }
        set {
            setSelectedBooster(newValue, in: .standard)
        }
    }

    static func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        isAchievementUnlocked(achievement, in: .standard)
    }

    @discardableResult
    static func unlock(_ achievement: Achievement) -> Bool {
        unlock(achievement, in: .standard)
    }

    static var unlockedAchievementCount: Int {
        Achievement.allCases.filter(isAchievementUnlocked).count
    }

    static var dailyProgress: Int {
        dailyProgress(in: .standard)
    }

    static func addDailyChip() -> (progress: Int, completedNow: Bool) {
        addDailyChip(in: .standard)
    }

    static func selectedBooster(in defaults: UserDefaults) -> BoosterStyle {
        BoosterStyle(rawValue: defaults.integer(forKey: selectedBoosterKey)) ?? .blueComet
    }

    static func setSelectedBooster(_ booster: BoosterStyle, in defaults: UserDefaults) {
        defaults.set(booster.rawValue, forKey: selectedBoosterKey)
    }

    static func isAchievementUnlocked(
        _ achievement: Achievement,
        in defaults: UserDefaults
    ) -> Bool {
        defaults.bool(forKey: achievementKey(achievement))
    }

    @discardableResult
    static func unlock(_ achievement: Achievement, in defaults: UserDefaults) -> Bool {
        guard !isAchievementUnlocked(achievement, in: defaults) else { return false }
        defaults.set(true, forKey: achievementKey(achievement))
        return true
    }

    static func unlockedAchievementCount(in defaults: UserDefaults) -> Int {
        Achievement.allCases.filter { isAchievementUnlocked($0, in: defaults) }.count
    }

    static func dailyProgress(
        in defaults: UserDefaults,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        prepareDailyState(in: defaults, now: now, calendar: calendar)
        return defaults.integer(forKey: dailyProgressKey)
    }

    static func addDailyChip(
        in defaults: UserDefaults,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> (progress: Int, completedNow: Bool) {
        prepareDailyState(in: defaults, now: now, calendar: calendar)
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

    private static func prepareDailyState(
        in defaults: UserDefaults,
        now: Date,
        calendar: Calendar
    ) {
        let today = dayIdentifier(for: now, calendar: calendar)
        guard defaults.string(forKey: dailyDateKey) != today else { return }
        defaults.set(today, forKey: dailyDateKey)
        defaults.set(0, forKey: dailyProgressKey)
        defaults.set(false, forKey: dailyRewardKey)
    }

    private static func dayIdentifier(for date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }
}

enum GameSaveStore {
    static var bestScore: Int {
        get { bestScore(in: .standard) }
        set { setBestScore(newValue, in: .standard) }
    }

    static var lifetimeChips: Int {
        get { lifetimeChips(in: .standard) }
        set { setLifetimeChips(newValue, in: .standard) }
    }

    static func bestScore(in defaults: UserDefaults) -> Int {
        max(0, defaults.integer(forKey: GameConstants.bestScoreKey))
    }

    static func setBestScore(_ value: Int, in defaults: UserDefaults) {
        defaults.set(max(0, value), forKey: GameConstants.bestScoreKey)
    }

    static func lifetimeChips(in defaults: UserDefaults) -> Int {
        max(0, defaults.integer(forKey: GameConstants.lifetimeChipsKey))
    }

    static func setLifetimeChips(_ value: Int, in defaults: UserDefaults) {
        defaults.set(max(0, value), forKey: GameConstants.lifetimeChipsKey)
    }
}

#if DEBUG
struct PersistenceDiagnosticResult {
    let passed: Bool
    let checks: [String]
    let failures: [String]
}

enum PersistenceDiagnostics {
    static func run() -> PersistenceDiagnosticResult {
        let suiteName = "AidanGameRush.PersistenceDiagnostics.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return PersistenceDiagnosticResult(
                passed: false,
                checks: [],
                failures: ["Could not create isolated save store"]
            )
        }
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        var checks: [String] = []
        var failures: [String] = []

        func expect(_ condition: @autoclosure () -> Bool, _ name: String) {
            if condition() {
                checks.append(name)
            } else {
                failures.append(name)
            }
        }

        expect(GameSaveStore.bestScore(in: defaults) == 0, "Clean save defaults")
        GameSaveStore.setBestScore(1_275, in: defaults)
        GameSaveStore.setLifetimeChips(83, in: defaults)
        expect(GameSaveStore.bestScore(in: defaults) == 1_275, "Best score round-trip")
        expect(GameSaveStore.lifetimeChips(in: defaults) == 83, "Chip total round-trip")

        expect(ProgressStore.selectedBooster(in: defaults) == .blueComet, "Default booster")
        ProgressStore.setSelectedBooster(.royalRocket, in: defaults)
        expect(ProgressStore.selectedBooster(in: defaults) == .royalRocket, "Gear selection round-trip")

        expect(
            ProgressStore.unlockedAchievementCount(in: defaults) == 0,
            "Clean achievement defaults"
        )
        expect(ProgressStore.unlock(.firstFlight, in: defaults), "Achievement unlock")
        expect(!ProgressStore.unlock(.firstFlight, in: defaults), "Duplicate unlock blocked")
        expect(
            ProgressStore.unlockedAchievementCount(in: defaults) == 1,
            "Achievement count round-trip"
        )

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let dayOne = calendar.date(from: DateComponents(year: 2026, month: 8, day: 1)) ?? Date()
        let dayTwo = calendar.date(byAdding: .day, value: 1, to: dayOne) ?? dayOne

        expect(
            ProgressStore.dailyProgress(in: defaults, now: dayOne, calendar: calendar) == 0,
            "Daily quest starts clean"
        )
        var completionCount = 0
        for _ in 0..<ProgressStore.dailyTarget {
            let result = ProgressStore.addDailyChip(in: defaults, now: dayOne, calendar: calendar)
            completionCount += result.completedNow ? 1 : 0
        }
        let capped = ProgressStore.addDailyChip(in: defaults, now: dayOne, calendar: calendar)
        expect(capped.progress == ProgressStore.dailyTarget, "Daily quest caps at target")
        expect(completionCount == 1 && !capped.completedNow, "Daily reward granted once")
        expect(
            ProgressStore.dailyProgress(in: defaults, now: dayTwo, calendar: calendar) == 0,
            "Daily quest resets next day"
        )

        return PersistenceDiagnosticResult(
            passed: failures.isEmpty,
            checks: checks,
            failures: failures
        )
    }
}
#endif
