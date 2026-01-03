import SpriteKit

class SpriteSheetAnimationProvider: AnimationProvider {

    private var stateFrames: [EnemyState: [SKTexture]] = [:]

    init(spriteSheet: SKTexture,
         stateRows: [EnemyState: Int],
         totalRows: Int = 1,
         columns: Int = 1) {

        for (state, rowIndex) in stateRows {
            let frames = SpriteSheetAnimationProvider.loadFrames(sheet: spriteSheet,
                                                                rowIndex: rowIndex,
                                                                totalRows: totalRows,
                                                                columns: columns)
            stateFrames[state] = frames
        }
    }

    init(stateSheets: [EnemyState: SKTexture],
         rowsPerSheet: [EnemyState: Int],
         columnsPerSheet: [EnemyState: Int] = [:]) {

        for (state, sheet) in stateSheets {
            let rows = rowsPerSheet[state] ?? 1
            let columns = columnsPerSheet[state] ?? 1
            let frames = SpriteSheetAnimationProvider.loadFrames(sheet: sheet,
                                                                rowIndex: 0,
                                                                totalRows: rows,
                                                                columns: columns)
            stateFrames[state] = frames
        }
    }

    func frames(for state: EnemyState) -> [SKTexture] {
        return stateFrames[state] ?? []
    }

    private static func loadFrames(sheet: SKTexture, rowIndex: Int, totalRows: Int, columns: Int) -> [SKTexture] {
        var frames: [SKTexture] = []
        let frameWidth = 1.0 / CGFloat(columns)
        let frameHeight = 1.0 / CGFloat(totalRows)

        for col in 0..<columns {
            let rect = CGRect(
                x: CGFloat(col) * frameWidth,
                y: CGFloat(totalRows - 1 - rowIndex) * frameHeight,
                width: frameWidth,
                height: frameHeight
            )
            frames.append(SKTexture(rect: rect, in: sheet))
        }
        return frames
    }
}
