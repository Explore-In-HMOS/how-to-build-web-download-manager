import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonPosition,
  ArcButtonStyleMode
} from '@kit.ArkUI'

@Component
export struct InvokePage {
  @State private isFeedbackVisible: boolean = false
  @State private hasBeenInvoked: boolean = false

  private invokeAction(): void {
    this.hasBeenInvoked = true
    this.isFeedbackVisible = true
  }

  private closeFeedback(): void {
    this.isFeedbackVisible = false
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Column({ space: 4 }) {
          Text('Action')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F4F4F5')

          Text(
            this.hasBeenInvoked
              ? 'The action was invoked.'
              : 'Run the available action.'
          )
            .fontSize(10)
            .fontColor('#9499A3')
            .textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 20 })

        Blank()
          .layoutWeight(1)

        Column({ space: 4 }) {
          Text(
            this.hasBeenInvoked
              ? 'Last status'
              : 'Status'
          )
            .fontSize(9)
            .fontColor('#7B818C')

          Text(
            this.hasBeenInvoked
              ? 'Invoked'
              : 'Ready'
          )
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F4F4F5')
        }
        .alignItems(HorizontalAlign.Center)
        .padding({
          top: 10,
          bottom: 10,
          left: 16,
          right: 16
        })
        .backgroundColor('#191B1F')
        .border({
          width: 1,
          color: '#30333A'
        })
        .borderRadius(14)

        Blank()
          .layoutWeight(1)

        ArcButton({
          options: new ArcButtonOptions({
            label: this.hasBeenInvoked ? 'Invoke Again' : 'Invoke',
            position: ArcButtonPosition.BOTTOM_EDGE,
            styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
            onClick: () => {
              this.invokeAction()
            }
          })
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#101114')

      if (this.isFeedbackVisible) {
        Column() {
          Column({ space: 5 }) {
            Text('Invoked')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F4F4F5')

            Text('Action triggered.')
              .fontSize(10)
              .fontColor('#A0A5AF')
              .textAlign(TextAlign.Center)

            Text('Tap to close')
              .fontSize(8)
              .fontColor('#6F7580')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Center)
          .padding({
            top: 12,
            bottom: 12,
            left: 16,
            right: 16
          })
          .backgroundColor('#1B1D22')
          .border({
            width: 1,
            color: '#3A3D45'
          })
          .borderRadius(14)
          .onClick(() => {
            this.closeFeedback()
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#101114CC')
      }
    }
    .width('100%')
    .height('100%')
  }
}