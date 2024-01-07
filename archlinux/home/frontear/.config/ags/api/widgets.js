import Widget from "resource:///com/github/Aylur/ags/widget.js";

// sane defaults for all GTK Widgets, including AGS properties
let BaseProperties = {
    // https://github.com/Aylur/ags/wiki/Widgets
    // className
    // classNames
    // css
    hpack: "center",
    vpack: "center",
    properties: null,
    connections: null,
    binds: null,
    setup: null,

    // https://docs.gtk.org/gtk3/class.Widget.html#properties
    // appPaintable
    // canDefault
    // canFocus
    // events
    expand: false,
    // focusOnClick,
    // halign
    // hasDefault
    // hasFocus
    hasTooltip: false,
    // heightRequest
    hexpand: true,
    hexpandSet: true,
    // isFocus
    // margin
    // marginBottom
    // marginEnd
    // marginLeft
    // marginRight
    // marginStart
    // marginTop
    // name
    // noShowAll
    // opacity
    // parent
    // receivesDefault
    sensitive: true,
    // style
    // tooltipMarkup
    // tooltipText,
    // valign
    vexpand: false,
    vexpandSet: true,
    visible: true,
    // widthRequest
};

export const Box = ({children, ...rest}) => Widget.Box({
    ...BaseProperties,

    // https://github.com/Aylur/ags/wiki/Basic-Widgets#box
    vertical: false,
    children: children || [],

    // https://docs.gtk.org/gtk3/class.Container.html#properties
    // borderWidth
    // resizeMode
    
    // https://docs.gtk.org/gtk3/class.Box.html#properties
    // baselinePosition
    homogeneous: false,
    spacing: 0,

    ...rest
});

export const Button = ({child, ...rest}) => Widget.Button({
    ...BaseProperties,

    // https://github.com/Aylur/ags/wiki/Basic-Widgets#button
    child: child,
    onClicked: null,
    onPrimaryClick: null,
    onSecondaryClick: null,
    onMiddleClick: null,
    onPrimaryClickRelease: null,
    onSecondaryClickRelease: null,
    onMiddleClickRelease: null,
    onHover: null,
    onHoverLost: null,
    onScrollUp: null,
    onScrollDown: null,

    // https://docs.gtk.org/gtk3/iface.Actionable.html#properties
    // actionName
    // actionTarget
    
    // https://docs.gtk.org/gtk3/iface.Activatable.html#properties
    // relatedAction
    // useActionAppearance

    // https://docs.gtk.org/gtk3/class.Container.html#properties
    // borderWidth
    // resizeMode

    // https://docs.gtk.org/gtk3/class.Button.html#properties
    // alwaysShowImage
    // image
    // imagePosition
    // label
    // useUnderline

    ...rest
});

export const CenterBox = ({startWidget, centerWidget, endWidget, ...rest}) => Widget.CenterBox({
    ...BaseProperties,

    // override
    halign: "fill",

    // https://github.com/Aylur/ags/wiki/Basic-Widgets#box
    vertical: false,
    children: [],

    // https://github.com/Aylur/ags/wiki/Basic-Widgets#centerbox
    startWidget: startWidget,
    centerWidget: centerWidget,
    endWidget: endWidget,

    // https://docs.gtk.org/gtk3/iface.Orientable.html#properties
    // orientation

    // https://docs.gtk.org/gtk3/class.Container.html#properties
    // borderWidth
    // resizeMode
    
    // https://docs.gtk.org/gtk3/class.Box.html#properties
    // baselinePosition
    homogeneous: false,
    spacing: 0,

    ...rest
});

export const Entry = ({...rest}) => Widget.Entry({
    //...BaseProperties,

    // https://github.com/Aylur/ags/wiki/Basic-Widgets#entry
    // onChange
    // onAccept

    // https://docs.gtk.org/gtk3/iface.CellEditable.html#properties
    // editingCanceled

    // https://docs.gtk.org/gtk3/class.Entry.html#properties
    // activatesDefault
    // attributes
    // buffer
    // capsLockWarning
    // completion
    // editable
    // enableEmojiCompletion
    // hasFrame
    // imModule
    // innerBorder
    // inputHints
    // inputPurpose
    // invisibleChar
    // invisibleCharSet
    // maxLength
    // maxWidthChars
    // overwriteMode
    // placeholderText
    // populateAll
    // primaryIconActivatable
    // primaryIconGicon
    // primaryIconName
    // primaryIconPixbuf
    // primaryIconSensitive
    // primaryIconStock
    // primaryIconTooltipMarkup
    // primaryIconTooltipText
    // progressFraction
    // progressPulseStep
    // secondaryIconActivatable
    // secondaryIconGicon
    // secondaryIconName
    // secondaryIconPixbuf
    // secondaryIconSensitive
    // secondaryIconStock
    // secondaryIconTooltipMarkup
    // secondaryIconTooltipText
    // shadowType
    // showEmojiIcon
    // tabs
    // text
    // textLength
    // truncateMultiline
    // visibility
    // widthChars
    // xalign: 0.5

    ...rest
});

export const Label = ({label, ...rest}) => Widget.Label({
    ...BaseProperties,

    // https://github.com/Aylur/ags/wiki/Basic-Widgets#label
    justification: "center",
    truncate: "end",

    // https://docs.gtk.org/gtk3/class.Label.html#properties
    // angle
    // attributes
    // cursorPosition,
    // ellipsize
    // justify
    label: label || "",
    // lines
    // maxWidthChars
    // mnemonicKeyval
    // mnemonicWidget
    // pattern
    // selectable
    // selectionBound
    // singleLineMode
    // trackVisitedLinks
    // useMarkup
    // useUnderline
    // widthChars
    wrap: false,
    // wrapMode
    xalign: 0.5,
    yalign: 0.5,

    ...rest
});

export const ProgressBar = ({value, ...rest}) => Widget.ProgressBar({
    ...BaseProperties,
    
    // override
    halign: "fill",

    // https://github.com/Aylur/ags/wiki/Basic-Widgets#progressbar
    vertical: false,
    value: value, // TODO: ensure works

    // https://docs.gtk.org/gtk3/class.ProgressBar.html#properties
    // ellipsize
    // fraction
    // inverted
    // pulseStep
    // text

    ...rest
});

// TODO: halign: "fill" sane default?
export const Window = ({child, name, anchor, exclusive, ...rest}) => Widget.Window({
    ...BaseProperties,

    // https://github.com/Aylur/ags/wiki/Basic-Widgets#window
    child: child,
    name: name,
    anchor: anchor,
    exclusivity: exclusive ? "exclusive" : "ignore",
    focusable: false,
    layer: "top",
    margins: [],
    monitor: 0,
    popup: false,

    // https://docs.gtk.org/gtk3/class.Container.html#properties
    // borderWidth
    // resizeMode

    // https://docs.gtk.org/gtk3/class.Window.html#properties
    acceptFocus: false,
    // application
    // attachedTo
    decorated: false,
    // defaultHeight
    // defaultWidth
    // deletetable: false,
    // destroyWithParent
    // focusOnMap
    // focusVisible
    // gravity
    hasResizeGrip: false,
    // hideTitlebarWhenMaximized
    // icon
    // iconName
    // mnemonicsVisible
    // modal
    // resizeable: false,
    // role
    // screen
    // skipPagerHint
    // skipTaskbarHint
    // startupId
    // title
    // transientFor
    // type
    // typeHint
    // urgencyHint
    // windowPosition

    ...rest
});
