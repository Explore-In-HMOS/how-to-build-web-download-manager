import { ArcList, ArcListItem, LengthMetrics } from '@kit.ArkUI'
import { DownloadActivityRecord, DownloadStatus } from '../../model/DownloadTypes'
import { appWebDownloadService } from '../../services/WebDownloadService'

@Component
export struct ActivityPage {
  @State private activities: DownloadActivityRecord[] = []

  private unsubscribe?: () => void

  aboutToAppear(): void {
    this.unsubscribe = appWebDownloadService.subscribeActivity(
      (records: DownloadActivityRecord[]) => {
        this.activities = records
      }
    )
  }

  aboutToDisappear(): void {
    if (this.unsubscribe) {
      this.unsubscribe()
      this.unsubscribe = undefined
    }
  }

  private getStatusColor(status: DownloadStatus): string {
    if (status === DownloadStatus.Completed) {
      return '#22C55E'
    }

    if (status === DownloadStatus.Canceled) {
      return '#EF4444'
    }

    if (status === DownloadStatus.Failed) {
      return '#EF4444'
    }

    if (status === DownloadStatus.Paused) {
      return '#F59E0B'
    }

    return '#3B82F6'
  }

  private getSubtitle(item: DownloadActivityRecord): string {
    if (item.status === DownloadStatus.Completed) {
      return 'Completed'
    }

    if (item.status === DownloadStatus.Canceled) {
      return `Canceled at ${item.progress}%`
    }

    if (item.status === DownloadStatus.Failed) {
      return item.errorMessage || 'Download failed'
    }

    if (item.status === DownloadStatus.Paused) {
      return `Paused at ${item.progress}%`
    }
    return `${item.progress}% complete`
  }

  private getTimeLabel(createdAt: number): string {
    const secondsAgo: number = Math.floor(
      (Date.now() - createdAt) / 1000
    )
    if (secondsAgo < 60) {
      return 'Just now'
    }

    const minutesAgo: number = Math.floor(secondsAgo / 60)
    if (minutesAgo < 60) {
      return `${minutesAgo}m ago`
    }

    const hoursAgo: number = Math.floor(minutesAgo / 60)

    return `${hoursAgo}h ago`
  }

  build() {
    Column({ space: 4 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column({ space: 2 }) {
          Text('Activity')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F4F4F5')
            .textAlign(TextAlign.Center)
            .width('100%')

          Text(
            this.activities.length > 0
              ? `${this.activities.length} recent downloads`
              : 'No recent downloads'
          )
            .fontSize(10)
            .fontColor('#8E9AAF')
            .textAlign(TextAlign.Center)
            .width('100%')
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
      }
      .width('100%')
      .height(46)
      .margin({
        top: 14,
        bottom: 2
      })
      if (this.activities.length === 0) {
        Column({ space: 6 }) {
          Text('No activity yet')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F4F4F5')

          Text('Completed and canceled downloads appear here.')
            .fontSize(10)
            .fontColor('#8E9AAF')
            .textAlign(TextAlign.Center)
            .width(150)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        ArcList({ initialIndex: 0 }) {
          ForEach(
            this.activities,
            (item: DownloadActivityRecord) => {
              ArcListItem() {
                Row({ space: 8 }) {
                  Column({ space: 2 }) {
                    Text(item.title)
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#F4F4F5')
                      .maxLines(1)

                    Text(this.getSubtitle(item))
                      .fontSize(9)
                      .fontColor('#8E9AAF')
                      .maxLines(1)
                  }
                  .layoutWeight(1)

                  Column({ space: 2 }) {
                    Text(item.status)
                      .fontSize(10)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.getStatusColor(item.status))

                    Text(this.getTimeLabel(item.createdAt))
                      .fontSize(8)
                      .fontColor('#667085')
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')
                .height('100%')
                .padding({
                  left: 14,
                  right: 14
                })
                .alignItems(VerticalAlign.Center)
              }
              .width('84%')
              .height(54)
              .backgroundColor('#191B1F')
              .border({
                width: 1,
                color: '#30333A'
              })
              .borderRadius(27)
              .autoScale(true)
            },
            (item: DownloadActivityRecord) => item.id
          )
        }
        .width('100%')
        .layoutWeight(1)
        .space(LengthMetrics.px(8))
        .scrollBar(BarState.Off)
      }

      Text('Download history')
        .fontSize(9)
        .fontColor('#667085')
        .margin({
          bottom: 12
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#101114')
  }
}