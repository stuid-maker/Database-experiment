-- =============================================================
-- 06_views.sql  视图
-- 内容：建立视图、使用视图（查询/更新）、WITH CHECK OPTION、删除视图
-- 同时验证"不可更新视图"
-- =============================================================

USE scs;
SET NAMES utf8mb4;

-- -------------------------------------------------------------
-- A. 建立视图
-- -------------------------------------------------------------

-- A1. 最简单：只指定行过滤条件，列名全部省略
CREATE OR REPLACE VIEW V_IS_Student AS
SELECT Sno, Sname, Sage, Sdept
FROM   Student
WHERE  Sdept = 'IS';

-- A2. 含表达式/聚合 —— 必须显式指定视图列名
CREATE OR REPLACE VIEW V_Student_AvgGrade (Sno, Sname, AvgGrade, CourseCnt) AS
SELECT  s.Sno, s.Sname,
        ROUND(AVG(sc.Grade),2),
        COUNT(sc.Cno)
FROM    Student s LEFT JOIN SC sc ON s.Sno = sc.Sno
GROUP   BY s.Sno, s.Sname;

-- A3. 多表连接视图：学生选课明细（供后续查询/更新演示）
CREATE OR REPLACE VIEW V_SC_Detail AS
SELECT  s.Sno, s.Sname, s.Sdept,
        c.Cno, c.Cname, c.Ccredit,
        sc.Grade
FROM    Student s
JOIN    SC      sc ON s.Sno = sc.Sno
JOIN    Course  c  ON sc.Cno = c.Cno;

-- A4. 带 WITH CHECK OPTION：只能看到 / 只能更新到满足视图条件的行
CREATE OR REPLACE VIEW V_IS_Student_Check AS
SELECT Sno, Sname, Sage, Sdept
FROM   Student
WHERE  Sdept = 'IS'
WITH CHECK OPTION;


-- -------------------------------------------------------------
-- B. 使用视图 —— 查询
-- -------------------------------------------------------------

-- B1. 直接查询视图，像查询表一样
SELECT * FROM V_IS_Student;

-- B2. 基于视图再做查询（分组）
SELECT Sdept, COUNT(*) AS cnt
FROM   V_IS_Student
GROUP  BY Sdept;

-- B3. 查询带聚合的视图
SELECT * FROM V_Student_AvgGrade ORDER BY AvgGrade DESC;

-- B4. 多表视图查询
SELECT Sname, Cname, Grade
FROM   V_SC_Detail
WHERE  Sdept = 'CS'
ORDER BY Sname;


-- -------------------------------------------------------------
-- C. 使用视图 —— 更新（验证"可更新"与"不可更新"视图）
-- -------------------------------------------------------------
SET autocommit = 0;
START TRANSACTION;

-- C1. 可更新视图：V_IS_Student 是简单单表视图，可以 UPDATE
UPDATE V_IS_Student SET Sage = Sage + 1 WHERE Sno = '201515004';
SELECT Sno, Sname, Sage, Sdept FROM Student WHERE Sno = '201515004';

-- C2. 不可更新视图：V_Student_AvgGrade 含聚合函数，不允许 UPDATE
--     下一语句会报错：ERROR 1288 The target table of the UPDATE is not updatable
--     请同学截图保留报错结果（可根据需要取消下一行注释运行）
UPDATE V_Student_AvgGrade SET AvgGrade = 100 WHERE Sno = '201515001';

-- C3. WITH CHECK OPTION 验证
-- 通过视图修改的学生如果其 Sdept 不再是 'IS'，会被 DBMS 拒绝
-- 下一语句应报错：CHECK OPTION failed
UPDATE V_IS_Student_Check SET Sdept = 'MA' WHERE Sno = '201515004';

-- C4. 通过视图插入（含 WITH CHECK OPTION）
-- 下一语句应成功（Sdept='IS' 满足视图条件）：
INSERT INTO V_IS_Student_Check (Sno, Sname, Sage, Sdept)
VALUES ('201515097', 'Hui Zhou', 21, 'IS');
SELECT * FROM V_IS_Student_Check;

-- 若尝试插入 Sdept='CS'（不满足视图条件）则会被拒绝：
INSERT INTO V_IS_Student_Check (Sno, Sname, Sage, Sdept) VALUES ('201515096','Yi Qian',21,'CS');

ROLLBACK;
SET autocommit = 1;

-- -------------------------------------------------------------
-- D. 删除视图
-- -------------------------------------------------------------
DROP VIEW IF EXISTS V_IS_Student;
DROP VIEW IF EXISTS V_Student_AvgGrade;
DROP VIEW IF EXISTS V_SC_Detail;
DROP VIEW IF EXISTS V_IS_Student_Check;

-- 查看已不存在
SHOW FULL TABLES WHERE Table_type = 'VIEW';
