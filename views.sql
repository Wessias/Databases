-- This file will contain all your views

CREATE VIEW BasicInformation AS
SELECT idnr, name, login, Students.program, branch  FROM Students 
LEFT JOIN StudentBranches ON idnr = student;


CREATE VIEW FinishedCourses AS
SELECT student, course as course_code, name AS course_name, grade, credits 
FROM Taken
LEFT JOIN Courses ON Taken.course = Courses.code;


CREATE VIEW Registrations AS
SELECT student, course, 'registered' AS status
FROM Registered
UNION
SELECT student, course, 'waiting' AS status
FROM WaitingList;

CREATE VIEW PassedCourses AS
SELECT * 
FROM FinishedCourses
WHERE grade != 'U';
