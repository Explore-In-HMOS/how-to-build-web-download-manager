@Component
export struct SystemStatusPage {
  @Prop engineState: string = 'Waiting'

  private getStatusTitle(): string {
    if (this.engineState === 'Attached') {
      return 'Attached'
    }

    if (this.engineState === 'Error') {
      return 'Unavailable'
    }

    return 'Starting'
  }

  private getStatusDescription(): string {
    if (this.engineState === 'Attached') {
      return 'System is running and healthy'
    }

    if (this.engineState === 'Error') {
      return 'Web engine could not be initialized'
    }

    return 'Preparing web engine runtime'
  }

  private getStatusColor(): string {
    if (this.engineState === 'Attached') {
      return '#A8C7B3'
    }

    if (this.engineState === 'Error') {
      return '#C99B9B'
    }

    return '#B6C0CC'
  }

  build() {
    Column() {
      Text('System Status')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F4F4F5')
        .margin({ top: 22 })

      Blank()
        .layoutWeight(1)

      Column({ space: 8 }) {
        Row({ space: 6 }) {
          Circle()
            .width(7)
            .height(7)
            .fill(this.getStatusColor())
            .opacity(this.engineState === 'Attached' ? 1 : 0.75)
            .animation({
              duration: 300,
              curve: Curve.EaseOut
            })

          Text('WEB ENGINE')
            .fontSize(9)
            .fontWeight(FontWeight.Medium)
            .fontColor('#8E9AAF')
        }
        .justifyContent(FlexAlign.Center)

        Text(this.getStatusTitle())
          .fontSize(23)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F4F4F5')
          .animation({
            duration: 300,
            curve: Curve.EaseOut
          })

        Text(this.getStatusDescription())
          .fontSize(10)
          .fontColor('#A8B0BD')
          .textAlign(TextAlign.Center)
          .width(150)
          .maxLines(2)
          .animation({
            duration: 300,
            curve: Curve.EaseOut
          })
      }
      .alignItems(HorizontalAlign.Center)
      .padding({
        top: 16,
        bottom: 16,
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

      Column({ space: 3 }) {
        Text('DOWNLOAD SERVICE')
          .fontSize(9)
          .fontColor('#667085')

        Text(
          this.engineState === 'Attached'
            ? 'Ready for download requests'
            : 'Waiting for engine availability'
        )
          .fontSize(10)
          .fontColor('#8E9AAF')
          .textAlign(TextAlign.Center)
          .width(170)
          .maxLines(2)
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 18 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#101114')
  }
}