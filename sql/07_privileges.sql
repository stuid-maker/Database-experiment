-- =============================================================
-- 07_privileges.sql  权限管理
-- 内容：用户 / 角色 / 直接授权 / 通过角色授权 / WITH GRANT OPTION
--       以及权限验证与回收
-- 说明：需要以 root 或具备 CREATE USER / ROLE 权限的账号执行
-- =============================================================

USE scs;
SET NAMES utf8mb4;

-- -------------------------------------------------------------
-- 0. 预清理（如有残留账户/角色则删除，确保脚本可重复执行）
-- -------------------------------------------------------------
DROP USER IF EXISTS 'u_student'@'localhost';
DROP USER IF EXISTS 'u_teacher'@'localhost';
DROP USER IF EXISTS 'u_admin'@'localhost';
DROP ROLE IF EXISTS 'r_read_only', 'r_grade_writer';

-- -------------------------------------------------------------
-- A. 创建用户
-- -------------------------------------------------------------
CREATE USER 'u_student'@'localhost' IDENTIFIED BY 'Stu@2024';
CREATE USER 'u_teacher'@'localhost' IDENTIFIED BY 'Tch@2024';
CREATE USER 'u_admin'@'localhost'   IDENTIFIED BY 'Adm@2024';

-- -------------------------------------------------------------
-- B. 创建角色并分配权限
-- -------------------------------------------------------------
CREATE ROLE 'r_read_only', 'r_grade_writer';

-- r_read_only：对所有表只读
GRANT SELECT ON scs.* TO 'r_read_only';

-- r_grade_writer：可以查询学生与课程，且可以修改 SC.Grade
GRANT SELECT ON scs.Student TO 'r_grade_writer';
GRANT SELECT ON scs.Course  TO 'r_grade_writer';
GRANT SELECT, UPDATE (Grade) ON scs.SC TO 'r_grade_writer';

-- -------------------------------------------------------------
-- C. 给用户分配权限
-- -------------------------------------------------------------

-- C1. 直接分配：u_admin 获得对 scs 库所有权限，并可以再授予别人
GRANT ALL PRIVILEGES ON scs.* TO 'u_admin'@'localhost' WITH GRANT OPTION;

-- C2. 通过角色分配：u_student 只读、u_teacher 可以改成绩
GRANT 'r_read_only'     TO 'u_student'@'localhost';
GRANT 'r_grade_writer'  TO 'u_teacher'@'localhost';

-- 让角色在登录时默认激活
SET DEFAULT ROLE ALL TO 'u_student'@'localhost', 'u_teacher'@'localhost';

-- 应用更改
FLUSH PRIVILEGES;

-- -------------------------------------------------------------
-- D. 验证权限分配的正确性
-- -------------------------------------------------------------

-- D1. 查看各账号拥有的权限
SHOW GRANTS FOR 'u_admin'@'localhost';
SHOW GRANTS FOR 'u_student'@'localhost' USING 'r_read_only';
SHOW GRANTS FOR 'u_teacher'@'localhost' USING 'r_grade_writer';

-- D2. 验证权限（重要：以下命令在「命令提示符 / PowerShell」里执行，不要在 mysql> 里执行）
--     原因：`mysql -u ...` 是启动客户端的程序命令，不是 SQL；在 mysql> 里输入会报 ERROR 1064。
--     做法：先在本窗口输入 exit; 退出 mysql，或另开一个终端窗口，再执行下面的 mysql 命令。
/*
   # 终端 1（在 cmd / PowerShell 中，不是 mysql>）
   mysql --default-character-set=utf8mb4 -u u_student -p scs
   （输入密码：脚本里为 Stu@2024）

   进入后出现 mysql>，再输入 SQL：
   SELECT * FROM Student LIMIT 5;          -- 应成功
   UPDATE SC SET Grade = 100 WHERE Sno = '201515001' AND Cno = 'C001';  -- 应拒绝 ERROR 1142

   # 终端 2
   mysql --default-character-set=utf8mb4 -u u_teacher -p scs
   （密码：Tch@2024）

   SELECT Sno, Sname FROM Student LIMIT 5;   -- 应成功
   UPDATE SC SET Grade = 95 WHERE Sno = '201515001' AND Cno = 'C001';   -- 应成功
   UPDATE Student SET Sage = 30 WHERE Sno = '201515001';                -- 应拒绝

   # 终端 3（演示 WITH GRANT OPTION 传递授权）
   mysql --default-character-set=utf8mb4 -u u_admin -p scs
   （密码：Adm@2024）

   GRANT SELECT ON scs.Teacher TO 'u_student'@'localhost';
*/


-- -------------------------------------------------------------
-- E. 收回权限
-- -------------------------------------------------------------

-- E1. 从用户收回角色
REVOKE 'r_read_only'    FROM 'u_student'@'localhost';
REVOKE 'r_grade_writer' FROM 'u_teacher'@'localhost';

-- E2. 从角色收回权限
REVOKE UPDATE (Grade) ON scs.SC FROM 'r_grade_writer';

-- E3. 从用户收回所有权限
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'u_admin'@'localhost';

-- E4. 最终清理（如需保留用户演示给老师看，可注释掉以下 DROP）
--DROP USER 'u_student'@'localhost';
--DROP USER 'u_teacher'@'localhost';
--DROP USER 'u_admin'@'localhost';
--DROP ROLE 'r_read_only', 'r_grade_writer';

FLUSH PRIVILEGES;

-- E5. 再次查看，确认权限已回收
SHOW GRANTS FOR 'u_student'@'localhost';
SHOW GRANTS FOR 'u_teacher'@'localhost';
SHOW GRANTS FOR 'u_admin'@'localhost';

