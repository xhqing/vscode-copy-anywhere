# vscode-copy-anywhere · 项目硬约束

身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。

## 这是什么

macOS 后台小工具：在 VSCode 资源管理器里 ⌘C 复制的文件，能直接粘到 Finder / 微信 / 浏览器等任意 App。实现是一个 Swift 单文件（`vscode-copy-anywhere.swift`）编成的常驻进程，由用户级 LaunchAgent 拉起，每 0.2 秒看一眼系统剪贴板，发现 VSCode 的私有格式 `code/file-list` 且系统文件格式还没写时，补上 `NSFilenamesPboardType` / `public.file-url` / `text/uri-list` / 纯文本路径。

## 构建与安装

```bash
bash build.sh      # 出产物 vscode-copy-anywhere-<VERSION>（本平台编译，当前 arm64）
bash install.sh    # 编译 → 装到 ~/.local/bin/vscode-copy-anywhere → 注册 LaunchAgent
bash uninstall.sh  # 停掉并移除 LaunchAgent 与二进制
```

产物与临时二进制被 `.gitignore` 忽略（`/vscode-copy-anywhere`、`vscode-copy-anywhere-*`），**不要为了让它们入库去改 `.gitignore`**。

## 不许破坏的既有行为

1. **VSCode 内部粘贴必须照旧可用。** VSCode 的私有数据要按**原始动态 UTI 类型**原样写回剪贴板——覆盖或改名都会让「在 VSCode 里粘回来」失效。
2. **只认 VSCode 的文件复制，别的一律不碰。** 纯文本、图片、别的 App 写的剪贴板内容都不能被改动。
3. **让路行为。** 系统文件格式已经存在时直接跳过（未来 VSCode 官方支持标准格式后就自动退场）。
4. **轮询要轻。** 0.2 秒一轮的循环里不做重活，别把 CPU 拖上去。

## 验证方式（改剪贴板逻辑必做）

真机实测两条，缺一条都算没验完：

1. VSCode 资源管理器 ⌘C 一个文件 → Finder 里 ⌘V，文件能粘出来；
2. 同一份剪贴板内容在 VSCode 内部粘贴，行为与改动前一致。

只跑 `swiftc` 编过不算验证——这两条依赖 macOS 剪贴板真实行为，只能实测。

## 命名与版本

- 二进制名、产物名、LaunchAgent label（`com.xhq.vscode-copy-anywhere`）、日志路径全部用当前项目名；改名是**成套动作**（源文件、`build.sh` / `install.sh` / `uninstall.sh`、CI、双语 README 同批）。
- 版本号单一权威是 `VERSION`：README 徽章与产物名都要跟它一致；CI 里有「`--version` 输出 vs `VERSION`」一致性检查，改一处必须改齐。

## 发布渠道

GitHub Release，**带产物**——每次发版上传当前平台预编译二进制 `vscode-copy-anywhere-<version>`。（历史 `v0.1.x` 的 asset 叫 `copybridge-<version>` 是旧项目名遗留，新发版按现名。）

## 敏感信息

本项目不需要任何凭证；脚本里不写死个人路径之外的信息，README 里不展示本机私有配置。
