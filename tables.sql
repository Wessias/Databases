-- This file will contain all your tables
CREATE TABLE Students (
    idnr CHAR(10) NOT NULL PRIMARY KEY
    CHECK (idnr SIMILAR TO '[0-9]{10]}'),
    name TEXT NOT NULL
    CHECK (name LIKE '% %'),
    login TEXT NOT NULL,
    program TEXT NOT NULL

);

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name,program)
);

CREATE TABLE Courses(
    code TEXT NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    credits INT NOT NULL
    CHECK (credits >= 0 ),
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
    code TEXT NOT NULL PRIMARY KEY,
    capacity INT NOT NULL
    CHECK (capacity >= 0),
    FOREIGN KEY (code) REFERENCES Courses(code)
);

CREATE TABLE StudentBranches(
    student CHAR(10) NOT NULL PRIMARY KEY,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)    
);

CREATE TABLE Classifications(
    name TEXT NOT NULL PRIMARY KEY
);


CREATE TABLE Classified(
    course TEXT NOT NULL,
    classification TEXT NOT NULL,
    PRIMARY KEY (course, classification),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (classification) REFERENCES Classifications(name)
);

CREATE TABLE MandatoryProgram(
    course TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, program),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE MandatoryBranch(
    course TEXT NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch,program) REFERENCES Branches(name, program)
);

CREATE TABLE RecommendedBranch(
    course TEXT NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Registered(
    student CHAR(10) NOT NULL,
    course TEXT NOT NULL,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
 );

 CREATE TABLE Taken(
    student CHAR(10) NOT NULL,
    course TEXT NOT NULL,
    grade CHAR(1) NOT NULL
    CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
 );


 CREATE TABLE WaitingList(
    student CHAR(10) NOT NULL,
    course TEXT NOT NULL,
    position INTEGER NOT NULL
    CHECK (position >= 0),
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses(code)
 );