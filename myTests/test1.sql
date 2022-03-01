-- creates a zzanswer and zzsolution

DELETE FROM Transcripts;
DELETE FROM Tutors;
DELETE FROM Teaches;
DELETE FROM Offerings;
DELETE FROM Courses;
DELETE FROM Profs;
DELETE FROM Students;
DELETE FROM Departments;
DELETE FROM zz1;
DROP VIEW IF EXISTS zzanswer, zzsolution;

-- data ingest
INSERT INTO departments (did, faculty) VALUES 
    ('maths','fos'),
    ('cs','soc')
;

INSERT INTO students (sid, did, year) VALUES 
    ('alice','cs',2020),
    ('carol','maths',2018),
    ('bob','cs',2019),
    ('dave','cs',2019),
    ('eve','maths',2021),
    ('fred','cs',2018)
;

INSERT INTO profs (pid, did) VALUES 
    ('homer','cs'),
    ('maggie','cs'),
    ('willie','maths'),
    ('lisa','maths')
;

INSERT INTO courses (cid, did, credits) VALUES 
    ('cs1','cs',5),
    ('cs2','cs',5),
    ('cs3','cs',5),
    ('ma4','maths',5)
;

INSERT INTO offerings (cid, year, semester) VALUES 
    ('cs1',2019,1),
    ('cs1',2020,1),
    ('cs1',2021,2),
    ('cs1',2022,1),
    ('cs2',2020,1),
    ('cs2',2021,2),
    ('cs3',2020,1),
    ('ma4',2020,1),
    ('ma4',2021,2)
;

INSERT INTO teaches (pid, cid, year, semester, hours) VALUES 
    ('homer','cs1',2019,1,30),
    ('lisa','cs1',2019,1,30),
    ('homer','cs1',2020,1,30),
    ('lisa','cs1',2020,1,30),
    ('homer','cs1',2021,2,30),
    ('lisa','cs1',2021,2,30),
    ('homer','cs1',2022,1,30),
    ('maggie','cs2',2020,1,30),
    ('lisa','cs2',2020,1,30),
    ('maggie','cs2',2021,2,30),
    ('lisa','cs2',2021,2,30),
    ('homer','cs3',2020,1,30),
    ('lisa','cs3',2020,1,30),
    ('maggie','ma4',2020,1,30),
    ('lisa','ma4',2020,1,30),
    ('maggie','ma4',2021,2,30),
    ('lisa','ma4',2021,2,30)
;

INSERT INTO tutors (sid, cid, year, semester, hours) VALUES 
    ('alice','cs1',2022,1,10),
    ('bob','cs1',2022,1,10),
    ('dave','cs1',2022,1,10),
    ('eve','cs1',2022,1,10)
;

INSERT INTO transcripts (sid, cid, year, semester, marks) VALUES 
    ('alice','cs2',2020,1,90),
    ('alice','cs3',2020,1,90),
    ('bob','cs1',2021,2,70),
    ('carol','cs1',2021,2,60),
    ('eve','cs1',2021,2,60),
    ('eve','cs2',2021,2,50),
    ('eve','ma4',2021,2,90),
    ('fred','cs1',2019,1,40),
    ('fred','cs1',2020,1,40),
    ('fred','cs1',2021,2,40),
    ('fred','cs1',2022,1,40),
    ('fred','cs2',2020,1,40),
    ('fred','cs2',2021,2,40),
    ('fred','cs3',2020,1,40),
    ('fred','ma4',2020,1,40),
    ('fred','ma4',2021,2,40)
;
-- /data ingest

-- answer ingest
INSERT INTO zz1 (sid, cid) VALUES 
    ('alice', 'cs1'),
    ('dave', 'cs1')
;
-- /answer ingest


-- create tables by running the appropriate code
CREATE OR REPLACE VIEW zzanswer AS SELECT * FROM v1;
CREATE OR REPLACE VIEW zzsolution AS SELECT * FROM zz1 ;
