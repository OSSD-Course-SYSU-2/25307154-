import { TileGenerator } from '../mahjong/generator/TileGenerator'
import { TileWallImpl } from '../mahjong/generator/TileWall'
import { GameOperator } from '../mahjong/operator/GameOperator'
import { suggestDiscard } from '../mahjong/suggestor/Suggestor'
import { Tile, tileTypeToString, tileToTileType, encodeTileIndex } from '../mahjong/models/tile'
import { HuType, RiskTag } from '../mahjong/types/enums'
import { HandInfo, ProbabilityResult, SuggestResult, SuggestionItem, TileWall } from '../mahjong/models/results'
import { analyzeProbability } from '../mahjong/analyzer/ProbAnalyzer'
import { Result } from '../mahjong/types/result'
import { validateSafetyConfig } from '../mahjong/config/ComputeSafetyConfig'
import { sortHand, groupBySuit, formatSortedHand } from '../mahjong/utils/handSorter'
import { TileSuit } from '../mahjong/types/enums'

@Entry
@Component
struct Index {
  @State handTiles: Tile[] = []
  @State wallRemaining: number = 0
  @State shantenInfo: string = ''
  @State tingInfo: string = ''
  @State probInfo: string = ''
  @State suggestInfo: string = '点击"打最优牌"查看建议'
  @State statusMsg: string = '请点击"发牌"开始'
  @State isHu: boolean = false
  @State isSortedMode: boolean = true
  @State isCalculating: boolean = false
  @State drawnTile: Tile | null = null

  private operator: GameOperator = new GameOperator()
  private generator: TileGenerator = new TileGenerator()

  aboutToAppear(): void {
    validateSafetyConfig()
  }

  private refreshHandDisplay(): void {
    this.handTiles = this.operator.hand.slice()
  }

  private tileToText(tile: Tile): string {
    if (tile.suit === TileSuit.ZI) {
      return '红中'
    }
    if (tile.suit === TileSuit.WAN) {
      return `${tile.faceValue}万`
    }
    if (tile.suit === TileSuit.TIAO) {
      return `${tile.faceValue}条`
    }
    return `${tile.faceValue}筒`
  }

  private getBaseTiles(): Tile[] {
    if (this.drawnTile === null) {
      return this.handTiles
    }
    const drawnSeqNo = this.drawnTile.seqNo
    const result: Tile[] = []
    for (let i = 0; i < this.handTiles.length; i++) {
      if (this.handTiles[i].seqNo !== drawnSeqNo) {
        result.push(this.handTiles[i])
      }
    }
    return result
  }

  private getHandDisplayText(): string {
    if (this.handTiles.length === 0) {
      return '未发牌'
    }

    if (this.isSortedMode) {
      const baseTiles = this.getBaseTiles()
      const sorted = sortHand(baseTiles)
      const groups = groupBySuit(sorted)
      const groupStrings: string[] = []
      for (let i = 0; i < groups.length; i++) {
        const parts: string[] = []
        for (let j = 0; j < groups[i].length; j++) {
          parts.push(this.tileToText(groups[i][j]))
        }
        groupStrings.push(parts.join(' '))
      }
      let result = groupStrings.join(' | ')
      if (this.drawnTile !== null) {
        result += '   ' + this.tileToText(this.drawnTile)
      }
      return result
    }

    const parts: string[] = []
    let drawnAdded = false
    for (let i = 0; i < this.handTiles.length; i++) {
      const tile = this.handTiles[i]
      if (this.drawnTile !== null && tile.seqNo === this.drawnTile.seqNo && !drawnAdded) {
        parts.push('  ' + this.tileToText(tile))
        drawnAdded = true
      } else {
        parts.push(this.tileToText(tile))
      }
    }
    return parts.join(' ')
  }

  toggleSortMode(): void {
    this.isSortedMode = !this.isSortedMode
    this.refreshHandDisplay()
  }

  onGenerateHand(): void {
    const result = this.generator.generateHand(13)
    if (!result.success) {
      this.statusMsg = `发牌失败: ${result.errorMessage}`
      return
    }

    const data = result.data
    if (data === null) {
      this.statusMsg = '发牌失败'
      return
    }

    const handInfo: HandInfo = data
    this.wallRemaining = handInfo.wallRemaining

    const wall = this.generator.wall
    if (wall === null) {
      this.statusMsg = '牌墙初始化失败'
      return
    }

    this.operator.setHandAndWall(handInfo.tiles, wall)
    this.drawnTile = null
    this.refreshHandDisplay()
    this.analyzeCurrentHand()

    this.statusMsg = '已发牌，可以摸牌'
    this.isHu = false
  }

  private analyzeCurrentHand(): void {
    const hand = this.operator.hand
    const wall = this.operator.tileWall
    if (wall === null) {
      return
    }
    const probResult: Result<ProbabilityResult> = analyzeProbability(hand, wall)
    if (!probResult.success || probResult.data === null) {
      this.shantenInfo = '分析失败'
      return
    }

    const probData: ProbabilityResult = probResult.data
    this.updateAnalysisDisplay(probData)
  }

  private updateAnalysisDisplay(data: ProbabilityResult): void {
    if (data.shantenNumber === -1) {
      this.shantenInfo = '已胡牌！'
      this.tingInfo = ''
      this.probInfo = '概率: 100%'
    } else if (data.shantenNumber === 0) {
      this.shantenInfo = '听牌状态'
      const parts: string[] = []
      for (let i = 0; i < data.tingList.length; i++) {
        const t = data.tingList[i]
        parts.push(`${tileTypeToString(t.tile)}(剩${t.remainCount}张)`)
      }
      this.tingInfo = '听牌: ' + parts.join(', ')
      this.probInfo = `胡牌概率: ${(data.huProbability * 100).toFixed(2)}%`
    } else {
      this.shantenInfo = `${data.shantenNumber}向听`
      const parts: string[] = []
      const maxShow = Math.min(data.effectiveDraws.length, 6)
      for (let i = 0; i < maxShow; i++) {
        const t = data.effectiveDraws[i]
        parts.push(`${tileTypeToString(t.tile)}(剩${t.remainCount}张)`)
      }
      this.tingInfo = '有效进张: ' + parts.join(', ')
      this.probInfo = `进张概率: ${(data.huProbability * 100).toFixed(2)}%`
    }
  }

  onDrawTile(): void {
    if (this.isHu) {
      this.statusMsg = '已胡牌，无需继续'
      return
    }

    const result = this.operator.drawTile()
    if (!result.success || result.data === null) {
      const em = result.errorMessage
      this.statusMsg = em !== null ? em : '摸牌失败'
      return
    }

    const data = result.data
    this.drawnTile = data.drawnTile
    this.refreshHandDisplay()
    this.wallRemaining = data.wallRemaining
    this.isHu = data.huJudgeResult.isHu

    if (data.huJudgeResult.isHu) {
      const typeNames: string[] = []
      const huTypes = data.huJudgeResult.huTypes
      for (let i = 0; i < huTypes.length; i++) {
        if (huTypes[i] === HuType.PING_HU) {
          typeNames.push('平胡')
        } else if (huTypes[i] === HuType.QI_DUI) {
          typeNames.push('七对')
        } else if (huTypes[i] === HuType.PENG_PENG_HU) {
          typeNames.push('碰碰胡')
        }
      }
      this.statusMsg = `胡牌！牌型: ${typeNames.join(', ')}`
      this.shantenInfo = '已胡牌！'
      this.probInfo = '概率: 100%'
      this.tingInfo = ''
      this.suggestInfo = '已胡牌，无需打牌建议'
    } else {
      this.statusMsg = `摸到: ${tileTypeToString(tileToTileType(data.drawnTile))}，未胡牌`
      this.analyzeCurrentHand()
      this.suggestInfo = '点击"打最优牌"查看建议'
    }
  }

  onDiscardBest(): void {
    if (this.isCalculating) {
      return
    }

    const hand = this.operator.hand
    const wall = this.operator.tileWall
    if (wall === null) {
      return
    }

    this.isCalculating = true
    this.statusMsg = '计算中...'

    try {
      const suggestResult = suggestDiscard(hand, wall)
      if (!suggestResult.success || suggestResult.data === null) {
        this.statusMsg = '无法生成打牌建议'
        return
      }

      const sugData = suggestResult.data
      if (sugData.suggestions.length === 0) {
        this.statusMsg = '无法生成打牌建议，请手动选择'
        return
      }

      let bestSuggestion: SuggestionItem | null = null
      for (let i = 0; i < sugData.suggestions.length; i++) {
        if (sugData.suggestions[i].discardTiles.length >= 1) {
          bestSuggestion = sugData.suggestions[i]
          break
        }
      }
      if (bestSuggestion === null) {
        this.statusMsg = '无法确定最优牌，请手动选择'
        return
      }

      const bestTileType = bestSuggestion.discardTiles[0]
      const bestIdx = encodeTileIndex(bestTileType)

      let tileToDiscard: Tile | null = null
      for (let i = 0; i < hand.length; i++) {
        const tType = tileToTileType(hand[i])
        if (encodeTileIndex(tType) === bestIdx) {
          tileToDiscard = hand[i]
          break
        }
      }
      if (tileToDiscard === null) {
        this.statusMsg = '无法找到建议的牌'
        return
      }

      const result = this.operator.discardTile(tileToDiscard)
      if (!result.success || result.data === null) {
        const em = result.errorMessage
        this.statusMsg = em !== null ? em : '打牌失败'
        return
      }

      const discardData = result.data
      this.drawnTile = null
      this.refreshHandDisplay()
      const currentWall = this.operator.tileWall
      if (currentWall !== null) {
        this.wallRemaining = currentWall.totalRemaining
      }

      const probData = discardData.probabilityResult
      this.updateAnalysisDisplay(probData)

      const lines: string[] = []
      const maxShow = Math.min(sugData.suggestions.length, 3)
      for (let i = 0; i < maxShow; i++) {
        const s = sugData.suggestions[i]
        const tileNames: string[] = []
        for (let j = 0; j < s.discardTiles.length; j++) {
          tileNames.push(tileTypeToString(s.discardTiles[j]))
        }
        const risk = s.riskTag === RiskTag.WILD_TILE_RISK ? ' ⚠万能牌风险' : ''
        lines.push(`${i + 1}. 打${tileNames.join('/')} → ${s.shantenAfterDiscard}向听, ${s.effectiveDrawCount}进张${risk}`)
      }

      if (!sugData.isComplete) {
        lines.push('（计算已简化）')
      }
      if (sugData.isDegraded) {
        lines.push('（部分结果为近似值）')
      }
      this.suggestInfo = lines.join('\n')

      this.statusMsg = `打出: ${tileTypeToString(tileToTileType(tileToDiscard))}`
      this.isHu = false
    } catch (e) {
      this.statusMsg = '计算出错，请重试'
      this.suggestInfo = ''
    } finally {
      this.isCalculating = false
    }
  }

  build() {
    Scroll() {
      Column() {
        Text('红中麻将胡牌分析器')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })

        Text(this.statusMsg)
          .fontSize(16)
          .fontColor('#FF666666')
          .margin({ bottom: 10 })

        Text('当前手牌:')
          .fontSize(14)
          .fontColor('#FF999999')
          .margin({ bottom: 3 })

        Text(this.getHandDisplayText())
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 5 })

        Text(`牌墙剩余: ${this.wallRemaining} 张`)
          .fontSize(14)
          .fontColor('#FF999999')
          .margin({ bottom: 10 })

        Divider().margin({ left: 20, right: 20, bottom: 10 })

        Row() {
          Column() {
            Text(this.shantenInfo)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 5 })

            Text(this.tingInfo)
              .fontSize(13)
              .fontColor('#FF666666')
              .margin({ bottom: 5 })
              .maxLines(3)

            Text(this.probInfo)
              .fontSize(15)
              .fontColor('#FF3366CC')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('打牌建议:')
              .fontSize(14)
              .fontColor('#FF999999')
              .margin({ bottom: 5 })

            Text(this.suggestInfo)
              .fontSize(13)
              .maxLines(6)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({ bottom: 10 })

        Divider().margin({ left: 20, right: 20, bottom: 10 })

        Row() {
          Button(this.isSortedMode ? '原序' : '理牌')
            .width(80)
            .height(40)
            .onClick(() => this.toggleSortMode())

          Button('发牌')
            .width(80)
            .height(40)
            .margin({ left: 15 })
            .onClick(() => this.onGenerateHand())

          Button('摸牌')
            .width(80)
            .height(40)
            .margin({ left: 15 })
            .onClick(() => this.onDrawTile())

          Button('打最优牌')
            .width(100)
            .height(40)
            .margin({ left: 15 })
            .enabled(!this.isCalculating)
            .onClick(() => this.onDiscardBest())
        }
        .margin({ bottom: 20 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}
