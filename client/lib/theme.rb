module CncRemasteredLanBridge
  THEME = {
    TextBlock: {
      text_static: true,
      # font: "LiberationSans-Regular"
    },
    Banner: {
      text_size: 46
    },
    ToolTip: {
      text_size: 24,
      background: 0xdd_000000,
      border_color: 0xff_888888
    },
    Button: {
      min_width: 128,
      text_size: 22,
      border_thickness: 1,
      border_color: 0xff_000000,
      background: 0xff_780001,
      hover: {
        color: 0xff_ffffff,
        background: 0xff_ce0000
      },
      active: {
        color: 0xff_ffffff,
        background: 0xff_4e1111
      }
    },
    EditLine: {
      text_static: false,
      border_thickness: 1,
      border_color: 0xff_e40505
    }
  }
end
