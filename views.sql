-- This file will contain all your views

CREATE VIEW BasicInformation AS
SELECT idnr, name, login, Students.program, branch  FROM Students 
LEFT JOIN StudentBranches ON idnr = student;


CREATE VIEW FinishedCourses AS
SELECT student, course, name AS courseName, grade, credits 
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

CREATE VIEW UnreadMandatory AS 
WITH AllMandatory AS (
    SELECT idnr AS student, MandatoryProgram.course
    FROM Students
    JOIN MandatoryProgram ON Students.program = MandatoryProgram.program
    UNION
    SELECT student, MandatoryBranch.course
    FROM StudentBranches
    JOIN MandatoryBranch ON StudentBranches.branch = MandatoryBranch.branch
                        AND StudentBranches.program = MandatoryBranch.program
)
SELECT student, course
FROM AllMandatory
WHERE NOT EXISTS (
    SELECT 42
    FROM PassedCourses
    WHERE PassedCourses.student = AllMandatory.student AND PassedCourses.course = AllMandatory.course
);

CREATE VIEW PathToGraduation AS
WITH TotalCredits AS (
    SELECT student, SUM(credits) AS totalCredits
    FROM PassedCourses
    GROUP BY student
    ),

MandatoryLeft AS (
    SELECT student, COUNT(course) AS mandatoryLeft
    FROM UnreadMandatory
    GROUP BY student
    ),
    
MathCredits AS (
    SELECT student, SUM(PassedCourses.credits) AS mathCredits
    FROM PassedCourses
    JOIN Classified ON PassedCourses.course = Classified.course
    WHERE Classified.classification = 'math'
    GROUP BY student
    ),
    
SeminarCourses AS (
    SELECT student, COUNT(PassedCourses.course) AS seminarCourses
    FROM PassedCourses
    JOIN Classified ON PassedCourses.course = Classified.course
    WHERE Classified.classification = 'seminar'
    GROUP BY student
    ),

RecommendedCredits AS (
    SELECT PassedCourses.student, SUM(PassedCourses.credits) AS recommendedCredits
    FROM PassedCourses 
    JOIN RecommendedBranch ON RecommendedBranch.course = PassedCourses.course
    JOIN StudentBranches ON PassedCourses.student = StudentBranches.student
    AND StudentBranches.branch = RecommendedBranch.branch
    AND StudentBranches.program = RecommendedBranch.program
    GROUP BY PassedCourses.student
)


SELECT 
    Students.idnr AS student, 
    COALESCE(TotalCredits.totalCredits, 0) AS totalCredits, 
    COALESCE(MandatoryLeft.mandatoryLeft, 0) AS mandatoryLeft,
    COALESCE(MathCredits.mathCredits, 0) AS mathCredits,
    COALESCE(SeminarCourses.seminarCourses, 0) AS seminarCourses,
    (
        COALESCE(TotalCredits.totalCredits, 0) >= 10 AND
        COALESCE(MandatoryLeft.mandatoryLeft, 0) = 0 AND
        COALESCE(MathCredits.mathCredits, 0) >= 20 AND
        COALESCE(SeminarCourses.seminarCourses, 0) >= 1 AND
        COALESCE(RecommendedCredits.recommendedCredits, 0) >= 10
    ) AS qualified
FROM Students
LEFT JOIN TotalCredits ON Students.idnr = TotalCredits.student
LEFT JOIN MandatoryLeft ON Students.idnr = MandatoryLeft.student 
LEFT JOIN MathCredits ON Students.idnr = MathCredits.student
LEFT JOIN SeminarCourses ON Students.idnr = SeminarCourses.student
LEFT JOIN RecommendedCredits ON Students.idnr = RecommendedCredits.student;
