-- =============================================================
-- 01_schema.sql  建库、建表及建表时的三类完整性约束
-- 场景：学生-教师-课程-选课（SCS）
-- 适用：MySQL 8.x / 9.x
-- 说明：职称、性别使用英文 ENUM 字面量，避免客户端字符集导致 ENUM 乱码。
-- =============================================================

DROP DATABASE IF EXISTS scs;
CREATE DATABASE scs DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE scs;
SET NAMES utf8mb4;

-- -------------------------------------------------------------
-- 1. Teacher 教师表
--    实体完整性：Tno 主键
--    用户定义完整性：Tname NOT NULL、Ttitle 限定取值
-- -------------------------------------------------------------
CREATE TABLE Teacher (
    Tno     CHAR(5)      NOT NULL COMMENT '教师编号',
    Tname   VARCHAR(20)  NOT NULL COMMENT '姓名',
    Ttitle  ENUM('TA','LECTURER','ASSOC_PROF','PROF') NOT NULL DEFAULT 'LECTURER' COMMENT '职称',
    Tdept   VARCHAR(20)  NOT NULL COMMENT '所在院系',
    CONSTRAINT pk_teacher PRIMARY KEY (Tno)
) ENGINE=InnoDB COMMENT='教师表';

-- -------------------------------------------------------------
-- 2. Student 学生表
--    实体完整性：Sno 主键
--    参照完整性：Tutor_Sno 自引用外键（导师制）
--    用户定义完整性：Ssex 取值限定、Sage 合理范围、Sname 非空
-- -------------------------------------------------------------
CREATE TABLE Student (
    Sno       CHAR(9)      NOT NULL COMMENT '学号',
    Sname     VARCHAR(20)  NOT NULL COMMENT '姓名',
    Ssex      ENUM('M','F') NOT NULL DEFAULT 'M' COMMENT '性别',
    Sage      TINYINT UNSIGNED COMMENT '年龄',
    Sdept     VARCHAR(20)  NOT NULL COMMENT '所在院系',
    Tutor_Sno CHAR(9)      NULL COMMENT '导师学号（高年级学生导师）',
    CONSTRAINT pk_student PRIMARY KEY (Sno),
    CONSTRAINT uk_student_name_dept UNIQUE (Sname, Sdept),
    CONSTRAINT ck_student_age  CHECK (Sage BETWEEN 14 AND 60),
    CONSTRAINT fk_student_tutor FOREIGN KEY (Tutor_Sno)
        REFERENCES Student(Sno)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='学生表';

-- -------------------------------------------------------------
-- 3. Course 课程表
--    实体完整性：Cno 主键
--    参照完整性：Cpno 自引用（先修课）、Tno 外键到 Teacher
--    用户定义完整性：Ccredit 为正数
-- -------------------------------------------------------------
CREATE TABLE Course (
    Cno      CHAR(4)      NOT NULL COMMENT '课程号',
    Cname    VARCHAR(40)  NOT NULL COMMENT '课程名',
    Cpno     CHAR(4)      NULL     COMMENT '先修课程号',
    Ccredit  TINYINT UNSIGNED NOT NULL COMMENT '学分',
    Tno      CHAR(5)      NULL     COMMENT '授课教师',
    CONSTRAINT pk_course PRIMARY KEY (Cno),
    CONSTRAINT uk_course_name UNIQUE (Cname),
    CONSTRAINT ck_course_credit CHECK (Ccredit BETWEEN 1 AND 10),
    CONSTRAINT fk_course_pre FOREIGN KEY (Cpno) REFERENCES Course(Cno)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_course_teacher FOREIGN KEY (Tno) REFERENCES Teacher(Tno)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='课程表';

-- -------------------------------------------------------------
-- 4. SC 选课表
--    实体完整性：(Sno,Cno) 联合主键
--    参照完整性：Sno 外键到 Student、Cno 外键到 Course
--    用户定义完整性：Grade 取值 0~100
-- -------------------------------------------------------------
CREATE TABLE SC (
    Sno    CHAR(9)  NOT NULL,
    Cno    CHAR(4)  NOT NULL,
    Grade  DECIMAL(5,2) NULL COMMENT '百分制成绩',
    CONSTRAINT pk_sc PRIMARY KEY (Sno, Cno),
    CONSTRAINT ck_sc_grade CHECK (Grade IS NULL OR Grade BETWEEN 0 AND 100),
    CONSTRAINT fk_sc_student FOREIGN KEY (Sno) REFERENCES Student(Sno)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_sc_course FOREIGN KEY (Cno) REFERENCES Course(Cno)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='选课表';

-- 创建索引，便于后续查询演示与性能观察
CREATE INDEX idx_student_dept ON Student(Sdept);
CREATE INDEX idx_sc_cno       ON SC(Cno);

-- 查看建表结果
SHOW TABLES;
