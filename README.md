# 《数据库原理》课程实验 —— SCS 场景

本项目基于 **MySQL 8.x/9.x**，围绕"学生-教师-课程-选课"场景（Student-Course-SC，简称 SCS）完成课程实验 1~9 的全部内容。

## 一、目录结构

```
课程实验+{学号}+{姓名}/
├── README.md                    # 本说明
├── sql/
│   ├── 01_schema.sql            # 建库建表 + 建表时的三类完整性约束
│   ├── 02_alter_drop.sql        # 修改表结构、演示 DROP TABLE
│   ├── 03_sample_data.sql       # 插入样例数据（完整/不完整/子查询插入）
│   ├── 04_queries.sql           # 单表/分组/自连接/多表连接/嵌套/集合查询
│   ├── 05_updates.sql           # 插入 / 删除 / 修改（含子查询）
│   ├── 06_views.sql             # 视图：建立/查询/更新/WITH CHECK OPTION/删除
│   ├── 07_privileges.sql        # 用户、角色、授权/回收（含 WITH GRANT OPTION）
│   ├── 08_constraints.sql       # 完整性约束的建表后增/删/改及违反验证
│   ├── 09_triggers.sql          # 触发器：定义、激活、删除
│   └── 10_backup_restore.md     # mysqldump 备份与恢复说明
├── backup/
│   └── scs_backup.sql           # 由 mysqldump 生成的备份文件（初始为占位）
└── docs/
    ├── 实验报告.md
    └── 验证问题回答.md
```

## 二、执行顺序

**重要（Windows PowerShell）**：PowerShell 里 **不支持** `mysql ... < 文件.sql` 这种输入重定向（会报「`<` 运算符是为将来使用而保留的」）。请任选其一：

- **推荐**：下面「方式一」用 `cmd /c` 调用 cmd 的重定向；
- **或**：「方式二」在 `mysql>` 里用 `SOURCE`；
- **或**：在「命令提示符 cmd」里执行（不是 PowerShell），此时 `mysql -u root -p < sql\01_schema.sql` 可用。

```powershell
# 方式一：在项目根目录下，用 cmd 执行重定向（PowerShell 下可用）
cd "C:\Users\33755\Desktop\数据库实验"   # 按你的实际路径修改
cmd /c "mysql --default-character-set=utf8mb4 -u root -p < sql\01_schema.sql"
cmd /c "mysql --default-character-set=utf8mb4 -u root -p < sql\02_alter_drop.sql"
cmd /c "mysql --default-character-set=utf8mb4 -u root -p < sql\03_sample_data.sql"
cmd /c "mysql --default-character-set=utf8mb4 -u root -p < sql\04_queries.sql"
cmd /c "mysql --default-character-set=utf8mb4 -u root -p < sql\05_updates.sql"
cmd /c "mysql --default-character-set=utf8mb4 -u root -p < sql\06_views.sql"
cmd /c "mysql --default-character-set=utf8mb4 -u root -p < sql\07_privileges.sql"
cmd /c "mysql --default-character-set=utf8mb4 -u root -p < sql\08_constraints.sql"
cmd /c "mysql --default-character-set=utf8mb4 -u root -p < sql\09_triggers.sql"
```

或在 MySQL 客户端里依次 `SOURCE`：

```sql
SOURCE D:/课程实验+学号+姓名/sql/01_schema.sql;
SOURCE D:/课程实验+学号+姓名/sql/02_alter_drop.sql;
-- ...依次执行到 09_triggers.sql
```

### 字符集（建议）

样例数据与 ENUM 字面量为 **ASCII（英文）**，一般不再出现乱码。仍建议：

1. 登录时指定：`mysql --default-character-set=utf8mb4 -u root -p`
2. 各 `sql/*.sql` 在 `USE scs` 后已含 `SET NAMES utf8mb4;`

若曾用错误字符集建库导致元数据异常，可重新执行 [`sql/01_schema.sql`](sql/01_schema.sql)（会 `DROP DATABASE scs`），再顺序执行 `02`～`03`。

> 建议使用支持彩色输出与结果导出的客户端（MySQL Workbench、Navicat 或 DBeaver），便于截取实验报告所需截图。

## 三、备份与恢复

```powershell
# 备份（含触发器、存储过程）。建议用 cmd 重定向，避免 PowerShell 默认编码影响 SQL 文件
cmd /c "mysqldump -u root -p --databases scs --routines --triggers --events > backup\scs_backup.sql"

# 恢复（PowerShell 下同样用 cmd 做输入重定向）
cmd /c "mysql -u root -p < backup\scs_backup.sql"
```

详见 [sql/10_backup_restore.md](sql/10_backup_restore.md)。

## 四、提交打包

1. 执行 `mysqldump` 产生真实的 `backup/scs_backup.sql`（覆盖占位文件）；
2. 填写 [docs/实验报告.md](docs/实验报告.md) 中的姓名、学号、截图、感想；
3. 把根目录重命名为 `课程实验+你的学号+你的姓名`；
4. 使用 7-Zip 或 WinRAR 将其打包为同名的 `.zip` 或 `.rar` 文件提交。

例如：

```
课程实验+20230001+张三.zip
```

## 五、环境依赖

- MySQL 8.0.16 及以上（`CHECK` 约束在 8.0.16 开始生效；`INTERSECT`/`EXCEPT` 需 8.0.31+）
- 字符集 `utf8mb4`
- 客户端登录账户需具备 `ALL PRIVILEGES` 或至少：`CREATE, DROP, ALTER, INSERT, SELECT, UPDATE, DELETE, CREATE VIEW, TRIGGER, CREATE USER, CREATE ROLE, GRANT OPTION`

## 六、注意事项

- `05_updates.sql`、`06_views.sql`、`08_constraints.sql`、`09_triggers.sql` 中的 DML 均使用 `START TRANSACTION; ... ROLLBACK;` 回滚，以保证后续脚本依赖的数据不被污染；若需要保留修改，请将 `ROLLBACK` 改为 `COMMIT`。
- `08_constraints.sql` 中"违反约束"的 DML 默认以注释方式提供，演示时请按需取消注释并截图保存报错输出。
- `07_privileges.sql` 中创建的用户 `u_student / u_teacher / u_admin` 密码详见脚本，如在公用环境演示后请及时 `DROP USER`。
