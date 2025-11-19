# PetVetAI - 宠物医疗 AI 咨询平台

## 📋 项目概述

PetVetAI 是一个基于 Spring Boot 和 Spring AI 的智能宠物医疗咨询平台，通过集成 OpenAI GPT-4 模型，为宠物主人提供专业的症状分析和医疗建议。系统采用分层架构设计，支持高并发访问，具备完善的流量控制和安全机制。

## 🛠 技术栈

### 核心框架
- **Spring Boot 3.3.5** - 应用框架
- **Java 17** - 开发语言
- **Spring AI 1.0.0** - AI 集成框架
- **OpenAI GPT-4o** - AI 模型

### 数据持久化
- **MySQL** - 关系型数据库
- **MyBatis Plus 3.5.5** - ORM 框架
- **Redis** - 缓存数据库

### 中间件
- **RocketMQ 2.3.0** - 消息队列
- **Sentinel** - 流量控制与熔断降级

### 安全与监控
- **Spring Security** - 安全框架
- **OAuth2 Resource Server** - 认证授权
- **JWT** - Token 认证
- **Spring Boot Actuator** - 监控与管理

### 工具库
- **Lombok** - 简化代码
- **Hutool 5.8.25** - Java 工具库

## 🏗 系统架构

### 架构分层

```
┌─────────────────────────────────────────────────────────┐
│                     前端层 (Frontend)                      │
│              Next.js / React / Vue 应用                   │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP/REST API
┌──────────────────────▼──────────────────────────────────┐
│                    Controller 层                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │PetVetController│  │SentinelDemo  │  │  其他Controller │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                    Service 层                            │
│  ┌──────────────┐  ┌──────────────┐                    │
│  │PetMedicalService│ │MqProducerService│                  │
│  └──────────────┘  └──────────────┘                    │
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
┌───────▼──────┐ ┌────▼─────┐ ┌─────▼──────┐
│  Mapper 层    │ │ Spring AI │ │  RocketMQ  │
│  ┌──────────┐ │ │  OpenAI   │ │  消息队列   │
│  │PetMapper │ │ │  GPT-4o   │ └───────────┘
│  │SymptomMap│ │ └───────────┘
│  └──────────┘ │
└───────┬───────┘
        │
┌───────▼──────────────────────────────────┐
│              Domain 层                     │
│  ┌────────┐  ┌────────┐  ┌──────────┐   │
│  │  Pet   │  │Symptom │  │Diagnosis │   │
│  └────────┘  └────────┘  └──────────┘   │
└───────┬──────────────────────────────────┘
        │
┌───────▼──────────────────────────────────┐
│           数据存储层                        │
│  ┌────────┐  ┌────────┐                  │
│  │  MySQL │  │ Redis  │                  │
│  └────────┘  └────────┘                  │
└───────────────────────────────────────────┘
```

### 核心组件说明

#### 1. Controller 层 (`com.petvetai.app.controller`)
- **PetVetController**: 宠物医疗诊断 API 入口
  - `POST /api/pet/diagnose` - 宠物症状诊断接口
- **SentinelDemoController**: Sentinel 流量控制演示
- **JavaReferenceTypesDemo**: Java 引用类型演示

#### 2. Service 层 (`com.petvetai.app.service`)
- **PetMedicalService**: 核心业务服务
  - 集成 Spring AI ChatClient
  - 调用 OpenAI API 进行症状分析
  - 管理诊断流程和结果持久化
- **MqProducerService**: 消息队列生产者服务

#### 3. Mapper 层 (`com.petvetai.app.mapper`)
- **PetMapper**: 宠物信息数据访问
- **SymptomMapper**: 症状记录数据访问
- 基于 MyBatis Plus BaseMapper，提供基础 CRUD 能力

#### 4. Domain 层 (`com.petvetai.app.domain`)
- **Pet**: 宠物实体
  - 字段：id, name, breed, age, createdAt
- **Symptom**: 症状实体
  - 字段：id, description, petId, reportedAt
- **Diagnosis**: 诊断结果值对象
  - 字段：suggestion（建议）, confidence（置信度）

#### 5. Config 层 (`com.petvetai.app.config`)
- **ChatClientConfig**: Spring AI ChatClient 配置
- **CorsConfig**: 跨域资源共享配置
- **RedisConfig**: Redis 连接池配置
- **SentinelConfig**: Sentinel 流量控制配置
- **SecurityConfig**: Spring Security 安全配置
  - 支持 JWT/OAuth2 认证（可扩展）
  - 当前开放 `/api/pet/**` 和 `/actuator/**` 用于测试

## �� 数据模型

### 宠物表 (pets)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键，自增 |
| name | VARCHAR | 宠物名称 |
| breed | VARCHAR | 宠物品种 |
| age | INT | 年龄 |
| created_at | DATETIME | 创建时间 |

### 症状表 (symptoms)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键，自增 |
| description | VARCHAR | 症状描述 |
| pet_id | BIGINT | 关联宠物ID |
| reported_at | DATETIME | 报告时间 |

## 🔄 核心业务流程

### 宠物诊断流程

```
1. 用户提交诊断请求
   ↓
2. Controller 接收请求 (PetVetController.diagnose)
   ↓
3. Service 层处理 (PetMedicalService.analyzeSymptom)
   ├─ 查询宠物信息 (PetMapper)
   ├─ 构建 AI Prompt（包含宠物信息 + 症状描述）
   ├─ 调用 OpenAI API (Spring AI ChatClient)
   ├─ 解析 AI 响应
   └─ 保存症状记录 (SymptomMapper)
   ↓
4. 返回诊断结果 (Diagnosis)
   ├─ suggestion: 诊断建议
   └─ confidence: 置信度分数
```

## ⚙️ 配置说明

### 环境配置

项目支持多环境配置，通过 `SPRING_PROFILES_ACTIVE` 环境变量切换：

- **dev** - 开发环境 (`application-dev.yml`)
- **test** - 测试环境 (`application-test.yml`)
- **uat** - 预发布环境 (`application-uat.yml`)
- **prod** - 生产环境 (`application-prod.yml`)

### 关键环境变量

```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_NAME=pet_vet_ai_dev
DB_USERNAME=root
DB_PASSWORD=password

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# OpenAI 配置
OPENAI_API_KEY=your-api-key-here

# RocketMQ 配置
ROCKETMQ_NAMESRV=localhost:9876

# Sentinel 配置
SENTINEL_DASHBOARD=localhost:8718

# Spring Profile
SPRING_PROFILES_ACTIVE=dev
```

### 应用配置 (`application.yml`)

- **Spring Cloud Sentinel**: 流量控制与熔断
- **MyBatis Plus**: ORM 配置，支持下划线转驼峰
- **Actuator**: 健康检查和监控端点

## 🚀 部署说明

### 本地开发

1. **环境要求**
   - JDK 17+
   - Maven 3.6+
   - MySQL 8.0+
   - Redis 6.0+
   - RocketMQ (可选)
   - Sentinel Dashboard (可选)

2. **启动步骤**

```bash
# 1. 配置环境变量
export OPENAI_API_KEY=your-api-key
export SPRING_PROFILES_ACTIVE=dev

# 2. 启动数据库和 Redis
# 确保 MySQL 和 Redis 服务已启动

# 3. 执行启动脚本
chmod +x start.sh
./start.sh

# 或使用 Maven
mvn clean spring-boot:run
```

3. **验证服务**

```bash
# 健康检查
curl http://localhost:8080/actuator/health

# Ping 接口
curl http://localhost:8080/api/ping
```

### Docker 部署

```bash
# 1. 构建镜像
docker build -t pet-vet-ai:latest .

# 2. 运行容器
docker run -d \
  -p 8080:8080 \
  -e OPENAI_API_KEY=your-api-key \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e DB_HOST=your-db-host \
  -e DB_PASSWORD=your-db-password \
  pet-vet-ai:latest
```

## 📡 API 接口

### 诊断接口

**POST** `/api/pet/diagnose`

请求体：
```json
{
  "petId": 1,
  "symptomDesc": "宠物出现呕吐、食欲不振的症状"
}
```

响应：
```json
{
  "suggestion": "建议：可能是消化系统问题，建议禁食12小时观察...",
  "confidence": 0.8
}
```

### 监控接口

- **GET** `/actuator/health` - 健康检查
- **GET** `/actuator/info` - 应用信息
- **GET** `/actuator/metrics` - 指标监控

## 🔒 安全机制

1. **Spring Security**: 基础安全框架
2. **CORS 配置**: 跨域访问控制
3. **JWT/OAuth2**: Token 认证（可扩展）
4. **Sentinel**: 流量控制与限流

## 📈 性能优化

1. **Redis 缓存**: 缓存热点数据
2. **连接池**: MySQL 和 Redis 连接池优化
3. **Sentinel 限流**: 防止系统过载
4. **异步消息**: RocketMQ 支持异步处理

## 🧪 测试

```bash
# 运行单元测试
mvn test

# 运行集成测试
mvn verify
```

## 📝 开发规范

- 遵循 DDD（领域驱动设计）思想
- 使用设计模式优化代码结构
- 分层清晰：Controller -> Service -> Mapper -> Domain
- 统一异常处理和响应格式
- 完善的代码注释和文档

## 🔧 故障排查

### 常见问题

1. **OpenAI API 调用失败**
   - 检查 `OPENAI_API_KEY` 环境变量
   - 确认网络连接正常

2. **数据库连接失败**
   - 检查数据库服务是否启动
   - 验证连接配置是否正确

3. **端口被占用**
   - 修改 `application.yml` 中的 `server.port`
   - 或使用 `SERVER_PORT` 环境变量

## 📚 相关文档

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [Spring AI 文档](https://docs.spring.io/spring-ai/reference/)
- [MyBatis Plus 文档](https://baomidou.com/)
- [Sentinel 文档](https://sentinelguard.io/)

## 📄 许可证

本项目采用 MIT 许可证。

---

**维护者**: PetVetAI Team  
**最后更新**: 2025
