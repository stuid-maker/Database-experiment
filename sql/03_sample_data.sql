-- =============================================================
-- 03_sample_data.sql  样例数据插入
-- 演示三种 INSERT：
--   (1) 完整元组插入
--   (2) 不完整元组插入（只给出部分列）
--   (3) 将子查询结果批量插入（INSERT ... SELECT）
-- =============================================================

USE scs;
SET NAMES utf8mb4;

-- 清空旧数据（按照外键关系的反序删除）
DELETE FROM SC;
DELETE FROM Course;
UPDATE Student SET Tutor_Sno = NULL;  -- 断开自引用避免删除时级联
DELETE FROM Student;
DELETE FROM Teacher;

-- -------------------------------------------------------------
-- (1) 完整元组插入 —— 教师
-- -------------------------------------------------------------
INSERT INTO Teacher (Tno, Tname, Ttitle, Tdept) VALUES
('T0001', 'Wang Wei',   'PROF',       'CS'),
('T0002', 'Li Qiang',   'ASSOC_PROF', 'CS'),
('T0003', 'Liu Yang',   'LECTURER',   'IS'),
('T0004', 'Chen Jing',  'PROF',       'MA'),
('T0005', 'Zhao Lei',   'ASSOC_PROF', 'EE');

-- -------------------------------------------------------------
-- (2) 不完整元组插入 —— 学生
--     省略部分可空列 / 依赖默认值（Ssex 默认 'M'，Tutor_Sno 允许为 NULL）
--     首先插入不依赖导师的根节点学生
-- -------------------------------------------------------------
INSERT INTO Student (Sno, Sname, Ssex, Sage, Sdept) VALUES
('201515001', 'Leo Li',    'M', 20, 'CS'),
('201515003', 'Mary Wang', 'F', 18, 'MA'),
('201515004', 'Tom Zhang', 'M', 19, 'IS'),
('201515008', 'Eric Wu',   'M', 22, 'EE');

-- 不完整元组：省略 Ssex（由 DEFAULT 'M' 填入）、省略 Sage
INSERT INTO Student (Sno, Sname, Sdept) VALUES
('201515011', 'Ray Chen', 'MA');

-- 完整元组：含 Tutor_Sno
INSERT INTO Student VALUES
('201515002', 'Grace Liu', 'F', 19, 'CS', '201515001'),
('201515005', 'Alice Zhao','F', 20, 'CS', '201515001'),
('201515006', 'Bob Sun',   'M', 21, 'IS', '201515004'),
('201515007', 'Carol Zhou','F', 19, 'MA', '201515003'),
('201515009', 'David Zheng','M', 20, 'CS', '201515001'),
('201515010', 'Eva Feng',  'F', 18, 'IS', '201515004'),
('201515012', 'Frank He',  'F', 20, 'EE', '201515008');

-- -------------------------------------------------------------
-- 课程 —— 因 Cpno 自引用，按依赖顺序插入
-- -------------------------------------------------------------
-- 无先修课
INSERT INTO Course (Cno, Cname, Cpno, Ccredit, Tno) VALUES
('C002', 'Math Analysis',    NULL, 4, 'T0004'),
('C006', 'Digital Circuits', NULL, 3, 'T0005'),
('C007', 'C Programming',    NULL, 2, 'T0002');

-- 依赖 C007
INSERT INTO Course VALUES ('C005', 'Data Structures', 'C007', 3, 'T0001');

-- 依赖 C005
INSERT INTO Course VALUES
('C001', 'Database',          'C005', 4, 'T0001'),
('C004', 'Operating Systems', 'C005', 3, 'T0002'),
('C008', 'Compiler',          'C005', 3, 'T0002');

-- 依赖 C001
INSERT INTO Course VALUES ('C003', 'Information Systems', 'C001', 4, 'T0003');

-- -------------------------------------------------------------
-- 选课与成绩（30 条以上，含一条成绩为 NULL 的缺考记录）
-- -------------------------------------------------------------
INSERT INTO SC (Sno, Cno, Grade) VALUES
('201515001','C001',92),('201515001','C002',85),('201515001','C005',88),
('201515002','C001',90),('201515002','C002',80),('201515002','C003',NULL),
('201515003','C002',95),('201515003','C007',88),
('201515004','C001',78),('201515004','C003',82),('201515004','C005',75),
('201515005','C001',85),('201515005','C004',90),('201515005','C005',92),
('201515006','C003',70),('201515006','C005',68),('201515006','C007',72),
('201515007','C002',90),('201515007','C006',88),
('201515008','C006',95),('201515008','C007',85),
('201515009','C001',65),('201515009','C005',60),('201515009','C008',70),
('201515010','C003',88),('201515010','C005',85),
('201515011','C002',75),('201515011','C007',68),
('201515012','C004',82),('201515012','C006',90),('201515012','C008',85);

-- -------------------------------------------------------------
-- (3) INSERT ... SELECT  将子查询结果插入
--     场景：为"计算机系学生档案"建立一张副本表并从 Student 导入
-- -------------------------------------------------------------
DROP TABLE IF EXISTS CS_Student_Archive;
CREATE TABLE CS_Student_Archive (
    Sno   CHAR(9) PRIMARY KEY,
    Sname VARCHAR(20) NOT NULL,
    Sage  TINYINT UNSIGNED,
    ArchiveTime DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO CS_Student_Archive (Sno, Sname, Sage)
SELECT Sno, Sname, Sage
FROM   Student
WHERE  Sdept = 'CS';

-- 查看导入结果
SELECT * FROM CS_Student_Archive;

-- 统计行数，确认样例数据已装载
SELECT 'Teacher' AS TableName, COUNT(*) AS Cnt FROM Teacher
UNION ALL SELECT 'Student', COUNT(*) FROM Student
UNION ALL SELECT 'Course',  COUNT(*) FROM Course
UNION ALL SELECT 'SC',      COUNT(*) FROM SC;
