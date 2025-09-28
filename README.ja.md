# sticky-window.el

ウィンドウ操作時にも維持される「固定」ウィンドウを管理するEmacsパッケージ

## 機能

- **永続的なウィンドウ**: `delete-other-windows` (C-x 1) を使用してもstickyウィンドウは保持されます
- **レイアウト保護**: 最後の非stickyウィンドウの削除を防ぎます
- **自動リサイズ**: フレームサイズが変更されてもstickyウィンドウのサイズを自動的に維持します
- **柔軟な配置**: 任意の側（左、右、上、下）にstickyウィンドウを作成できます
- **専用ウィンドウ**: stickyウィンドウは特定のバッファ専用になります

## インストール

### 手動インストール

1. このリポジトリをクローンまたは`sticky-window.el`をダウンロード
2. Emacs設定に以下を追加：

```elisp
(add-to-list 'load-path "/path/to/sticky-window")
(require 'sticky-window)
```

### straight.elを使用

```elisp
(straight-use-package
 '(sticky-window :type git :host github :repo "ofnhwx/sticky-window"))
```

## 使い方

### モードを有効化

```elisp
(sticky-window-mode 1)
```

### stickyウィンドウの作成

```elisp
;; デフォルトサイズ（フレーム幅の30%）で左側にstickyウィンドウを作成
(sticky-window-create "*Buffer Name*" 'left)

;; 幅40%で右側にstickyウィンドウを作成
(sticky-window-create "*Buffer Name*" 'right 0.4)

;; 高さ200ピクセルで下部にstickyウィンドウを作成
(sticky-window-create "*Buffer Name*" 'bottom 200)
```

### 設定例

```elisp
;; 左側にファイルツリーを固定表示
(sticky-window-create (dired-noselect "~/") 'left 0.25)

;; 下部にターミナルを固定表示
(sticky-window-create "*eshell*" 'bottom 0.3)

;; 右側にコンパイルバッファを固定表示
(sticky-window-create "*compilation*" 'right 0.35)
```

## カスタマイズ

### デフォルトサイズの変更

```elisp
(setq sticky-window-default-size 0.25)  ; デフォルトをフレームサイズの25%に設定
```

`M-x customize-group RET sticky-window RET` からも設定可能です。

## API

### 関数

- `sticky-window-create (buffer side &optional size)` - stickyウィンドウを作成
  - `buffer`: 表示するバッファ
  - `side`: 配置位置 ('left, 'right, 'top, 'bottom)
  - `size`: オプションのサイズ (0.0-1.0で比率、1.0超でピクセル指定)

- `sticky-window-p (window)` - ウィンドウがstickyかどうかを確認

- `sticky-window-list` - 全てのstickyウィンドウのリストを取得

- `sticky-window-mode` - sticky window機能を有効にするグローバルマイナーモード

## 仕組み

stickyウィンドウは以下の技術を使って実装されています：
- ウィンドウパラメータでウィンドウをstickyとしてマーク
- `delete-other-windows`と`delete-window`へのアドバイスでstickyウィンドウを保護
- ウィンドウサイズ変更フックでウィンドウサイズを維持
- サイドウィンドウで予測可能な配置を実現

## 必要環境

- Emacs 28.1以降

## ライセンス

GPL-3.0-or-later

## 作者

ofnhwx

## コントリビューション

バグ報告やプルリクエストは https://github.com/ofnhwx/sticky-window にて歓迎します。
