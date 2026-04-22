-- MySQL dump 10.13  Distrib 9.0.1, for Win64 (x86_64)
--
-- Host: localhost    Database: scs
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `scs`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `scs` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `scs`;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course` (
  `Cno` char(4) NOT NULL COMMENT '课程号',
  `Cname` varchar(40) NOT NULL COMMENT '课程名',
  `Cpno` char(4) DEFAULT NULL COMMENT '先修课程号',
  `Ccredit` tinyint unsigned NOT NULL COMMENT '学分',
  `Tno` char(5) DEFAULT NULL COMMENT '授课教师',
  PRIMARY KEY (`Cno`),
  UNIQUE KEY `uk_course_name` (`Cname`),
  KEY `fk_course_pre` (`Cpno`),
  KEY `fk_course_teacher` (`Tno`),
  CONSTRAINT `fk_course_pre` FOREIGN KEY (`Cpno`) REFERENCES `course` (`Cno`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_course_teacher` FOREIGN KEY (`Tno`) REFERENCES `teacher` (`Tno`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `ck_course_credit` CHECK ((`Ccredit` between 1 and 10))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='课程表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course`
--

LOCK TABLES `course` WRITE;
/*!40000 ALTER TABLE `course` DISABLE KEYS */;
INSERT INTO `course` VALUES ('C001','Database','C005',4,'T0001'),('C002','Math Analysis',NULL,4,'T0004'),('C003','Information Systems','C001',4,'T0003'),('C004','Operating Systems','C005',3,'T0002'),('C005','Data Structures','C007',3,'T0001'),('C006','Digital Circuits',NULL,3,'T0005'),('C007','C Programming',NULL,2,'T0002'),('C008','Compiler','C005',3,'T0002');
/*!40000 ALTER TABLE `course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cs_student_archive`
--

DROP TABLE IF EXISTS `cs_student_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cs_student_archive` (
  `Sno` char(9) NOT NULL,
  `Sname` varchar(20) NOT NULL,
  `Sage` tinyint unsigned DEFAULT NULL,
  `ArchiveTime` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Sno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cs_student_archive`
--

LOCK TABLES `cs_student_archive` WRITE;
/*!40000 ALTER TABLE `cs_student_archive` DISABLE KEYS */;
INSERT INTO `cs_student_archive` VALUES ('201515001','Leo Li',20,'2026-04-21 16:30:19'),('201515002','Grace Liu',19,'2026-04-21 16:30:19'),('201515005','Alice Zhao',20,'2026-04-21 16:30:19'),('201515009','David Zheng',20,'2026-04-21 16:30:19');
/*!40000 ALTER TABLE `cs_student_archive` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deptcount`
--

DROP TABLE IF EXISTS `deptcount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deptcount` (
  `Sdept` varchar(20) NOT NULL,
  `Cnt` int DEFAULT NULL,
  PRIMARY KEY (`Sdept`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deptcount`
--

LOCK TABLES `deptcount` WRITE;
/*!40000 ALTER TABLE `deptcount` DISABLE KEYS */;
/*!40000 ALTER TABLE `deptcount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sc`
--

DROP TABLE IF EXISTS `sc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sc` (
  `Sno` char(9) NOT NULL,
  `Cno` char(4) NOT NULL,
  `Grade` decimal(5,2) DEFAULT NULL COMMENT '百分制成绩',
  PRIMARY KEY (`Sno`,`Cno`),
  KEY `idx_sc_cno` (`Cno`),
  CONSTRAINT `fk_sc_course` FOREIGN KEY (`Cno`) REFERENCES `course` (`Cno`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_sc_student` FOREIGN KEY (`Sno`) REFERENCES `student` (`Sno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ck_sc_grade` CHECK (((`Grade` is null) or (`Grade` between 0 and 100)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='选课表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sc`
--

LOCK TABLES `sc` WRITE;
/*!40000 ALTER TABLE `sc` DISABLE KEYS */;
INSERT INTO `sc` VALUES ('201515001','C001',95.00),('201515001','C002',85.00),('201515001','C005',88.00),('201515002','C001',90.00),('201515002','C002',80.00),('201515002','C003',NULL),('201515003','C002',95.00),('201515003','C007',88.00),('201515004','C001',78.00),('201515004','C003',82.00),('201515004','C005',75.00),('201515005','C001',85.00),('201515005','C004',90.00),('201515005','C005',92.00),('201515006','C003',70.00),('201515006','C005',68.00),('201515006','C007',72.00),('201515007','C002',90.00),('201515007','C006',88.00),('201515008','C006',95.00),('201515008','C007',85.00),('201515009','C001',65.00),('201515009','C005',60.00),('201515009','C008',70.00),('201515010','C003',88.00),('201515010','C005',85.00),('201515011','C002',75.00),('201515011','C007',68.00),('201515012','C004',82.00),('201515012','C006',90.00),('201515012','C008',85.00);
/*!40000 ALTER TABLE `sc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sc_deletelog`
--

DROP TABLE IF EXISTS `sc_deletelog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sc_deletelog` (
  `LogId` bigint NOT NULL AUTO_INCREMENT,
  `Sno` char(9) DEFAULT NULL,
  `Cno` char(4) DEFAULT NULL,
  `OldGrade` decimal(5,2) DEFAULT NULL,
  `DeletedAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `OpUser` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`LogId`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sc_deletelog`
--

LOCK TABLES `sc_deletelog` WRITE;
/*!40000 ALTER TABLE `sc_deletelog` DISABLE KEYS */;
/*!40000 ALTER TABLE `sc_deletelog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student`
--

DROP TABLE IF EXISTS `student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student` (
  `Sno` char(9) NOT NULL COMMENT '学号',
  `Sname` varchar(20) NOT NULL,
  `Ssex` enum('M','F') NOT NULL DEFAULT 'M' COMMENT '性别',
  `Sage` tinyint unsigned DEFAULT NULL COMMENT '年龄',
  `Sdept` varchar(20) NOT NULL COMMENT '所在院系',
  `Tutor_Sno` char(9) DEFAULT NULL COMMENT '导师学号（高年级学生导师）',
  PRIMARY KEY (`Sno`),
  UNIQUE KEY `uk_student_name_dept` (`Sname`,`Sdept`),
  KEY `fk_student_tutor` (`Tutor_Sno`),
  KEY `idx_student_dept` (`Sdept`),
  CONSTRAINT `fk_student_tutor` FOREIGN KEY (`Tutor_Sno`) REFERENCES `student` (`Sno`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `ck_student_age` CHECK ((`Sage` between 14 and 60))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student`
--

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
INSERT INTO `student` VALUES ('201515001','Leo Li','M',20,'CS',NULL),('201515002','Grace Liu','F',19,'CS','201515001'),('201515003','Mary Wang','F',18,'MA',NULL),('201515004','Tom Zhang','M',19,'IS',NULL),('201515005','Alice Zhao','F',20,'CS','201515001'),('201515006','Bob Sun','M',21,'IS','201515004'),('201515007','Carol Zhou','F',19,'MA','201515003'),('201515008','Eric Wu','M',22,'EE',NULL),('201515009','David Zheng','M',20,'CS','201515001'),('201515010','Eva Feng','F',18,'IS','201515004'),('201515011','Ray Chen','M',NULL,'MA',NULL),('201515012','Frank He','F',20,'EE','201515008'),('201515098','Jia Sun','M',NULL,'IS',NULL),('201515099','Jin Qian','M',20,'CS','201515001');
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher`
--

DROP TABLE IF EXISTS `teacher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher` (
  `Tno` char(5) NOT NULL COMMENT '教师编号',
  `Tname` varchar(20) NOT NULL COMMENT '姓名',
  `Ttitle` enum('TA','LECTURER','ASSOC_PROF','PROF') NOT NULL DEFAULT 'LECTURER' COMMENT '职称',
  `Tdept` varchar(20) NOT NULL COMMENT '所在院系',
  PRIMARY KEY (`Tno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='教师表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher`
--

LOCK TABLES `teacher` WRITE;
/*!40000 ALTER TABLE `teacher` DISABLE KEYS */;
INSERT INTO `teacher` VALUES ('T0001','Wang Wei','PROF','CS'),('T0002','Li Qiang','ASSOC_PROF','CS'),('T0003','Liu Yang','LECTURER','IS'),('T0004','Chen Jing','PROF','MA'),('T0005','Zhao Lei','ASSOC_PROF','EE');
/*!40000 ALTER TABLE `teacher` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'scs'
--

--
-- Dumping routines for database 'scs'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-21 19:59:23
