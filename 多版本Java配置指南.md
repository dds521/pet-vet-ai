# Java 8 和 Java 17 共存配置指南

## 📋 目标
- 保留现有的 Java 8（默认）
- 安装 Java 17
- 两个版本可以同时存在
- 默认使用 Java 8

## 🔧 安装 Java 17

### 方式一：手动下载安装（推荐）

1. **访问下载页面**：
   https://adoptium.net/temurin/releases/?version=17

2. **选择配置**：
   - Operating System: **macOS**
   - Architecture: **x64**
   - Package Type: **JDK**
   - Version: **17 (LTS)**

3. **下载并安装**：
   - 下载 `.pkg` 文件
   - 双击安装包，按提示完成安装

4. **验证安装**：
   ```bash
   /usr/libexec/java_home -V
   ```
   应该能看到 Java 8 和 Java 17 两个版本

### 方式二：使用 Homebrew（需要 Xcode）

```bash
brew install openjdk@17
```

## ⚙️ 配置环境变量

### 1. 创建 Java 版本管理脚本

已自动创建 `~/.java_versions.sh` 脚本，包含以下功能：

- **默认使用 Java 8**（启动终端时自动设置）
- **use_java8()** - 切换到 Java 8
- **use_java17()** - 切换到 Java 17
- **show_java_version()** - 显示当前 Java 版本
- **list_java_versions()** - 列出所有已安装的版本

### 2. 配置 Shell 环境

脚本已自动添加到 `~/.zshrc`，每次打开终端时会：
- 自动加载 Java 版本管理脚本
- 默认使用 Java 8

### 3. 应用配置

```bash
# 重新加载配置
source ~/.zshrc
```

## 🚀 使用方法

### 查看当前 Java 版本

```bash
show_java_version
# 或
java -version
```

### 切换到 Java 8

```bash
use_java8
```

### 切换到 Java 17

```bash
use_java17
```

### 列出所有已安装的版本

```bash
list_java_versions
```

## 📝 项目特定配置

### 对于需要 Java 8 的项目

无需特殊配置，默认就是 Java 8。

### 对于需要 Java 17 的项目（如 spring-ai）

在项目目录下创建启动脚本或使用：

```bash
# 临时切换到 Java 17
use_java17

# 运行项目
cd /path/to/spring-ai
./mvnw clean spring-boot:run

# 运行完成后可以切换回 Java 8
use_java8
```

### 修改 spring-ai 的启动脚本

可以修改 `start.sh`，在脚本开头添加：

```bash
#!/bin/bash

# 切换到 Java 17
source ~/.java_versions.sh
use_java17

# 原有的启动逻辑...
```

## 🔍 验证配置

### 1. 检查 Java 8

```bash
use_java8
java -version
# 应该显示: java version "1.8.0_251"
```

### 2. 检查 Java 17

```bash
use_java17
java -version
# 应该显示: openjdk version "17.x.x"
```

### 3. 检查环境变量

```bash
echo $JAVA_HOME
# Java 8: /Library/Java/JavaVirtualMachines/jdk1.8.0_251.jdk/Contents/Home
# Java 17: /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
```

## 📋 配置总结

| 配置项 | 值 |
|--------|-----|
| 默认 Java 版本 | Java 8 |
| Java 8 路径 | `/Library/Java/JavaVirtualMachines/jdk1.8.0_251.jdk/Contents/Home` |
| Java 17 路径 | `/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home`（安装后） |
| 管理脚本 | `~/.java_versions.sh` |
| Shell 配置 | `~/.zshrc` |

## ⚠️ 注意事项

1. **Maven 配置**：Maven 会使用当前 `JAVA_HOME` 环境变量
2. **IDE 配置**：IDE（如 IntelliJ IDEA）需要单独配置项目使用的 JDK
3. **全局默认**：系统默认使用 Java 8，不影响现有项目
4. **临时切换**：使用 `use_java17` 只在当前终端会话有效

## 🆘 故障排查

### 问题：找不到 Java 17

```bash
# 检查是否安装
/usr/libexec/java_home -V

# 如果未安装，重新安装
# 访问: https://adoptium.net/temurin/releases/?version=17
```

### 问题：切换后版本不对

```bash
# 重新加载脚本
source ~/.java_versions.sh

# 手动设置
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH=$JAVA_HOME/bin:$PATH
```

### 问题：Maven 仍使用旧版本

```bash
# 检查 Maven 使用的 Java
./mvnw -version

# 确保 JAVA_HOME 正确
echo $JAVA_HOME
```

---

**配置完成后，默认使用 Java 8，需要时使用 `use_java17` 切换到 Java 17**
