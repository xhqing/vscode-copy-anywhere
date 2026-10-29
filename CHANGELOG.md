# Changelog

All notable changes to this project will be documented in this file.

## [未发布]

### 变更（`.pi` 由软链接改为真实目录 + 资源引用：全局规矩 2026-10-30 修订）

- **为什么改**：2026-10-30 用户修订了子项目的智能体专属文件规则。旧形态把 `.pi` 整个挂成指向负责 Agent 的软链接，「共享」与「独占」被压在同一个符号上：子项目要放自己的配置时无处安放，硬写进 `.pi` 等于直接写进 Kit 的 Agent 项目——会瞬间影响 Kit 的全部兄弟子项目、并进 Agent 仓库的 git 历史。新规则分层：身份层（`AGENTS.md`）继续保持软链接一致（pi 的上下文文件没有 include 机制，超集只能靠复制、复制必然漂移）；能力层（`.pi/`）改在子项目里建真实目录，用 `settings.json` 以**路径引用** Agent 项目的资源目录，本地专属内容放自己的目录——行为上是超集，结构上无副本、不漂移，且子项目写自己的 `.pi` 不再污染 Agent 项目。
- **改了什么**：删除 `.pi` 软链接（原指向 `../ExecutiveAssistantAgent/.pi`），改为真实目录加 `.pi/settings.json`：`extensions` / `skills` / `prompts` / `themes` 四组各指向 `~/Developer/ExecutiveAssistantAgent/.pi/` 下对应目录，并附带本地 `./extensions` / `./skills` / `./prompts` / `./themes`（本地目录不存在时自动跳过）。`AGENTS.md` 软链接保持不变。
- **验证**：据 pi 官方文档（`settings.md`「Resources」——项目 `.pi/settings.json` 的路径相对 `.pi` 解析、支持 `~`、路径可为目录并递归收集；`skills.md` / `extensions.md`——`.pi/{skills,extensions,prompts,themes}` 的自动发现照常生效）；同批在 `xhqing` 子项目实跑 `pi --approve -p`，技能与项目级扩展均从 Agent 项目加载成功。
- **规则出处**：全局 `~/.pi/agent/docs/agents-registry.md`「智能体专属文件归属与子项目映射（2026-10-30 修订）」节。

### 变更（新增指回负责 Agent 的软链接：AGENTS.md、.pi）

- **为什么改**：用户 2026-10-17 决定把 Agent 与子项目关系统一为「Agent 进驻子项目」网络（取代 2026-10-12 的「子项目不得有智能体专属文件」）：子项目根目录挂两条指回负责 Agent 的相对路径软链接，随仓库提交——在子项目目录开会话即继承负责 Agent 的身份 / 规则 / 技能；本仓库作为 Kit（ExecutiveAssistantAgent）的子项目相应挂链。
- **改了什么**：根目录新增两条软链接——`AGENTS.md → ../ExecutiveAssistantAgent/AGENTS.md`、`.pi → ../ExecutiveAssistantAgent/.pi`。（单独 clone 到别处时链接悬空，无害。）

## [0.1.1] - 2026-10-12

### 变更（按 2026-10-12 新规清理随附的智能体专属文件 CLAUDE.md / AGENTS.md）

- **为什么改**：用户 2026-10-12 修订团队规则——智能体专属文件（`CLAUDE.md` / `AGENTS.md` / `.claude/` / 项目级 `.pi/`）只有 Agent 项目允许拥有，非 Agent 项目（含本仓库这类子项目）一律不得存在；后台开启 pi 会话只能以 Agent 项目根目录为工作目录（细则见全局 `~/.claude/docs/agents-registry.md`「智能体专属文件归属与子项目映射」节）。本仓库此前按旧「超集」规则随附了 Kit 的 CLAUDE.md 全文，需按新规清理。
- **改了什么**：删除根目录 `CLAUDE.md`（项目指南 + Kit CLAUDE.md 全文随附）与 `AGENTS.md`（软链 → CLAUDE.md）；项目指南里的生产目录 / 发版约定在 `README_cn.md`「开发目录与生产目录」「安装与要求」已有等价说明，删除无内容损失。

## [0.1.0] - 2026-10-08

### Added

- **copybridge 初版**：让 VSCode 资源管理器里「复制文件」（选中文件按 ⌘C / 右键复制）之后，可以直接粘贴到 Finder、微信、浏览器上传框等系统应用。原理：常驻小进程（LaunchAgent）每 0.2 秒查看一次系统剪贴板，发现 VSCode 私有格式 `code/file-list` 且剪贴板里还没有系统文件格式时，解析出文件路径并补上 `NSFilenamesPboardType`（Finder 传统格式）、`public.file-url`、`text/uri-list` 与纯文本路径；同时按原样保留 VSCode 的私有数据（按原始动态 UTI 类型写回），VSCode 内部粘贴不受影响（实测验证）。
- 只处理本地工作区（`file://`）的文件；远程窗口（SSH / WSL / 容器）复制的文件跳过、原剪贴板保持不动（日志记 `skip: non-local uri`）；普通复制（文字、图片、其它应用的任何内容）完全不碰。VSCode 未来若官方支持标准格式，本工具检测到系统格式已存在时会自动让路。
- `install.sh` / `uninstall.sh`：一键编译安装到 `~/.local/bin/copybridge` 并注册用户级 LaunchAgent（无需 sudo）+ 一键卸载。
- `copybridge --once`：只处理一次当前剪贴板后退出（用于测试）。
- `copybridge --version`：输出版本号。

### Project

- **建立本仓库（开发目录）**：copybridge 的开发在 `~/Developer/copybridge` 进行；`~/.local/bin/copybridge` 为生产副本（LaunchAgent 实际运行所在），发版（tag + GitHub Release）后从 Release 产物安装，禁止软链 / 直跑开发目录二进制（运行版本与开发版本隔离）。
- CI（`.github/workflows/ci.yml`，macOS runner）：Swift 编译检查、`--version` 输出与 `VERSION` 一致性检查、shell 脚本语法检查、shellcheck 静态检查。
- README 中英双语 + LOGO + 徽章；MIT LICENSE；CHANGELOG 与 VERSION。
- 踩坑记录（实现要点）：macOS 会把非法 UTI 字符串 `code/file-list` 在「条目层」自动转成动态 UTI（`dyn.…`）存放，条目层用原名查不到、剪贴板层（`NSPasteboard.data(forType:)`）才能查到——本工具按剪贴板层读取、按原始动态 UTI 名字写回，VSCode 内部粘贴才不受影响。
