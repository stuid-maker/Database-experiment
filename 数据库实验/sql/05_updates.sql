-- =============================================================
-- 05_updates.sql  数据更新（插入 / 删除 / 修改）
-- 技巧：所有更新语句放入事务并最后 ROLLBACK，
--       这样可以观察结果而不破坏后续脚本依赖的数据。
-- =============================================================

USE scs;
SET NAMES utf8mb4;
SET autocommit = 0;

-- -------------------------------------------------------------
-- A. 插入
-- -------------------------------------------------------------
START TRANSACTION;

-- A1. 单个完整元组
INSERT INTO Student (Sno, Sname, Ssex, Sage, Sdept, Tutor_Sno)
VALUES ('201515099', 'Jin Qian', 'M', 20, 'CS', '201515001');

-- A2. 单个不完整元组（省略 Ssex、Sage、Tutor_Sno）
INSERT INTO Student (Sno, Sname, Sdept) VALUES ('201515098', 'Jia Sun', 'IS');

-- A3. 子查询结果批量插入
--     将每个院系的学生人数统计到一张临时表中
DROP TABLE IF EXISTS DeptCount;
CREATE TABLE DeptCount (Sdept VARCHAR(20) PRIMARY KEY, Cnt INT);
INSERT INTO DeptCount (Sdept, Cnt)
SELECT Sdept, COUNT(*)
FROM   Student
GROUP  BY Sdept;

SELECT '--- section A insert ---' AS tag;
SELECT * FROM Student WHERE Sno IN ('201515098','201515099');
SELECT * FROM DeptCount;

ROLLBACK;  -- 回滚 A 节的插入，保持原数据

-- -------------------------------------------------------------
-- B. 删除
-- -------------------------------------------------------------
START TRANSACTION;

-- B1. 直接删除：删除学号为 201515011 的学生
DELETE FROM Student WHERE Sno = '201515011';

-- B2. 带子查询的删除：删除所有"计算机系（CS）且平均分 < 70"的学生的选课记录
DELETE FROM SC
WHERE  Sno IN (
    SELECT x.Sno FROM (
        SELECT sc.Sno
        FROM   SC sc JOIN Student s ON sc.Sno = s.Sno
        WHERE  s.Sdept = 'CS' AND sc.Grade IS NOT NULL
        GROUP  BY sc.Sno
        HAVING AVG(sc.Grade) < 70
    ) x
);
-- 说明：MySQL 不允许直接在 DELETE 的子查询中引用被删表，
-- 因此这里用"子查询外再包一层派生表 x"绕过。

SELECT '--- section B delete ---' AS tag;
SELECT * FROM Student WHERE Sno = '201515011';
SELECT Sno, COUNT(*) AS sc_cnt FROM SC GROUP BY Sno ORDER BY Sno;

ROLLBACK;

-- -------------------------------------------------------------
-- C. 修改
-- -------------------------------------------------------------
START TRANSACTION;

-- C1. 直接修改：将学号 201515002 的学生年龄改为 20
UPDATE Student SET Sage = 20 WHERE Sno = '201515002';

-- C2. 带子查询的修改：把 CS 系所有学生的 C001（数据库）成绩提 5 分（封顶 100）
UPDATE SC
SET    Grade = LEAST(Grade + 5, 100)
WHERE  Cno = 'C001'
  AND  Sno IN ( SELECT Sno FROM Student WHERE Sdept = 'CS' );

-- C3. 多表 UPDATE：将讲授 Database 课程的教师职称一律改为 PROF
UPDATE Teacher t
JOIN   Course  c ON t.Tno = c.Tno
SET    t.Ttitle = 'PROF'
WHERE  c.Cname = 'Database';

SELECT '--- section C update ---' AS tag;
SELECT Sno, Sname, Sage FROM Student WHERE Sno = '201515002';
SELECT Sno, Cno, Grade FROM SC
 WHERE Cno = 'C001'
   AND Sno IN (SELECT Sno FROM Student WHERE Sdept = 'CS');
SELECT Tno, Tname, Ttitle FROM Teacher
 WHERE Tno IN (SELECT Tno FROM Course WHERE Cname = 'Database');

ROLLBACK;

SET autocommit = 1;
