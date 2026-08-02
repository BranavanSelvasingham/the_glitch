import SpriteKit
import UIKit

@MainActor
enum WorldArt {
    static let glitchPink = UIColor(red: 0.98, green: 0.08, blue: 0.62, alpha: 1)
    static let glitchBlue = UIColor(red: 0.10, green: 0.92, blue: 1, alpha: 1)
    static let ink = UIColor(red: 0.035, green: 0.025, blue: 0.09, alpha: 1)

    private static func softParticleTexture() -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24))
        let image = renderer.image { context in
            let colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: colors as CFArray,
                locations: [0, 1]
            ) else { return }
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: 12, y: 12),
                startRadius: 0,
                endCenter: CGPoint(x: 12, y: 12),
                endRadius: 12,
                options: []
            )
        }
        return SKTexture(image: image)
    }

    static func makeBackdrop(for theme: WorldTheme, size: CGSize) -> SKNode {
        let root = SKNode()

        let sky = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        sky.fillColor = theme.skyColor
        sky.strokeColor = .clear
        sky.zPosition = -40
        root.addChild(sky)

        let texture = SKTexture(imageNamed: theme.backdropAssetName)
        let paintedBackdrop = SKSpriteNode(texture: texture)
        let sourceSize = texture.size()
        let aspectFill = max(size.width / sourceSize.width, size.height / sourceSize.height)
        let horizontalTravel = max(0, (sourceSize.width * aspectFill - size.width) / 2)
        paintedBackdrop.name = "paintedBackdrop"
        paintedBackdrop.size = CGSize(width: sourceSize.width * aspectFill, height: sourceSize.height * aspectFill)
        paintedBackdrop.position = CGPoint(x: size.width / 2 + horizontalTravel, y: size.height / 2)
        paintedBackdrop.zPosition = -38
        root.addChild(paintedBackdrop)

        if horizontalTravel > 4 {
            paintedBackdrop.run(.repeatForever(.sequence([
                .moveTo(x: size.width / 2 - horizontalTravel, duration: 28),
                .moveTo(x: size.width / 2 + horizontalTravel, duration: 28)
            ])))
        }

        for index in 0..<3 {
            let tile = makeSceneryTile(for: theme, size: size, variant: index)
            tile.name = "worldTile"
            tile.position.x = CGFloat(index) * size.width
            tile.zPosition = -20
            tile.alpha = 0.06
            root.addChild(tile)
        }
        return root
    }

    static func makePlayer() -> SKNode {
        let player = SKNode()

        // One physical anchor drives every exhaust effect. It sits on the rear
        // nozzle already painted into AidanFlying instead of drawing a second pack.
        let nozzle = SKNode()
        nozzle.name = "boosterNozzle"
        nozzle.position = CGPoint(x: -41, y: 6)
        nozzle.zRotation = 0.31
        nozzle.zPosition = 0.5

        let nozzleRim = SKShapeNode(ellipseOf: CGSize(width: 14, height: 10))
        nozzleRim.name = "nozzleRim"
        nozzleRim.fillColor = ink
        nozzleRim.strokeColor = glitchBlue
        nozzleRim.lineWidth = 2
        nozzleRim.glowWidth = 2
        nozzle.addChild(nozzleRim)

        let exhaust = SKNode()
        exhaust.name = "boosterExhaust"
        exhaust.zPosition = -3

        let flamePath = CGMutablePath()
        flamePath.move(to: CGPoint(x: -2, y: 0))
        flamePath.addCurve(
            to: CGPoint(x: -57, y: 0),
            control1: CGPoint(x: -17, y: 13),
            control2: CGPoint(x: -42, y: 10)
        )
        flamePath.addCurve(
            to: CGPoint(x: -2, y: 0),
            control1: CGPoint(x: -43, y: -10),
            control2: CGPoint(x: -16, y: -12)
        )
        flamePath.closeSubpath()
        let flame = SKShapeNode(path: flamePath)
        flame.name = "flame"
        flame.fillColor = UIColor(red: 1, green: 0.88, blue: 0.18, alpha: 1)
        flame.strokeColor = UIColor(red: 1, green: 0.28, blue: 0.12, alpha: 1)
        flame.lineWidth = 3
        flame.glowWidth = 5
        flame.zPosition = -2

        let corePath = CGMutablePath()
        corePath.move(to: CGPoint(x: -1, y: 0))
        corePath.addCurve(
            to: CGPoint(x: -34, y: 0),
            control1: CGPoint(x: -12, y: 6),
            control2: CGPoint(x: -26, y: 5)
        )
        corePath.addCurve(
            to: CGPoint(x: -1, y: 0),
            control1: CGPoint(x: -25, y: -5),
            control2: CGPoint(x: -11, y: -6)
        )
        corePath.closeSubpath()
        let flameCore = SKShapeNode(path: corePath)
        flameCore.fillColor = .white
        flameCore.strokeColor = glitchBlue
        flameCore.lineWidth = 2
        flameCore.glowWidth = 3
        flame.addChild(flameCore)
        exhaust.addChild(flame)

        let particles = SKEmitterNode()
        particles.name = "exhaustParticles"
        particles.particleTexture = softParticleTexture()
        particles.particleBirthRate = 0
        particles.particleLifetime = 0.34
        particles.particleLifetimeRange = 0.12
        particles.particlePositionRange = CGVector(dx: 4, dy: 7)
        particles.emissionAngle = .pi
        particles.emissionAngleRange = 0.22
        particles.particleSpeed = 195
        particles.particleSpeedRange = 75
        particles.particleAlpha = 0.9
        particles.particleAlphaRange = 0.1
        particles.particleAlphaSpeed = -2.4
        particles.particleScale = 0.22
        particles.particleScaleRange = 0.11
        particles.particleScaleSpeed = -0.36
        particles.particleColor = glitchBlue
        particles.particleColorBlendFactor = 1
        particles.particleBlendMode = .add
        particles.particleZPosition = -1
        exhaust.addChild(particles)

        nozzle.addChild(exhaust)
        player.addChild(nozzle)

        let character = SKSpriteNode(imageNamed: "AidanFlying")
        character.name = "characterArt"
        character.size = CGSize(width: 230, height: 115)
        character.position = CGPoint(x: 5, y: 2)
        character.zPosition = 1
        player.addChild(character)

        let shield = SKShapeNode(ellipseOf: CGSize(width: 208, height: 128))
        shield.name = "shieldAura"
        shield.fillColor = glitchBlue.withAlphaComponent(0.12)
        shield.strokeColor = glitchBlue
        shield.lineWidth = 4
        shield.glowWidth = 8
        shield.isHidden = true
        shield.zPosition = -4
        player.addChild(shield)

        let magnetAura = SKShapeNode(ellipseOf: CGSize(width: 226, height: 144))
        magnetAura.name = "magnetAura"
        magnetAura.fillColor = .clear
        magnetAura.strokeColor = UIColor(red: 1, green: 0.84, blue: 0.16, alpha: 0.7)
        magnetAura.lineWidth = 3
        magnetAura.isHidden = true
        magnetAura.zPosition = -5
        player.addChild(magnetAura)

        player.physicsBody = SKPhysicsBody(
            circleOfRadius: GameConstants.playerCollisionRadius,
            center: CGPoint(x: 0, y: 3)
        )
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.hazard | PhysicsCategory.chip | PhysicsCategory.powerUp
        player.physicsBody?.collisionBitMask = 0
        return player
    }

    static func applyBoosterStyle(_ style: BoosterStyle, to player: SKNode) {
        if let rim = player.childNode(withName: "//nozzleRim") as? SKShapeNode {
            rim.fillColor = style.bodyColor
            rim.strokeColor = style.trailColor
        }
        if let flame = player.childNode(withName: "//flame") as? SKShapeNode {
            flame.strokeColor = style.trailColor
        }
        if let particles = player.childNode(withName: "//exhaustParticles") as? SKEmitterNode {
            particles.particleColor = style.trailColor
        }
    }

    static func makeChip() -> SKNode {
        let chip = SKNode()
        chip.name = "chip"

        let art = SKSpriteNode(imageNamed: "GameChip")
        art.size = CGSize(width: 58, height: 58)
        chip.addChild(art)

        chip.physicsBody = SKPhysicsBody(circleOfRadius: 22)
        chip.physicsBody?.isDynamic = false
        chip.physicsBody?.categoryBitMask = PhysicsCategory.chip
        chip.physicsBody?.contactTestBitMask = PhysicsCategory.player
        chip.physicsBody?.collisionBitMask = 0
        art.run(.repeatForever(.sequence([
            .group([
                .scaleX(to: 0.62, duration: 0.34),
                .scaleY(to: 1.04, duration: 0.34)
            ]),
            .group([
                .scaleX(to: 1, duration: 0.34),
                .scaleY(to: 1, duration: 0.34)
            ])
        ])))
        return chip
    }

    static func makePowerUp(_ kind: PowerUpKind) -> SKNode {
        let root = SKNode()
        root.name = "powerUp"
        root.userData = ["kind": kind.rawValue]

        let art = SKSpriteNode(imageNamed: kind == .shield ? "ShieldPickup" : "MagnetPickup")
        art.size = CGSize(width: 86, height: 86)
        root.addChild(art)

        root.physicsBody = SKPhysicsBody(circleOfRadius: 32)
        root.physicsBody?.isDynamic = false
        root.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        root.physicsBody?.contactTestBitMask = PhysicsCategory.player
        root.physicsBody?.collisionBitMask = 0
        root.run(.repeatForever(.sequence([
            .scale(to: 1.12, duration: 0.42),
            .scale(to: 0.92, duration: 0.42)
        ])))
        return root
    }

    static func makeGlitchEnemy() -> SKNode {
        let root = SKNode()
        root.name = "hazard"

        let body = SKSpriteNode(imageNamed: "GlitchEnemy")
        body.name = "glitchArt"
        body.size = CGSize(width: 112, height: 112)
        root.addChild(body)

        body.run(.repeatForever(.sequence([
            .group([
                .rotate(toAngle: 0.045, duration: 0.22, shortestUnitArc: true),
                .scaleX(to: 1.035, duration: 0.22),
                .scaleY(to: 0.97, duration: 0.22)
            ]),
            .group([
                .rotate(toAngle: -0.035, duration: 0.18, shortestUnitArc: true),
                .scaleX(to: 0.98, duration: 0.18),
                .scaleY(to: 1.035, duration: 0.18)
            ]),
            .group([
                .rotate(toAngle: 0, duration: 0.13, shortestUnitArc: true),
                .scale(to: 1, duration: 0.13)
            ]),
            .wait(forDuration: 0.10)
        ])))

        root.physicsBody = SKPhysicsBody(circleOfRadius: 42)
        root.physicsBody?.isDynamic = false
        root.physicsBody?.categoryBitMask = PhysicsCategory.hazard
        root.physicsBody?.contactTestBitMask = PhysicsCategory.player
        root.physicsBody?.collisionBitMask = 0
        return root
    }

    static func makeEnemy(_ kind: EnemyKind) -> SKNode {
        let root = SKNode()
        root.name = "hazard"
        root.userData = [
            "enemyKind": kind.rawValue,
            "nearMissChecked": false
        ]

        let art = SKSpriteNode(imageNamed: kind.assetName)
        art.name = "enemyArt"
        let radius: CGFloat
        switch kind {
        case .cloudSwooper:
            art.size = CGSize(width: 164, height: 92)
            radius = 36
        case .jungleSnapper:
            art.size = CGSize(width: 140, height: 100)
            radius = 36
        case .candyBouncer:
            art.size = CGSize(width: 108, height: 108)
            radius = 38
        case .castleGargoyle:
            art.size = CGSize(width: 132, height: 104)
            radius = 38
        }
        root.userData?["collisionRadius"] = radius
        root.addChild(art)

        let breathing: SKAction
        switch kind {
        case .cloudSwooper:
            breathing = .sequence([
                .group([.scaleX(to: 1.05, duration: 0.28), .scaleY(to: 0.95, duration: 0.28)]),
                .group([.scaleX(to: 0.97, duration: 0.24), .scaleY(to: 1.04, duration: 0.24)])
            ])
        case .jungleSnapper:
            breathing = .sequence([
                .rotate(toAngle: 0.045, duration: 0.20, shortestUnitArc: true),
                .rotate(toAngle: -0.035, duration: 0.20, shortestUnitArc: true)
            ])
        case .candyBouncer:
            breathing = .sequence([
                .group([.scaleX(to: 1.06, duration: 0.18), .scaleY(to: 0.94, duration: 0.18)]),
                .group([.scaleX(to: 0.95, duration: 0.20), .scaleY(to: 1.07, duration: 0.20)])
            ])
        case .castleGargoyle:
            breathing = .sequence([
                .rotate(toAngle: 0.04, duration: 0.24, shortestUnitArc: true),
                .rotate(toAngle: -0.04, duration: 0.24, shortestUnitArc: true)
            ])
        }
        art.run(.repeatForever(breathing))

        root.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        root.physicsBody?.isDynamic = false
        root.physicsBody?.categoryBitMask = PhysicsCategory.hazard
        root.physicsBody?.contactTestBitMask = PhysicsCategory.player
        root.physicsBody?.collisionBitMask = 0
        return root
    }

    static func makeGlitchBoss() -> SKNode {
        let boss = makeGlitchEnemy()
        boss.name = "boss"
        boss.setScale(2.15)
        boss.removeAllActions()
        boss.physicsBody = SKPhysicsBody(circleOfRadius: 82)
        boss.physicsBody?.isDynamic = false
        boss.physicsBody?.categoryBitMask = PhysicsCategory.boss
        boss.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.heroShot
        boss.physicsBody?.collisionBitMask = 0

        let crownPath = polygonPath([
            CGPoint(x: -30, y: 43),
            CGPoint(x: -20, y: 76),
            CGPoint(x: 0, y: 55),
            CGPoint(x: 20, y: 78),
            CGPoint(x: 34, y: 42)
        ])
        let crown = SKShapeNode(path: crownPath)
        crown.fillColor = UIColor(red: 1, green: 0.78, blue: 0.14, alpha: 1)
        crown.strokeColor = .white
        crown.lineWidth = 3
        crown.position.y = 20
        boss.addChild(crown)

        return boss
    }

    static func makeHeroBolt(color: UIColor) -> SKNode {
        let root = SKNode()
        root.name = "heroShot"

        let star = SKShapeNode(path: starPath(outerRadius: 16, innerRadius: 8, points: 5))
        star.fillColor = UIColor(red: 1, green: 0.88, blue: 0.18, alpha: 1)
        star.strokeColor = color
        star.lineWidth = 3
        star.glowWidth = 5
        root.addChild(star)

        root.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        root.physicsBody?.isDynamic = true
        root.physicsBody?.affectedByGravity = false
        root.physicsBody?.allowsRotation = false
        root.physicsBody?.usesPreciseCollisionDetection = true
        root.physicsBody?.categoryBitMask = PhysicsCategory.heroShot
        root.physicsBody?.contactTestBitMask = PhysicsCategory.boss
        root.physicsBody?.collisionBitMask = 0
        return root
    }

    static func makeBossOrb() -> SKNode {
        let root = SKNode()
        root.name = "hazard"

        let orb = SKShapeNode(circleOfRadius: 24)
        orb.fillColor = ink
        orb.strokeColor = glitchPink
        orb.lineWidth = 4
        orb.glowWidth = 6
        root.addChild(orb)

        let core = SKShapeNode(rectOf: CGSize(width: 21, height: 7), cornerRadius: 2)
        core.fillColor = glitchBlue
        core.strokeColor = .clear
        orb.addChild(core)

        root.physicsBody = SKPhysicsBody(circleOfRadius: 24)
        root.physicsBody?.isDynamic = false
        root.physicsBody?.categoryBitMask = PhysicsCategory.hazard
        root.physicsBody?.contactTestBitMask = PhysicsCategory.player
        root.physicsBody?.collisionBitMask = 0
        return root
    }

    static func makeFallingHazard(for theme: WorldTheme) -> SKNode {
        let root = SKNode()
        root.name = "hazard"

        let art = SKSpriteNode(imageNamed: theme.hazardAssetName)
        art.size = CGSize(width: 82, height: 82)
        root.addChild(art)

        root.physicsBody = SKPhysicsBody(circleOfRadius: 34)
        root.physicsBody?.isDynamic = false
        root.physicsBody?.categoryBitMask = PhysicsCategory.hazard
        root.physicsBody?.contactTestBitMask = PhysicsCategory.player
        root.physicsBody?.collisionBitMask = 0
        art.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 1.6)))
        return root
    }

    static func makeBarrier(for theme: WorldTheme, size: CGSize) -> SKNode {
        let root = SKNode()
        root.name = "hazard"

        let art = SKSpriteNode(imageNamed: theme.barrierAssetName)
        art.size = CGSize(width: size.width + 22, height: max(48, size.height + 12))
        root.addChild(art)

        root.physicsBody = SKPhysicsBody(rectangleOf: size)
        root.physicsBody?.isDynamic = false
        root.physicsBody?.categoryBitMask = PhysicsCategory.hazard
        root.physicsBody?.contactTestBitMask = PhysicsCategory.player
        root.physicsBody?.collisionBitMask = 0
        return root
    }

    static func makeWorldBadge(for theme: WorldTheme, radius: CGFloat = 43) -> SKNode {
        let badge = SKNode()
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = theme.skyColor
        circle.strokeColor = theme.accentColor
        circle.lineWidth = 4
        badge.addChild(circle)

        let symbol = SKLabelNode(fontNamed: "AppleColorEmoji")
        symbol.text = switch theme {
        case .cloudKingdom: "☁️"
        case .dinoJungle: "🦕"
        case .candyCanyon: "🍭"
        case .storybookCastle: "🏰"
        }
        symbol.fontSize = radius * 0.9
        symbol.verticalAlignmentMode = .center
        badge.addChild(symbol)
        return badge
    }

    private static func makeSceneryTile(for theme: WorldTheme, size: CGSize, variant: Int) -> SKNode {
        let tile = SKNode()
        let floorHeight = size.height * 0.17

        let distantGround = SKShapeNode(rectOf: CGSize(width: size.width, height: floorHeight * 1.8))
        distantGround.position = CGPoint(x: size.width / 2, y: floorHeight * 0.5)
        distantGround.fillColor = theme.horizonColor
        distantGround.strokeColor = .clear
        tile.addChild(distantGround)

        switch theme {
        case .cloudKingdom:
            addCloudKingdom(to: tile, size: size, variant: variant)
        case .dinoJungle:
            addDinoJungle(to: tile, size: size, variant: variant)
        case .candyCanyon:
            addCandyCanyon(to: tile, size: size, variant: variant)
        case .storybookCastle:
            addStorybookCastle(to: tile, size: size, variant: variant)
        }

        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: floorHeight))
        ground.position = CGPoint(x: size.width / 2, y: floorHeight / 2)
        ground.fillColor = theme.groundColor
        ground.strokeColor = theme.accentColor
        ground.lineWidth = 4
        ground.zPosition = 5
        tile.addChild(ground)

        return tile
    }

    private static func addCloudKingdom(to tile: SKNode, size: CGSize, variant: Int) {
        for index in 0..<6 {
            let cloud = makeCloud(scale: 0.75 + CGFloat((index + variant) % 3) * 0.18)
            cloud.position = CGPoint(
                x: size.width * (CGFloat(index) + 0.3) / 6,
                y: size.height * (0.32 + CGFloat((index * 17 + variant * 9) % 45) / 100)
            )
            tile.addChild(cloud)
        }

        for index in 0..<3 {
            let island = SKShapeNode(ellipseOf: CGSize(width: 170, height: 52))
            island.position = CGPoint(x: size.width * (CGFloat(index) + 0.55) / 3, y: size.height * (0.28 + CGFloat(index % 2) * 0.10))
            island.fillColor = UIColor(red: 0.34, green: 0.62, blue: 0.30, alpha: 1)
            island.strokeColor = .white
            island.lineWidth = 3
            tile.addChild(island)
        }
    }

    private static func addDinoJungle(to tile: SKNode, size: CGSize, variant: Int) {
        let volcano = SKShapeNode(path: polygonPath([
            CGPoint(x: size.width * 0.12, y: size.height * 0.17),
            CGPoint(x: size.width * 0.34, y: size.height * 0.62),
            CGPoint(x: size.width * 0.54, y: size.height * 0.17)
        ]))
        volcano.fillColor = UIColor(red: 0.22, green: 0.30, blue: 0.18, alpha: 1)
        volcano.strokeColor = .clear
        tile.addChild(volcano)

        for index in 0..<8 {
            let x = size.width * (CGFloat(index) + 0.25) / 8
            let trunk = SKShapeNode(rectOf: CGSize(width: 18, height: size.height * 0.18), cornerRadius: 7)
            trunk.position = CGPoint(x: x, y: size.height * 0.24)
            trunk.fillColor = UIColor(red: 0.30, green: 0.18, blue: 0.08, alpha: 1)
            trunk.strokeColor = .clear
            tile.addChild(trunk)

            let canopy = SKShapeNode(circleOfRadius: 42 + CGFloat((index + variant) % 3) * 6)
            canopy.position = CGPoint(x: x, y: size.height * 0.35)
            canopy.fillColor = index.isMultiple(of: 2)
                ? UIColor(red: 0.10, green: 0.48, blue: 0.20, alpha: 1)
                : UIColor(red: 0.20, green: 0.62, blue: 0.24, alpha: 1)
            canopy.strokeColor = .clear
            tile.addChild(canopy)
        }
    }

    private static func addCandyCanyon(to tile: SKNode, size: CGSize, variant: Int) {
        for index in 0..<5 {
            let hill = SKShapeNode(circleOfRadius: size.width * 0.10)
            hill.position = CGPoint(x: size.width * (CGFloat(index) + 0.4) / 5, y: size.height * 0.19)
            hill.fillColor = index.isMultiple(of: 2)
                ? UIColor(red: 1, green: 0.70, blue: 0.78, alpha: 1)
                : UIColor(red: 0.78, green: 0.52, blue: 0.92, alpha: 1)
            hill.strokeColor = .clear
            tile.addChild(hill)
        }

        for index in 0..<6 {
            let stick = SKShapeNode(rectOf: CGSize(width: 9, height: 90), cornerRadius: 4)
            stick.position = CGPoint(x: size.width * (CGFloat(index) + 0.6) / 6, y: size.height * 0.28)
            stick.fillColor = .white
            stick.strokeColor = .clear
            tile.addChild(stick)

            let candy = SKShapeNode(circleOfRadius: 29 + CGFloat((index + variant) % 2) * 7)
            candy.position = CGPoint(x: stick.position.x, y: stick.position.y + 52)
            candy.fillColor = index.isMultiple(of: 2)
                ? UIColor(red: 1, green: 0.18, blue: 0.46, alpha: 1)
                : UIColor(red: 0.26, green: 0.86, blue: 0.86, alpha: 1)
            candy.strokeColor = .white
            candy.lineWidth = 5
            tile.addChild(candy)
        }
    }

    private static func addStorybookCastle(to tile: SKNode, size: CGSize, variant: Int) {
        for index in 0..<4 {
            let hill = SKShapeNode(circleOfRadius: size.width * 0.16)
            hill.position = CGPoint(x: size.width * (CGFloat(index) + 0.3) / 4, y: size.height * 0.1)
            hill.fillColor = UIColor(red: 0.22, green: 0.34, blue: 0.30, alpha: 1)
            hill.strokeColor = .clear
            tile.addChild(hill)
        }

        for index in 0..<3 {
            let tower = shape(
                rect: CGSize(width: 90, height: 170 + CGFloat((index + variant) % 2) * 45),
                radius: 5,
                fill: UIColor(red: 0.28, green: 0.24, blue: 0.48, alpha: 1),
                stroke: UIColor(red: 0.68, green: 0.58, blue: 0.92, alpha: 1)
            )
            tower.position = CGPoint(x: size.width * (CGFloat(index) + 0.65) / 3, y: size.height * 0.28)
            tower.lineWidth = 3
            tile.addChild(tower)

            let roof = SKShapeNode(path: polygonPath([
                CGPoint(x: -58, y: 80),
                CGPoint(x: 0, y: 145),
                CGPoint(x: 58, y: 80)
            ]))
            roof.fillColor = UIColor(red: 0.62, green: 0.18, blue: 0.42, alpha: 1)
            roof.strokeColor = UIColor(red: 1, green: 0.72, blue: 0.28, alpha: 1)
            roof.lineWidth = 3
            tower.addChild(roof)
        }
    }

    private static func makeCloud(scale: CGFloat) -> SKNode {
        let cloud = SKNode()
        for (x, y, radius) in [(-34.0, 0.0, 23.0), (0.0, 12.0, 34.0), (39.0, 0.0, 25.0)] {
            let puff = SKShapeNode(circleOfRadius: CGFloat(radius) * scale)
            puff.position = CGPoint(x: CGFloat(x) * scale, y: CGFloat(y) * scale)
            puff.fillColor = UIColor.white.withAlphaComponent(0.82)
            puff.strokeColor = .clear
            cloud.addChild(puff)
        }
        return cloud
    }

    private static func shape(
        rect size: CGSize,
        radius: CGFloat,
        fill: UIColor,
        stroke: UIColor
    ) -> SKShapeNode {
        let shape = SKShapeNode(rectOf: size, cornerRadius: radius)
        shape.fillColor = fill
        shape.strokeColor = stroke
        shape.lineWidth = stroke == .clear ? 0 : 2
        return shape
    }

    private static func polygonPath(_ points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() { path.addLine(to: point) }
        path.closeSubpath()
        return path
    }

    private static func starPath(outerRadius: CGFloat, innerRadius: CGFloat, points: Int) -> CGPath {
        let path = CGMutablePath()
        for index in 0..<(points * 2) {
            let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = CGFloat(index) * .pi / CGFloat(points) - .pi / 2
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            index == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}
