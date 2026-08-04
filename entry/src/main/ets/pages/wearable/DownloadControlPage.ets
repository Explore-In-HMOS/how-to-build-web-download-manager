import { ArcButton, ArcButtonOptions, ArcButtonPosition, ArcButtonStyleMode } from '@kit.ArkUI'
import { DownloadSnapshot, DownloadStatus } from '../../model/DownloadTypes'
import { appWebDownloadService } from '../../services/WebDownloadService'

@Component
export struct DownloadPage {
  @State private status: DownloadStatus = DownloadStatus.Idle
  @State private progressValue: number = 0
  @State private fileName: string = 'No active download'
  @State private errorMessage: string = ''

  private unsubscribe?: () => void

  aboutToAppear(): void {
    this.unsubscribe = appWebDownloadService.subscribe(
      (snapshot: DownloadSnapshot) => {
        this.status = snapshot.status
        this.progressValue = snapshot.progress
        this.fileName = snapshot.fileName || 'Offline map'
        this.errorMessage = snapshot.errorMessage
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

    if (this.status === DownloadStatus.Canceled) {
      return '#EF4444'
    }

    if (this.status === DownloadStatus.Failed) {
      return '#EF4444'
    }

    return '#7B818C'
  }

  private getStatusText(): string {
    if (this.status === DownloadStatus.Downloading) {
      return 'Downloading'
    }

    if (this.status === DownloadStatus.Paused) {
      return 'Paused'
    }

    if (this.status === DownloadStatus.Canceled) {
      return 'Canceled'
    }

    if (this.status === DownloadStatus.Completed) {
      return 'Completed'
    }

    if (this.status === DownloadStatus.Failed) {
      return 'Failed'
    }

    return 'Ready'
  }

  private getStatusHint(): string {
    if (this.status === DownloadStatus.Downloading) {
      return this.fileName
    }

    if (this.status === DownloadStatus.Paused) {
      return 'Download paused'
    }

    if (this.status === DownloadStatus.Canceled) {
      return `Stopped at ${this.progressValue}%`
    }

    if (this.status === DownloadStatus.Completed) {
      return 'Successful'
    }

    if (this.status === DownloadStatus.Failed) {
      return this.errorMessage || 'Download failed'
    }

    return 'Select a map to download'
  }

  private pauseDownload(): void {
    appWebDownloadService.pauseDownload()
  }

  private continueDownload(): void {
    appWebDownloadService.resumeDownload()
  }

  private cancelDownload(): void {
    appWebDownloadService.cancelDownload()
  }

  private restartDownload(): void {
    appWebDownloadService.restartDownload()
  }

  private retryDownload(): void {
    appWebDownloadService.retryDownload()
  }

  private startMapDownload(): void {
    appWebDownloadService.startDownload(
      'xxxxx', //please add the download address
      'offline_map_test.mp4'
    )
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Stack({ alignContent: Alignment.Center }) {
        Progress({
          value: this.progressValue,
          total: 100,
          type: ProgressType.ScaleRing
        })
          .width(120)
          .height(120)
          .color(this.getStatusColor())
          .backgroundColor('#252C38')
          .style({
            strokeWidth: 8,
            scaleCount: 32,
            scaleWidth: 4
          })

        Column({ space: 4 }) {
          Text(this.getStatusText())
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getStatusColor())
            .maxLines(1)

          Text(`${this.progressValue}%`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text(this.getStatusHint())
            .fontSize(10)
            .fontColor('#8E9AAF')
            .maxLines(1)
            .textAlign(TextAlign.Center)
            .width(104)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width(120)
      .height(120)

      Column() {
        if (this.status === DownloadStatus.Downloading) {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Pause',
              position: ArcButtonPosition.TOP_EDGE,
              styleMode: ArcButtonStyleMode.NORMAL_LIGHT,
              onClick: () => {
                this.pauseDownload()
              }
            })
          })
        } else if (this.status === DownloadStatus.Paused) {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Continue',
              position: ArcButtonPosition.TOP_EDGE,
              styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
              onClick: () => {
                this.continueDownload()
              }
            })
          })
        } else if (this.status === DownloadStatus.Failed) {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Retry',
              position: ArcButtonPosition.TOP_EDGE,
              styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
              onClick: () => {
                this.retryDownload()
              }
            })
          })
        } else if (this.status === DownloadStatus.Completed) {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Completed',
              position: ArcButtonPosition.TOP_EDGE,
              styleMode: ArcButtonStyleMode.NORMAL_LIGHT
            })
          })
            .enabled(false)
        } else if (this.status === DownloadStatus.Canceled) {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Canceled',
              position: ArcButtonPosition.TOP_EDGE,
              styleMode: ArcButtonStyleMode.NORMAL_LIGHT
            })
          })
            .enabled(false)
        } else {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Download Map',
              position: ArcButtonPosition.TOP_EDGE,
              styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
              onClick: () => {
                this.startMapDownload()
              }
            })
          })
        }

        Blank()
          .layoutWeight(1)

        if (
          this.status === DownloadStatus.Downloading ||
            this.status === DownloadStatus.Paused
        ) {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Cancel',
              position: ArcButtonPosition.BOTTOM_EDGE,
              styleMode: ArcButtonStyleMode.NORMAL_LIGHT,
              onClick: () => {
                this.cancelDownload()
              }
            })
          })
        } else if (
          this.status === DownloadStatus.Canceled ||
            this.status === DownloadStatus.Completed
        ) {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Restart',
              position: ArcButtonPosition.BOTTOM_EDGE,
              styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
              onClick: () => {
                this.restartDownload()
              }
            })
          })
        } else if (this.status === DownloadStatus.Failed) {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'Restart',
              position: ArcButtonPosition.BOTTOM_EDGE,
              styleMode: ArcButtonStyleMode.NORMAL_LIGHT,
              onClick: () => {
                this.restartDownload()
              }
            })
          })
        } else {
          ArcButton({
            options: new ArcButtonOptions({
              label: 'No Download',
              position: ArcButtonPosition.BOTTOM_EDGE,
              styleMode: ArcButtonStyleMode.NORMAL_LIGHT
            })
          })
            .enabled(false)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#101114')
  }
}