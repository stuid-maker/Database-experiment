-- =============================================================
-- 04_queries.sql  数据查询
-- 包含：单表、分组、自身连接、多表连接、嵌套查询、集合查询
-- =============================================================

USE scs;
SET NAMES utf8mb4;

-- =============================================================
-- A. 单表查询
-- =============================================================

-- A1. 选择所有计算机系 (CS) 学生
SELECT Sno, Sname, Sage
FROM   Student
WHERE  Sdept = 'CS';

-- A2. 使用 BETWEEN、LIKE 与 ORDER BY：年龄 18~20 且姓名以 M 开头（示例：Mary Wang）
SELECT *
FROM   Student
WHERE  Sage BETWEEN 18 AND 20
  AND  Sname LIKE 'M%'
ORDER  BY Sage DESC, Sno ASC;

-- A3. DISTINCT + 表达式列：出现过的院系集合
SELECT DISTINCT Sdept AS dept_list
FROM   Student;

-- A4. IS NULL 查询：哪些选课记录缺考（Grade IS NULL）
SELECT Sno, Cno
FROM   SC
WHERE  Grade IS NULL;


-- =============================================================
-- B. 分组统计查询
-- =============================================================

-- B1. 不带 HAVING：每个院系的学生人数、平均年龄
SELECT Sdept,
       COUNT(*)      AS cnt,
       ROUND(AVG(Sage),2) AS avg_age
FROM   Student
GROUP  BY Sdept
ORDER  BY cnt DESC;

-- B2. 带 HAVING：每门课程的平均分及最高分，只显示平均分 >= 80 的课程
SELECT Cno,
       COUNT(*)         AS enroll_cnt,
       ROUND(AVG(Grade),2) AS avg_grade,
       MAX(Grade)       AS max_grade,
       MIN(Grade)       AS min_grade
FROM   SC
WHERE  Grade IS NOT NULL
GROUP  BY Cno
HAVING AVG(Grade) >= 80
ORDER  BY avg_grade DESC;

-- B3. 每位学生选课门数 >= 3 的学生
SELECT Sno, COUNT(*) AS course_cnt
FROM   SC
GROUP  BY Sno
HAVING COUNT(*) >= 3;


-- =============================================================
-- C. 单表自身连接查询
-- =============================================================

-- C1. 查询每位学生及其导师的姓名（Student 与 Student 自连接）
SELECT  s.Sno   AS stu_sno, s.Sname AS stu_name,
        t.Sno   AS tutor_sno, t.Sname AS tutor_name
FROM    Student s
LEFT JOIN Student t ON s.Tutor_Sno = t.Sno
ORDER BY s.Sno;

-- C2. 查询与 Leo Li 同一导师的所有学生
SELECT  a.Sno, a.Sname
FROM    Student a
JOIN    Student b ON a.Tutor_Sno = b.Tutor_Sno
WHERE   b.Sname = 'Leo Li' AND a.Sname <> 'Leo Li'
  AND   a.Tutor_Sno IS NOT NULL;

-- C3. Course 自身连接：查询每门课的先修课名
SELECT  c1.Cno  AS cno,  c1.Cname AS cname,
        c2.Cno  AS prereq_cno, c2.Cname AS prereq_name
FROM    Course c1
LEFT JOIN Course c2 ON c1.Cpno = c2.Cno
ORDER BY c1.Cno;


-- =============================================================
-- D. 多表连接查询
-- =============================================================

-- D1. 学生 × 选课 × 课程 × 教师 四表连接：学生的选课详单
SELECT  s.Sno, s.Sname, s.Sdept,
        c.Cno, c.Cname, c.Ccredit,
        t.Tname AS teacher_name,
        sc.Grade
FROM    Student s
JOIN    SC      sc ON s.Sno = sc.Sno
JOIN    Course  c  ON sc.Cno = c.Cno
LEFT JOIN Teacher t  ON c.Tno = t.Tno
ORDER BY s.Sno, c.Cno;

-- D2. 查询 Wang Wei 老师所授课程的学生名单及成绩
SELECT  t.Tname AS teacher_name, c.Cname AS course_name,
        s.Sno, s.Sname, sc.Grade
FROM    Teacher t
JOIN    Course  c  ON t.Tno = c.Tno
JOIN    SC      sc ON c.Cno = sc.Cno
JOIN    Student s  ON sc.Sno = s.Sno
WHERE   t.Tname = 'Wang Wei'
ORDER BY c.Cno, sc.Grade DESC;


-- =============================================================
-- E. 嵌套查询（相关 / 不相关、各种谓词）
-- =============================================================

-- E1. IN 引出的不相关子查询：查询选修了 C001（数据库）的学生姓名
SELECT Sno, Sname
FROM   Student
WHERE  Sno IN ( SELECT Sno FROM SC WHERE Cno = 'C001' );

-- E2. = 标量子查询：查询与 Grace Liu 同一院系的学生（除其本人）
SELECT Sno, Sname, Sdept
FROM   Student
WHERE  Sdept = ( SELECT Sdept FROM Student WHERE Sname = 'Grace Liu' )
  AND  Sname <> 'Grace Liu';

-- E3. EXISTS 相关子查询：查询选修了课程 C001 的学生
SELECT Sno, Sname
FROM   Student s
WHERE  EXISTS (
    SELECT 1 FROM SC
    WHERE  SC.Sno = s.Sno AND SC.Cno = 'C001'
);

-- E4. NOT EXISTS 相关子查询 —— 实现"关系除法"
-- 查询选修了全部课程的学生姓名
SELECT Sname
FROM   Student s
WHERE  NOT EXISTS (
    SELECT 1 FROM Course c
    WHERE  NOT EXISTS (
        SELECT 1 FROM SC
        WHERE  SC.Sno = s.Sno AND SC.Cno = c.Cno
    )
);

-- E5. ANY 子查询：查询成绩高于课程 C005 任一一名同学的学生
SELECT DISTINCT s.Sno, s.Sname, sc.Cno, sc.Grade
FROM   Student s JOIN SC sc ON s.Sno = sc.Sno
WHERE  sc.Grade > ANY ( SELECT Grade FROM SC WHERE Cno = 'C005' AND Grade IS NOT NULL )
  AND  sc.Cno = 'C005'
ORDER BY sc.Grade DESC;

-- E6. ALL 子查询：查询 C001 课程中成绩高于所有 CS 系同学 C001 成绩的人
SELECT Sno, Grade
FROM   SC
WHERE  Cno = 'C001'
  AND  Grade > ALL (
        SELECT sc.Grade
        FROM   SC sc JOIN Student s ON sc.Sno = s.Sno
        WHERE  sc.Cno = 'C001' AND s.Sdept = 'IS'
              AND sc.Grade IS NOT NULL
  );

-- E7. 相关子查询（每组最大）：查询每门课程成绩最高的学生
SELECT sc.Cno, sc.Sno, sc.Grade
FROM   SC sc
WHERE  sc.Grade = (
    SELECT MAX(Grade) FROM SC sc2 WHERE sc2.Cno = sc.Cno
)
ORDER BY sc.Cno;

-- E8. NOT IN 子查询：查询没有选修任何课程的学生
SELECT Sno, Sname
FROM   Student
WHERE  Sno NOT IN ( SELECT DISTINCT Sno FROM SC );


-- =============================================================
-- F. 集合查询
-- =============================================================

-- F1. UNION：CS 系学生或选了 C001 的学生（去重）
SELECT Sno, Sname FROM Student WHERE Sdept = 'CS'
UNION
SELECT s.Sno, s.Sname FROM Student s JOIN SC ON s.Sno = SC.Sno WHERE SC.Cno = 'C001';

-- F2. UNION ALL：将两个查询结果不去重地合并
SELECT Sno FROM Student WHERE Sdept = 'CS'
UNION ALL
SELECT Sno FROM SC WHERE Cno = 'C001';

-- F3. INTERSECT（MySQL 8.0.31+）：CS 系且选修了 C001 的学生
-- 若 MySQL 版本 < 8.0.31，请改用 F3'（INNER JOIN）
SELECT Sno FROM Student WHERE Sdept = 'CS'
INTERSECT
SELECT Sno FROM SC WHERE Cno = 'C001';

-- F3'. 低版本等价写法：使用 IN 子查询
-- SELECT Sno FROM Student WHERE Sdept = 'CS' AND Sno IN (SELECT Sno FROM SC WHERE Cno='C001');

-- F4. EXCEPT（MySQL 8.0.31+）：CS 系但未选修 C001 的学生
SELECT Sno FROM Student WHERE Sdept = 'CS'
EXCEPT
SELECT Sno FROM SC WHERE Cno = 'C001';

-- F4'. 低版本等价写法：NOT IN 子查询
-- SELECT Sno FROM Student WHERE Sdept = 'CS' AND Sno NOT IN (SELECT Sno FROM SC WHERE Cno='C001');
