import webview from '@ohos.web.webview'
import {
  DownloadActivityListener,
  DownloadActivityRecord,
  DownloadListener,
  DownloadSnapshot,
  DownloadStatus
} from '../model/DownloadTypes'

export class AppWebDownloadService {
  private static instance: AppWebDownloadService = new AppWebDownloadService()

  private controller?: webview.WebviewController
  private activeItem?: webview.WebDownloadItem
  private filesDir: string = ''

  private sourceUrl: string = ''
  private fileName: string = ''
  private filePath: string = ''
  private activityRecords: DownloadActivityRecord[] = []
  private activityListeners: DownloadActivityListener[] = []

  private currentSessionId: number = 0
  private recordedSessionId: number = -1
  private listeners: DownloadListener[] = []

  private snapshot: DownloadSnapshot = {
    status: DownloadStatus.Idle,
    progress: 0,
    sourceUrl: '',
    fileName: '',
    filePath: '',
    errorMessage: '',
    updatedAt: Date.now()
  }

  private readonly downloadDelegate: webview.WebDownloadDelegate =
    new webview.WebDownloadDelegate()

  private isDelegateInitialized: boolean = false

  private constructor() {
  }

  static getInstance(): AppWebDownloadService {
    return AppWebDownloadService.instance
  }

  initialize(
    controller: webview.WebviewController,
    filesDir: string
  ): void {
    this.controller = controller
    this.filesDir = filesDir

    if (!this.isDelegateInitialized) {
      this.configureDelegate()
      this.isDelegateInitialized = true
    }

    try {
      this.controller.setDownloadDelegate(this.downloadDelegate)
      console.info('DOWNLOAD: delegate attached to controller')

    } catch (error) {
      console.error(`DOWNLOAD: delegate setup failed: ${JSON.stringify(error)}`)
    }
  }

  subscribe(listener: DownloadListener): () => void {
    this.listeners.push(listener)

    listener(this.snapshot)

    return () => {
      this.listeners = this.listeners.filter(
        (currentListener: DownloadListener) => currentListener !== listener
      )
    }
  }

  subscribeActivity(listener: DownloadActivityListener): () => void {
    this.activityListeners.push(listener)

    listener(this.activityRecords.slice())

    return () => {
      this.activityListeners = this.activityListeners.filter(
        (currentListener: DownloadActivityListener) => {
          return currentListener !== listener
        }
      )
    }
  }

  getActivityRecords(): DownloadActivityRecord[] {
    return this.activityRecords.slice()
  }

  getSnapshot(): DownloadSnapshot {
    return this.snapshot
  }

  startDownload(sourceUrl: string, fileName: string): void {
    if (!this.controller) {
      this.updateSnapshot({
        status: DownloadStatus.Failed,
        errorMessage: 'Download engine is not initialized.'
      })
      return
    }

    if (this.snapshot.status === DownloadStatus.Downloading) {
      return
    }
    this.currentSessionId += 1
    this.recordedSessionId = -1

    this.sourceUrl = sourceUrl
    this.fileName = fileName
    this.filePath = `${this.filesDir}/${this.fileName}`

    this.updateSnapshot({
      status: DownloadStatus.Idle,
      progress: 0,
      sourceUrl: this.sourceUrl,
      fileName: this.fileName,
      filePath: this.filePath,
      errorMessage: ''
    })

    try {
      console.info(`DOWNLOAD: start requested -> ${this.sourceUrl}`)

      this.controller.startDownload(this.sourceUrl)

      console.info('DOWNLOAD: controller.startDownload called')
    } catch (error) {
      console.error(`DOWNLOAD: startDownload error -> ${JSON.stringify(error)}`)

      this.updateSnapshot({
        status: DownloadStatus.Failed,
        errorMessage: JSON.stringify(error)
      })
    }
  }

  pauseDownload(): void {
    if (
      this.snapshot.status !== DownloadStatus.Downloading ||
        !this.activeItem
    ) {
      return
    }

    try {
      console.info('DOWNLOAD: pause requested')

      this.activeItem.pause()

      this.updateSnapshot({
        status: DownloadStatus.Paused
      })

      console.info('DOWNLOAD: paused')
    } catch (error) {
      console.error(`DOWNLOAD: pause failed -> ${JSON.stringify(error)}`)

      this.updateSnapshot({
        status: DownloadStatus.Failed,
        errorMessage: JSON.stringify(error)
      })
    }
  }

  resumeDownload(): void {
    if (
      this.snapshot.status !== DownloadStatus.Paused ||
        !this.activeItem
    ) {
      return
    }

    try {
      console.info('DOWNLOAD: resume requested')

      this.activeItem.resume()

      this.updateSnapshot({
        status: DownloadStatus.Downloading
      })

      console.info('DOWNLOAD: resumed')
    } catch (error) {
      console.error(`DOWNLOAD: resume failed -> ${JSON.stringify(error)}`)

      this.updateSnapshot({
        status: DownloadStatus.Failed,
        errorMessage: JSON.stringify(error)
      })
    }
  }

  cancelDownload(): void {
    if (
      this.snapshot.status !== DownloadStatus.Downloading &&
        this.snapshot.status !== DownloadStatus.Paused
    ) {
      return
    }

    if (!this.activeItem) {
      return
    }

    try {
      this.activeItem.cancel()

      this.updateSnapshot({
        status: DownloadStatus.Canceled
      })
      this.recordActivity(DownloadStatus.Canceled)
    } catch (error) {
      this.updateSnapshot({
        status: DownloadStatus.Failed,
        errorMessage: JSON.stringify(error)
      })
    }
  }

  restartDownload(): void {
    if (!this.sourceUrl || !this.fileName) {
      this.updateSnapshot({
        status: DownloadStatus.Failed,
        errorMessage: 'No previous download is available.'
      })
      return
    }

    this.activeItem = undefined

    this.startDownload(this.sourceUrl, this.fileName)
  }

  retryDownload(): void {
    this.restartDownload()
  }

  private configureDelegate(): void {
    this.downloadDelegate.onBeforeDownload(
      (item: webview.WebDownloadItem) => {
        console.info('DOWNLOAD: onBeforeDownload received')
        console.info(`DOWNLOAD: target path -> ${this.filePath}`)
        console.info(`DOWNLOAD: file name -> ${this.fileName}`)

        this.activeItem = item

        if (!this.filePath) {
          console.error('DOWNLOAD: file path is empty')

          this.updateSnapshot({
            status: DownloadStatus.Failed,
            errorMessage: 'Download destination is missing.'
          })
          return
        }

        try {
          item.start(this.filePath)

          console.info('DOWNLOAD: item.start completed')

          this.updateSnapshot({
            status: DownloadStatus.Downloading,
            progress: 0,
            errorMessage: ''
          })
        } catch (error) {
          console.error(`DOWNLOAD: item.start failed -> ${JSON.stringify(error)}`)

          this.updateSnapshot({
            status: DownloadStatus.Failed,
            errorMessage: JSON.stringify(error)
          })
        }
      }
    )

    this.downloadDelegate.onDownloadUpdated(
      (item: webview.WebDownloadItem) => {
        this.activeItem = item

        const progress: number = Math.max(
          0,
          Math.min(100, item.getPercentComplete())
        )

        console.info(
          `DOWNLOAD: update -> ${progress}% | status=${this.snapshot.status}`
        )

        if (this.snapshot.status === DownloadStatus.Paused) {
          if (progress !== this.snapshot.progress) {
            console.info(
              `DOWNLOAD: progress changed while paused -> ${this.snapshot.progress}% to ${progress}%`
            )

            this.updateSnapshot({
              progress: progress
            })
          }

          return
        }
        this.updateSnapshot({
          status: DownloadStatus.Downloading,
          progress: progress
        })
      }
    )


    this.downloadDelegate.onDownloadFinish(
      (item: webview.WebDownloadItem) => {
        console.info('DOWNLOAD: finished')
        this.activeItem = item

        this.updateSnapshot({
          status: DownloadStatus.Completed,
          progress: 100,
          errorMessage: ''
        })
        this.recordActivity(DownloadStatus.Completed)
      }
    )

    this.downloadDelegate.onDownloadFailed(
      (item: webview.WebDownloadItem) => {
        console.error('DOWNLOAD: onDownloadFailed received')

        this.activeItem = item

        if (this.snapshot.status === DownloadStatus.Canceled) {
          console.info('DOWNLOAD: failure ignored because task was canceled')
          return
        }

        const progress: number = Math.max(
          0,
          Math.min(100, item.getPercentComplete())
        )

        this.updateSnapshot({
          status: DownloadStatus.Failed,
          progress: progress,
          errorMessage: 'The download failed.'
        })

        this.recordActivity(
          DownloadStatus.Failed,
          'The download failed.'
        )
      }
    )
  }
  private recordActivity(
    status: DownloadStatus,
    errorMessage: string = ''
  ): void {
    if (this.recordedSessionId === this.currentSessionId) {
      return
    }

    if (!this.fileName) {
      return
    }

    const record: DownloadActivityRecord = {
      id: `${this.currentSessionId}-${Date.now()}`,
      title: this.fileName,
      status: status,
      progress: this.snapshot.progress,
      errorMessage: errorMessage,
      createdAt: Date.now()
    }

    this.recordedSessionId = this.currentSessionId
    this.activityRecords = [record].concat(this.activityRecords)

    this.activityListeners.forEach(
      (listener: DownloadActivityListener) => {
        listener(this.activityRecords.slice())
      }
    )
  }

  private updateSnapshot(changes: Partial<DownloadSnapshot>): void {
    this.snapshot = {
      status: changes.status !== undefined
        ? changes.status
        : this.snapshot.status,

      progress: changes.progress !== undefined
        ? changes.progress
        : this.snapshot.progress,

      sourceUrl: changes.sourceUrl !== undefined
        ? changes.sourceUrl
        : this.snapshot.sourceUrl,

      fileName: changes.fileName !== undefined
        ? changes.fileName
        : this.snapshot.fileName,

      filePath: changes.filePath !== undefined
        ? changes.filePath
        : this.snapshot.filePath,

      errorMessage: changes.errorMessage !== undefined
        ? changes.errorMessage
        : this.snapshot.errorMessage,

      updatedAt: Date.now()
    }

    this.listeners.forEach((listener: DownloadListener) => {
      listener(this.snapshot)
    })
  }

}

export const appWebDownloadService: AppWebDownloadService =
  AppWebDownloadService.getInstance()

export { DownloadSnapshot }