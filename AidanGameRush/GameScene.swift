import SpriteKit
import UIKit
import Darwin

final class GameScene: SKScene, @MainActor SKPhysicsContactDelegate {
    private let backgroundLayer = SKNode()
    private let gameplayLayer = SKNode()
    private let hudLayer = SKNode()
    private let screenOverlay = SKNode()

    private let player = WorldArt.makePlayer()
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let chipLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let worldLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let powerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let scoreHUDPanel = SKShapeNode(rectOf: CGSize(width: 245, height: 92), cornerRadius: 24)
    private let worldHUDPanel = SKShapeNode(rectOf: CGSize(width: 360, height: 88), cornerRadius: 24)
    private let pauseButton = SKShapeNode()
    private let soundButton = SKShapeNode()
    private let menuSoundButton = SKShapeNode()
    private let gearButton = SKShapeNode()
    private let gearBackButton = SKShapeNode()

    private var phase: GamePhase = .title
    private var currentWorld: WorldTheme = .cloudKingdom
    private var selectedBooster = ProgressStore.selectedBooster
    private var gearCardFrames: [BoosterStyle: CGRect] = [:]
    private var backgroundRoot: SKNode?
    private var backgroundTiles: [SKNode] = []
    private var worldBackgrounds: [WorldTheme: SKNode] = [:]
    private var worldBackgroundSize = CGSize.zero

    private var lastUpdateTime: TimeInterval = 0
    private var runTime: TimeInterval = 0
    private var verticalVelocity: CGFloat = 0
    private var scoreValue: CGFloat = 0
    private var runChips = 0
    private var bestScore = GameSaveStore.bestScore
    private var lifetimeChips = GameSaveStore.lifetimeChips
    private var worldStage = 0

    private var obstacleTimer: TimeInterval = 0
    private var enemyTimer: TimeInterval = 0
    private var fallingHazardTimer: TimeInterval = 0
    private var powerUpTimer: TimeInterval = 0
    private var shieldTime: TimeInterval = 0
    private var magnetTime: TimeInterval = 0
    private var invulnerabilityTime: TimeInterval = 0
    private var bossFightActive = false
    private var bossHealth = 0
    private var bossShotTimer: TimeInterval = 0
    private var heroShotTimer: TimeInterval = 0
    private var bossNode: SKNode?
    private var boostTrailTimer: TimeInterval = 0
    private var hazardSeparationTimer: TimeInterval = 0
    private var nearMissStreak = 0
    private var gameOverReady = false

    private var isBoosting = false
    private var hasBuiltScene = false
    private let demoMode = ProcessInfo.processInfo.arguments.contains("--demo-mode")
    private let gearPreviewMode = ProcessInfo.processInfo.arguments.contains("--gear-preview")
    private let bossPreviewMode = ProcessInfo.processInfo.arguments.contains("--boss-preview")
    private let crashPreviewMode = ProcessInfo.processInfo.arguments.contains("--crash-preview")
    private let pausePreviewMode = ProcessInfo.processInfo.arguments.contains("--pause-preview")
    private let enemyShowcaseMode = ProcessInfo.processInfo.arguments.contains("--enemy-showcase")
    private let nearMissShowcaseMode = ProcessInfo.processInfo.arguments.contains("--near-miss-showcase")
    private let persistenceDiagnosticMode = ProcessInfo.processInfo.arguments.contains(
        "--persistence-self-test"
    )
    private let performanceDiagnosticMode = ProcessInfo.processInfo.arguments.contains(
        "--performance-probe"
    )
    private let gameplayQualityDiagnosticMode = ProcessInfo.processInfo.arguments.contains(
        "--gameplay-quality-probe"
    )
    private let audioQualityDiagnosticMode = ProcessInfo.processInfo.arguments.contains(
        "--audio-quality-probe"
    )

    #if DEBUG
    private var performanceProbeStartTime: TimeInterval?
    private var performanceProbeLastFrameTime: TimeInterval?
    private var performanceFrameIntervals: [TimeInterval] = []
    private var performanceLaunchSeconds: TimeInterval = 0
    private var performanceProbeFinished = false
    private var qualityProbeStartTime: TimeInterval?
    private var qualityProbeFirstChipSeconds: TimeInterval?
    private var qualityProbeFirstPowerUpSeconds: TimeInterval?
    private var qualityProbeInputRequestTime: TimeInterval?
    private var qualityProbeInputResponseMS: Double?
    private var qualityProbeRestartRequestTime: TimeInterval?
    private var qualityProbeRestartResponseMS: Double?
    private var qualityProbeDidScheduleInput = false
    private var qualityProbeDidTriggerCrash = false
    private var qualityProbeDidRestart = false
    private var qualityProbeFinished = false
    #endif

    private let baseScrollSpeed: CGFloat = 235
    private let riseAcceleration: CGFloat = 1_260
    private let fallAcceleration: CGFloat = -920
    private let maximumRiseSpeed: CGFloat = 530
    private let maximumFallSpeed: CGFloat = -560

    override func didMove(to view: SKView) {
        guard !hasBuiltScene else { return }
        hasBuiltScene = true

        backgroundColor = currentWorld.skyColor
        anchorPoint = .zero
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        backgroundLayer.zPosition = -100
        gameplayLayer.zPosition = 0
        hudLayer.zPosition = 50
        screenOverlay.zPosition = 100
        addChild(backgroundLayer)
        addChild(gameplayLayer)
        addChild(hudLayer)
        addChild(screenOverlay)

        gameplayLayer.addChild(player)
        configurePlayerDynamics()
        WorldArt.applyBoosterStyle(selectedBooster, to: player)
        buildHUD()
        setWorld(.cloudKingdom, announce: false)
        showTitleScreen()
        layoutScene()

        #if DEBUG
        if persistenceDiagnosticMode {
            showPersistenceDiagnosticScreen()
            return
        }
        if audioQualityDiagnosticMode {
            showAudioQualityDiagnosticScreen()
            return
        }
        #endif

        if gearPreviewMode {
            run(.sequence([
                .wait(forDuration: 0.25),
                .run { [weak self] in self?.showGearScreen() }
            ]))
        } else if let storyPage = requestedStoryPreview {
            run(.sequence([
                .wait(forDuration: 0.25),
                .run { [weak self] in self?.showStoryPage(storyPage) }
            ]))
        } else if demoMode {
            run(.sequence([
                .wait(forDuration: 0.5),
                .run { [weak self] in self?.startRun() }
            ]))
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard hasBuiltScene, size.width > 0, size.height > 0 else { return }
        setWorld(currentWorld, announce: false)
        layoutScene()

        switch phase {
        case .title:
            showTitleScreen()
        case .story(let page):
            showStoryPage(page)
        case .gear:
            showGearScreen()
        case .paused:
            showPauseOverlay()
        case .gameOver:
            if gameOverReady {
                showGameOverScreen()
            }
        case .playing:
            break
        }
    }

    private var lowerFlightLimit: CGFloat { max(92, size.height * 0.18) }
    private var upperFlightLimit: CGFloat { size.height - max(82, size.height * 0.08) }
    private var currentScrollSpeed: CGFloat {
        baseScrollSpeed + min(125, CGFloat(runTime) * 1.15)
    }
    private var activeWorldDuration: TimeInterval {
        demoMode ? 5 : GameConstants.worldDuration
    }
    private var requestedDemoWorld: Int {
        guard
            let argument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--demo-world=") }),
            let value = Int(argument.replacingOccurrences(of: "--demo-world=", with: ""))
        else {
            return 0
        }
        return max(0, min(WorldTheme.allCases.count - 1, value))
    }
    private var locksRequestedDemoWorld: Bool {
        demoMode && ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("--demo-world=") })
    }
    private var requestedStoryPreview: Int? {
        guard
            let argument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--story-page=") }),
            let value = Int(argument.replacingOccurrences(of: "--story-page=", with: ""))
        else {
            return nil
        }
        return max(0, min(2, value))
    }

    // MARK: - Screens

    #if DEBUG
    private func showAudioQualityDiagnosticScreen() {
        let result = GameAudio.shared.runQualityDiagnostic()
        phase = .title
        screenOverlay.removeAllChildren()
        hudLayer.isHidden = true
        player.isHidden = true

        let backdrop = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backdrop.fillColor = UIColor(red: 0.05, green: 0.09, blue: 0.17, alpha: 0.96)
        backdrop.strokeColor = .clear
        screenOverlay.addChild(backdrop)

        let title = makeLabel(
            result.passed ? "AUDIO PROBE: PASS" : "AUDIO PROBE: NEEDS WORK",
            size: min(46, size.height * 0.085),
            color: result.passed ? .systemGreen : .systemYellow
        )
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        screenOverlay.addChild(title)

        let subtitle = makeLabel(
            "LIVE BUFFER • SCHEDULING • PEAK • MUTE • SESSION CHECKS",
            size: min(20, size.height * 0.038),
            color: .white
        )
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        screenOverlay.addChild(subtitle)

        let rows = [
            "ACTION SOUND COVERAGE     \(result.effectCoverage) / \(GameAudio.Effect.allCases.count)   (TARGET ALL)",
            "MUSIC THEME COVERAGE      \(result.themeCoverage) / \(GameAudio.MusicTheme.allCases.count)   (TARGET ALL)",
            String(format: "MAX EFFECT SCHEDULE       %.2f ms  (TARGET ≤16.7 ms)", result.maximumEffectScheduleMS),
            String(format: "MAX MUSIC SWITCH          %.2f ms  (TARGET ≤16.7 ms)", result.maximumMusicScheduleMS),
            String(format: "MAX EFFECT PEAK           %.3f    (TARGET <0.920)", result.maximumEffectPeak),
            String(format: "MAX MUSIC PEAK            %.3f    (TARGET <0.920)", result.maximumMusicPeak),
            "MUTE + VOLUME RESTORE     \(result.muteRoundTripPassed ? "PASS" : "FAIL")",
            "AMBIENT MIXING SESSION    \(result.ambientSessionPassed ? "PASS" : "FAIL")"
        ]
        for (index, row) in rows.enumerated() {
            let label = makeLabel(row, size: min(18, size.height * 0.034), color: .white)
            label.fontName = "Menlo-Bold"
            label.position = CGPoint(
                x: size.width / 2,
                y: size.height * 0.61 - CGFloat(index) * min(39, size.height * 0.060)
            )
            screenOverlay.addChild(label)
        }

        let caveat = makeLabel(
            "IMPLEMENTATION PASS • PHYSICAL SPEAKER + PLAYER LISTENING STILL REQUIRED",
            size: min(17, size.height * 0.032),
            color: .systemYellow
        )
        caveat.position = CGPoint(x: size.width / 2, y: size.height * 0.10)
        screenOverlay.addChild(caveat)

        print(String(
            format: "AUDIO_QUALITY_PROBE %@ effects=%d themes=%d effectMS=%.2f musicMS=%.2f effectPeak=%.3f musicPeak=%.3f mute=%@ session=%@",
            result.passed ? "PASS" : "FAIL",
            result.effectCoverage,
            result.themeCoverage,
            result.maximumEffectScheduleMS,
            result.maximumMusicScheduleMS,
            result.maximumEffectPeak,
            result.maximumMusicPeak,
            result.muteRoundTripPassed ? "PASS" : "FAIL",
            result.ambientSessionPassed ? "PASS" : "FAIL"
        ))
    }

    private func showPersistenceDiagnosticScreen() {
        let result = PersistenceDiagnostics.run()
        func addDiagnosticLabel(
            _ text: String,
            font: String,
            size: CGFloat,
            color: UIColor,
            at position: CGPoint
        ) {
            let label = makeLabel(text, size: size, color: color)
            label.fontName = font
            label.position = position
            screenOverlay.addChild(label)
        }

        phase = .title
        screenOverlay.removeAllChildren()
        hudLayer.isHidden = true
        player.isHidden = true

        let backdrop = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backdrop.fillColor = UIColor(red: 0.06, green: 0.10, blue: 0.19, alpha: 0.95)
        backdrop.strokeColor = .clear
        screenOverlay.addChild(backdrop)

        addDiagnosticLabel(
            result.passed ? "SAVE SYSTEM: PASS" : "SAVE SYSTEM: NEEDS ATTENTION",
            font: "AvenirNext-Heavy",
            size: min(46, size.height * 0.085),
            color: result.passed ? .systemGreen : .systemRed,
            at: CGPoint(x: size.width / 2, y: size.height * 0.80)
        )

        let summary = result.passed
            ? "\(result.checks.count) CHECKS PASSED • REAL SAVE DATA UNTOUCHED"
            : "\(result.failures.count) CHECKS FAILED • REAL SAVE DATA UNTOUCHED"
        addDiagnosticLabel(
            summary,
            font: "AvenirNext-Bold",
            size: min(22, size.height * 0.04),
            color: .white,
            at: CGPoint(x: size.width / 2, y: size.height * 0.70)
        )

        let rows = result.passed ? result.checks : result.failures
        for (index, check) in rows.prefix(13).enumerated() {
            addDiagnosticLabel(
                "\(result.passed ? "✓" : "!")  \(check)",
                font: "AvenirNext-DemiBold",
                size: min(19, size.height * 0.034),
                color: result.passed ? UIColor(white: 0.90, alpha: 1) : .systemYellow,
                at: CGPoint(
                    x: size.width / 2,
                    y: size.height * 0.61 - CGFloat(index) * min(28, size.height * 0.043)
                )
            )
        }

        let status = result.passed ? "PASS" : "FAIL: \(result.failures.joined(separator: ", "))"
        print("PERSISTENCE_SELF_TEST \(status)")
    }
    #endif

    private func showTitleScreen() {
        phase = .title
        screenOverlay.removeAllChildren()
        hudLayer.isHidden = true
        gameplayLayer.isPaused = false
        player.isHidden = true
        player.removeAllActions()

        let artSize = min(390, size.height * 0.62)
        let artFrame = SKShapeNode(
            rectOf: CGSize(width: artSize + 12, height: artSize + 12),
            cornerRadius: 30
        )
        artFrame.position = CGPoint(x: size.width * 0.23, y: size.height * 0.52)
        artFrame.fillColor = UIColor.white.withAlphaComponent(0.94)
        artFrame.strokeColor = UIColor(red: 1, green: 0.83, blue: 0.20, alpha: 1)
        artFrame.lineWidth = 5
        screenOverlay.addChild(artFrame)

        let keyArt = SKSpriteNode(imageNamed: "KeyArt")
        keyArt.size = CGSize(width: artSize, height: artSize)
        artFrame.addChild(keyArt)

        let rightColumnX = size.width * 0.66

        let title = makeLabel("AIDAN'S WORLD RUSH", size: 44, color: .white)
        title.position = CGPoint(x: rightColumnX, y: size.height * 0.77)
        screenOverlay.addChild(title)

        let subtitle = makeLabel(
            "THE GLITCH IS STEALING EVERY WORLD'S SPARK!",
            size: 21,
            color: UIColor(red: 1, green: 0.86, blue: 0.20, alpha: 1)
        )
        subtitle.position = CGPoint(x: rightColumnX, y: size.height * 0.69)
        screenOverlay.addChild(subtitle)

        let worlds = SKNode()
        worlds.position = CGPoint(x: rightColumnX, y: size.height * 0.48)
        for (index, world) in WorldTheme.allCases.enumerated() {
            let badge = WorldArt.makeWorldBadge(for: world, radius: 37)
            badge.position.x = CGFloat(index - 2) * 105 + 52
            worlds.addChild(badge)
        }
        screenOverlay.addChild(worlds)

        let best = makeLabel(
            "BEST SCORE  \(String(format: "%04d", bestScore))    •    SAVED CHIPS  \(lifetimeChips)",
            size: 18,
            color: .white
        )
        best.position = CGPoint(x: rightColumnX, y: size.height * 0.34)
        screenOverlay.addChild(best)

        let daily = makeLabel(
            "DAILY QUEST  ★ \(ProgressStore.dailyProgress) / \(ProgressStore.dailyTarget)    •    BADGES \(ProgressStore.unlockedAchievementCount) / \(Achievement.allCases.count)",
            size: 15,
            color: UIColor(red: 0.12, green: 0.12, blue: 0.24, alpha: 1)
        )
        daily.position = CGPoint(x: rightColumnX, y: size.height * 0.295)
        screenOverlay.addChild(daily)

        configureButton(
            gearButton,
            text: "GEAR  •  \(selectedBooster.name)",
            width: 300,
            color: selectedBooster.trailColor
        )
        gearButton.position = CGPoint(x: rightColumnX, y: size.height * 0.235)
        screenOverlay.addChild(gearButton)

        let prompt = makePill(
            text: "TAP TO BEGIN THE STORY",
            width: 330,
            color: WorldArt.glitchPink
        )
        prompt.position = CGPoint(x: rightColumnX, y: size.height * 0.15)
        prompt.run(.repeatForever(.sequence([
            .scale(to: 1.04, duration: 0.55),
            .scale(to: 0.98, duration: 0.55)
        ])))
        screenOverlay.addChild(prompt)

        addMenuSoundButton(at: CGPoint(x: 96, y: 52))
        GameAudio.shared.playMusic(.title)
    }

    private func showGearScreen() {
        phase = .gear
        screenOverlay.removeAllChildren()
        hudLayer.isHidden = true
        player.isHidden = true
        gearCardFrames.removeAll()

        let shade = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        shade.fillColor = UIColor(red: 0.05, green: 0.04, blue: 0.14, alpha: 0.90)
        shade.strokeColor = .clear
        screenOverlay.addChild(shade)

        let title = makeLabel("AIDAN'S BOOSTER GARAGE", size: 38, color: .white)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.83)
        screenOverlay.addChild(title)

        let subtitle = makeLabel(
            "Spark Chips permanently unlock new booster colors",
            size: 18,
            color: UIColor(red: 1, green: 0.86, blue: 0.20, alpha: 1)
        )
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.77)
        screenOverlay.addChild(subtitle)

        let spacing = min(235, size.width * 0.205)
        let cardCenterY = size.height * 0.52
        for (index, style) in BoosterStyle.allCases.enumerated() {
            let centerX = size.width / 2 + (CGFloat(index) - 1.5) * spacing
            let cardSize = CGSize(width: 205, height: 270)
            gearCardFrames[style] = CGRect(
                x: centerX - cardSize.width / 2,
                y: cardCenterY - cardSize.height / 2,
                width: cardSize.width,
                height: cardSize.height
            )

            let unlocked = lifetimeChips >= style.unlockCost
            let selected = selectedBooster == style
            let card = SKShapeNode(rectOf: cardSize, cornerRadius: 24)
            card.position = CGPoint(x: centerX, y: cardCenterY)
            card.fillColor = unlocked
                ? UIColor.white.withAlphaComponent(0.97)
                : UIColor(red: 0.16, green: 0.14, blue: 0.24, alpha: 0.98)
            card.strokeColor = selected ? style.trailColor : UIColor.white.withAlphaComponent(0.48)
            card.lineWidth = selected ? 7 : 3
            screenOverlay.addChild(card)

            if selected {
                let halo = SKShapeNode(ellipseOf: CGSize(width: 126, height: 146))
                halo.position.y = 44
                halo.fillColor = style.trailColor.withAlphaComponent(0.13)
                halo.strokeColor = style.trailColor.withAlphaComponent(0.72)
                halo.lineWidth = 3
                halo.glowWidth = 7
                card.addChild(halo)
            }

            let texture = SKTexture(imageNamed: style.assetName)
            texture.filteringMode = .linear
            let booster = SKSpriteNode(texture: texture)
            booster.name = "gearBooster"
            booster.position.y = 45
            booster.size = CGSize(width: 94, height: 141)
            if !unlocked {
                booster.color = UIColor(white: 0.22, alpha: 1)
                booster.colorBlendFactor = 0.86
                booster.alpha = 0.68
            }
            booster.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: 2.5, duration: 0.75 + Double(index) * 0.04),
                .moveBy(x: 0, y: -2.5, duration: 0.75 + Double(index) * 0.04)
            ])))
            card.addChild(booster)

            let name = makeLabel(style.name, size: 16, color: unlocked ? WorldArt.ink : .white)
            name.position.y = -57
            card.addChild(name)

            let statusText: String
            if selected {
                statusText = "EQUIPPED"
            } else if unlocked {
                statusText = "TAP TO EQUIP"
            } else {
                statusText = "UNLOCKS AT ★ \(style.unlockCost)"
            }
            let status = makeLabel(
                statusText,
                size: 13,
                color: selected ? style.bodyColor : (unlocked ? UIColor.darkGray : style.trailColor)
            )
            status.position.y = -94
            card.addChild(status)
        }

        let unlockedBadges = Achievement.allCases
            .filter(ProgressStore.isAchievementUnlocked)
            .map(\.title)
        let badgeText = unlockedBadges.isEmpty
            ? "BADGES: Begin your first flight to earn one"
            : "BADGES: " + unlockedBadges.joined(separator: "  •  ")
        let badges = makeLabel(badgeText, size: 14, color: .white)
        badges.position = CGPoint(x: size.width / 2, y: size.height * 0.24)
        screenOverlay.addChild(badges)

        configureButton(
            gearBackButton,
            text: "BACK TO ADVENTURE",
            width: 270,
            color: UIColor(red: 1, green: 0.78, blue: 0.20, alpha: 1)
        )
        gearBackButton.position = CGPoint(x: size.width / 2, y: size.height * 0.14)
        screenOverlay.addChild(gearBackButton)
        addMenuSoundButton(at: CGPoint(x: 96, y: 52))
    }

    private func showStoryPage(_ page: Int) {
        phase = .story(page: page)
        screenOverlay.removeAllChildren()
        hudLayer.isHidden = true
        player.isHidden = true

        let shade = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        shade.fillColor = UIColor(red: 0.04, green: 0.03, blue: 0.12, alpha: 0.58)
        shade.strokeColor = .clear
        screenOverlay.addChild(shade)

        let panel = SKShapeNode(
            rectOf: CGSize(width: min(760, size.width * 0.74), height: min(410, size.height * 0.66)),
            cornerRadius: 30
        )
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = UIColor(red: 0.98, green: 0.96, blue: 0.88, alpha: 0.98)
        panel.strokeColor = currentWorld.accentColor
        panel.lineWidth = 6
        screenOverlay.addChild(panel)

        let chapter = makeLabel("STORY  \(page + 1) / 3", size: 15, color: UIColor.darkGray)
        chapter.position = CGPoint(x: 0, y: panel.frame.height * 0.37)
        panel.addChild(chapter)

        let title: String
        let body: String
        switch page {
        case 0:
            title = "THE BOOSTER CHOOSES AIDAN"
            body = "After bedtime, a tiny world gate opens in Aidan's room.\nA brave booster pack zooms out and asks for his help."
            let miniAidan = WorldArt.makePlayer()
            miniAidan.physicsBody = nil
            miniAidan.position = CGPoint(x: -panel.frame.width * 0.31, y: -10)
            miniAidan.setScale(1.15)
            panel.addChild(miniAidan)
        case 1:
            title = "THE GLITCH BREAKS THE GATES"
            body = "A sneaky shadow called The Glitch has mixed up four wonderful worlds.\nIts bug-beasts are stealing every world's golden Spark Chips."
            let villain = WorldArt.makeGlitchEnemy()
            villain.physicsBody = nil
            villain.position = CGPoint(x: -panel.frame.width * 0.31, y: -8)
            villain.setScale(1.3)
            panel.addChild(villain)
        default:
            title = "RACE, RESCUE, RESTORE!"
            body = "Hold to boost up. Release to glide down.\nGather chips, use shields and magnets, and outrun The Glitch!"
            let chip = WorldArt.makeChip()
            chip.physicsBody = nil
            chip.position = CGPoint(x: -panel.frame.width * 0.31, y: 25)
            chip.setScale(1.5)
            panel.addChild(chip)
            let shield = WorldArt.makePowerUp(.shield)
            shield.physicsBody = nil
            shield.position = CGPoint(x: -panel.frame.width * 0.36, y: -72)
            panel.addChild(shield)
            let magnet = WorldArt.makePowerUp(.magnet)
            magnet.physicsBody = nil
            magnet.position = CGPoint(x: -panel.frame.width * 0.25, y: -72)
            panel.addChild(magnet)
        }

        let titleLabel = makeLabel(title, size: 30, color: WorldArt.ink)
        titleLabel.position = CGPoint(x: panel.frame.width * 0.12, y: 90)
        panel.addChild(titleLabel)

        let bodyLabel = makeMultilineLabel(
            body,
            size: 19,
            color: UIColor(red: 0.16, green: 0.14, blue: 0.24, alpha: 1),
            width: panel.frame.width * 0.53
        )
        bodyLabel.position = CGPoint(x: panel.frame.width * 0.12, y: -10)
        panel.addChild(bodyLabel)

        let promptText = page == 2 ? "TAP TO FLY!" : "TAP FOR NEXT"
        let prompt = makePill(text: promptText, width: 220, color: currentWorld.accentColor)
        prompt.position = CGPoint(x: panel.frame.width * 0.12, y: -panel.frame.height * 0.34)
        panel.addChild(prompt)
        addMenuSoundButton(at: CGPoint(x: 96, y: 52))
    }

    private func showPauseOverlay() {
        screenOverlay.removeAllChildren()

        let shade = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        shade.fillColor = UIColor.black.withAlphaComponent(0.62)
        shade.strokeColor = .clear
        screenOverlay.addChild(shade)

        let panel = SKShapeNode(rectOf: CGSize(width: 420, height: 245), cornerRadius: 28)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = UIColor(red: 0.08, green: 0.06, blue: 0.18, alpha: 0.98)
        panel.strokeColor = currentWorld.accentColor
        panel.lineWidth = 5
        screenOverlay.addChild(panel)

        let title = makeLabel("ADVENTURE PAUSED", size: 30, color: .white)
        title.position.y = 40
        panel.addChild(title)

        let world = makeLabel(currentWorld.name, size: 17, color: currentWorld.accentColor)
        world.position.y = 0
        panel.addChild(world)

        let prompt = makeLabel("Tap pause to keep flying", size: 16, color: .white)
        prompt.position.y = -37
        panel.addChild(prompt)

    }

    private func showGameOverScreen() {
        screenOverlay.removeAllChildren()
        hudLayer.isHidden = true

        let shade = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        shade.fillColor = UIColor.black.withAlphaComponent(0.67)
        shade.strokeColor = .clear
        screenOverlay.addChild(shade)

        let panel = SKShapeNode(rectOf: CGSize(width: 500, height: 350), cornerRadius: 30)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = UIColor(red: 0.98, green: 0.96, blue: 0.88, alpha: 0.99)
        panel.strokeColor = WorldArt.glitchPink
        panel.lineWidth = 6
        panel.alpha = 0
        panel.setScale(0.78)
        screenOverlay.addChild(panel)

        let villain = WorldArt.makeGlitchEnemy()
        villain.physicsBody = nil
        villain.position = CGPoint(x: -185, y: 98)
        villain.setScale(0.82)
        panel.addChild(villain)

        let title = makeLabel("THE GLITCH GOT YOU!", size: 32, color: WorldArt.ink)
        title.position = CGPoint(x: 35, y: 108)
        panel.addChild(title)

        let score = Int(scoreValue)
        let scoreText = makeLabel("SCORE  \(score)", size: 29, color: WorldArt.glitchPink)
        scoreText.position.y = 42
        panel.addChild(scoreText)

        let results = makeLabel(
            "BEST  \(bestScore)    •    CHIPS FOUND  \(runChips)",
            size: 19,
            color: UIColor.darkGray
        )
        results.position.y = -4
        panel.addChild(results)

        let encouragement = makeLabel(
            score == bestScore && score > 0 ? "NEW BEST! THE WORLDS ARE CHEERING!" : "AIDAN ALWAYS TRIES AGAIN!",
            size: 16,
            color: currentWorld.groundColor
        )
        encouragement.position.y = -48
        panel.addChild(encouragement)

        let prompt = makePill(text: "TAP TO FLY AGAIN", width: 270, color: currentWorld.accentColor)
        prompt.position.y = -114
        prompt.run(.repeatForever(.sequence([
            .scale(to: 1.04, duration: 0.5),
            .scale(to: 0.98, duration: 0.5)
        ])))
        panel.addChild(prompt)

        panel.run(.group([
            .fadeIn(withDuration: 0.22),
            .scale(to: 1, duration: 0.30)
        ]))
    }

    // MARK: - Game lifecycle

    private func startRun() {
        phase = .playing
        screenOverlay.removeAllChildren()
        hudLayer.isHidden = false
        gameplayLayer.isPaused = false
        player.removeAllActions()
        player.isHidden = false

        gameplayLayer.removeAllChildren()
        gameplayLayer.addChild(player)
        configurePlayerDynamics()
        player.position = CGPoint(x: size.width * 0.25, y: size.height * 0.56)
        player.zRotation = 0
        player.setScale(1)
        player.alpha = 1
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.childNode(withName: "shieldAura")?.isHidden = true
        player.childNode(withName: "magnetAura")?.isHidden = true
        player.childNode(withName: "//flame")?.isHidden = true
        (player.childNode(withName: "//exhaustParticles") as? SKEmitterNode)?.particleBirthRate = 0
        WorldArt.applyBoosterStyle(selectedBooster, to: player)

        let startingWorld = demoMode ? requestedDemoWorld : 0
        runTime = demoMode ? TimeInterval(startingWorld) * activeWorldDuration + 0.35 : 0
        verticalVelocity = 0
        scoreValue = 0
        runChips = 0
        worldStage = startingWorld
        let isolatesEnemyFeedback = enemyShowcaseMode || nearMissShowcaseMode
        obstacleTimer = isolatesEnemyFeedback ? 999 : GameConstants.initialObstacleDelay
        enemyTimer = nearMissShowcaseMode ? 999 : (enemyShowcaseMode ? 0.45 : 4.2)
        fallingHazardTimer = isolatesEnemyFeedback ? 999 : 6.3
        powerUpTimer = isolatesEnemyFeedback ? 999 : GameConstants.initialPowerUpDelay
        shieldTime = demoMode && !isolatesEnemyFeedback ? 999 : 0
        magnetTime = demoMode && !isolatesEnemyFeedback ? 999 : 0
        invulnerabilityTime = 1.4
        bossFightActive = false
        bossHealth = 0
        bossNode = nil
        boostTrailTimer = 0
        hazardSeparationTimer = 0
        nearMissStreak = 0
        gameOverReady = false
        hudLayer.childNode(withName: "bossBar")?.removeFromParent()
        isBoosting = false
        lastUpdateTime = 0

        setWorld(WorldTheme.allCases[startingWorld], announce: !isolatesEnemyFeedback)
        GameAudio.shared.playMusic(currentWorld.musicTheme)
        updateHUD()
        showToast("HOLD TO BOOST  •  RELEASE TO GLIDE", color: .white, duration: 3.2)
        ProgressStore.unlock(.firstFlight)
        GameAudio.shared.play(.begin)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        player.alpha = 0
        player.setScale(0.72)
        player.run(.group([
            .fadeIn(withDuration: 0.28),
            .scale(to: 1, duration: 0.34)
        ]))

        if nearMissShowcaseMode {
            run(.sequence([
                .wait(forDuration: 0.85),
                .run { [weak self] in self?.spawnNearMissShowcaseEnemy() }
            ]), withKey: "nearMissShowcase")
        }

        #if DEBUG
        if gameplayQualityDiagnosticMode, qualityProbeStartTime == nil {
            qualityProbeStartTime = ProcessInfo.processInfo.systemUptime
            scheduleQualityProbeInput()
        }
        #endif

        if bossPreviewMode {
            run(.sequence([
                .wait(forDuration: 1.0),
                .run { [weak self] in self?.beginBossFight() }
            ]))
        } else if crashPreviewMode {
            run(.sequence([
                .wait(forDuration: 1.8),
                .run { [weak self] in self?.endRun() }
            ]))
        } else if pausePreviewMode {
            run(.sequence([
                .wait(forDuration: 1.2),
                .run { [weak self] in self?.togglePause() }
            ]))
        }
    }

    private func endRun() {
        guard phase == .playing else { return }
        phase = .gameOver
        gameOverReady = false
        isBoosting = false
        player.childNode(withName: "//flame")?.isHidden = true
        (player.childNode(withName: "//exhaustParticles") as? SKEmitterNode)?.particleBirthRate = 0
        player.physicsBody?.categoryBitMask = 0
        player.removeAllActions()
        gameplayLayer.isPaused = false
        hudLayer.childNode(withName: "bossBar")?.removeFromParent()

        let finalScore = Int(scoreValue)
        if finalScore > bestScore {
            bestScore = finalScore
            GameSaveStore.bestScore = bestScore
        }

        GameAudio.shared.play(.crash)
        GameAudio.shared.stopMusic()
        UINotificationFeedbackGenerator().notificationOccurred(.error)

        player.run(.sequence([
            .group([
                .rotate(byAngle: -.pi * 0.72, duration: 0.58),
                .moveBy(x: -55, y: -92, duration: 0.58),
                .scale(to: 0.72, duration: 0.58),
                .fadeAlpha(to: 0.30, duration: 0.58)
            ]),
            .run { [weak self] in
                guard let self else { return }
                self.gameplayLayer.isPaused = true
                self.gameOverReady = true
                self.hudLayer.isHidden = true
                self.showGameOverScreen()
                #if DEBUG
                if self.gameplayQualityDiagnosticMode, self.qualityProbeDidTriggerCrash {
                    self.qualityProbeRestartRequestTime = ProcessInfo.processInfo.systemUptime
                    self.qualityProbeDidRestart = true
                    self.startRun()
                }
                #endif
            }
        ]))
    }

    private func togglePause() {
        switch phase {
        case .playing:
            phase = .paused
            isBoosting = false
            gameplayLayer.isPaused = true
            GameAudio.shared.pauseMusic()
            showPauseOverlay()
        case .paused:
            phase = .playing
            gameplayLayer.isPaused = false
            screenOverlay.removeAllChildren()
            GameAudio.shared.resumeMusic()
            lastUpdateTime = 0
        default:
            break
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - World progression

    private func setWorld(_ world: WorldTheme, announce: Bool) {
        currentWorld = world
        backgroundColor = world.skyColor
        prepareWorldBackgroundsIfNeeded()

        for (theme, node) in worldBackgrounds {
            let isActive = theme == world
            node.isHidden = !isActive
            node.isPaused = !isActive
        }
        guard let backdrop = worldBackgrounds[world] else { return }
        backgroundRoot = backdrop
        backgroundTiles = backdrop.children.filter { $0.name == "worldTile" }
        worldLabel.text = world.name

        if announce {
            showWorldBanner(world)
        }
    }

    private func prepareWorldBackgroundsIfNeeded() {
        guard worldBackgrounds.isEmpty || worldBackgroundSize != size else { return }

        backgroundLayer.removeAllChildren()
        worldBackgrounds.removeAll()
        worldBackgroundSize = size

        for world in WorldTheme.allCases {
            let backdrop = WorldArt.makeBackdrop(for: world, size: size)
            backdrop.isHidden = true
            backdrop.isPaused = true
            backgroundLayer.addChild(backdrop)
            worldBackgrounds[world] = backdrop
        }
    }

    private func advanceWorldIfNeeded() {
        guard !locksRequestedDemoWorld else { return }
        let newStage = Int(runTime / activeWorldDuration)
        guard newStage != worldStage else { return }

        worldStage = newStage
        let worlds = WorldTheme.allCases
        if newStage > 0, newStage.isMultiple(of: worlds.count) {
            beginBossFight()
            return
        }

        let nextWorld = worlds[newStage % worlds.count]
        scoreValue += 100
        invulnerabilityTime = 1.5

        gameplayLayer.removeAllChildren()
        gameplayLayer.addChild(player)
        configurePlayerDynamics()
        obstacleTimer = 2.1
        enemyTimer = 4.0
        fallingHazardTimer = 6.0
        setWorld(nextWorld, announce: true)
        GameAudio.shared.playMusic(nextWorld.musicTheme)
        if nextWorld == .storybookCastle {
            awardAchievement(.worldTraveler)
        }

        let flash = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.alpha = 0.75
        flash.zPosition = 80
        hudLayer.addChild(flash)
        flash.run(.sequence([.fadeOut(withDuration: 0.55), .removeFromParent()]))

        GameAudio.shared.play(.worldChange)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - Boss fight

    private func beginBossFight() {
        bossFightActive = true
        bossHealth = 12
        bossShotTimer = 1.5
        heroShotTimer = 0.9
        invulnerabilityTime = 1.8

        gameplayLayer.removeAllChildren()
        gameplayLayer.addChild(player)
        configurePlayerDynamics()

        let boss = WorldArt.makeGlitchBoss()
        boss.position = CGPoint(x: size.width + 180, y: size.height * 0.56)
        boss.zPosition = 25
        gameplayLayer.addChild(boss)
        bossNode = boss

        let entrance = SKAction.moveTo(x: size.width * 0.79, duration: 1.15)
        entrance.timingMode = .easeOut
        let attackPattern = SKAction.repeatForever(.sequence([
            .moveTo(y: upperFlightLimit - 115, duration: 1.5),
            .moveTo(y: lowerFlightLimit + 150, duration: 1.5)
        ]))
        boss.run(.sequence([entrance, attackPattern]))

        showBossBar()
        GameAudio.shared.playMusic(.boss)
        showToast("BOSS BATTLE  •  BOOSTER BLASTS READY!", color: WorldArt.glitchPink, duration: 2.3)
        GameAudio.shared.play(.worldChange)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    private func updateBossFight(deltaTime: TimeInterval) {
        guard bossFightActive, bossNode?.parent != nil else { return }
        bossShotTimer -= deltaTime
        heroShotTimer -= deltaTime

        if heroShotTimer <= 0 {
            fireHeroBolt()
            heroShotTimer = 0.62
        }
        if bossShotTimer <= 0 {
            fireBossOrb()
            bossShotTimer = max(0.82, 1.45 - runTime * 0.0015)
        }
    }

    private func fireHeroBolt() {
        guard let boss = bossNode else { return }
        let bolt = WorldArt.makeHeroBolt(color: selectedBooster.trailColor)
        bolt.position = CGPoint(x: player.position.x + 67, y: player.position.y + 2)
        bolt.zPosition = 12
        gameplayLayer.addChild(bolt)
        bolt.run(.sequence([
            .move(to: CGPoint(x: boss.position.x + 40, y: boss.position.y), duration: 0.58),
            .removeFromParent()
        ]))
    }

    private func fireBossOrb() {
        guard let boss = bossNode else { return }
        let orb = WorldArt.makeBossOrb()
        orb.position = CGPoint(
            x: boss.position.x - 95,
            y: boss.position.y + CGFloat.random(in: -70...70)
        )
        orb.zPosition = 14
        gameplayLayer.addChild(orb)
        orb.run(.sequence([
            .moveBy(
                x: -(size.width + 220),
                y: CGFloat.random(in: -140...140),
                duration: 3.25
            ),
            .removeFromParent()
        ]))
    }

    private func damageBoss(with bolt: SKNode, at point: CGPoint) {
        guard bossFightActive, bolt.parent != nil else { return }
        bolt.removeFromParent()
        bossHealth = max(0, bossHealth - 1)
        scoreValue += 35
        updateBossBar()
        makeBurst(at: point, colors: [WorldArt.glitchPink, .white], count: 9)

        bossNode?.run(.sequence([
            .fadeAlpha(to: 0.28, duration: 0.06),
            .fadeAlpha(to: 1, duration: 0.08)
        ]))
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.38)

        if bossHealth == 0 {
            defeatBoss()
        }
    }

    private func defeatBoss() {
        guard bossFightActive else { return }
        bossFightActive = false
        scoreValue += 1_000

        gameplayLayer.children
            .filter { $0.name == "hazard" || $0.name == "heroShot" }
            .forEach { $0.removeFromParent() }

        if let boss = bossNode {
            makeBurst(
                at: boss.position,
                colors: [WorldArt.glitchPink, WorldArt.glitchBlue, .white],
                count: 38
            )
            boss.physicsBody = nil
            boss.run(.sequence([
                .group([
                    .rotate(byAngle: .pi * 1.6, duration: 0.70),
                    .scale(to: 1.45, duration: 0.32),
                    .fadeOut(withDuration: 0.70)
                ]),
                .removeFromParent()
            ]))
        }
        bossNode = nil
        hudLayer.childNode(withName: "bossBar")?.removeFromParent()

        awardAchievement(.glitchBuster)
        showToast("THE GLITCH RETREATS!  +1000", color: UIColor(red: 1, green: 0.84, blue: 0.18, alpha: 1), duration: 2.6)
        GameAudio.shared.play(.powerUp)
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        if let character = player.childNode(withName: "characterArt") {
            character.removeAction(forKey: "reaction")
            character.run(.sequence([
                .group([
                    .rotate(byAngle: .pi * 2, duration: 0.62),
                    .scale(to: 1.16, duration: 0.31)
                ]),
                .group([
                    .rotate(toAngle: 0, duration: 0.16, shortestUnitArc: true),
                    .scale(to: 1, duration: 0.16)
                ])
            ]), withKey: "reaction")
        }

        runTime = TimeInterval(worldStage) * activeWorldDuration + 0.2
        invulnerabilityTime = 2.0
        obstacleTimer = 2.4
        enemyTimer = 4.5
        fallingHazardTimer = 6.2
        setWorld(.cloudKingdom, announce: true)
        GameAudio.shared.playMusic(.cloudKingdom)
    }

    private func showBossBar() {
        hudLayer.childNode(withName: "bossBar")?.removeFromParent()

        let root = SKNode()
        root.name = "bossBar"
        root.position = CGPoint(x: size.width / 2 - 170, y: size.height - 105)
        root.zPosition = 92

        let title = makeLabel("THE GLITCH", size: 15, color: .white)
        title.position = CGPoint(x: 170, y: 24)
        root.addChild(title)

        let background = SKShapeNode(
            rect: CGRect(x: 0, y: -9, width: 340, height: 18),
            cornerRadius: 9
        )
        background.fillColor = UIColor.black.withAlphaComponent(0.62)
        background.strokeColor = .white
        background.lineWidth = 2
        root.addChild(background)

        let fill = SKShapeNode(
            rect: CGRect(x: 0, y: -7, width: 336, height: 14),
            cornerRadius: 7
        )
        fill.name = "bossHealthFill"
        fill.position.x = 2
        fill.fillColor = WorldArt.glitchPink
        fill.strokeColor = .clear
        root.addChild(fill)

        hudLayer.addChild(root)
        updateBossBar()
    }

    private func updateBossBar() {
        let ratio = CGFloat(bossHealth) / 12
        hudLayer
            .childNode(withName: "bossBar")?
            .childNode(withName: "bossHealthFill")?
            .xScale = ratio
    }

    private func showWorldBanner(_ world: WorldTheme) {
        hudLayer.childNode(withName: "worldBanner")?.removeFromParent()

        let banner = SKNode()
        banner.name = "worldBanner"
        banner.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        banner.zPosition = 90

        let panel = SKShapeNode(rectOf: CGSize(width: 470, height: 112), cornerRadius: 24)
        panel.fillColor = UIColor.white.withAlphaComponent(0.94)
        panel.strokeColor = world.accentColor
        panel.lineWidth = 5
        banner.addChild(panel)

        let badge = WorldArt.makeWorldBadge(for: world, radius: 35)
        badge.position.x = -184
        panel.addChild(badge)

        let title = makeLabel(world.name, size: 27, color: WorldArt.ink)
        title.position = CGPoint(x: 36, y: 17)
        panel.addChild(title)

        let subtitle = makeLabel(world.subtitle, size: 15, color: UIColor.darkGray)
        subtitle.position = CGPoint(x: 36, y: -22)
        panel.addChild(subtitle)

        banner.alpha = 0
        banner.setScale(0.88)
        hudLayer.addChild(banner)
        banner.run(.sequence([
            .group([.fadeIn(withDuration: 0.25), .scale(to: 1, duration: 0.25)]),
            .wait(forDuration: 2.0),
            .group([.fadeOut(withDuration: 0.35), .moveBy(x: 0, y: 25, duration: 0.35)]),
            .removeFromParent()
        ]))
    }

    // MARK: - Spawning

    private func spawnObstacleCourse() {
        let floorY = lowerFlightLimit - 38
        let ceilingY = upperFlightLimit + 48
        let gapHeight = max(
            GameConstants.minimumObstacleGap,
            size.height * 0.31 - CGFloat(runTime) * 1.25
        )
        let minCenter = floorY + gapHeight / 2 + 70
        let maxCenter = ceilingY - gapHeight / 2 - 70
        guard maxCenter > minCenter else { return }

        let gapCenter = CGFloat.random(in: minCenter...maxCenter)
        let barrierWidth: CGFloat = 78
        let spawnX = size.width + 120

        let bottomHeight = max(28, gapCenter - gapHeight / 2 - floorY)
        let bottom = WorldArt.makeBarrier(
            for: currentWorld,
            size: CGSize(width: barrierWidth, height: bottomHeight)
        )
        bottom.position = CGPoint(x: spawnX, y: floorY + bottomHeight / 2)
        addMovingNode(bottom)

        let topHeight = max(28, ceilingY - (gapCenter + gapHeight / 2))
        let top = WorldArt.makeBarrier(
            for: currentWorld,
            size: CGSize(width: barrierWidth, height: topHeight)
        )
        top.position = CGPoint(x: spawnX, y: gapCenter + gapHeight / 2 + topHeight / 2)
        addMovingNode(top)

        let chipCount = 5
        #if DEBUG
        if gameplayQualityDiagnosticMode, qualityProbeFirstChipSeconds == nil,
           let startTime = qualityProbeStartTime {
            qualityProbeFirstChipSeconds = ProcessInfo.processInfo.systemUptime - startTime
        }
        #endif
        for index in 0..<chipCount {
            let chip = WorldArt.makeChip()
            let arc = sin(CGFloat(index) / CGFloat(chipCount - 1) * .pi) * gapHeight * 0.16
            chip.position = CGPoint(
                x: spawnX + CGFloat(index - 2) * 58,
                y: gapCenter + arc - gapHeight * 0.07
            )
            addMovingNode(chip)
        }
    }

    private func spawnWorldEnemy() {
        let kind = currentWorld.enemyKind
        let enemy = WorldArt.makeEnemy(kind)
        let safeBottom = lowerFlightLimit + 78
        let safeTop = upperFlightLimit - 78
        let centerY = (safeBottom + safeTop) / 2

        let startY: CGFloat
        switch kind {
        case .cloudSwooper:
            startY = CGFloat.random(in: centerY...safeTop)
        case .jungleSnapper:
            startY = min(max(player.position.y, safeBottom), safeTop)
        case .candyBouncer, .castleGargoyle:
            let movementPadding: CGFloat = 72
            startY = CGFloat.random(
                in: (safeBottom + movementPadding)...(safeTop - movementPadding)
            )
        }

        let holdingX = size.width - 84
        enemy.position = CGPoint(x: size.width + 110, y: startY)
        enemy.zPosition = 12
        gameplayLayer.addChild(enemy)
        addEnemyTelegraph(to: enemy, kind: kind)

        let warningDuration: TimeInterval = 0.72
        let distance = holdingX + 210
        let travelDuration = TimeInterval(distance / (currentScrollSpeed * enemySpeedMultiplier(for: kind)))
        let movement = enemyMovement(
            for: kind,
            distance: distance,
            duration: travelDuration,
            startY: startY,
            safeBottom: safeBottom,
            safeTop: safeTop
        )
        let enter = SKAction.moveTo(x: holdingX, duration: 0.22)
        enter.timingMode = .easeOut
        enemy.run(.sequence([
            enter,
            .wait(forDuration: warningDuration),
            .run { [weak enemy] in enemy?.childNode(withName: "enemyWarning")?.removeFromParent() },
            movement,
            .removeFromParent()
        ]))

        if enemyShowcaseMode {
            showToast("\(kind.displayName)  •  WATCH ITS MOVE", color: currentWorld.accentColor, duration: 1.8)
        }
    }

    private func enemySpeedMultiplier(for kind: EnemyKind) -> CGFloat {
        switch kind {
        case .cloudSwooper: 1.18
        case .jungleSnapper: 1.34
        case .candyBouncer: 1.04
        case .castleGargoyle: 1.12
        }
    }

    private func enemyMovement(
        for kind: EnemyKind,
        distance: CGFloat,
        duration: TimeInterval,
        startY: CGFloat,
        safeBottom: CGFloat,
        safeTop: CGFloat
    ) -> SKAction {
        switch kind {
        case .cloudSwooper:
            let dive = min(155, startY - safeBottom)
            return .sequence([
                .group([
                    .moveBy(x: -distance * 0.48, y: -dive, duration: duration * 0.48),
                    .rotate(toAngle: -0.16, duration: duration * 0.18, shortestUnitArc: true)
                ]),
                .group([
                    .moveBy(x: -distance * 0.52, y: dive * 0.72, duration: duration * 0.52),
                    .rotate(toAngle: 0.10, duration: duration * 0.18, shortestUnitArc: true)
                ])
            ])
        case .jungleSnapper:
            let lunge = SKAction.moveBy(x: -distance, y: 0, duration: duration)
            lunge.timingMode = .easeIn
            return lunge
        case .candyBouncer:
            let step = distance / 6
            return .sequence((0..<6).map { index in
                let y: CGFloat = index.isMultiple(of: 2) ? 62 : -62
                let hop = SKAction.moveBy(x: -step, y: y, duration: duration / 6)
                hop.timingMode = index.isMultiple(of: 2) ? .easeOut : .easeIn
                return hop
            })
        case .castleGargoyle:
            let step = distance / 4
            let availableUp = safeTop - startY
            let availableDown = startY - safeBottom
            let amplitude = min(78, availableUp, availableDown)
            return .sequence((0..<4).map { index in
                let y: CGFloat = index.isMultiple(of: 2) ? amplitude : -amplitude
                return .group([
                    .moveBy(x: -step, y: y, duration: duration / 4),
                    .rotate(toAngle: index.isMultiple(of: 2) ? 0.11 : -0.11, duration: duration / 4, shortestUnitArc: true)
                ])
            })
        }
    }

    private func addEnemyTelegraph(to enemy: SKNode, kind: EnemyKind) {
        let warning = SKNode()
        warning.name = "enemyWarning"

        let ring = SKShapeNode(ellipseOf: CGSize(width: 126, height: 126))
        ring.strokeColor = currentWorld.accentColor
        ring.fillColor = currentWorld.accentColor.withAlphaComponent(0.08)
        ring.lineWidth = 5
        ring.glowWidth = 5
        ring.alpha = 0.95
        warning.addChild(ring)
        ring.run(.repeatForever(.sequence([
            .group([.scale(to: 1.18, duration: 0.22), .fadeAlpha(to: 0.42, duration: 0.22)]),
            .group([.scale(to: 0.86, duration: 0.20), .fadeAlpha(to: 0.95, duration: 0.20)])
        ])))

        let mark = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        mark.text = "!"
        mark.fontSize = 34
        mark.fontColor = .white
        mark.position = CGPoint(x: 0, y: 72)
        mark.verticalAlignmentMode = .center
        warning.addChild(mark)

        if kind == .jungleSnapper {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -size.width, y: 0))
            path.addLine(to: CGPoint(x: -72, y: 0))
            let aimLine = SKShapeNode(path: path)
            aimLine.strokeColor = currentWorld.accentColor.withAlphaComponent(0.55)
            aimLine.lineWidth = 3
            aimLine.glowWidth = 2
            warning.addChild(aimLine)
        }
        enemy.addChild(warning)
    }

    private func spawnNearMissShowcaseEnemy() {
        guard phase == .playing else { return }
        let enemy = WorldArt.makeEnemy(.jungleSnapper)
        enemy.position = CGPoint(x: size.width - 84, y: player.position.y + 96)
        enemy.zPosition = 12
        gameplayLayer.addChild(enemy)
        addEnemyTelegraph(to: enemy, kind: .jungleSnapper)

        enemy.run(.sequence([
            .wait(forDuration: 0.72),
            .run { [weak enemy] in enemy?.childNode(withName: "enemyWarning")?.removeFromParent() },
            .moveBy(x: -(size.width + 180), y: 0, duration: 2.1),
            .removeFromParent()
        ]))
    }

    private func spawnFallingHazard() {
        let hazard = WorldArt.makeFallingHazard(for: currentWorld)
        hazard.position = CGPoint(
            x: CGFloat.random(in: (size.width * 0.68)...(size.width * 1.05)),
            y: upperFlightLimit + 95
        )
        let fall = SKAction.moveBy(
            x: -size.width * 0.48,
            y: -(size.height + 230),
            duration: max(3.0, 4.5 - runTime * 0.008)
        )
        hazard.run(.sequence([fall, .removeFromParent()]))
        gameplayLayer.addChild(hazard)
    }

    private func spawnPowerUp() {
        #if DEBUG
        if gameplayQualityDiagnosticMode, qualityProbeFirstPowerUpSeconds == nil,
           let startTime = qualityProbeStartTime {
            qualityProbeFirstPowerUpSeconds = ProcessInfo.processInfo.systemUptime - startTime
        }
        #endif
        let kind: PowerUpKind = Int(runTime / 10).isMultiple(of: 2) ? .shield : .magnet
        let powerUp = WorldArt.makePowerUp(kind)
        powerUp.position = CGPoint(
            x: size.width + 90,
            y: CGFloat.random(in: (lowerFlightLimit + 85)...(upperFlightLimit - 85))
        )
        addMovingNode(powerUp)
    }

    private func addMovingNode(_ node: SKNode) {
        let distance = node.position.x + 180
        let duration = TimeInterval(distance / currentScrollSpeed)
        node.run(.sequence([
            .moveBy(x: -distance, y: 0, duration: duration),
            .removeFromParent()
        ]))
        gameplayLayer.addChild(node)
    }

    // MARK: - Update loop

    override func update(_ currentTime: TimeInterval) {
        #if DEBUG
        if gameplayQualityDiagnosticMode {
            recordGameplayQualityFrame()
            if qualityProbeFinished { return }
        }
        if performanceDiagnosticMode {
            recordPerformanceFrame(at: currentTime)
            if performanceProbeFinished { return }
        }
        #endif

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = min(TimeInterval(currentTime - lastUpdateTime), 1.0 / 30.0)
        lastUpdateTime = currentTime

        switch phase {
        case .title, .story, .gear, .gameOver:
            updateBackground(deltaTime: CGFloat(deltaTime), speed: 42)
        case .paused:
            return
        case .playing:
            updateRun(deltaTime: deltaTime, currentTime: currentTime)
        }
    }

    private func updateRun(deltaTime: TimeInterval, currentTime: TimeInterval) {
        runTime += deltaTime
        scoreValue += CGFloat(deltaTime) * (10 + min(10, CGFloat(runTime) * 0.05))

        if nearMissShowcaseMode {
            player.position.y = size.height * 0.50
            verticalVelocity = 0
            isBoosting = false
        } else if demoMode {
            let target = size.height * (0.53 + sin(currentTime * 0.9) * 0.16)
            isBoosting = player.position.y < target
        }

        updatePlayer(deltaTime: CGFloat(deltaTime), currentTime: currentTime)
        updateBackground(deltaTime: CGFloat(deltaTime), speed: currentScrollSpeed)
        if bossFightActive {
            updateBossFight(deltaTime: deltaTime)
        } else {
            updateSpawners(deltaTime: deltaTime)
            updateNearMisses()
            advanceWorldIfNeeded()
        }
        updatePowerUps(deltaTime: deltaTime)
        if scoreValue >= 750 {
            awardAchievement(.highFlyer)
        }
        updateHUD()

        #if DEBUG
        if gameplayQualityDiagnosticMode,
           !qualityProbeDidTriggerCrash,
           qualityProbeFirstPowerUpSeconds != nil,
           let startTime = qualityProbeStartTime,
           ProcessInfo.processInfo.systemUptime - startTime >= 9 {
            qualityProbeDidTriggerCrash = true
            endRun()
        }
        #endif
    }

    #if DEBUG
    private func scheduleQualityProbeInput() {
        guard !qualityProbeDidScheduleInput else { return }
        qualityProbeDidScheduleInput = true
        run(.sequence([
            .wait(forDuration: 0.65),
            .run { [weak self] in
                guard let self else { return }
                self.qualityProbeInputRequestTime = ProcessInfo.processInfo.systemUptime
                self.beginBoostInput(playHaptic: false)
            }
        ]))
    }

    private func recordGameplayQualityFrame() {
        guard !qualityProbeFinished else { return }
        let now = ProcessInfo.processInfo.systemUptime

        if let requestTime = qualityProbeInputRequestTime,
           qualityProbeInputResponseMS == nil,
           isBoosting {
            qualityProbeInputResponseMS = (now - requestTime) * 1_000
        }

        if let restartTime = qualityProbeRestartRequestTime,
           qualityProbeRestartResponseMS == nil,
           qualityProbeDidRestart,
           phase == .playing {
            qualityProbeRestartResponseMS = (now - restartTime) * 1_000
        }

        if qualityProbeFirstChipSeconds != nil,
           qualityProbeFirstPowerUpSeconds != nil,
           qualityProbeInputResponseMS != nil,
           qualityProbeRestartResponseMS != nil {
            showGameplayQualityDiagnosticScreen()
        }
    }

    private func showGameplayQualityDiagnosticScreen() {
        guard
            !qualityProbeFinished,
            let chipSeconds = qualityProbeFirstChipSeconds,
            let powerUpSeconds = qualityProbeFirstPowerUpSeconds,
            let inputMS = qualityProbeInputResponseMS,
            let restartMS = qualityProbeRestartResponseMS
        else { return }

        qualityProbeFinished = true
        let playerDiameter = GameConstants.playerCollisionRadius * 2
        let clearance = GameConstants.minimumObstacleGap - playerDiameter
        let passed = inputMS <= 50
            && chipSeconds <= 5
            && powerUpSeconds <= 25
            && restartMS <= 1_000
            && clearance >= playerDiameter
            && (20...30).contains(GameConstants.worldDuration)

        phase = .paused
        gameplayLayer.isPaused = true
        GameAudio.shared.stopMusic()
        screenOverlay.removeAllChildren()

        let backdrop = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backdrop.fillColor = UIColor(red: 0.05, green: 0.09, blue: 0.17, alpha: 0.96)
        backdrop.strokeColor = .clear
        screenOverlay.addChild(backdrop)

        let title = makeLabel(
            passed ? "MECHANICS PROBE: PASS" : "MECHANICS PROBE: NEEDS WORK",
            size: min(43, size.height * 0.08),
            color: passed ? .systemGreen : .systemYellow
        )
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        screenOverlay.addChild(title)

        let subtitle = makeLabel(
            "LIVE SPAWN • INPUT • COLLISION • RESTART CHECKS",
            size: min(20, size.height * 0.038),
            color: .white
        )
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        screenOverlay.addChild(subtitle)

        let rows = [
            String(format: "BOOST INPUT TO FRAME      %.1f ms  (TARGET ≤50 ms)", inputMS),
            String(format: "FIRST CHIP COURSE         %.2f s   (TARGET ≤5 s)", chipSeconds),
            String(format: "FIRST POWER-UP            %.2f s   (TARGET ≤25 s)", powerUpSeconds),
            String(format: "RESTART TO PLAY FRAME     %.1f ms  (TARGET ≤1,000 ms)", restartMS),
            String(format: "MINIMUM GAP               %.0f pt   (PLAYER BODY %.0f pt)", GameConstants.minimumObstacleGap, playerDiameter),
            String(format: "COLLISION CLEARANCE       %.0f pt   (TARGET ≥%.0f pt)", clearance, playerDiameter),
            String(format: "WORLD CHANGE              %.0f s    (TARGET 20–30 s)", GameConstants.worldDuration)
        ]
        for (index, row) in rows.enumerated() {
            let label = makeLabel(row, size: min(18, size.height * 0.034), color: .white)
            label.fontName = "Menlo-Bold"
            label.position = CGPoint(
                x: size.width / 2,
                y: size.height * 0.61 - CGFloat(index) * min(42, size.height * 0.065)
            )
            screenOverlay.addChild(label)
        }

        let caveat = makeLabel(
            "IMPLEMENTATION PASS • UNCOACHED PLAYER FAIRNESS STILL REQUIRED",
            size: min(17, size.height * 0.032),
            color: .systemYellow
        )
        caveat.position = CGPoint(x: size.width / 2, y: size.height * 0.11)
        screenOverlay.addChild(caveat)

        print(String(
            format: "GAMEPLAY_QUALITY_PROBE %@ inputMS=%.1f chipS=%.2f powerS=%.2f restartMS=%.1f gap=%.0f player=%.0f",
            passed ? "PASS" : "FAIL",
            inputMS,
            chipSeconds,
            powerUpSeconds,
            restartMS,
            GameConstants.minimumObstacleGap,
            playerDiameter
        ))
    }
    #endif

    #if DEBUG
    private func recordPerformanceFrame(at currentTime: TimeInterval) {
        guard !performanceProbeFinished else { return }

        if performanceLaunchSeconds == 0 {
            performanceLaunchSeconds = max(
                0,
                ProcessInfo.processInfo.systemUptime - GameLaunchMetrics.processStartTime
            )
        }
        guard phase == .playing else { return }

        guard let startTime = performanceProbeStartTime else {
            performanceProbeStartTime = currentTime
            performanceProbeLastFrameTime = currentTime
            return
        }

        if let lastFrameTime = performanceProbeLastFrameTime {
            let interval = currentTime - lastFrameTime
            let elapsed = currentTime - startTime
            if elapsed >= 2, interval > 0, interval < 1 {
                performanceFrameIntervals.append(interval)
            }
        }
        performanceProbeLastFrameTime = currentTime

        if currentTime - startTime >= 22 {
            finishPerformanceProbe()
        }
    }

    private func finishPerformanceProbe() {
        performanceProbeFinished = true
        let sortedIntervals = performanceFrameIntervals.sorted()
        let percentileIndex = min(
            max(0, Int(Double(max(0, sortedIntervals.count - 1)) * 0.95)),
            max(0, sortedIntervals.count - 1)
        )
        let p95Interval = sortedIntervals.isEmpty ? 0 : sortedIntervals[percentileIndex]
        let p95FPS = p95Interval > 0 ? 1 / p95Interval : 0
        let worstInterval = sortedIntervals.last ?? 0
        let hitchCount = sortedIntervals.filter { $0 > 0.05 }.count
        let memoryMB = currentResidentMemoryMB()
        let passed = p95FPS >= 58
            && worstInterval <= 0.05
            && performanceLaunchSeconds <= 2
            && memoryMB <= 250

        phase = .paused
        gameplayLayer.isPaused = true
        GameAudio.shared.stopMusic()
        screenOverlay.removeAllChildren()

        let backdrop = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backdrop.fillColor = UIColor(red: 0.05, green: 0.09, blue: 0.17, alpha: 0.96)
        backdrop.strokeColor = .clear
        screenOverlay.addChild(backdrop)

        let title = makeLabel(
            passed ? "PERFORMANCE PROBE: PASS" : "PERFORMANCE PROBE: NEEDS WORK",
            size: min(43, size.height * 0.08),
            color: passed ? .systemGreen : .systemYellow
        )
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.80)
        screenOverlay.addChild(title)

        let subtitle = makeLabel(
            "20-SECOND FOUR-WORLD + BOSS STRESS RUN • SIMULATOR",
            size: min(20, size.height * 0.038),
            color: .white
        )
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.69)
        screenOverlay.addChild(subtitle)

        let rows = [
            String(format: "95TH-PERCENTILE FPS     %.1f     (TARGET 58–60)", p95FPS),
            String(format: "WORST FRAME             %.1f ms  (TARGET ≤50 ms)", worstInterval * 1_000),
            "VISIBLE HITCHES >50 ms    \(hitchCount)       (TARGET 0)",
            String(format: "LAUNCH TO FIRST FRAME    %.2f s   (TARGET ≤2 s)", performanceLaunchSeconds),
            String(format: "RESIDENT MEMORY          %.0f MB   (TARGET ≤250 MB)", memoryMB),
            "MEASURED FRAMES           \(performanceFrameIntervals.count)",
            "WORLD CYCLE               CLOUD → DINO → CANDY → CASTLE → BOSS"
        ]

        for (index, row) in rows.enumerated() {
            let label = makeLabel(row, size: min(19, size.height * 0.035), color: .white)
            label.fontName = "Menlo-Bold"
            label.position = CGPoint(
                x: size.width / 2,
                y: size.height * 0.57 - CGFloat(index) * min(42, size.height * 0.065)
            )
            screenOverlay.addChild(label)
        }

        let result = String(
            format: "PERFORMANCE_PROBE %@ p95FPS=%.1f worstMS=%.1f hitches=%d launchS=%.2f memoryMB=%.0f frames=%d",
            passed ? "PASS" : "FAIL",
            p95FPS,
            worstInterval * 1_000,
            hitchCount,
            performanceLaunchSeconds,
            memoryMB,
            performanceFrameIntervals.count
        )
        print(result)
    }

    private func currentResidentMemoryMB() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size
        )
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    rebound,
                    &count
                )
            }
        }
        guard result == KERN_SUCCESS else { return .infinity }
        return Double(info.resident_size) / 1_048_576
    }
    #endif

    private func updatePlayer(deltaTime: CGFloat, currentTime: TimeInterval) {
        let acceleration = isBoosting ? riseAcceleration : fallAcceleration
        verticalVelocity += acceleration * deltaTime
        verticalVelocity = min(max(verticalVelocity, maximumFallSpeed), maximumRiseSpeed)
        player.position.y += verticalVelocity * deltaTime

        if player.position.y <= lowerFlightLimit {
            player.position.y = lowerFlightLimit
            verticalVelocity = max(verticalVelocity, 0)
        } else if player.position.y >= upperFlightLimit {
            player.position.y = upperFlightLimit
            verticalVelocity = min(verticalVelocity, 0)
        }

        player.zRotation = max(-0.32, min(0.34, verticalVelocity / 1_360))
        if let character = player.childNode(withName: "characterArt") {
            let targetRotation: CGFloat = isBoosting ? 0.045 : -0.035
            let targetXScale: CGFloat = isBoosting ? 1.035 : 0.985
            let targetYScale: CGFloat = isBoosting ? 0.97 : 1.025
            let blend = min(1, deltaTime * 9)
            character.zRotation += (targetRotation - character.zRotation) * blend
            character.xScale += (targetXScale - character.xScale) * blend
            character.yScale += (targetYScale - character.yScale) * blend
            character.position.y = 2 + CGFloat(sin(currentTime * 5.4)) * 1.8
        }
        if let booster = player.childNode(withName: "//nozzleRim") {
            let pulse = isBoosting ? 1 + CGFloat(sin(currentTime * 20)) * 0.06 : 1
            booster.setScale(pulse)
        }
        let thrustIntensity = isBoosting
            ? 0.88 + min(0.24, max(0, -verticalVelocity) / 1_800)
            : 0
        if let flame = player.childNode(withName: "//flame") {
            flame.isHidden = !isBoosting
            if isBoosting {
                flame.yScale = thrustIntensity * (0.88 + CGFloat(sin(currentTime * 23)) * 0.12)
                flame.xScale = thrustIntensity * (0.98 + CGFloat(cos(currentTime * 17)) * 0.08)
            }
        }
        if let particles = player.childNode(withName: "//exhaustParticles") as? SKEmitterNode {
            particles.particleBirthRate = isBoosting ? 108 * thrustIntensity : 0
            particles.particleSpeed = 185 + 65 * thrustIntensity
        }

        boostTrailTimer -= TimeInterval(deltaTime)
        if isBoosting, boostTrailTimer <= 0 {
            spawnBoostTrailSpark()
            boostTrailTimer = 0.055
        }

        if invulnerabilityTime > 0 {
            player.alpha = sin(currentTime * 24) > 0 ? 1 : 0.38
        } else {
            player.alpha = 1
        }
    }

    private func updateBackground(deltaTime: CGFloat, speed: CGFloat) {
        for tile in backgroundTiles {
            tile.position.x -= speed * deltaTime
        }

        for tile in backgroundTiles where tile.position.x + size.width < 0 {
            let rightmost = backgroundTiles.map(\.position.x).max() ?? 0
            tile.position.x = rightmost + size.width
        }
    }

    private func updateSpawners(deltaTime: TimeInterval) {
        obstacleTimer -= deltaTime
        enemyTimer -= deltaTime
        fallingHazardTimer -= deltaTime
        powerUpTimer -= deltaTime
        hazardSeparationTimer = max(0, hazardSeparationTimer - deltaTime)

        if obstacleTimer <= 0 {
            if hazardSeparationTimer > 0 {
                obstacleTimer = 0.35
            } else {
                spawnObstacleCourse()
                hazardSeparationTimer = 1.10
                obstacleTimer = max(1.85, 2.8 - runTime * 0.006)
            }
        }
        if enemyTimer <= 0 {
            if hazardSeparationTimer > 0 {
                enemyTimer = 0.35
            } else {
                spawnWorldEnemy()
                hazardSeparationTimer = 1.10
                enemyTimer = enemyShowcaseMode
                    ? 999
                    : max(3.0, Double.random(in: 4.0...5.4) - runTime * 0.004)
            }
        }
        if fallingHazardTimer <= 0 {
            if hazardSeparationTimer > 0 {
                fallingHazardTimer = 0.35
            } else {
                spawnFallingHazard()
                hazardSeparationTimer = 0.95
                fallingHazardTimer = max(4.4, Double.random(in: 5.8...7.3) - runTime * 0.004)
            }
        }
        if powerUpTimer <= 0 {
            spawnPowerUp()
            powerUpTimer = Double.random(in: 10.5...13.5)
        }
    }

    private func updatePowerUps(deltaTime: TimeInterval) {
        shieldTime = max(0, shieldTime - deltaTime)
        magnetTime = max(0, magnetTime - deltaTime)
        invulnerabilityTime = max(0, invulnerabilityTime - deltaTime)

        player.childNode(withName: "shieldAura")?.isHidden = shieldTime <= 0
        player.childNode(withName: "magnetAura")?.isHidden = magnetTime <= 0

        guard magnetTime > 0 else { return }
        for chip in gameplayLayer.children where chip.name == "chip" {
            let dx = player.position.x - chip.position.x
            let dy = player.position.y - chip.position.y
            let distance = max(1, hypot(dx, dy))
            guard distance < size.width * 0.58 else { continue }
            let pull = CGFloat(deltaTime) * 720
            chip.position.x += dx / distance * pull
            chip.position.y += dy / distance * pull
        }
    }

    private func updateNearMisses() {
        guard phase == .playing else { return }
        for enemy in gameplayLayer.children where enemy.userData?["enemyKind"] != nil {
            let alreadyChecked = enemy.userData?["nearMissChecked"] as? Bool ?? false
            guard !alreadyChecked, enemy.position.x < player.position.x - 58 else { continue }
            enemy.userData?["nearMissChecked"] = true

            let verticalDistance = abs(enemy.position.y - player.position.y)
            guard verticalDistance < 116 else {
                nearMissStreak = 0
                continue
            }

            nearMissStreak = min(5, nearMissStreak + 1)
            let reward = 25 + nearMissStreak * 10
            scoreValue += CGFloat(reward)
            let sparkPoint = CGPoint(
                x: (enemy.position.x + player.position.x) / 2,
                y: (enemy.position.y + player.position.y) / 2
            )
            makeBurst(at: sparkPoint, colors: [currentWorld.accentColor, .white], count: 7)
            showToast("NEAR MISS ×\(nearMissStreak)  +\(reward)", color: currentWorld.accentColor, duration: 0.72)
            GameAudio.shared.play(.nearMiss)
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.55)
        }
    }

    // MARK: - Contacts and pickups

    func didBegin(_ contact: SKPhysicsContact) {
        let combinedCategories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if combinedCategories == (PhysicsCategory.heroShot | PhysicsCategory.boss) {
            let boltBody = contact.bodyA.categoryBitMask == PhysicsCategory.heroShot
                ? contact.bodyA
                : contact.bodyB
            if let bolt = boltBody.node {
                damageBoss(with: bolt, at: contact.contactPoint)
            }
            return
        }

        let playerMask = PhysicsCategory.player
        let otherBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask == playerMask {
            otherBody = contact.bodyB
        } else if contact.bodyB.categoryBitMask == playerMask {
            otherBody = contact.bodyA
        } else {
            return
        }

        guard phase == .playing, let node = otherBody.node else { return }
        switch otherBody.categoryBitMask {
        case PhysicsCategory.chip:
            collectChip(node)
        case PhysicsCategory.powerUp:
            collectPowerUp(node)
        case PhysicsCategory.hazard:
            hitHazard(node, at: contact.contactPoint)
        case PhysicsCategory.boss:
            hitHazard(node, at: contact.contactPoint)
        default:
            break
        }
    }

    private func collectChip(_ chip: SKNode) {
        guard chip.parent != nil else { return }
        let position = chip.position
        chip.removeFromParent()
        runChips += 1
        lifetimeChips += 1
        scoreValue += 25
        GameSaveStore.lifetimeChips = lifetimeChips

        let dailyResult = ProgressStore.addDailyChip()
        if dailyResult.completedNow {
            scoreValue += 300
            showToast(
                "DAILY QUEST COMPLETE!  +300",
                color: UIColor(red: 1, green: 0.84, blue: 0.18, alpha: 1),
                duration: 2.2
            )
        }
        if lifetimeChips >= 25 {
            awardAchievement(.chipCollector)
        }

        makeBurst(
            at: position,
            colors: [UIColor(red: 1, green: 0.86, blue: 0.14, alpha: 1), .white],
            count: 8
        )
        GameAudio.shared.play(.chip)
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.45)
        animatePlayerPickup(color: UIColor(red: 1, green: 0.86, blue: 0.14, alpha: 1))
    }

    private func collectPowerUp(_ node: SKNode) {
        guard
            node.parent != nil,
            let value = node.userData?["kind"] as? String,
            let kind = PowerUpKind(rawValue: value)
        else {
            return
        }

        let position = node.position
        node.removeFromParent()
        scoreValue += 50

        switch kind {
        case .shield:
            shieldTime = 8
            player.childNode(withName: "shieldAura")?.isHidden = false
            showToast("SHIELD BUBBLE!", color: WorldArt.glitchBlue, duration: 1.6)
        case .magnet:
            magnetTime = 9
            player.childNode(withName: "magnetAura")?.isHidden = false
            showToast("CHIP MAGNET!", color: UIColor(red: 1, green: 0.84, blue: 0.16, alpha: 1), duration: 1.6)
        }

        makeBurst(at: position, colors: [WorldArt.glitchBlue, .white], count: 13)
        GameAudio.shared.play(.powerUp)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        animatePlayerPickup(color: kind == .shield ? WorldArt.glitchBlue : UIColor(red: 1, green: 0.84, blue: 0.16, alpha: 1))
    }

    private func hitHazard(_ hazard: SKNode, at point: CGPoint) {
        guard invulnerabilityTime <= 0 else { return }
        hazard.userData?["nearMissChecked"] = true
        nearMissStreak = 0

        if demoMode {
            if hazard.name != "boss" {
                hazard.removeFromParent()
            }
            makeBurst(at: point, colors: [WorldArt.glitchPink, WorldArt.glitchBlue], count: 12)
            return
        }

        if shieldTime > 0 {
            shieldTime = 0
            invulnerabilityTime = 1.1
            if hazard.name != "boss" {
                hazard.removeFromParent()
            }
            makeBurst(at: point, colors: [WorldArt.glitchBlue, .white], count: 18)
            showToast("SHIELD SAVE!", color: WorldArt.glitchBlue, duration: 1.2)
            GameAudio.shared.play(.shieldHit)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            animatePlayerHit()
        } else {
            makeBurst(at: player.position, colors: [WorldArt.glitchPink, .white], count: 22)
            endRun()
        }
    }

    private func awardAchievement(_ achievement: Achievement) {
        guard ProgressStore.unlock(achievement) else { return }
        scoreValue += 100
        showToast(
            "NEW BADGE  •  \(achievement.title)",
            color: UIColor(red: 1, green: 0.84, blue: 0.18, alpha: 1),
            duration: 2.0
        )
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func makeBurst(at point: CGPoint, colors: [UIColor], count: Int) {
        for index in 0..<count {
            let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2.5...5.5))
            spark.position = point
            spark.fillColor = colors[index % colors.count]
            spark.strokeColor = .clear
            spark.zPosition = 45
            gameplayLayer.addChild(spark)

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 35...105)
            spark.run(.sequence([
                .group([
                    .moveBy(x: cos(angle) * distance, y: sin(angle) * distance, duration: 0.42),
                    .fadeOut(withDuration: 0.42),
                    .scale(to: 0.1, duration: 0.42)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func spawnBoostTrailSpark() {
        guard let exhaust = player.childNode(withName: "//boosterExhaust") else { return }
        let origin = exhaust.convert(CGPoint.zero, to: gameplayLayer)
        let tail = exhaust.convert(CGPoint(x: -58, y: 0), to: gameplayLayer)
        let travel = CGVector(dx: tail.x - origin.x, dy: tail.y - origin.y)
        let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 3.5...7.0))
        spark.position = CGPoint(
            x: origin.x,
            y: origin.y + CGFloat.random(in: -4...4)
        )
        spark.fillColor = Bool.random()
            ? selectedBooster.trailColor
            : UIColor(red: 1, green: 0.86, blue: 0.20, alpha: 1)
        spark.strokeColor = .white
        spark.lineWidth = 1.5
        spark.glowWidth = 3
        spark.zPosition = -2
        gameplayLayer.addChild(spark)
        let travelX = travel.dx * CGFloat.random(in: 0.72...1.08)
        let travelY = travel.dy * CGFloat.random(in: 0.72...1.08) + CGFloat.random(in: -8...8)
        let drift = SKAction.moveBy(x: travelX, y: travelY, duration: 0.34)
        let disappear = SKAction.group([
            drift,
            .fadeOut(withDuration: 0.34),
            .scale(to: 0.15, duration: 0.34)
        ])
        spark.run(.sequence([disappear, .removeFromParent()]))
    }

    private func configurePlayerDynamics() {
        guard let particles = player.childNode(withName: "//exhaustParticles") as? SKEmitterNode else {
            return
        }
        particles.targetNode = gameplayLayer
    }

    private func animatePlayerPickup(color: UIColor) {
        let ring = SKShapeNode(ellipseOf: CGSize(width: 188, height: 116))
        ring.strokeColor = color
        ring.fillColor = .clear
        ring.lineWidth = 4
        ring.glowWidth = 6
        ring.zPosition = 6
        player.addChild(ring)
        ring.run(.sequence([
            .group([
                .scale(to: 1.34, duration: 0.24),
                .fadeOut(withDuration: 0.24)
            ]),
            .removeFromParent()
        ]))

        guard let character = player.childNode(withName: "characterArt") else { return }
        character.removeAction(forKey: "reaction")
        character.run(.sequence([
            .group([
                .scaleX(to: 1.09, duration: 0.09),
                .scaleY(to: 0.92, duration: 0.09)
            ]),
            .group([
                .scaleX(to: 1, duration: 0.13),
                .scaleY(to: 1, duration: 0.13)
            ])
        ]), withKey: "reaction")
    }

    private func animatePlayerHit() {
        guard let character = player.childNode(withName: "characterArt") else { return }
        character.removeAction(forKey: "reaction")
        character.run(.sequence([
            .moveBy(x: -14, y: 4, duration: 0.05),
            .moveBy(x: 24, y: -8, duration: 0.07),
            .moveBy(x: -18, y: 6, duration: 0.06),
            .moveBy(x: 8, y: -2, duration: 0.05)
        ]), withKey: "reaction")
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)

        switch phase {
        case .title:
            if handleSoundButton(at: point) {
                return
            } else if gearButton.contains(point) {
                showGearScreen()
            } else {
                showStoryPage(0)
            }
        case .story(let page):
            if handleSoundButton(at: point) {
                return
            } else if page < 2 {
                showStoryPage(page + 1)
            } else {
                startRun()
            }
        case .gear:
            if handleSoundButton(at: point) {
                return
            } else if gearBackButton.contains(point) {
                showTitleScreen()
                return
            }
            for (style, frame) in gearCardFrames where frame.contains(point) {
                guard lifetimeChips >= style.unlockCost else {
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    return
                }
                selectedBooster = style
                ProgressStore.selectedBooster = style
                WorldArt.applyBoosterStyle(style, to: player)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showGearScreen()
                return
            }
        case .playing:
            if handleSoundButton(at: point) {
                return
            } else if pauseButton.contains(point) {
                togglePause()
            } else {
                beginBoostInput(playHaptic: true)
            }
        case .paused:
            if handleSoundButton(at: point) {
                return
            } else if pauseButton.contains(point) {
                togglePause()
            }
        case .gameOver:
            if handleSoundButton(at: point) {
                return
            }
            guard gameOverReady else { return }
            startRun()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if phase == .playing, !demoMode {
            isBoosting = false
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if phase == .playing, !demoMode {
            isBoosting = false
        }
    }

    private func beginBoostInput(playHaptic: Bool) {
        isBoosting = true
        if playHaptic {
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
        }
    }

    // MARK: - HUD and layout

    private func buildHUD() {
        for panel in [scoreHUDPanel, worldHUDPanel] {
            panel.fillColor = WorldArt.ink.withAlphaComponent(0.58)
            panel.strokeColor = UIColor.white.withAlphaComponent(0.34)
            panel.lineWidth = 2
            panel.zPosition = -1
            hudLayer.addChild(panel)
        }

        scoreLabel.fontSize = 22
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .center
        hudLayer.addChild(scoreLabel)

        chipLabel.fontSize = 17
        chipLabel.fontColor = UIColor(red: 1, green: 0.86, blue: 0.20, alpha: 1)
        chipLabel.horizontalAlignmentMode = .left
        chipLabel.verticalAlignmentMode = .center
        hudLayer.addChild(chipLabel)

        worldLabel.fontSize = 18
        worldLabel.fontColor = .white
        worldLabel.horizontalAlignmentMode = .center
        worldLabel.verticalAlignmentMode = .center
        hudLayer.addChild(worldLabel)

        powerLabel.fontSize = 16
        powerLabel.fontColor = .white
        powerLabel.horizontalAlignmentMode = .center
        powerLabel.verticalAlignmentMode = .center
        hudLayer.addChild(powerLabel)

        let path = CGPath(
            roundedRect: CGRect(x: -28, y: -24, width: 56, height: 48),
            cornerWidth: 13,
            cornerHeight: 13,
            transform: nil
        )
        pauseButton.path = path
        pauseButton.fillColor = UIColor.black.withAlphaComponent(0.34)
        pauseButton.strokeColor = .white
        pauseButton.lineWidth = 2
        pauseButton.zPosition = 80
        for offset in [-6, 6] as [CGFloat] {
            let bar = SKShapeNode(rectOf: CGSize(width: 5, height: 19), cornerRadius: 2)
            bar.position.x = offset
            bar.fillColor = .white
            bar.strokeColor = .clear
            pauseButton.addChild(bar)
        }
        hudLayer.addChild(pauseButton)

        configureSoundButton(soundButton)
        soundButton.zPosition = 80
        hudLayer.addChild(soundButton)
    }

    private func layoutScene() {
        guard size.width > 0, size.height > 0 else { return }

        scoreLabel.position = CGPoint(x: 28, y: size.height - 36)
        chipLabel.position = CGPoint(x: 29, y: size.height - 67)
        scoreHUDPanel.position = CGPoint(x: 137, y: size.height - 52)
        worldLabel.position = CGPoint(x: size.width / 2, y: size.height - 35)
        powerLabel.position = CGPoint(x: size.width / 2, y: size.height - 64)
        worldHUDPanel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        pauseButton.position = CGPoint(x: size.width - 48, y: size.height - 43)
        soundButton.position = CGPoint(x: size.width - 162, y: size.height - 43)

        if phase == .playing || phase == .paused {
            player.position.x = size.width * 0.25
            player.position.y = min(max(player.position.y, lowerFlightLimit), upperFlightLimit)
        }
    }

    private func updateHUD() {
        scoreLabel.text = "SCORE  \(String(format: "%04d", Int(scoreValue)))"
        chipLabel.text = "★  \(runChips)"
        worldLabel.text = currentWorld.name

        if shieldTime > 0 {
            powerLabel.text = "SHIELD  \(Int(ceil(shieldTime)))s"
            powerLabel.fontColor = WorldArt.glitchBlue
        } else if magnetTime > 0 {
            powerLabel.text = "MAGNET  \(Int(ceil(magnetTime)))s"
            powerLabel.fontColor = UIColor(red: 1, green: 0.86, blue: 0.20, alpha: 1)
        } else {
            powerLabel.text = ""
        }
    }

    private func showToast(_ text: String, color: UIColor, duration: TimeInterval) {
        hudLayer.childNode(withName: "toast")?.removeFromParent()

        let toast = makePill(text: text, width: max(250, CGFloat(text.count) * 12), color: color)
        toast.name = "toast"
        toast.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        toast.zPosition = 95
        toast.alpha = 0
        toast.setScale(0.85)
        hudLayer.addChild(toast)
        toast.run(.sequence([
            .group([.fadeIn(withDuration: 0.18), .scale(to: 1, duration: 0.18)]),
            .wait(forDuration: duration),
            .group([.fadeOut(withDuration: 0.3), .moveBy(x: 0, y: 18, duration: 0.3)]),
            .removeFromParent()
        ]))
    }

    private func makeLabel(_ text: String, size: CGFloat, color: UIColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }

    private func makeMultilineLabel(
        _ text: String,
        size: CGFloat,
        color: UIColor,
        width: CGFloat
    ) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
        label.lineBreakMode = .byWordWrapping
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }

    private func makePill(text: String, width: CGFloat, color: UIColor) -> SKNode {
        let root = SKNode()
        let background = SKShapeNode(rectOf: CGSize(width: width, height: 58), cornerRadius: 22)
        background.fillColor = UIColor(red: 0.06, green: 0.04, blue: 0.16, alpha: 0.96)
        background.strokeColor = color
        background.lineWidth = 4
        root.addChild(background)

        let label = makeLabel(text, size: 18, color: .white)
        background.addChild(label)
        return root
    }

    private func configureButton(
        _ button: SKShapeNode,
        text: String,
        width: CGFloat,
        color: UIColor
    ) {
        button.removeAllChildren()
        button.path = CGPath(
            roundedRect: CGRect(x: -width / 2, y: -29, width: width, height: 58),
            cornerWidth: 22,
            cornerHeight: 22,
            transform: nil
        )
        button.fillColor = UIColor(red: 0.06, green: 0.04, blue: 0.16, alpha: 0.96)
        button.strokeColor = color
        button.lineWidth = 4

        let label = makeLabel(text, size: 17, color: .white)
        button.addChild(label)
    }

    private func addMenuSoundButton(at position: CGPoint) {
        configureSoundButton(menuSoundButton)
        menuSoundButton.position = position
        menuSoundButton.zPosition = 120
        screenOverlay.addChild(menuSoundButton)
    }

    private func configureSoundButton(_ button: SKShapeNode) {
        configureButton(
            button,
            text: GameAudio.shared.isMuted ? "SOUND OFF" : "SOUND ON",
            width: 142,
            color: GameAudio.shared.isMuted
                ? UIColor.gray
                : UIColor(red: 1, green: 0.82, blue: 0.20, alpha: 1)
        )
    }

    private func handleSoundButton(at point: CGPoint) -> Bool {
        let tappedHUDButton = soundButton.parent != nil && !hudLayer.isHidden && soundButton.contains(point)
        let tappedMenuButton = menuSoundButton.parent != nil && menuSoundButton.contains(point)
        guard tappedHUDButton || tappedMenuButton else { return false }

        let muted = GameAudio.shared.toggleMute()
        configureSoundButton(soundButton)
        if menuSoundButton.parent != nil {
            configureSoundButton(menuSoundButton)
        }
        if !muted {
            GameAudio.shared.play(.button)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.55)
        return true
    }
}
