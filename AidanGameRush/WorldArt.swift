import SpriteKit
import UIKit

@MainActor
enum WorldArt {
    static let glitchPink = UIColor(red: 0.98, green: 0.08, blue: 0.62, alpha: 1)
    static let glitchBlue = UIColor(red: 0.10, green: 0.92, blue: 1, alpha: 1)
    static let ink = UIColor(red: 0.035, green: 0.025, blue: 0.09, alpha: 1)

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

        let flamePath = CGMutablePath()
        flamePath.move(to: CGPoint(x: -98, y: 12))
        flamePath.addLine(to: CGPoint(x: -50, y: 27))
        flamePath.addLine(to: CGPoint(x: -54, y: 1))
        flamePath.closeSubpath()
        let flame = SKShapeNode(path: flamePath)
        flame.name = "flame"
        flame.fillColor = UIColor(red: 1, green: 0.88, blue: 0.18, alpha: 1)
        flame.strokeColor = UIColor(red: 1, green: 0.28, blue: 0.12, alpha: 1)
        flame.lineWidth = 3
        flame.glowWidth = 5
        flame.zPosition = -3

        let flameCore = SKShapeNode(path: flamePath)
        flameCore.setScale(0.58)
        flameCore.position = CGPoint(x: -22, y: 5)
        flameCore.fillColor = .white
        flameCore.strokeColor = glitchBlue
        flameCore.lineWidth = 2
        flameCore.glowWidth = 3
        flame.addChild(flameCore)
        player.addChild(flame)

        let booster = shape(
            rect: CGSize(width: 24, height: 46),
            radius: 10,
            fill: UIColor(red: 0.42, green: 0.20, blue: 0.84, alpha: 1),
            stroke: glitchBlue
        )
        booster.name = "boosterPack"
        booster.position = CGPoint(x: -51, y: 18)
        booster.zRotation = -0.22
        booster.zPosition = -1
        booster.lineWidth = 3
        player.addChild(booster)

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

        player.physicsBody = SKPhysicsBody(circleOfRadius: 35, center: CGPoint(x: 0, y: 3))
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.hazard | PhysicsCategory.chip | PhysicsCategory.powerUp
        player.physicsBody?.collisionBitMask = 0
        return player
    }

    static func applyBoosterStyle(_ style: BoosterStyle, to player: SKNode) {
        if let booster = player.childNode(withName: "boosterPack") as? SKShapeNode {
            booster.fillColor = style.bodyColor
            booster.strokeColor = style.trailColor
        }
        if let flame = player.childNode(withName: "flame") as? SKShapeNode {
            flame.strokeColor = style.trailColor
        }
    }

    static func makeChip() -> SKNode {
        let chip = SKNode()
        chip.name = "chip"

        let path = CGMutablePath()
        for index in 0..<6 {
            let angle = CGFloat(index) * .pi / 3
            let point = CGPoint(x: cos(angle) * 22, y: sin(angle) * 22)
            index == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.closeSubpath()

        let coin = SKShapeNode(path: path)
        coin.fillColor = UIColor(red: 1, green: 0.82, blue: 0.12, alpha: 1)
        coin.strokeColor = .white
        coin.lineWidth = 3
        coin.glowWidth = 3
        chip.addChild(coin)

        let mark = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        mark.text = "★"
        mark.fontSize = 18
        mark.fontColor = UIColor(red: 0.90, green: 0.34, blue: 0.08, alpha: 1)
        mark.verticalAlignmentMode = .center
        coin.addChild(mark)

        chip.physicsBody = SKPhysicsBody(circleOfRadius: 22)
        chip.physicsBody?.isDynamic = false
        chip.physicsBody?.categoryBitMask = PhysicsCategory.chip
        chip.physicsBody?.contactTestBitMask = PhysicsCategory.player
        chip.physicsBody?.collisionBitMask = 0
        chip.run(.repeatForever(.rotate(byAngle: .pi, duration: 0.8)))
        return chip
    }

    static func makePowerUp(_ kind: PowerUpKind) -> SKNode {
        let root = SKNode()
        root.name = "powerUp"
        root.userData = ["kind": kind.rawValue]

        let bubble = SKShapeNode(circleOfRadius: 32)
        bubble.fillColor = kind == .shield
            ? glitchBlue.withAlphaComponent(0.45)
            : UIColor(red: 1, green: 0.78, blue: 0.12, alpha: 0.45)
        bubble.strokeColor = kind == .shield ? glitchBlue : UIColor(red: 1, green: 0.86, blue: 0.18, alpha: 1)
        bubble.lineWidth = 4
        bubble.glowWidth = 7
        root.addChild(bubble)

        let icon = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        icon.text = kind == .shield ? "S" : "U"
        icon.fontSize = 26
        icon.fontColor = .white
        icon.verticalAlignmentMode = .center
        bubble.addChild(icon)

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

        let path = CGMutablePath()
        let points = [
            CGPoint(x: -39, y: 8), CGPoint(x: -29, y: 35), CGPoint(x: -5, y: 29),
            CGPoint(x: 13, y: 43), CGPoint(x: 37, y: 21), CGPoint(x: 31, y: -4),
            CGPoint(x: 41, y: -29), CGPoint(x: 10, y: -34), CGPoint(x: -12, y: -45),
            CGPoint(x: -25, y: -24), CGPoint(x: -46, y: -14)
        ]
        path.move(to: points[0])
        for point in points.dropFirst() { path.addLine(to: point) }
        path.closeSubpath()

        let body = SKShapeNode(path: path)
        body.fillColor = ink
        body.strokeColor = glitchPink
        body.lineWidth = 4
        body.glowWidth = 5
        root.addChild(body)

        for x in [-14, 14] as [CGFloat] {
            let eye = SKShapeNode(rectOf: CGSize(width: 13, height: 8), cornerRadius: 2)
            eye.position = CGPoint(x: x, y: 7)
            eye.fillColor = x < 0 ? glitchBlue : glitchPink
            eye.strokeColor = .white
            eye.lineWidth = 1
            body.addChild(eye)
        }

        let mouth = SKShapeNode(rectOf: CGSize(width: 24, height: 4))
        mouth.position.y = -13
        mouth.fillColor = glitchPink
        mouth.strokeColor = .clear
        body.addChild(mouth)

        for index in 0..<3 {
            let shard = SKShapeNode(rectOf: CGSize(width: CGFloat(13 + index * 5), height: 3))
            shard.position = CGPoint(x: CGFloat(49 + index * 11), y: CGFloat(19 - index * 18))
            shard.fillColor = index.isMultiple(of: 2) ? glitchBlue : glitchPink
            shard.strokeColor = .clear
            root.addChild(shard)
            shard.run(.repeatForever(.sequence([
                .wait(forDuration: 0.08 * Double(index)),
                .fadeAlpha(to: 0.25, duration: 0.07),
                .moveBy(x: CGFloat(5 + index * 2), y: index.isMultiple(of: 2) ? 4 : -4, duration: 0.09),
                .group([
                    .fadeAlpha(to: 1, duration: 0.08),
                    .moveBy(x: CGFloat(-(5 + index * 2)), y: index.isMultiple(of: 2) ? -4 : 4, duration: 0.08)
                ]),
                .wait(forDuration: 0.20)
            ])))
        }

        body.run(.repeatForever(.sequence([
            .group([
                .rotate(toAngle: 0.055, duration: 0.16, shortestUnitArc: true),
                .scaleX(to: 1.05, duration: 0.16),
                .scaleY(to: 0.96, duration: 0.16)
            ]),
            .group([
                .rotate(toAngle: -0.045, duration: 0.14, shortestUnitArc: true),
                .scaleX(to: 0.96, duration: 0.14),
                .scaleY(to: 1.05, duration: 0.14)
            ]),
            .group([
                .rotate(toAngle: 0, duration: 0.10, shortestUnitArc: true),
                .scale(to: 1, duration: 0.10)
            ]),
            .wait(forDuration: 0.16)
        ])))

        root.physicsBody = SKPhysicsBody(circleOfRadius: 39)
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

        let item: SKShapeNode
        switch theme {
        case .cloudKingdom:
            item = SKShapeNode(path: starPath(outerRadius: 36, innerRadius: 21, points: 8))
            item.fillColor = UIColor(red: 0.37, green: 0.38, blue: 0.43, alpha: 1)
        case .dinoJungle:
            item = SKShapeNode(circleOfRadius: 34)
            item.fillColor = UIColor(red: 0.37, green: 0.23, blue: 0.12, alpha: 1)
        case .candyCanyon:
            item = SKShapeNode(circleOfRadius: 34)
            item.fillColor = UIColor(red: 0.94, green: 0.22, blue: 0.42, alpha: 1)
        case .storybookCastle:
            item = SKShapeNode(rectOf: CGSize(width: 55, height: 62), cornerRadius: 5)
            item.fillColor = UIColor(red: 0.35, green: 0.19, blue: 0.52, alpha: 1)
        }
        item.strokeColor = glitchPink
        item.lineWidth = 4
        item.glowWidth = 3
        root.addChild(item)

        let corruption = SKShapeNode(rectOf: CGSize(width: 25, height: 8), cornerRadius: 2)
        corruption.position = CGPoint(x: 8, y: 4)
        corruption.fillColor = ink
        corruption.strokeColor = glitchBlue
        corruption.lineWidth = 2
        item.addChild(corruption)

        root.physicsBody = SKPhysicsBody(circleOfRadius: 34)
        root.physicsBody?.isDynamic = false
        root.physicsBody?.categoryBitMask = PhysicsCategory.hazard
        root.physicsBody?.contactTestBitMask = PhysicsCategory.player
        root.physicsBody?.collisionBitMask = 0
        root.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 1.4)))
        return root
    }

    static func makeBarrier(for theme: WorldTheme, size: CGSize) -> SKNode {
        let root = SKNode()
        root.name = "hazard"

        let body = shape(
            rect: size,
            radius: theme == .storybookCastle ? 4 : 18,
            fill: barrierColor(for: theme),
            stroke: theme.accentColor
        )
        body.lineWidth = 4
        root.addChild(body)

        switch theme {
        case .cloudKingdom:
            let count = max(1, Int(size.height / 62))
            for index in 0..<count {
                let puff = SKShapeNode(circleOfRadius: 29)
                puff.position = CGPoint(x: index.isMultiple(of: 2) ? -18 : 16, y: -size.height / 2 + 32 + CGFloat(index) * 61)
                puff.fillColor = UIColor.white.withAlphaComponent(0.92)
                puff.strokeColor = UIColor(red: 0.60, green: 0.84, blue: 1, alpha: 1)
                puff.lineWidth = 2
                body.addChild(puff)
            }
        case .dinoJungle:
            let count = max(1, Int(size.height / 54))
            for index in 0..<count {
                let leaf = SKShapeNode(ellipseOf: CGSize(width: 43, height: 22))
                leaf.position = CGPoint(x: index.isMultiple(of: 2) ? -28 : 28, y: -size.height / 2 + 25 + CGFloat(index) * 52)
                leaf.fillColor = index.isMultiple(of: 2) ? theme.accentColor : UIColor(red: 0.08, green: 0.52, blue: 0.24, alpha: 1)
                leaf.strokeColor = .clear
                leaf.zRotation = index.isMultiple(of: 2) ? 0.45 : -0.45
                body.addChild(leaf)
            }
        case .candyCanyon:
            let count = max(1, Int(size.height / 46))
            for index in 0..<count {
                let stripe = SKShapeNode(rectOf: CGSize(width: size.width - 8, height: 17), cornerRadius: 5)
                stripe.position.y = -size.height / 2 + 24 + CGFloat(index) * 46
                stripe.fillColor = index.isMultiple(of: 2) ? .white : theme.accentColor
                stripe.strokeColor = .clear
                stripe.zRotation = -0.17
                body.addChild(stripe)
            }
        case .storybookCastle:
            let rows = max(1, Int(size.height / 32))
            for row in 0..<rows {
                let mortar = SKShapeNode(rectOf: CGSize(width: size.width - 5, height: 2))
                mortar.position.y = -size.height / 2 + CGFloat(row) * 32
                mortar.fillColor = UIColor.white.withAlphaComponent(0.26)
                mortar.strokeColor = .clear
                body.addChild(mortar)
            }
        }

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

    private static func barrierColor(for theme: WorldTheme) -> UIColor {
        switch theme {
        case .cloudKingdom: UIColor(red: 0.76, green: 0.90, blue: 1, alpha: 1)
        case .dinoJungle: UIColor(red: 0.16, green: 0.40, blue: 0.16, alpha: 1)
        case .candyCanyon: UIColor(red: 0.92, green: 0.28, blue: 0.52, alpha: 1)
        case .storybookCastle: UIColor(red: 0.36, green: 0.32, blue: 0.56, alpha: 1)
        }
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
