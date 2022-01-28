[Alternative English README](https://github.com/ysugimoto/Albatross/blob/master/README.md)

![albatross-middle](https://user-images.githubusercontent.com/1000401/151051494-eba3d68b-fc0e-49bf-a769-8f5bd9eade7b.png)

# Albatross

Albatrossはシンプルなキーリマッピングアプリです。

## 免責事項

現在このアプリケーションはUS-ANSIキーボードしかサポートしていません（Macの内蔵キーボードとHHKBで動作確認していますが、いずれもUSキーボードです）
JISキーボードでは特定のキーコードが異なるかもしれませんが、JISキーボードを所持していないので確認できていません。

もしJISキーボードでの動作について問題が合った場合、ISSUEで教えていただけると嬉しいです。

## 動作確認OS

- macos 11.6.1 Big Sur

## インストール

このアプリは未署名なので、[GitHubのリリースページ](https://github.com/ysugimoto/Albatross/releases) から最新版をダウンロード後、アプリケーションフォルダに設置してください。
キーリマップにはアクセシビリティの許可が必要なため、アプリを起動すると許可が求められます。

## 使い方

アプリの初回起動時に、キーリマップに関する設定ファイルが `$HOME/.config/albatross/config.yml` に配置されるので、編集して設定を変更してください。

> 注意:
> アプリはこのファイルの変更を監視しています。ファイルを更新すると、リマップ設定が即座に反映されます。
> また、ユーザ領域にファイルを書き込む理由からサンドボックス化もしていません。

[設定](#設定) のセクションを参照してください。

## ステータスメニュー

このアプリはバックグラウンドで動作するため、ビューがありません。起動中はステータスメニューにアイコンが表示されるので、そこで確認してください:

- `Launch At Login`: ログイン時に起動する設定
- `Edit Remap`: 設定ファイルへのパスをクリップボードにコピー
- `Pause Remap`: 一時的にリマップを無効化します。おかしな設定を入れてしまった時に有用です
- `Quit Albatross`: アプリを終了します

## Configuration

`Albatross` は2つの方法でキーリマップを実現しており、ハードウェアキーに `IOKit`、仮想キーボードには `CGEvent` を使っています。
どちらの方法（または両方）の有効化、設定は設定ファイルで行うことができます。

### remap

`remap` フィールドはハードウェアのキーリマップを行う設定です。

| field        | type   | description           |
|:-------------|:-------|:----------------------|
| remap        | object | HIDキーリマップの設定 |
| remap[key]   | string | 入力キー              |
| remap[value] | string | リマップ先のキー      |

> 注意:
> - IOKitによるリマップはシステムグローバルに有効化されます。もし無効化したい場合は設定を空にするか、`Pause Remap` で一時的に無効化、またはアプリケーションを終了してください。
> - IOKitは単一キーのリマップのみをサポートしています。複数キーのリマップには `alias` の仮想キーボードで行ってください。

*重要: このアプリをターミナルから `kill` したりすると、IOKitのリマップ設定が残ったままになります。アプリのメニューから終了することで、Albatrossは終了時にすべてのキーリマップをデフォルトに戻します。*

### alias

`alias` フィールドは仮想キーボードのキーリマップを行う設定です。リマップというよりはショートカットに近いかもしれません。

| field                         | type                | description                                                                                     |
|:------------------------------|:--------------------|:------------------------------------------------------------------------------------------------|
| alias                         | object              | 仮想キーボードのリマップ設定                                                                    |
| alias.global                  | array               | システムグローバル設定                                                                          |
| alias.global[].from           | array&lt;string&gt; | 入力キーの組み合わせ                                                                            |
| alias.global[].to             | array&lt;string&gt; | リマップキーの組み合わせ                                                                        |
| alias.apps                    | array               | アプリケーション固有のリマップ設定。特定のアプリケーションがアクティブな場合のみ有効化できます  |
| alias.apps[].name             | string              | 有効化したいアプリケーション名                                                                  |
| alias.apps[].alias            | array               | リマップ設定                                                                                    |
| alias.apps[].alias[].from     | array&lt;string&gt; | 入力キーの組み合わせ                                                                            |
| alias.apps[].alias[].to?      | array&lt;string&gt; | リマップキーの組み合わせ                                                                        |
| alias.apps[].alias[].toggles? | array&lt;string&gt; | 入力キーにマッチする度にリマップ先をトグルします                                                |
| alias.apps[].alias[].double?  | bool                | キーを2回連続で押した時にリマップする設定                                                       |

> 注意:
> 有効化したいアプリケーション名はSwiftで `app.localizedName` で取得できるものになります。
> 例えば、GoogleChromeでのみリマップ設定を有効にしたい場合、 `alias.apps[].name` には `Google Chrome` と記述する必要があります。
> その他のアプリケーションについては、 `アクティビティモニタ.app` で表示されるプロセス名から取得できると思います。

仮想キーボードはAblatrossが起動している間だけ有効です。

### 特殊キー文字列

設定ファイルにて、Controlのような特殊キーは固定文字列で識別します。下の表の値を指定してください。

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

例えば、`Control + a` の組み合わせは、設定ファイルには `[Ctrl, a]` と書きます。

設定例については実際の設定ファイルにもコメントで記載しています。 [albatross.yml](https://github.com/ysugimoto/Albatross/blob/master/Albatross/albatross.yml) も確認してください。

## 謝辞

このプロジェクトを作るにあたって、素晴らしいOSSプロジェクトを参考にさせていただきました:

- [cmd-eikana](https://github.com/iMasanari/cmd-eikana)
- [Karabiner-Elements](https://github.com/pqrs-org/Karabiner-Elements)

ありがとうございます！

