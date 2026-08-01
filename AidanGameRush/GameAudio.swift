import AVFoundation

@MainActor
final class GameAudio {
    enum Effect: Hashable, CaseIterable {
        case begin
        case chip
        case powerUp
        case shieldHit
        case crash
        case worldChange
        case button

        var notes: [(frequency: Double, duration: Double)] {
            switch self {
            case .begin: [(392, 0.08), (523, 0.10), (659, 0.14)]
            case .chip: [(880, 0.055), (1_174, 0.085)]
            case .powerUp: [(440, 0.07), (660, 0.08), (880, 0.13), (1_100, 0.16)]
            case .shieldHit: [(310, 0.08), (220, 0.12)]
            case .crash: [(150, 0.13), (112, 0.18), (82, 0.25)]
            case .worldChange: [(523, 0.08), (659, 0.08), (784, 0.13), (1_047, 0.18)]
            case .button: [(620, 0.045), (780, 0.055)]
            }
        }
    }

    enum MusicTheme: Hashable, CaseIterable {
        case title
        case cloudKingdom
        case dinoJungle
        case candyCanyon
        case storybookCastle
        case boss
    }

    private enum Timbre {
        case airyBell
        case marimba
        case candyPop
        case storyHarp
        case bossPulse
    }

    private struct MusicProfile {
        let bpm: Double
        let rootMIDI: Int
        let scale: [Int]
        let melody: [Int]
        let bass: [Int]
        let chords: [Int]
        let timbre: Timbre
        let percussion: Double
    }

    static let shared = GameAudio()

    private static let muteKey = "AidanGameRush.audioMuted"

    private let engine = AVAudioEngine()
    private let musicPlayer = AVAudioPlayerNode()
    private let effectPlayers = (0..<4).map { _ in AVAudioPlayerNode() }
    private let effectFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    private let musicFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)!

    private var nextEffectPlayer = 0
    private var currentTheme: MusicTheme?
    private var musicPaused = false
    private var effectBuffers: [Effect: [AVAudioPCMBuffer]] = [:]
    private var musicBuffers: [MusicTheme: AVAudioPCMBuffer] = [:]
    private var effectPeaks: [Effect: Float] = [:]
    private var musicPeaks: [MusicTheme: Float] = [:]

    private(set) var isMuted = UserDefaults.standard.bool(forKey: muteKey)
    private(set) var lastMusicPeak: Float = 0

    private init() {
        engine.attach(musicPlayer)
        engine.connect(musicPlayer, to: engine.mainMixerNode, format: musicFormat)

        for player in effectPlayers {
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: effectFormat)
        }

        engine.mainMixerNode.outputVolume = 1
        applyVolumes()

        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        try? engine.start()

        preloadSynthesizedAudio()
    }

    @discardableResult
    func toggleMute() -> Bool {
        isMuted.toggle()
        UserDefaults.standard.set(isMuted, forKey: Self.muteKey)
        applyVolumes()
        return isMuted
    }

    func play(_ effect: Effect) {
        guard !isMuted else { return }
        ensureEngineIsRunning()

        let player = effectPlayers[nextEffectPlayer]
        nextEffectPlayer = (nextEffectPlayer + 1) % effectPlayers.count
        player.stop()

        for buffer in effectBuffers[effect] ?? [] {
            player.scheduleBuffer(buffer)
        }
        player.play()
    }

    func playMusic(_ theme: MusicTheme) {
        if currentTheme == theme {
            resumeMusic()
            return
        }

        ensureEngineIsRunning()
        musicPlayer.stop()
        currentTheme = theme
        musicPaused = false

        guard let buffer = musicBuffers[theme] else { return }
        musicPlayer.scheduleBuffer(buffer, at: nil, options: .loops)
        musicPlayer.play()
    }

    func pauseMusic() {
        guard musicPlayer.isPlaying else { return }
        musicPlayer.pause()
        musicPaused = true
    }

    func resumeMusic() {
        guard musicPaused, currentTheme != nil else { return }
        ensureEngineIsRunning()
        musicPlayer.play()
        musicPaused = false
    }

    func stopMusic() {
        musicPlayer.stop()
        currentTheme = nil
        musicPaused = false
    }

    private func ensureEngineIsRunning() {
        if !engine.isRunning {
            try? engine.start()
        }
    }

    private func applyVolumes() {
        musicPlayer.volume = isMuted ? 0 : 0.16
        for player in effectPlayers {
            player.volume = isMuted ? 0 : 0.72
        }
    }

    private func preloadSynthesizedAudio() {
        for effect in Effect.allCases {
            let buffers = effect.notes.compactMap { note in
                makeTone(frequency: note.frequency, duration: note.duration)
            }
            effectBuffers[effect] = buffers
            effectPeaks[effect] = buffers.map(peakAmplitude).max() ?? 0
        }

        for theme in MusicTheme.allCases {
            musicBuffers[theme] = makeMusicBuffer(for: theme)
        }
    }

    private func peakAmplitude(in buffer: AVAudioPCMBuffer) -> Float {
        guard let channels = buffer.floatChannelData else { return 0 }
        var peak: Float = 0
        for channelIndex in 0..<Int(buffer.format.channelCount) {
            for frame in 0..<Int(buffer.frameLength) {
                peak = max(peak, abs(channels[channelIndex][frame]))
            }
        }
        return peak
    }

    private func makeTone(frequency: Double, duration: Double) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(effectFormat.sampleRate * duration)
        guard
            let buffer = AVAudioPCMBuffer(pcmFormat: effectFormat, frameCapacity: frameCount),
            let channel = buffer.floatChannelData?[0]
        else {
            return nil
        }

        buffer.frameLength = frameCount
        for frame in 0..<Int(frameCount) {
            let progress = Double(frame) / Double(max(1, Int(frameCount) - 1))
            let attack = min(1, progress / 0.055)
            let release = min(1, (1 - progress) / 0.28)
            let envelope = min(attack, release)
            let time = Double(frame) / effectFormat.sampleRate
            let phase = 2 * Double.pi * frequency * time
            let shimmer = sin(phase) + sin(phase * 2.01) * 0.24 + sin(phase * 3.02) * 0.10
            channel[frame] = Float(shimmer * envelope * 0.25)
        }
        return buffer
    }

    private func makeMusicBuffer(for theme: MusicTheme) -> AVAudioPCMBuffer? {
        let profile = musicProfile(for: theme)
        let secondsPerBeat = 60 / profile.bpm
        let stepDuration = secondsPerBeat / 2
        let duration = stepDuration * Double(profile.melody.count)
        let frameCount = AVAudioFrameCount(musicFormat.sampleRate * duration)

        guard
            let buffer = AVAudioPCMBuffer(pcmFormat: musicFormat, frameCapacity: frameCount),
            let channels = buffer.floatChannelData
        else {
            return nil
        }

        buffer.frameLength = frameCount
        var peak: Double = 0

        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / musicFormat.sampleRate
            let step = min(profile.melody.count - 1, Int(time / stepDuration))
            let stepPhase = (time.truncatingRemainder(dividingBy: stepDuration)) / stepDuration
            let beat = Int(time / secondsPerBeat)
            let beatPhase = (time.truncatingRemainder(dividingBy: secondsPerBeat)) / secondsPerBeat

            var melodySample = 0.0
            let degree = profile.melody[step]
            if degree >= 0 {
                let frequency = frequency(forDegree: degree, profile: profile, octaveOffset: 0)
                let envelope = melodyEnvelope(for: profile.timbre, phase: stepPhase)
                melodySample = timbreSample(profile.timbre, frequency: frequency, time: time) * envelope * 0.22
            }

            let bassDegree = profile.bass[beat % profile.bass.count]
            let bassFrequency = frequency(forDegree: bassDegree, profile: profile, octaveOffset: -2)
            let bassEnvelope = min(1, beatPhase / 0.04) * exp(-beatPhase * 2.4)
            let bassSample = sin(2 * .pi * bassFrequency * time) * bassEnvelope * 0.115

            let chordIndex = Int(time / (secondsPerBeat * 4)) % profile.chords.count
            let chordDegree = profile.chords[chordIndex]
            let chordRoot = frequency(forDegree: chordDegree, profile: profile, octaveOffset: -1)
            let padSample = (
                sin(2 * .pi * chordRoot * time)
                + sin(2 * .pi * chordRoot * 1.25 * time) * 0.65
                + sin(2 * .pi * chordRoot * 1.50 * time) * 0.52
            ) * 0.035

            let kick = sin(2 * .pi * 64 * time) * exp(-beatPhase * 18) * 0.12 * profile.percussion
            let halfBeatPhase = stepPhase
            let hatWave = sin(2 * .pi * 7_800 * time) >= 0 ? 1.0 : -1.0
            let hat = hatWave * exp(-halfBeatPhase * 32) * 0.018 * profile.percussion
            let backbeat = beat.isMultiple(of: 2)
                ? 0
                : sin(2 * .pi * 1_900 * time) * exp(-beatPhase * 22) * 0.035 * profile.percussion

            let loopEdge = min(1, min(time / 0.018, (duration - time) / 0.018))
            let center = (bassSample + padSample + kick + hat + backbeat) * loopEdge
            let pan = sin(Double(step) * 1.7) * 0.10
            let left = (center + melodySample * (1 - pan)) * 0.88
            let right = (center + melodySample * (1 + pan)) * 0.88

            channels[0][frame] = Float(left)
            channels[1][frame] = Float(right)
            peak = max(peak, max(abs(left), abs(right)))
        }

        lastMusicPeak = Float(peak)
        musicPeaks[theme] = Float(peak)
        assert(peak < 0.92, "Music mix clipped at peak \(peak)")
        return buffer
    }

    #if DEBUG
    struct QualityDiagnosticResult {
        let effectCoverage: Int
        let themeCoverage: Int
        let maximumEffectScheduleMS: Double
        let maximumMusicScheduleMS: Double
        let maximumEffectPeak: Float
        let maximumMusicPeak: Float
        let muteRoundTripPassed: Bool
        let ambientSessionPassed: Bool

        var passed: Bool {
            effectCoverage == Effect.allCases.count
                && themeCoverage == MusicTheme.allCases.count
                && maximumEffectScheduleMS <= 16.7
                && maximumMusicScheduleMS <= 16.7
                && maximumEffectPeak < 0.92
                && maximumMusicPeak < 0.92
                && muteRoundTripPassed
                && ambientSessionPassed
        }
    }

    func runQualityDiagnostic() -> QualityDiagnosticResult {
        let originalMute = isMuted
        if isMuted {
            _ = toggleMute()
        }

        var effectScheduleTimes: [Double] = []
        for effect in Effect.allCases {
            let start = ProcessInfo.processInfo.systemUptime
            play(effect)
            effectScheduleTimes.append((ProcessInfo.processInfo.systemUptime - start) * 1_000)
        }

        var musicScheduleTimes: [Double] = []
        for theme in MusicTheme.allCases {
            let start = ProcessInfo.processInfo.systemUptime
            playMusic(theme)
            musicScheduleTimes.append((ProcessInfo.processInfo.systemUptime - start) * 1_000)
        }
        stopMusic()

        let muteRoundTripPassed = validateMuteRoundTrip()
        if isMuted != originalMute {
            _ = toggleMute()
        }

        let session = AVAudioSession.sharedInstance()
        let ambientSessionPassed = session.category == .ambient
            && session.categoryOptions.contains(.mixWithOthers)

        return QualityDiagnosticResult(
            effectCoverage: Effect.allCases.filter {
                effectBuffers[$0]?.count == $0.notes.count
            }.count,
            themeCoverage: MusicTheme.allCases.filter { musicBuffers[$0] != nil }.count,
            maximumEffectScheduleMS: effectScheduleTimes.max() ?? .infinity,
            maximumMusicScheduleMS: musicScheduleTimes.max() ?? .infinity,
            maximumEffectPeak: effectPeaks.values.max() ?? .infinity,
            maximumMusicPeak: musicPeaks.values.max() ?? .infinity,
            muteRoundTripPassed: muteRoundTripPassed && isMuted == originalMute,
            ambientSessionPassed: ambientSessionPassed
        )
    }

    private func validateMuteRoundTrip() -> Bool {
        let initialMute = isMuted
        let firstMute = toggleMute()
        let firstVolumesMatch = volumesMatchMuteState()
        let secondMute = toggleMute()
        let secondVolumesMatch = volumesMatchMuteState()
        return firstMute != initialMute
            && secondMute == initialMute
            && firstVolumesMatch
            && secondVolumesMatch
    }

    private func volumesMatchMuteState() -> Bool {
        let expectedMusic: Float = isMuted ? 0 : 0.16
        let expectedEffect: Float = isMuted ? 0 : 0.72
        return abs(musicPlayer.volume - expectedMusic) < 0.001
            && effectPlayers.allSatisfy { abs($0.volume - expectedEffect) < 0.001 }
    }
    #endif

    private func frequency(
        forDegree degree: Int,
        profile: MusicProfile,
        octaveOffset: Int
    ) -> Double {
        let safeDegree = max(0, degree)
        let scaleIndex = safeDegree % profile.scale.count
        let scaleOctave = safeDegree / profile.scale.count
        let midi = profile.rootMIDI + profile.scale[scaleIndex] + (scaleOctave + octaveOffset) * 12
        return 440 * pow(2, Double(midi - 69) / 12)
    }

    private func melodyEnvelope(for timbre: Timbre, phase: Double) -> Double {
        let attack = min(1, phase / 0.05)
        switch timbre {
        case .airyBell:
            return attack * exp(-phase * 3.2)
        case .marimba:
            return attack * exp(-phase * 6.4)
        case .candyPop:
            return attack * exp(-phase * 4.4)
        case .storyHarp:
            return attack * exp(-phase * 4.8)
        case .bossPulse:
            return attack * (0.74 + sin(phase * .pi) * 0.26)
        }
    }

    private func timbreSample(_ timbre: Timbre, frequency: Double, time: Double) -> Double {
        let phase = 2 * Double.pi * frequency * time
        switch timbre {
        case .airyBell:
            return sin(phase) + sin(phase * 2.01) * 0.42 + sin(phase * 4.03) * 0.12
        case .marimba:
            return sin(phase) + sin(phase * 3.0) * 0.34 + sin(phase * 5.0) * 0.09
        case .candyPop:
            return sin(phase) + sin(phase * 2.0) * 0.25 + (sin(phase) >= 0 ? 0.12 : -0.12)
        case .storyHarp:
            return sin(phase) + sin(phase * 2.0) * 0.30 + sin(phase * 3.0) * 0.16
        case .bossPulse:
            return tanh(sin(phase) * 1.7 + sin(phase * 0.5) * 0.42)
        }
    }

    private func musicProfile(for theme: MusicTheme) -> MusicProfile {
        switch theme {
        case .title:
            MusicProfile(
                bpm: 104,
                rootMIDI: 60,
                scale: [0, 2, 4, 7, 9],
                melody: [0, -1, 2, 4, 3, -1, 2, 1, 0, 2, 4, 6, 5, 4, 2, -1,
                         0, 2, 3, 4, 6, -1, 4, 3, 2, 4, 5, 7, 6, 4, 2, 1],
                bass: [0, 0, 3, 3, 4, 4, 3, 2, 0, 0, 3, 3, 4, 3, 2, 1],
                chords: [0, 3, 4, 3],
                timbre: .airyBell,
                percussion: 0.34
            )
        case .cloudKingdom:
            MusicProfile(
                bpm: 110,
                rootMIDI: 62,
                scale: [0, 2, 4, 7, 9],
                melody: [0, 2, 4, 6, 4, 2, 3, -1, 1, 3, 5, 7, 5, 3, 2, -1,
                         0, 3, 4, 7, 6, 4, 2, 3, 4, 6, 8, 7, 5, 4, 2, 1],
                bass: [0, 0, 3, 3, 4, 4, 3, 3, 0, 0, 2, 2, 4, 3, 2, 1],
                chords: [0, 3, 4, 2],
                timbre: .airyBell,
                percussion: 0.28
            )
        case .dinoJungle:
            MusicProfile(
                bpm: 116,
                rootMIDI: 57,
                scale: [0, 3, 5, 7, 10],
                melody: [0, -1, 2, 0, 3, 2, -1, 1, 0, 2, 4, 2, 3, -1, 1, 2,
                         0, 2, 3, 5, 3, 2, 1, -1, 0, 3, 4, 2, 5, 3, 2, 1],
                bass: [0, 0, 0, 3, 0, 0, 4, 3, 0, 2, 0, 3, 4, 3, 2, 1],
                chords: [0, 3, 1, 4],
                timbre: .marimba,
                percussion: 0.86
            )
        case .candyCanyon:
            MusicProfile(
                bpm: 128,
                rootMIDI: 64,
                scale: [0, 2, 4, 7, 9],
                melody: [0, 2, 4, 7, 6, 4, 2, 3, 4, 6, 8, 6, 5, 3, 2, -1,
                         2, 4, 5, 7, 9, 7, 6, 4, 3, 5, 7, 8, 7, 5, 3, 1],
                bass: [0, 0, 3, 3, 4, 4, 3, 2, 0, 2, 3, 4, 5, 4, 3, 2],
                chords: [0, 3, 4, 3],
                timbre: .candyPop,
                percussion: 0.64
            )
        case .storybookCastle:
            MusicProfile(
                bpm: 94,
                rootMIDI: 60,
                scale: [0, 2, 3, 5, 7, 8, 10],
                melody: [0, 2, 4, 6, 5, 3, 1, -1, 2, 4, 6, 8, 7, 5, 3, 1,
                         0, 3, 5, 7, 6, 4, 2, -1, 1, 3, 5, 8, 7, 5, 3, 2],
                bass: [0, 0, 4, 4, 3, 3, 4, 4, 0, 0, 5, 5, 3, 4, 2, 1],
                chords: [0, 4, 3, 5],
                timbre: .storyHarp,
                percussion: 0.24
            )
        case .boss:
            MusicProfile(
                bpm: 140,
                rootMIDI: 50,
                scale: [0, 1, 3, 5, 6, 8, 10],
                melody: [0, 0, 3, 2, 4, 3, 1, 0, 0, 3, 5, 4, 6, 4, 2, 1,
                         0, 2, 3, 6, 5, 3, 2, 0, 1, 3, 5, 7, 6, 4, 2, 0],
                bass: [0, 0, 0, 3, 0, 0, 4, 3, 0, 1, 0, 3, 4, 3, 1, 0],
                chords: [0, 4, 1, 3],
                timbre: .bossPulse,
                percussion: 1.0
            )
        }
    }
}

extension WorldTheme {
    var musicTheme: GameAudio.MusicTheme {
        switch self {
        case .cloudKingdom: .cloudKingdom
        case .dinoJungle: .dinoJungle
        case .candyCanyon: .candyCanyon
        case .storybookCastle: .storybookCastle
        }
    }
}
