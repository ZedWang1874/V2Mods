# Vermintide 2 Mod Development Scripts

这个目录包含了用于Vermintide 2 mod开发的自动化脚本。

## 脚本说明

### 1. `build_mod.bat` - 主要构建脚本
完整的mod构建和上传流程，包含文件同步检查。

**用法：**
```batch
build_mod.bat [mod_name]
# 例如：
build_mod.bat bordercheck
```

**功能：**
- ✅ 检查VMF配置
- ✅ 自动同步本地文件到VMF目录
- ✅ 验证文件时间戳，强制更新不同步的文件
- ✅ 构建mod并验证输出
- ✅ 可选择上传到Steam Workshop
- ✅ 详细的错误诊断信息

### 2. `sync_mod.bat` - 文件同步脚本
专门用于同步文件，不进行构建。

**用法：**
```batch
sync_mod.bat [mod_name]
# 例如：
sync_mod.bat bordercheck
```

**功能：**
- 显示文件差异
- 同步本地文件到VMF目录
- 验证同步结果

### 3. `check_environment.bat` - 环境检查脚本
检查开发环境是否正确配置。

**用法：**
```batch
check_environment.bat
```

**检查项目：**
- VMF/VMB安装
- 配置正确性
- SDK存在性
- mod目录结构

## 使用工作流

### 开发新功能时：
1. 在本地目录 `d:\V2Mods\[mod_name]\` 中编辑代码
2. 运行 `build_mod.bat [mod_name]` 进行构建和测试
3. 满意后选择上传到Steam Workshop

### 仅同步文件（不构建）：
1. 运行 `sync_mod.bat [mod_name]` 
2. 手动运行VMF命令进行构建

### 环境问题诊断：
1. 运行 `check_environment.bat`
2. 根据输出修复配置问题

## 文件同步机制

脚本会自动：
1. 检查本地文件和VMF目录文件的时间戳
2. 如果发现差异，强制复制最新的本地文件
3. 验证关键文件（.lua, .mod, .cfg等）是否正确同步
4. 在构建前确保所有文件都是最新版本

## 故障排除

### 常见问题：

**1. "VMF configuration check failed"**
- 运行 `check_environment.bat` 检查配置
- 确保VMF正确安装在 `D:\V2\Vermintide-Mod-Builder`

**2. "File synchronization failed"**
- 检查文件权限
- 确保VMF目录可写
- 手动运行 `sync_mod.bat` 进行诊断

**3. "Build failed"**
- 检查Lua语法错误
- 查看生成的 `.processed` 文件获取详细错误信息
- 确保所有资源路径正确

**4. "Upload failed"**
- 确保Steam正在运行
- 检查网络连接
- 验证Workshop ID配置

## 目录结构

```
D:\V2Mods\
├── build_mod.bat           # 主构建脚本
├── sync_mod.bat            # 文件同步脚本
├── check_environment.bat   # 环境检查脚本
├── .gitignore              # Git忽略规则
├── SCRIPTS_README.md       # 本文档
└── [mod_name]/             # 各个mod的目录
    ├── [mod_name].mod
    ├── itemV2.cfg
    ├── scripts/
    │   └── mods/
    │       └── [mod_name]/
    │           ├── [mod_name].lua
    │           ├── [mod_name]_data.lua
    │           └── [mod_name]_localization.lua
    └── resource_packages/
```

## 注意事项

1. **总是在本地目录编辑文件**，不要直接编辑VMF目录中的文件
2. **构建前运行脚本**，确保文件同步
3. **保持备份**，重要更改及时提交到Git
4. **测试构建**，上传前确保mod在游戏中正常工作
