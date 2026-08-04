import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonPosition,
  ArcButtonStyleMode
} from '@kit.ArkUI'
import http from '@ohos.net.http'

enum ManifestSyncStatus {
  Idle = 'Idle',
  Syncing = 'Syncing',
  Synced = 'Synced',
  Failed = 'Failed'
}

@Component
export struct ManifestSyncPage {
  @State private syncStatus: ManifestSyncStatus = ManifestSyncStatus.Idle
  @State private responseCode: number = 0
  @State private errorMessage: string = ''

  private getStatusTitle(): string {
    if (this.syncStatus === ManifestSyncStatus.Syncing) {
      return 'Syncing'
    }

    if (this.syncStatus === ManifestSyncStatus.Synced) {
      return 'Manifest Synced'
    }

    if (this.syncStatus === ManifestSyncStatus.Failed) {
      return 'Sync Failed'
    }

    return 'Ready'
  }

  private getStatusDescription(): string {
    if (this.syncStatus === ManifestSyncStatus.Syncing) {
      return 'Sending manifest payload'
    }

    if (this.syncStatus === ManifestSyncStatus.Synced) {
      return `Request completed (${this.responseCode})`
    }

    if (this.syncStatus === ManifestSyncStatus.Failed) {
      return this.errorMessage || 'The manifest request could not be completed'
    }

    return 'Ready to send manifest data'
  }

  private getButtonLabel(): string {
    if (this.syncStatus === ManifestSyncStatus.Syncing) {
      return 'Syncing'
    }

    if (this.syncStatus === ManifestSyncStatus.Synced) {
      return 'Sync Again'
    }

    if (this.syncStatus === ManifestSyncStatus.Failed) {
      return 'Retry Sync'
    }

    return 'Sync Manifest'
  }

  private getStatusColor(): string {
    if (this.syncStatus === ManifestSyncStatus.Synced) {
      return '#A8C7B3'
    }

    if (this.syncStatus === ManifestSyncStatus.Failed) {
      return '#C99B9B'
    }

    if (this.syncStatus === ManifestSyncStatus.Syncing) {
      return '#C7CDD6'
    }

    return '#8E9AAF'
  }

  private async syncManifest(): Promise<void> {
    if (this.syncStatus === ManifestSyncStatus.Syncing) {
      return
    }

    const payload: string = 'A'.repeat(100 * 1024)
    const request = http.createHttp()

    this.syncStatus = ManifestSyncStatus.Syncing
    this.responseCode = 0
    this.errorMessage = ''

    try {
      console.info(
        `SYNC: request started -> payloadSize=${payload.length} bytes`
      )

      const response = await request.request(
        'xxxxx', //please add the download address
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'text/plain; charset=utf-8'
          },
          extraData: payload
        }
      )

      this.responseCode = response.responseCode

      console.info(
        `SYNC: request completed -> responseCode=${response.responseCode}`
      )

      if (response.responseCode >= 200 && response.responseCode < 300) {
        this.syncStatus = ManifestSyncStatus.Synced
      } else {
        this.errorMessage = `Request failed (${response.responseCode})`
        this.syncStatus = ManifestSyncStatus.Failed
      }

    }catch (error) {
      const errorText: string = JSON.stringify(error)
      console.error(`SYNC: request failed -> ${errorText}`)
      this.errorMessage = errorText.length > 70
        ? `${errorText.substring(0, 70)}...` : errorText

      this.syncStatus = ManifestSyncStatus.Failed
    }finally {
      request.destroy()
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Column({ space: 4 }) {
          Text('Manifest Sync')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F4F4F5')

          Text('Remote manifest synchronization')
            .fontSize(10)
            .fontColor('#8E9AAF')
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 22 })

        Blank()
          .layoutWeight(1)

        Column({ space: 7 }) {
          Text('STATUS')
            .fontSize(9)
            .fontWeight(FontWeight.Medium)
            .fontColor('#667085')

          Text(this.getStatusTitle())
            .fontSize(21)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F4F4F5')
            .animation({
              duration: 220,
              curve: Curve.EaseOut
            })

          Text(this.getStatusDescription())
            .fontSize(10)
            .fontColor(this.getStatusColor())
            .textAlign(TextAlign.Center)
            .width(158)
            .maxLines(2)
            .animation({
              duration: 220,
              curve: Curve.EaseOut
            })

          if (this.syncStatus === ManifestSyncStatus.Syncing) {
            Text('100 KB payload in progress')
              .fontSize(9)
              .fontColor('#667085')
              .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.Center)
        .padding({
          top: 15,
          bottom: 15,
          left: 18,
          right: 18
        })
        .backgroundColor('#191B1F')
        .border({
          width: 1,
          color: '#30333A'
        })
        .borderRadius(18)

        Blank()
          .layoutWeight(1)

        ArcButton({
          options: new ArcButtonOptions({
            label: this.getButtonLabel(),
            position: ArcButtonPosition.BOTTOM_EDGE,
            styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
            onClick: () => {
              this.syncManifest()
            }
          })
        })
          .enabled(this.syncStatus !== ManifestSyncStatus.Syncing)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#101114')
    }
    .width('100%')
    .height('100%')
  }
}