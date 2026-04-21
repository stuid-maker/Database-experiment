-- =============================================================
-- 09_triggers.sql  触发器
-- 内容：定义触发器、激活触发器、删除触发器
-- 本脚本定义 3 个触发器，分别演示 BEFORE INSERT、BEFORE UPDATE
-- 以及 AFTER DELETE，并用实际 DML 激活它们。
-- =============================================================

USE scs;
SET NAMES utf8mb4;

-- -------------------------------------------------------------
-- 0. 准备一张"操作日志表"，记录删除事件
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS SC_DeleteLog (
    LogId      BIGINT       AUTO_INCREMENT PRIMARY KEY,
    Sno        CHAR(9),
    Cno        CHAR(4),
    OldGrade   DECIMAL(5,2),
    DeletedAt  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    OpUser     VARCHAR(64)
);

-- 为了让脚本可重复执行，先 DROP 已存在的触发器
DROP TRIGGER IF EXISTS trg_sc_grade_clip_ins;
DROP TRIGGER IF EXISTS trg_sc_grade_clip_upd;
DROP TRIGGER IF EXISTS trg_sc_log_delete;

-- -------------------------------------------------------------
-- A. 定义触发器 1：BEFORE INSERT 在插入 SC 时自动截断成绩
-- -------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_sc_grade_clip_ins
BEFORE INSERT ON SC
FOR EACH ROW
BEGIN
    IF NEW.Grade IS NOT NULL THEN
        IF NEW.Grade > 100 THEN SET NEW.Grade = 100; END IF;
        IF NEW.Grade < 0   THEN SET NEW.Grade = 0;   END IF;
    END IF;
END$$
DELIMITER ;

-- -------------------------------------------------------------
-- B. 定义触发器 2：BEFORE UPDATE 在修改 SC.Grade 时同样截断
-- -------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_sc_grade_clip_upd
BEFORE UPDATE ON SC
FOR EACH ROW
BEGIN
    IF NEW.Grade IS NOT NULL THEN
        IF NEW.Grade > 100 THEN SET NEW.Grade = 100; END IF;
        IF NEW.Grade < 0   THEN SET NEW.Grade = 0;   END IF;
    END IF;
END$$
DELIMITER ;

-- -------------------------------------------------------------
-- C. 定义触发器 3：AFTER DELETE 在删除 SC 记录后写入日志
-- -------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_sc_log_delete
AFTER DELETE ON SC
FOR EACH ROW
BEGIN
    INSERT INTO SC_DeleteLog (Sno, Cno, OldGrade, OpUser)
    VALUES (OLD.Sno, OLD.Cno, OLD.Grade, CURRENT_USER());
END$$
DELIMITER ;

-- 查看已创建的触发器
SHOW TRIGGERS FROM scs;

-- -------------------------------------------------------------
-- D. 激活触发器：通过实际 DML 观察效果
-- -------------------------------------------------------------
SET autocommit = 0;
START TRANSACTION;

-- D1. 触发 BEFORE INSERT：成绩 120 会被自动截断为 100
INSERT INTO SC (Sno, Cno, Grade) VALUES ('201515011', 'C005', 120);
SELECT Sno, Cno, Grade FROM SC WHERE Sno='201515011' AND Cno='C005';

-- D2. 触发 BEFORE UPDATE：试图把成绩改为 -5，会被截断为 0
UPDATE SC SET Grade = -5 WHERE Sno='201515011' AND Cno='C005';
SELECT Sno, Cno, Grade FROM SC WHERE Sno='201515011' AND Cno='C005';

-- D3. 触发 AFTER DELETE：删除一行后日志表自动多出一条记录
DELETE FROM SC WHERE Sno='201515011' AND Cno='C005';
SELECT * FROM SC_DeleteLog ORDER BY LogId DESC LIMIT 5;

ROLLBACK;  -- 回滚以保持原始数据不变（包括日志表的插入）
SET autocommit = 1;

-- -------------------------------------------------------------
-- E. 删除触发器
-- -------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_sc_grade_clip_ins;
DROP TRIGGER IF EXISTS trg_sc_grade_clip_upd;
DROP TRIGGER IF EXISTS trg_sc_log_delete;

-- 再次确认
SHOW TRIGGERS FROM scs;
