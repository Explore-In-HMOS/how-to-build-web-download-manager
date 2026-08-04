import { ArcDirection, ArcDotIndicator, ArcSwiper, ArcSwiperController } from '@kit.ArkUI'
import { ManifestSyncPage } from '../pages/wearable/ManifestSyncPage'
import { DownloadPage } from '../pages/wearable/DownloadControlPage'
import { ActivityPage } from './wearable/ActivityPage'
import { InvokePage } from './wearable/InvokePage'
import { DownloadEngineHost } from '../components/DownloadEngineHost'
import { SystemStatusPage } from '../pages/wearable/SystemStatusPage'

@Entry
@Component
struct Index {
  @State private engineState: string = 'Waiting'

  private swiperController: ArcSwiperController =
    new ArcSwiperController()

  private pageIndicator: ArcDotIndicator =
    new ArcDotIndicator()
      .arcDirection(ArcDirection.THREE_CLOCK_DIRECTION)
      .itemColor('#465164')
      .selectedItemColor('#F4F4F5')

  build() {
    Stack() {
      DownloadEngineHost({
        engineState: $engineState
      })

      ArcSwiper(this.swiperController) {
        InvokePage()
        ManifestSyncPage()
        DownloadPage()
        ActivityPage()
        SystemStatusPage({
          engineState: this.engineState
        })
      }
      .width('100%')
      .height('100%')
      .vertical(true)
      .duration(320)
      .indicator(this.pageIndicator)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .backgroundColor('#101114')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#101114')
  }
}