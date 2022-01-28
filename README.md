[Alternative Japanese README](https://github.com/ysugimoto/Albatross/blob/master/README-JP.md)


![albatross-middle](https://user-images.githubusercontent.com/1000401/151051494-eba3d68b-fc0e-49bf-a769-8f5bd9eade7b.png)

# Albatross

Albatross is simple key remap application for macos.

## Disclaimer

Currently, this app is tested only US-ANSI keyboard (e.g Builtin Keyboard and Happy Hacking Keyboard).
In JIS keyboard, some keycode may be different from US-ANSI one but we don't have JIS keyboard X(

We welcome to use this app and report to us!

## Support OS

- macos 11.6.1 Big Sur

## Installation

This app is unsigned so you can get it from [release](https://github.com/ysugimoto/Albatross/releases) page and put app into `Application` folder.

After launch this app, you need to allow an Accessibility permission on your machine, please allow this app.

## Usage

Once you have launched the app, default configuration file is generated at `$HOME/.config/albatross/config.yml`, modify this file as you like.

> Note: application watches configuration file so configuration automatically update after you edit this file.

See [Configuration](#Configuration) section about configuration.

## Status Menu

This app does not have any view, just only see icon in status bar during app is running. Menus work as follows:

- `Launch At Login`: toggle this app launches after you logged in automatically
- `Edit Remap`: Copy configuration file path
- `Pause Remap`: Temporary pause remapping, useful for unexpected settings have been written
- `Quit Albatross`: Quit application

## Configuration

Albatross supports two ways of remapping, hardware key using IOKit and virtual key using CGEvent.
You can configure about both remapping in configuration file placed at `$HOME/.config/albatross/config.yml`.

### remap

`remap` field enables hardware key remapping.

| field        | type   | description                 |
|:-------------|:-------|:----------------------------|
| remap        | object | HID key remap configuration |
| remap[key]   | string | remap source key            |
| remap[value] | string | remap destination key       |

> Note:
> - IOKit key remapping affects system global so if you want to reset remapping, set to empty or press `Pause Remap` in status menu, or Quit application.
> - IOKit only remaps single key. If you want to remap key combination like shortcut, please use `alias` setting.

*Important: DO NOT kill this app from terminal or apple menu because Albatross resotres default key setting on terminating app.*

### alias

`alias` field enables virtual key remapping.

| field                         | type                | description                                                                                    |
|:------------------------------|:--------------------|:-----------------------------------------------------------------------------------------------|
| alias                         | object              | Virtual key remap configuration                                                                |
| alias.global                  | array               | system global setting                                                                          |
| alias.global[].from           | array&lt;string&gt; | source key combination                                                                         |
| alias.global[].to             | array&lt;string&gt; | destination key combination                                                                    |
| alias.apps                    | array               | application specific setting, enables only the specific application is active e.g GoogleChrome |
| alias.apps[].name             | string              | specific application name to enable alias                                                      |
| alias.apps[].alias            | array               | alias setting for the application                                                              |
| alias.apps[].alias[].from     | array&lt;string&gt; | source key combination                                                                         |
| alias.apps[].alias[].to?      | array&lt;string&gt; | simple description key combination.                                                            |
| alias.apps[].alias[].toggles? | array&lt;string&gt; | toggle remapping. Toggle this field values for each source matching                            |
| alias.apps[].alias[].double?  | bool                | double key down remapping. If this field is true, handle double key keydown to remap           |

> Note:
> The application name must be an actual name which is shown in `app.localizedName` in Swift.
> For example, if you want to enable for GoogleChrome, you need to specify `Google Chrome` in `alias.apps[].name`.
> For other application, you may find their names in Activity Monitor.app.

The virtual key remap is enable only during Albatross is running.

### Meta key string

In the configuration, each meta keys are specified as fixed string. You can use them for setting, see follwing table:

| Albatross | Keyboard Meta Key             |
|:---------:|:-----------------------------:|
| Esc       | Escape                        |
| Tab       | Tab                           |
| Command_L | Command Left                  |
| Command_R | Command Right                 |
| Del       | Delete                        |
| Ins       | Insert                        |
| Return    | Return (Enter)                |
| Up        | Up Arrow                      |
| Right     | Right Arrow                   |
| Down      | Down Arrow                    |
| Left      | Left Arrow                    |
| Alphabet  | Switch input mode to alphabet |
| Kana      | Switch input mode to kana     |
| F1        | F1                            |
| F2        | F2                            |
| F3        | F3                            |
| F4        | F4                            |
| F5        | F5                            |
| F6        | F6                            |
| F7        | F7                            |
| F8        | F8                            |
| F9        | F9                            |
| F10       | F10                           |
| F11       | F11                           |
| F12       | F12                           |
| Shift_L   | Shift Left                    |
| Shift_R   | Shift Right                   |
| Option_L  | Option Left                   |
| Option_R  | Option Right                  |
| CapsLock  | Caps Lock                     |
| Space     | Space                         |
| Control   | Control                       |

For example, `Control + a` combination can be `[Ctrl, a]` in configuration file.

You can see an example in configuration file, see [albatross.yml](https://github.com/ysugimoto/Albatross/blob/master/Albatross/albatross.yml).

## Acknowledegments

This project much refer to existing great Open Source projects :)

- [cmd-eikana](https://github.com/iMasanari/cmd-eikana)
- [Karabiner-Elements](https://github.com/pqrs-org/Karabiner-Elements)

Many thanks!

## Contribution

- Fork this repository
- Customize / Fix problem
- Send PR :-)
- Or feel free to create issues for us. We'll look into it

## License

MIT License

## Contributors

- [@ysugimoto](https://github.com/ysugimoto)
