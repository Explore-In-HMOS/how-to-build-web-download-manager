import webview from '@ohos.web.webview'
import common from '@ohos.app.ability.common'
import { appWebDownloadService } from '../services/WebDownloadService'

@Component
export struct DownloadEngineHost {
  @Link engineState: string

  private webController: webview.WebviewController =
    new webview.WebviewController()

  build() {
    Web({
      src:'xxxxx', //please add the download address
      controller: this.webController
    })
      .width(1)
      .height(1)
      .opacity(0.01)
      .onControllerAttached(() => {
        const context = this.getUIContext().getHostContext() as common.UIAbilityContext
        appWebDownloadService.initialize(
          this.webController,
          context.filesDir
        )

        this.engineState = 'Attached'
      })
  }
}