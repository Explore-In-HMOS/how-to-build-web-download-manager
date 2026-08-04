import { appWebDownloadService } from '../../services/WebDownloadService'
import http from '@ohos.net.http'
import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonPosition,
  ArcButtonStyleMode
} from '@kit.ArkUI'
import { DownloadSnapshot, DownloadStatus } from '../../model/DownloadTypes'


@Component
export struct OverviewPage {
  @State private progressValue: number = 0
  @State private status: DownloadStatus = DownloadStatus.Idle
  @State private fileName: string = 'No active download'

  private unsubscribe?: () => void

  aboutToAppear(): void {
    this.unsubscribe = appWebDownloadService.subscribe(
      (snapshot: DownloadSnapshot) => {
        this.progressValue = snapshot.progress
        this.status = snapshot.status
        this.fileName = snapshot.fileName || 'Offline map'
      }
    )
  }

  aboutToDisappear(): void {
    if (this.unsubscribe) {
      this.unsubscribe()
      this.unsubscribe = undefined
    }
  }

  private getStatusColor(): string {
    if (this.status === DownloadStatus.Downloading) {
      return '#3B82F6'
    }

    if (this.status === DownloadStatus.Paused) {
      return '#F59E0B'
    }

    if (this.status === DownloadStatus.Completed) {
      return '#22C55E'
    }

    if (
      this.status === DownloadStatus.Canceled ||
        this.status === DownloadStatus.Failed
    ) {
      return '#EF4444'
    }

    return '#7B818C'
  }

  private getOverviewTitle(): string {
    if (this.status === DownloadStatus.Downloading) {
      return 'Downloading'
    }

    if (this.status === DownloadStatus.Paused) {
      return 'Paused'
    }

    if (this.status === DownloadStatus.Completed) {
      return 'Completed'
    }

    if (this.status === DownloadStatus.Canceled) {
      return 'Canceled'
    }

    if (this.status === DownloadStatus.Failed) {
      return 'Failed'
    }

    return 'Ready'
  }

  private getOverviewHint(): string {
    if (this.status === DownloadStatus.Downloading) {
      return this.fileName
    }

    if (this.status === DownloadStatus.Paused) {
      return 'Download paused'
    }

    if (this.status === DownloadStatus.Completed) {
      return 'File saved'
    }

    if (this.status === DownloadStatus.Canceled) {
      return `Stopped at ${this.progressValue}%`
    }

    if (this.status === DownloadStatus.Failed) {
      return 'Download failed'
    }

    return 'No active download'
  }

  private startMapDownload(): void {
    appWebDownloadService.startDownload(
      'xxxxx', //please add the download address
      'offline_map_test.mp4'
    )
  }

  private async syncManifest(): Promise<void> {
    const payload: string = 'A'.repeat(100 * 1024)
    const request = http.createHttp()

    try {
      console.info(`SYNC: request started -> payloadSize=${payload.length} bytes`)

      const response = await request.request(
        'xxxxxx', //please add your address
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'text/plain; charset=utf-8'
          },
          extraData: payload
        }
      )

      console.info(
        `SYNC: request completed -> responseCode=${response.responseCode}`
      )

      console.info(
        `SYNC: response body -> ${JSON.stringify(response.result)}`
      )
    } catch (error) {
      console.error(`SYNC: request failed -> ${JSON.stringify(error)}`)
    } finally {
      request.destroy()
    }
  }

  private restartMapDownload(): void {
    appWebDownloadService.restartDownload()
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Stack({ alignContent: Alignment.Center }) {
        Progress({
          value: this.progressValue,
          total: 100,
          type: ProgressType.ScaleRing
        })
          .width(128)
          .height(128)
          .color(this.getStatusColor())
          .backgroundColor('#252C38')
          .style({
            strokeWidth: 8,
            scaleCount: 32,
            scaleWidth: 4
          })

        Column({ space: 5 }) {
          Text(this.getOverviewTitle())
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getStatusColor())
            .maxLines(1)

          Text(`${this.progressValue}%`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text(this.getOverviewHint())
            .fontSize(10)
            .fontColor('#A8B0BD')
            .maxLines(1)
            .width(106)
            .textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width(128)
      .height(128)

      Column() {
        if (
          this.status === DownloadStatus.Idle ||
            this.status === DownloadStatus.Completed ||
            this.status === DownloadStatus.Canceled ||
            this.status === DownloadStatus.Failed
        ) {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Download Map',
              position: ArcButtonPosition.TOP_EDGE,
              styleMode: ArcButtonStyleMode.NORMAL_LIGHT,
              onClick: () => {
                this.startMapDownload()
              }
            })
          })
        } else {
          ArcButton({
            options: new ArcButtonOptions({
              label: this.getOverviewTitle(),
              position: ArcButtonPosition.TOP_EDGE,
              styleMode: ArcButtonStyleMode.NORMAL_LIGHT
            })
          })
            .enabled(false)
        }

        Blank()
          .layoutWeight(1)

          ArcButton({
            options: new ArcButtonOptions({
              label: 'Sync Manifest (POST)',
              position: ArcButtonPosition.BOTTOM_EDGE,
              styleMode: ArcButtonStyleMode.NORMAL_LIGHT,
              onClick: () => {
                this.syncManifest()
              }
            })
          })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#101114')
  }
}