# License Policy

すべてのリポジトリに `LICENSE` ファイルを含める。ライセンスなしでの公開は禁止。

## License Selection

ライセンスは **Closed / AGPL・GPL・LGPL / MIT** の3分類から選択する。OSS だからといって必ずしも MIT ではない。

| プロジェクト種別 | 推奨ライセンス | 備考 |
|---|---|---|
| 研究・実験系（配布しない） | Closed | All Rights Reserved |
| 研究・実験系（配布する） | MIT | 制限なく利用できるよう MIT を基本とする |
| コンパイル配布系（Swift アプリ・Chrome 拡張など） | Closed または AGPL/GPL/LGPL | 将来の再ライセンスの余地を確保したい場合は準 CLA 対応を推奨（[GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md) 参照） |
| ソースコードで配布系（Alfred、Python など） | Closed（配布しない）または MIT | |
| 配布なし（Web app） | Closed | API ドキュメントのみ公開も選択肢 |
| 商用利用を制限したいドキュメント系 | CC BY-NC 4.0 など | ドキュメント系に限る |

ライセンス選択は case by case。上記は傾向の参考にとどめ、プロジェクトの状況に応じて判断すること。

## License Templates

### All Rights Reserved

クローズドプロジェクト向け：

```
Copyright (c) [YEAR] [AUTHOR]

All rights reserved.

This software and associated documentation files are proprietary and
confidential. Unauthorized copying, distribution, modification, or use
of this software, in whole or in part, is strictly prohibited without
the express written permission of the author.
```

### MIT

OSS プロジェクト向け：

```
MIT License

Copyright (c) [YEAR] [AUTHOR]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### AGPL / GPL / LGPL

コンパイル配布系でコピーレフトを採用する場合、ライセンス本文は公式ソースから取得すること：

- AGPL v3: https://www.gnu.org/licenses/agpl-3.0.txt
- GPL v3: https://www.gnu.org/licenses/gpl-3.0.txt
- LGPL v3: https://www.gnu.org/licenses/lgpl-3.0.txt

取得したテキストをそのまま `LICENSE` ファイルとして配置する。

**選択の目安：**

| ライセンス | 用途 |
|---|---|
| AGPL v3 | Web サービス・SaaS 等、サーバサイドでの使用にもコピーレフトを及ぼしたい場合 |
| GPL v3 | スタンドアローンアプリ等、配布バイナリにコピーレフトを及ぼしたい場合 |
| LGPL v3 | ライブラリ等、リンクするコードへの影響を最小化したい場合 |

将来的な再ライセンスの余地を確保したい場合は [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md) の準 CLA 設定を参照。

---

*このドキュメントには英語版 [README.md](README.md) があります。編集時は同一コミットで更新してください。*
