
-- init db
DROP VIEW IF EXISTS zzsolution, zzanswer CASCADE;
DROP VIEW IF EXISTS v1, v2, v3, v4, v5, v6, v7, v8, v9, v10 CASCADE;
DROP TABLE IF EXISTS zzSummary CASCADE;

CREATE TABLE zzSummary (
	test_No 		integer,
	status		TEXT
);

-- ------------------- database schema

DROP TABLE IF EXISTS Transcripts, Tutors, Teaches, Offerings, Courses, Profs, Students, Departments CASCADE;
DROP TABLE IF EXISTS zz1, zz2, zz1, zz3, zz4, zz5, zz6, zz7, zz8, zz9, zz10;


CREATE TABLE Departments (
	did 		text PRIMARY KEY,
	faculty 	text NOT NULL
);

CREATE TABLE Students (
	sid 		text PRIMARY KEY,
	did		text NOT NULL REFERENCES Departments,
	year		integer NOT NULL CHECK (year >= 1980)
);

CREATE TABLE Profs (
	pid 		text PRIMARY KEY,
	did		text NOT NULL REFERENCES Departments
);

CREATE TABLE Courses (
	cid 		text PRIMARY KEY,
	did		text NOT NULL REFERENCES Departments,
	credits 	integer NOT NULL CHECK (credits in (2,3,4,5))
);

CREATE TABLE Offerings (
	cid 		text REFERENCES Courses,
	year 		integer CHECK (year >= 1980),
	semester 	integer CHECK (semester in (1,2)),
	PRIMARY KEY 	(cid, year, semester)
);

CREATE TABLE Teaches (
	pid 		text REFERENCES Profs,
	cid 		text,
	year 		integer,
	semester 	integer,
	hours		integer NOT NULL CHECK (hours > 0),
	PRIMARY KEY 	(pid, cid, year, semester),
	FOREIGN KEY 	(cid, year, semester) REFERENCES Offerings
);

CREATE TABLE Tutors (
	sid 		text REFERENCES Students,
	cid 		text,
	year 		integer,
	semester 	integer,
	hours		integer NOT NULL CHECK (hours > 0),
	PRIMARY KEY 	(sid, cid, year, semester),
	FOREIGN KEY 	(cid, year, semester) REFERENCES Offerings
);

CREATE TABLE Transcripts (
	sid 		text,
	cid 		text,
	year 		integer,
	semester 	integer,
	marks 		integer NOT NULL CHECK (marks >= 0 AND marks <= 100),
	PRIMARY KEY 	(sid, cid, year, semester),
	FOREIGN KEY 	(sid) REFERENCES Students,
	FOREIGN KEY 	(cid, year, semester) REFERENCES Offerings
);


CREATE TABLE zz1 (
	sid text,
    cid text
);