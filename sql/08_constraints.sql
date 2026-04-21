-- =============================================================
-- 08_constraints.sql  三类完整性约束
-- 内容：
--   (1) 建表时的约束已在 01_schema.sql 给出；
--   (2) 本脚本演示建表后通过 ALTER TABLE 增加 / 删除 / 修改约束；
--   (3) 通过"故意违反约束"的 SQL 观察 DBMS 的保护作用。
-- =============================================================

USE scs;
SET NAMES utf8mb4;

-- -------------------------------------------------------------
-- A. 建表后增加约束
-- -------------------------------------------------------------

-- A1. 实体完整性：保证 Teacher.Tname 唯一
ALTER TABLE Teacher
    ADD CONSTRAINT uk_teacher_name UNIQUE (Tname);

-- A2. 用户定义完整性：学分只能是 1~10 整数（原表已有，此处演示替换）
ALTER TABLE Course
    DROP CONSTRAINT ck_course_credit;
ALTER TABLE Course
    ADD CONSTRAINT ck_course_credit CHECK (Ccredit BETWEEN 1 AND 6);

-- A3. 参照完整性：SC.Sno 外键（原表已存在），下面演示删除后再添加
ALTER TABLE SC DROP FOREIGN KEY fk_sc_student;
ALTER TABLE SC
    ADD CONSTRAINT fk_sc_student FOREIGN KEY (Sno)
        REFERENCES Student(Sno)
        ON UPDATE CASCADE ON DELETE CASCADE;

-- A4. 为 Student 增加非空约束（用户定义完整性）：
--     Sdept 原本已 NOT NULL，这里把 Sage 也设为 NOT NULL 并给默认值
ALTER TABLE Student MODIFY COLUMN Sage TINYINT UNSIGNED NOT NULL DEFAULT 18;


-- -------------------------------------------------------------
-- B. 验证 DBMS 的完整性保护功能
--    每条语句都是"故意违反约束"的 DML，执行后应观察到报错。
--    为不影响其他脚本，所有验证放入事务并 ROLLBACK。
-- -------------------------------------------------------------
SET autocommit = 0;
START TRANSACTION;

-- B1. 违反主键 / 实体完整性：插入重复 Sno
-- 预期报错：Duplicate entry '201515001' for key 'Student.PRIMARY'
-- INSERT INTO Student (Sno,Sname,Sdept) VALUES ('201515001','Dup Stu','CS');

-- B2. 违反 NOT NULL：不提供 Sdept
-- 预期报错：Field 'Sdept' doesn't have a default value
-- INSERT INTO Student (Sno,Sname) VALUES ('201515090','Si Li');

-- B3. 违反 ENUM 取值：插入非法性别（Ssex 列为 ENUM，无 'X'）
-- 预期报错（严格模式）：Data truncated for column 'Ssex' 或 Invalid value for enum
-- INSERT INTO Student (Sno,Sname,Ssex,Sage,Sdept) VALUES ('201515091','Wu Zhang','X',20,'CS');

-- B4. 违反 UNIQUE：插入与已有教师同名的教师
-- 预期报错：Duplicate entry 'Wang Wei' for key 'Teacher.uk_teacher_name'
-- INSERT INTO Teacher (Tno,Tname,Tdept) VALUES ('T9999','Wang Wei','CS');

-- B5. 违反参照完整性：SC 中插入不存在的 Sno
-- 预期报错：Cannot add or update a child row: foreign key constraint fails
-- INSERT INTO SC (Sno,Cno,Grade) VALUES ('999999999','C001',80);

-- B6. 违反参照完整性：删除 Course 中仍被 SC 引用的课程
-- 因 SC.fk_sc_course 未指定 CASCADE，删除将被拒绝
-- DELETE FROM Course WHERE Cno='C001';

-- ★提示：请同学按需取消注释，在客户端执行以记录错误输出和截图

ROLLBACK;
SET autocommit = 1;


-- -------------------------------------------------------------
-- C. 修改约束 —— 将 CHECK 约束恢复为 1~10
-- -------------------------------------------------------------
ALTER TABLE Course DROP CONSTRAINT ck_course_credit;
ALTER TABLE Course
    ADD CONSTRAINT ck_course_credit CHECK (Ccredit BETWEEN 1 AND 10);

-- -------------------------------------------------------------
-- D. 删除约束 —— 演示 DROP CONSTRAINT / DROP INDEX
-- -------------------------------------------------------------
ALTER TABLE Teacher DROP CONSTRAINT uk_teacher_name;

-- -------------------------------------------------------------
-- E. 查看当前约束（information_schema）
-- -------------------------------------------------------------
SELECT CONSTRAINT_NAME, TABLE_NAME, CONSTRAINT_TYPE
FROM   information_schema.TABLE_CONSTRAINTS
WHERE  TABLE_SCHEMA = 'scs'
ORDER  BY TABLE_NAME, CONSTRAINT_TYPE;

SELECT CONSTRAINT_NAME, TABLE_NAME, CHECK_CLAUSE
FROM   information_schema.CHECK_CONSTRAINTS
WHERE  CONSTRAINT_SCHEMA = 'scs'
ORDER  BY TABLE_NAME;
