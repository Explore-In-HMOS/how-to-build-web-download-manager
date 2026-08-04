import { BottomTabsModel } from '../model/BottomTabModel';

export const bottomTabsList: Array<BottomTabsModel> = [
  {
    icon: $r('app.media.feed_white'),
    iconSelected: $r('app.media.feed_black'),
    text: $r('app.string.bottom_text_home')
  },
  {
    icon: $r('app.media.photo_white'),
    iconSelected: $r('app.media.photo_black'),
    text: $r('app.string.bottom_text_drag')
  },
  {
    icon: $r('app.media.photo_white'),
    iconSelected: $r('app.media.photo_black'),
    text: $r('app.string.bottom_text_mouse')
  },
  {
    icon: $r('app.media.photo_white'),
    iconSelected: $r('app.media.photo_black'),
    text: $r('app.string.bottom_text_keyboard')
  },
  {
    icon: $r('app.media.photo_white'),
    iconSelected: $r('app.media.photo_black'),
    text: $r('app.string.bottom_text_device')
  },
  {
    icon: $r('app.media.photo_white'),
    iconSelected: $r('app.media.photo_black'),
    text: $r('app.string.bottom_text_window')
  }
]