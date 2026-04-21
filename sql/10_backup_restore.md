# 10. 数据库备份与恢复（选做）

本实验使用 MySQL 自带的 `mysqldump` 工具进行逻辑备份，用 `mysql` 客户端或 `SOURCE` 命令进行恢复。

## 一、备份数据库

### 1. 只备份数据与表结构

```powershell
# Windows PowerShell（在项目根目录执行）
# 说明：PowerShell 中 `mysql ... < xxx.sql` 不可用；mysqldump 输出建议也用 cmd 重定向，避免编码问题
cmd /c "mysqldump -u root -p --databases scs > backup\scs_backup.sql"
```

- `--databases scs` 会在备份中包含 `CREATE DATABASE` 和 `USE scs;` 语句，恢复时可直接使用。
- 系统会提示输入 root 密码。

### 2. 包含触发器、存储过程、事件

```powershell
cmd /c "mysqldump -u root -p --databases scs --routines --triggers --events > backup\scs_full_backup.sql"
```

### 3. 仅备份某几张表

```powershell
cmd /c "mysqldump -u root -p scs Student Course SC > backup\scs_core_tables.sql"
```

## 二、恢复数据库

### 方式 A：命令行重定向

```powershell
# PowerShell 下请用 cmd 调用，否则 `<` 会报错
cmd /c "mysql -u root -p < backup\scs_backup.sql"
```

### 方式 B：在 MySQL 客户端里 SOURCE

```sql
mysql> SOURCE D:/课程实验+学号+姓名/backup/scs_backup.sql;
```

> 注意：`SOURCE` 后面是文件路径，**不要加引号**，Windows 路径用正斜杠 `/` 或双反斜杠 `\\`。

### 方式 C：在已存在的数据库上恢复

```powershell
mysql -u root -p scs < backup\scs_core_tables.sql
```

## 三、验证备份与恢复

1. 执行备份命令后，检查 `backup/scs_backup.sql` 文件是否生成且非空（文件大小 > 0）。
2. 在 MySQL 中 `DROP DATABASE scs;`，再用恢复命令导入。
3. 执行以下查询确认数据完整：

```sql
USE scs;
SELECT (SELECT COUNT(*) FROM Student) AS S,
       (SELECT COUNT(*) FROM Teacher) AS T,
       (SELECT COUNT(*) FROM Course)  AS C,
       (SELECT COUNT(*) FROM SC)      AS SC;
```

应与备份前行数一致。

## 四、常见问题

| 问题 | 排查思路 |
| ---- | -------- |
| `Access denied` | 确认 MySQL 用户名密码，并且该账号具有 `SELECT, SHOW VIEW, TRIGGER, LOCK TABLES` 权限 |
| 中文乱码 | 加入 `--default-character-set=utf8mb4` 参数 |
| 恢复时报 `Unknown collation` | MySQL 版本差异，可在备份 SQL 里把 `utf8mb4_0900_ai_ci` 替换为 `utf8mb4_general_ci` |
| Windows 下提示 `mysqldump 不是内部命令` | 将 MySQL 安装目录下的 `bin` 加入 PATH |
