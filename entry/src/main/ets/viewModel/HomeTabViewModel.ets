export class HomeTabViewModel {
  currentIndex: number = 0
  displayText: string = 'Hello World'
  invocationCount: number = 0

  get pageLabel(): string {
    return this.currentIndex === 0 ? 'Home · 1/2' : 'Second · 2/2'
  }

  setCurrentIndex(index: number): void {
    this.currentIndex = index
  }

  invokeAction(): void {
    this.invocationCount += 1
    this.displayText = `Invoked ${this.invocationCount}`
  }
}
