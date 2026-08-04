@Component
export struct Home {
  @Link currentBreakpoint: string;
  @Link bottomTabIndex: number;
  private scroller: Scroller = new Scroller();
  private controller: TextController = new TextController();
  @State childController: ChildController = new ChildController(this.getUIContext());


  build() {
    Column() {
      ChildComponent({ controller: this.childController });
      // The parent component passes a singleton to the child component.
      Button('Invoking the Subcomponent Method')
        .onClick(() => {
          this.childController.changeText();
        });
    }
    .height('100%')
    .width('100%');
  }
}

export class ChildController {
  uiContext?: UIContext;
  changeText = () => {
  };

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }
}



@Component
export struct ChildComponent {
  @Link controller: ChildController;
  uiContext: UIContext = this.getUIContext();
  message: string = '';

  aboutToAppear() {
    if (this.controller) {
      this.controller.changeText = this.onShowToast;
    }
  }

  onShowToast() {
    this.message = 'Subcomponent invoked.';
    console.info(this.message);
    if (this.message) {
      this.uiContext.getPromptAction().showToast({ message: this.message });
    } else {
      this.uiContext.getPromptAction().showToast({ message: 'this.hi is Null' });
    }
  }

  build() {
  }
}