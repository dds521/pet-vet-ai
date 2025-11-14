#!/bin/bash

echo "=========================================="
echo "Spring AI 项目启动脚本"
echo "=========================================="

# 加载 Java 版本管理脚本
if [ -f ~/.java_versions.sh ]; then
    source ~/.java_versions.sh
else
    echo "⚠️  Java 版本管理脚本不存在，使用默认方式"
fi

# 检测Java 17
JAVA_17_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null)

if [ -z "$JAVA_17_HOME" ]; then
    echo "❌ 未检测到Java 17"
    echo ""
    echo "请先安装Java 17："
    echo "1. 访问: https://adoptium.net/temurin/releases/?version=17"
    echo "2. 下载 macOS x64 版本的 .pkg 文件"
    echo "3. 双击安装"
    echo "4. 重新运行此脚本"
    echo ""
    exit 1
fi

echo "✅ 检测到Java 17: $JAVA_17_HOME"
echo ""

# 切换到 Java 17（使用版本管理脚本）
if command -v use_java17 &> /dev/null; then
    use_java17
else
    # 如果脚本函数不可用，手动设置
    export JAVA_HOME=$JAVA_17_HOME
    export PATH=$JAVA_HOME/bin:$PATH
    echo "当前Java版本："
    java -version
    echo ""
fi

# 检查OpenAI API Key
if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" = "dummy-key" ]; then
    echo "⚠️  警告: OPENAI_API_KEY 未配置"
    echo "   项目可以启动，但AI功能将不可用"
    echo ""
    echo "   配置方法："
    echo "   export OPENAI_API_KEY='your-api-key'"
    echo ""
fi

echo "=========================================="
echo "开始启动项目..."
echo "=========================================="
echo ""

# 创建临时日志文件
LOG_FILE=$(mktemp /tmp/spring-ai-startup-XXXXXX.log)
echo "📝 启动日志: $LOG_FILE"
echo ""

# 在后台启动项目
echo "🚀 正在启动 Spring AI 服务..."
./mvnw clean spring-boot:run > "$LOG_FILE" 2>&1 &
MAVEN_PID=$!

# 等待服务启动
echo "⏳ 等待服务启动..."
MAX_WAIT=120  # 最大等待时间（秒）
WAIT_COUNT=0
STARTED=false

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    # 检查端口是否被占用
    if lsof -i :8080 > /dev/null 2>&1; then
        # 检查 API 是否可访问
        if curl -s http://localhost:8080/api/ping > /dev/null 2>&1; then
            STARTED=true
            break
        fi
    fi
    
    # 检查进程是否还在运行
    if ! ps -p $MAVEN_PID > /dev/null 2>&1; then
        echo ""
        echo "❌ 服务启动失败！"
        echo ""
        echo "📋 错误日志："
        tail -30 "$LOG_FILE"
        rm -f "$LOG_FILE"
        exit 1
    fi
    
    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 2))
    echo -n "."
done

echo ""
echo ""

if [ "$STARTED" = true ]; then
    # 显示启动成功标识
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║          ✅  Spring AI 服务启动成功！                        ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📍 服务信息："
    echo "   - 服务地址: http://localhost:8080"
    echo "   - 健康检查: http://localhost:8080/api/ping"
    echo "   - Actuator: http://localhost:8080/actuator/health"
    echo "   - AI 接口:  http://localhost:8080/api/ai/quick?q=你的问题"
    echo ""
    echo "🔧 测试命令："
    echo "   curl http://localhost:8080/api/ping"
    echo ""
    if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" = "dummy-key" ]; then
        echo "⚠️  提示: OPENAI_API_KEY 未配置，AI 功能不可用"
        echo "   配置方法: export OPENAI_API_KEY='your-api-key'"
        echo ""
    fi
    echo "🛑 停止服务: 按 Ctrl+C 或运行 kill $MAVEN_PID"
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # 保持脚本运行，显示实时日志
    echo "📊 实时日志（按 Ctrl+C 停止服务）："
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # 使用 tail -f 显示实时日志，并在 Ctrl+C 时清理
    trap "echo ''; echo '🛑 正在停止服务...'; kill $MAVEN_PID 2>/dev/null; rm -f '$LOG_FILE'; exit 0" INT TERM
    
    # 显示实时日志
    tail -f "$LOG_FILE" 2>/dev/null &
    TAIL_PID=$!
    
    # 等待 Maven 进程结束
    wait $MAVEN_PID
    MAVEN_EXIT_CODE=$?
    
    # 停止 tail
    kill $TAIL_PID 2>/dev/null
    
    # 清理临时日志文件
    rm -f "$LOG_FILE"
    
    # 如果进程异常退出，显示错误
    if [ $MAVEN_EXIT_CODE -ne 0 ]; then
        echo ""
        echo "❌ 服务异常退出（退出码: $MAVEN_EXIT_CODE）"
        exit $MAVEN_EXIT_CODE
    fi
else
    echo ""
    echo "❌ 服务启动超时（超过 ${MAX_WAIT} 秒）"
    echo ""
    echo "📋 最近日志："
    tail -50 "$LOG_FILE"
    echo ""
    echo "🛑 正在停止服务..."
    kill $MAVEN_PID 2>/dev/null
    rm -f "$LOG_FILE"
    exit 1
fi

