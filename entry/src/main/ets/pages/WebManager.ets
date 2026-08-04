import { webview } from '@kit.ArkWeb';
import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct WebManager {
  controller: webview.WebviewController = new webview.WebviewController();
  delegate: webview.WebDownloadDelegate = new webview.WebDownloadDelegate();
  @Link currentBreakpoint: string;
  @Link bottomTabIndex: number;
  schemeHandler: webview.WebSchemeHandler = new webview.WebSchemeHandler();
  // UI State
  @State progress: number = 0;
  @State speed: number = 0;
  @State fileName: string = 'Awaiting Sync...';
  @State isDownloading: boolean = false;
  @State isPaused: boolean = false;
  private activeItem: webview.WebDownloadItem | null = null;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext
  // Local Test UI
  private wearableTestUI: string = `
    <!DOCTYPE html>
    <html>
    <body style="background: black; color: white; text-align: center; font-family: sans-serif; padding-top: 20px;">
      <h3 style="color: #007DFF">Map Portal</h3>
      <button onclick="syncManifest()" style="padding: 12px; border-radius: 8px; background: #333; color: white; border: none; margin-bottom: 15px;">
        1. Sync Manifest (POST)
      </button><br>
      <a href="xxxxxxxx" download="offline_map.bin">
        <button style="padding: 12px; border-radius: 8px; background: #007DFF; color: white; border: none;">
          2. Download Map File
        </button>
      </a>
      <script>
        function syncManifest() {
          let payload = "A".repeat(1024 * 100); // 100KB test payload
          fetch('xxxxxxxxxx', { method: 'POST', body: payload });
        }
      </script>
    </body>
    </html>
  `;

  // --- Background OS Task Management ---

  async startContinuousTask() {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{ bundleName: this.context.abilityInfo.bundleName, abilityName: this.context.abilityInfo.name }],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    try {
      let wantAgentObj = await wantAgent.getWantAgent(wantAgentInfo);
      await backgroundTaskManager.startBackgroundRunning(this.context,
        backgroundTaskManager.BackgroundMode.DATA_TRANSFER, wantAgentObj);
      console.info('[System] Continuous task started.');
    } catch (error) {
      let e = error as BusinessError;
      console.error(`[System] Failed to start continuous task: ${e.code}`);
    }
  }

  async stopContinuousTask() {
    try {
      await backgroundTaskManager.stopBackgroundRunning(this.context);
      console.info('[System] Continuous task stopped.');
    } catch (error) {
      console.error('[System] Failed to stop continuous task.');
    }
  }

  // --- Network Interception (WebHttpBodyStream) ---

  setupSchemeHandler() {
    this.schemeHandler.onRequestStart((request: webview.WebSchemeHandlerRequest,
      resourceHandler: webview.WebResourceHandler) => {
      let url: string = request.getRequestUrl();
      let method: string = request.getRequestMethod();

      if (method === 'POST' && url.includes('/api/manifest')) {
        // Launch async process to handl e the stream without blocking ArkWeb
        (async () => {
          let bodyStream: webview.WebHttpBodyStream | null =
            request.getHttpBodyStream() as webview.WebHttpBodyStream | null;
          if (bodyStream) {
            try {
              await bodyStream.initialize();
              let totalBytes: number = 0;
              let chunkSize: number = 4096;

              let chunk: ArrayBuffer = await bodyStream.read(chunkSize);
              while (chunk.byteLength > 0) {
                totalBytes += chunk.byteLength;
                chunk = await bodyStream.read(chunkSize);
              }
              console.info(`[SchemeHandler] Parsed ${totalBytes} bytes successfully.`);
            } catch (error) {
              console.error(`[SchemeHandler] Stream error: ${error}`);
            }
          }

          let response: webview.WebSchemeHandlerResponse = new webview.WebSchemeHandlerResponse();
          response.setStatus(200);
          resourceHandler.didReceiveResponse(response);
          resourceHandler.didFinish();
        })();
        return true;
      }
      return false;
    });

    this.schemeHandler.onRequestStop((request: webview.WebSchemeHandlerRequest) => {
    });
  }

  // --- Standard File Download (WebDownloadManager) ---

  setupDownloadDelegate() {
    this.delegate.onBeforeDownload((item: webview.WebDownloadItem) => {
      this.activeItem = item;
      let name = item.getSuggestedFileName() || 'file.bin';
      this.fileName = name;
      const targetPath = `${this.context.cacheDir} / ${name} `

      this.startContinuousTask(); // Keep watch awake
      item.start(targetPath);

      this.isDownloading = true;
      this.isPaused = false;
    });

    this.delegate.onDownloadUpdated((item: webview.WebDownloadItem) => {
      console.info(`DOWNLOAD: progress -> ${item.getPercentComplete()}%`)
      this.progress = item.getPercentComplete();
      this.speed = item.getCurrentSpeed();
    });

    this.delegate.onDownloadFinish((item: webview.WebDownloadItem) => {
      console.info('DOWNLOAD: finished')
      this.progress = 100;
      this.stopContinuousTask();
      setTimeout((): void => this.resetUI(), 2000);
    });

    this.delegate.onDownloadFailed((item: webview.WebDownloadItem) => {
      console.error(
        `DOWNLOAD: failed -> code=${item.getLastErrorCode()}`
      )
      this.stopContinuousTask();
      this.resetUI();
    });

  }

  // --- UI Interactions ---

  togglePauseResume() {
    if (!this.activeItem) {
      return;
    }
    if (this.isPaused) {
      this.activeItem.resume();
      this.isPaused = false;
    } else {
      this.activeItem.pause();
      this.isPaused = true;
      this.speed = 0;
    }
  }

  cancelDownload() {
    if (this.activeItem) {
      this.activeItem.cancel();
      this.stopContinuousTask();
      this.resetUI();
    }
  }

  resetUI() {
    this.isDownloading = false;
    this.isPaused = false;
    this.progress = 0;
    this.speed = 0;
    this.fileName = 'Awaiting Sync...';
    this.activeItem = null;
  }

  formatSpeed(bytes: number): string {
    if (bytes === 0) {
      return '';
    }
    return (bytes / 1024).toFixed(0) + ' KB/s';
  }

  // --- Architecture Layout ---

  build() {
    Column() {
      // 1. Wearable Progress Monitor
      Column({ space: 8 }) {
        Stack() {
          Progress({ value: this.progress, total: 100, type: ProgressType.Ring })
            .width(130)
            .height(130)
            .color(this.isPaused ? Color.Orange : Color.Green)
            .style({ strokeWidth: 10 })

          Column() {
            Text(`${this.progress}%`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Text(this.formatSpeed(this.speed))
              .fontSize(12)
              .fontColor(Color.Gray)
          }
        }

        Text(this.fileName)
          .fontSize(14)
          .fontColor(Color.White)
          .maxLines(1)
          .width('80%')
          .textAlign(TextAlign.Center)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.isDownloading) {
          Row({ space: 15 }) {
            Button(this.isPaused ? 'Resume' : 'Pause')
              .onClick(() => this.togglePauseResume())
              .backgroundColor(this.isPaused ? '#007DFF' : Color.Orange)
              .height(35)
            Button('Cancel')
              .onClick(() => this.cancelDownload())
              .backgroundColor(Color.Red)
              .height(35)
          }
          .margin({ top: 10 })
        }
      }
      .height('55%')
      .justifyContent(FlexAlign.Center)

      // 2. The Web Engine
      Web({ src: 'about:blank', controller: this.controller })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .width('100%')
        .layoutWeight(1)
        .onControllerAttached(() => {
          // Bind Scheme Handler for POST body streams
          this.setupSchemeHandler();
          try {
            this.controller.setWebSchemeHandler('https', this.schemeHandler);
          } catch (e) {
            console.error('Failed to bind scheme handler');
          }

          // Bind Delegate for standard downloads
          this.setupDownloadDelegate();
          webview.WebDownloadManager.setDownloadDelegate(this.delegate);
        })
        .onPageEnd(() => {
          this.controller.loadData(this.wearableTestUI, 'text/html', 'UTF-8', 'about:blank', 'about:blank');
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}