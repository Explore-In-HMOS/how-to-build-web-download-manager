export enum DownloadStatus {
  Idle = 'Idle',
  Downloading = 'Downloading',
  Paused = 'Paused',
  Canceled = 'Canceled',
  Completed = 'Completed',
  Failed = 'Failed'
}

export interface DownloadSnapshot {
  status: DownloadStatus
  progress: number
  sourceUrl: string
  fileName: string
  filePath: string
  errorMessage: string
  updatedAt: number
}

export interface DownloadActivityRecord {
  id: string
  title: string
  status: DownloadStatus
  progress: number
  errorMessage: string
  createdAt: number
}

export type DownloadListener = (snapshot: DownloadSnapshot) => void

export type DownloadActivityListener = (
  records: DownloadActivityRecord[]
) => void