-- =============================================================
-- 02_alter_drop.sql  修改基本表结构、删除基本表
-- 说明：本脚本演示 ALTER TABLE 的增/改/删列、重命名、约束增删，
--       以及 DROP TABLE；为避免破坏后续实验数据，所有修改都在
--       演示完成后回滚回原始状态或仅在临时表上执行 DROP。
-- =============================================================

USE scs;
SET NAMES utf8mb4;

-- -------------------------------------------------------------
-- 1. 为 Student 增加列：邮箱、入学时间
-- -------------------------------------------------------------
ALTER TABLE Student
    ADD COLUMN Semail    VARCHAR(50) NULL        COMMENT '邮箱',
    ADD COLUMN Senroll   DATE        DEFAULT (CURRENT_DATE) COMMENT '入学日期';

-- -------------------------------------------------------------
-- 2. 修改列的数据类型 / 默认值
--    将 Sname 长度由 VARCHAR(20) 扩大到 VARCHAR(30)
-- -------------------------------------------------------------
ALTER TABLE Student
    MODIFY COLUMN Sname VARCHAR(30) NOT NULL;

-- -------------------------------------------------------------
-- 3. 重命名列（MySQL 8.0 起支持 RENAME COLUMN）
-- -------------------------------------------------------------
ALTER TABLE Student
    RENAME COLUMN Semail TO StuEmail;

-- -------------------------------------------------------------
-- 4. 增加一条新的约束：邮箱必须包含 '@'
-- -------------------------------------------------------------
ALTER TABLE Student
    ADD CONSTRAINT ck_student_email CHECK (StuEmail IS NULL OR StuEmail LIKE '%@%');

-- -------------------------------------------------------------
-- 5. 删除列
-- -------------------------------------------------------------
ALTER TABLE Student
    DROP COLUMN Senroll;

-- -------------------------------------------------------------
-- 6. 删除刚才添加的约束与列（还原为原始结构，便于后续实验）
-- -------------------------------------------------------------
ALTER TABLE Student DROP CONSTRAINT ck_student_email;
ALTER TABLE Student DROP COLUMN StuEmail;
ALTER TABLE Student MODIFY COLUMN Sname VARCHAR(20) NOT NULL;

-- -------------------------------------------------------------
-- 7. 演示 DROP TABLE —— 在临时表上删除，不破坏 SCS 主要数据
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS TempDemo (
    id   INT PRIMARY KEY,
    note VARCHAR(50)
);
DROP TABLE TempDemo;

-- -------------------------------------------------------------
-- 8. 查看最终表结构
-- -------------------------------------------------------------
DESC Student;
DESC Teacher;
DESC Course;
DESC SC;
