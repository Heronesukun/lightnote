# 轻记 - 简单记账本 (Flutter版)

> A simple, local-first记账应用 built with Flutter

## 📱 项目概述

**项目名称**: 轻记 (LightNote)  
**项目类型**: 移动端应用 (Android/iOS) + 桌面端 (Web/Desktop)  
**核心定位**: 简洁、无需登录、数据本地存储的记账工具

---

## 🎯 核心特性 (MVP)

### 1. 记账功能
- ✅ 记收入/支出
- ✅ 选择账户 (支付宝、微信、现金、银行等)
- ✅ 选择分类 (餐饮、交通、购物、工资等)
- ✅ 添加备注
- ✅ 选择日期时间
- ✅ 修改/删除记录

### 2. 账户管理
- ✅ 创建/编辑/删除账户
- ✅ 账户类型 (现金、支付宝、微信、银行、信用卡等)
- ✅ 账户余额自动计算

### 3. 分类管理
- ✅ 预设常用分类 (收入/支出)
- ✅ 自定义分类图标
- ✅ 收入/支出分类

### 4. 报表统计
- ✅ 月度收支统计
- ✅ 分类占比饼图
- ✅ 趋势折线图

### 5. 数据存储
- ✅ 本地 SQLite 存储
- ✅ 无需登录，无需网络
- ✅ 数据导出 (JSON/CSV)

---

## 📊 数据模型

### Transaction (交易记录)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| amount | double | 金额 (正数收入，负数支出) |
| type | enum | income / expense |
| categoryId | int | 分类ID |
| accountId | int | 账户ID |
| merchant | String? | 商户名称 (可选) |
| note | String? | 备注 |
| date | DateTime | 交易时间 |
| createdAt | DateTime | 创建时间 |
| updatedAt | DateTime | 更新时间 |

### Account (账户)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| name | String | 账户名称 |
| type | enum | cash / alipay / wechat / bank / credit |
| balance | double | 当前余额 |
| icon | String | 图标名称 |
| color | int | 颜色值 |
| createdAt | DateTime | 创建时间 |

### Category (分类)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| name | String | 分类名称 |
| type | enum | income / expense |
| icon | String | 图标名称 |
| color | int | 颜色值 |
| isDefault | bool | 是否默认分类 |

---

## 🛠️ 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 框架 | Flutter | 3.x |
| 语言 | Dart | 3.x |
| 状态管理 | flutter_bloc | ^8.x |
| 本地数据库 | sqflite | ^2.x |
| 路由 | go_router | ^14.x |
| UI 组件 | Material Design 3 | - |
| 图表 | fl_chart | ^0.69.x |
| 日期处理 | intl | ^0.19.x |
| 导入/导出 | share_plus, path_provider | latest |

---

## 📱 页面结构

```
App
├── Home (首页/流水)
│   ├── 月份选择
│   ├── 收支概览
│   └── 交易列表
├── AddTransaction (记账)
│   ├── 金额输入
│   ├── 类型切换 (收入/支出)
│   ├── 分类选择
│   ├── 账户选择
│   ├── 日期选择
│   └── 备注输入
├── Accounts (账户)
│   ├── 账户列表
│   └── 新增/编辑账户
├── Statistics (统计)
│   ├── 月度收支
│   ├── 饼图 (分类占比)
│   └── 趋势图
└── Settings (设置)
    ├── 分类管理
    ├── 数据导出
    ├── 关于
    └── 主题切换
```

---

## 🚀 开发计划

### Phase 1: 基础功能 (MVP)
- [ ] 项目初始化
- [ ] 数据库搭建 (sqflite)
- [ ] 账户 CRUD
- [ ] 分类 CRUD
- [ ] 记账功能 (增删改查)
- [ ] 首页流水展示

### Phase 2: 统计与优化
- [ ] 账户余额计算
- [ ] 月度收支统计
- [ ] 饼图/折线图
- [ ] 数据导出

### Phase 3: 完善与发布
- [ ] 主题切换 (明/暗)
- [ ] 国际化
- [ ] App Icon & 启动页
- [ ] 发布到 App Store / Google Play

---

## 📦 相关参考

- 原始项目: [AccountBookSystem](https://github.com/Heronesukun/AccountBookSystem) (Java + Vue3)
- Flutter 文档: https://flutter.dev/docs

---

## 📄 License

MIT License
