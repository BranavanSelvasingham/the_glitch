import AVFoundation

@MainActor
final class GameAudio {
    enum Effect {
        case begin
        case chip
        case powerUp
        case shieldHit
        case crash
        case worldChange

        var notes: [(frequency: Double, duration: Double)] {
            switch self {
            case .begin: [(392, 0.08), (523, 0.10), (659, 0.14)]
            case .chip: [(880, 0.07), (1_174, 0.09)]
            case .powerUp: [(440, 0.08), (660, 0.08), (880, 0.14)]
            case .shieldHit: [(310, 0.08), (220, 0.12)]
            case .crash: [(150, 0.16), (92, 0.24)]
            case .worldChange: [(523, 0.09), (659, 0.09), (784, 0.16)]
            }
        }
    }

    static let shared = GameAudio()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!

    private init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.22

        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        try? engine.start()
    }

    func play(_ effect: Effect) {
        if !engine.isRunning {
            try? engine.start()
        }

        for note in effect.notes {
            guard let buffer = makeTone(frequency: note.frequency, duration: note.duration) else { continue }
            player.scheduleBuffer(buffer)
        }
        if !player.isPlaying {
            player.play()
        }
    }

    private func makeTone(frequency: Double, duration: Double) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(format.sampleRate * duration)
        guard
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
            let channel = buffer.floatChannelData?[0]
        else {
            return nil
        }

        buffer.frameLength = frameCount
        for frame in 0..<Int(frameCount) {
            let progress = Double(frame) / Double(max(1, Int(frameCount) - 1))
            let attack = min(1, progress / 0.08)
            let release = min(1, (1 - progress) / 0.25)
            let envelope = min(attack, release)
            let sample = sin(2 * .pi * frequency * Double(frame) / format.sampleRate)
            channel[frame] = Float(sample * envelope * 0.34)
        }
        return buffer
    }
}

