-- 1 Which is the name of the course with the fewest subjects?

use faculty;
SELECT 
    descriptiveName
FROM
    course
WHERE
    nSubjects = (SELECT 
            MIN(nSubjects)
        FROM
            course);

-- 2 Show the first name and surnames of the students who have a 40 in their NIF, and who do not have any emergency contact."

SELECT 
    name, surname1, surname2
FROM
    student s
WHERE
    NIF LIKE '%40%'
        AND emergencyContactId IS NULL;

-- 3. Show the name, NIF, and email of the professors who teach 2 subjects.


SELECT 
    p.name, p.NIF, p.email
FROM
    professor p
        JOIN
    teach t ON p.idProfessor = t.idProfessor
GROUP BY p.name , p.NIF , p.email
HAVING COUNT(p.NIF) = 2;



-- 4. Find the first name, last names, and province of the students who are enrolled in elective subjects worth 3 credits in the first trimester.

SELECT DISTINCT
    s.name, s.surname1, s.surname2, s.province
FROM
    student s
        JOIN
    enrollment e ON s.idStudent = e.idStudent
        JOIN
    subject sub ON e.idSubject = sub.idSubject
WHERE
    sub.type = 'elective'
        AND sub.credits = 3
        AND sub.semester = 1;


-- 5. Find the name and NIF of the professors who teach students from Los Angeles.

SELECT DISTINCT
    p.name AS nameprof, p.NIF AS NIFprof
FROM
    professor p
        JOIN
    teach t ON p.idProfessor = t.idProfessor
        JOIN
    enrollment e ON t.idSubject = e.idSubject
        JOIN
    student s ON e.idStudent = s.idStudent
WHERE
    s.municipality = 'Los Angeles';


-- 6. Find the IDs of the subjects that have enrolled students who were born on May 27.

SELECT DISTINCT
    e.idSubject
FROM
    student s
        JOIN
    enrollment e ON s.idStudent = e.idStudent
WHERE
    DAY(s.birthDate) = 27
        AND MONTH(s.birthDate) = 5;


-- 7. Find all subjects whose name contains the word “data”, and whose course descriptive name contains a “d”.

SELECT 
    s.idSubject,
    s.name AS subject_name,
    c.descriptiveName AS course_name
FROM
    subject s
        JOIN
    course c ON s.course = c.idCourse
WHERE
    LOWER(s.name) LIKE '%data%'
        AND LOWER(c.descriptiveName) LIKE '%d%';


-- 8. Show the professors who have no contact phone number and who teach subjects from the third course (year).

SELECT DISTINCT
    p.idProfessor, p.name, p.surname1, p.surname2
FROM
    professor p
        JOIN
    teach t ON p.idProfessor = t.idProfessor
        JOIN
    subject s ON t.idSubject = s.idSubject
        LEFT JOIN
    profcontactphone pc ON p.idProfessor = pc.idProfessor
WHERE
    s.course = 3 AND pc.idProfessor IS NULL;


-- 9. Find all the data of the professors who teach subjects in course 3 and who do not have any registered contact phone number.

SELECT DISTINCT
    p.*
FROM
    professor p
        JOIN
    teach t ON p.idProfessor = t.idProfessor
        JOIN
    subject s ON t.idSubject = s.idSubject
WHERE
    s.course = 3
        AND p.idProfessor NOT IN (SELECT DISTINCT
            pc.idProfessor
        FROM
            profcontactphone pc);


-- 10. Show the name of each first-year subject and the number of students enrolled in it, ordering the results from the highest to the lowest number of students.

SELECT 
    s.name AS subject_name, COUNT(e.idStudent) AS total_students
FROM
    subject s
        JOIN
    enrollment e ON s.idSubject = e.idSubject
WHERE
    s.course = 1
GROUP BY s.idSubject , s.name
ORDER BY total_students DESC;


-- 11. Show the number of students born in each month of the year, ordered from January to December.

SELECT 
    MONTH(birthDate) AS month, COUNT(*) AS num_students
FROM
    student
GROUP BY MONTH(birthDate)
ORDER BY month;


-- 12. Find the ID, first name, and first surname of the professors who teach subjects in which there are students with a grade below 1.05, ordering the professors by idProfessor.

SELECT DISTINCT
    p.idProfessor, p.name, p.surname1
FROM
    professor p
        JOIN
    teach t ON p.idProfessor = t.idProfessor
        JOIN
    subject s ON t.idSubject = s.idSubject
        JOIN
    enrollment e ON s.idSubject = e.idSubject
WHERE
    e.grade < 1.05
ORDER BY p.idProfessor;



-- 13. Show the professors from the province ‘CA’ who do not teach any subject.

  SELECT 
    *
FROM
    professor p
WHERE
    p.province = 'CA'
        AND p.idProfessor NOT IN (SELECT DISTINCT
            t.idProfessor
        FROM
            teach t);


-- 14. How many years have passed since the birth of the youngest student?

SELECT 
    s.idStudent,
    s.name,
    TIMESTAMPDIFF(YEAR,
        s.birthDate,
        CURDATE()) AS antiquity
FROM
    student s
WHERE
    s.birthDate = (SELECT 
            MAX(s2.birthDate)
        FROM
            student s2);


-- 15. Show the total number of recorded grades, the minimum grade, and the maximum grade among all enrollments.

SELECT 
    COUNT(*) AS total_grades,
    MIN(grade) AS minimum_grade,
    MAX(grade) AS maximum_grade
FROM
    enrollment;


-- 16. Find the ID, first name, and first surname of each professor and the number of distinct students they teach, but only for those professors who teach at least one subject in which there is at least one student with a grade between 8.5 and 8.55. Order by idProfessor.

SELECT 
    p.idProfessor,
    p.name,
    p.surname1,
    COUNT(DISTINCT e.idStudent) AS total_students
FROM
    professor p
        JOIN
    teach t ON p.idProfessor = t.idProfessor
        JOIN
    enrollment e ON t.idSubject = e.idSubject
WHERE
    e.grade BETWEEN 8.5 AND 8.55
GROUP BY p.idProfessor , p.name , p.surname1
ORDER BY p.idProfessor;


-- 17. Select the enrollments (student ID and grade) of students who take subjects taught by professors from Cupertino and classify them according to the grade as:
--    Greater than 8 → 'Excellent grade'
--    Between 5 and 8 → 'Pass grade'
--    Less than 5 → 'Fail grade'

SELECT 
    e.idStudent AS student_id,
    e.grade,
    CASE
        WHEN e.grade > 8 THEN 'Excellent grade'
        WHEN e.grade BETWEEN 5 AND 8 THEN 'Pass grade'
        ELSE 'Fail grade'
    END AS classification
FROM
    professor p
        JOIN
    teach t ON p.idProfessor = t.idProfessor
        JOIN
    subject s ON t.idSubject = s.idSubject
        JOIN
    enrollment e ON s.idSubject = e.idSubject
WHERE
    p.municipality = 'Cupertino';


-- 18. Show a list with the municipality name, and the first name and first surname of the professors who work there, ordered by municipality and surname.

SELECT
    p.municipality AS city,
    p.name,
    p.surname1
FROM professor p
ORDER BY p.municipality, p.surname1;


-- 19. Show the municipality of the professors who teach subjects in which Lucas Reed Ortiz is enrolled.


SELECT DISTINCT
    p.municipality
FROM
    professor p
        JOIN
    teach t ON p.idProfessor = t.idProfessor
        JOIN
    subject s ON t.idSubject = s.idSubject
        JOIN
    enrollment e ON s.idSubject = e.idSubject
        JOIN
    student st ON e.idStudent = st.idStudent
WHERE
    st.name = 'Lucas'
        AND st.surname1 = 'Reed'
        AND st.surname2 = 'Ortiz';



-- 20. Show the first name and last names of the students who do NOT have a scholarship, also indicating the full name of their emergency contact.
--     Students without an emergency contact must also appear.

SELECT 
    s.name,
    s.surname1,
    s.surname2,
    CONCAT(ec.name,
            ' ',
            ec.surname1,
            ' ',
            ec.surname2) AS emergency_contact
FROM
    student s
        LEFT JOIN
    student ec ON s.emergencyContactId = ec.idStudent
WHERE
    s.scholarship = 'N';


-- 21. Show the name of each course and the average grade of the subjects that compose it.

SELECT 
    c.descriptiveName AS course_name,
    AVG(e.grade) AS average_grade
FROM
    course c
        LEFT JOIN
    subject s ON c.idCourse = s.course
        LEFT JOIN
    enrollment e ON s.idSubject = e.idSubject
GROUP BY c.idCourse , c.descriptiveName;


-- 22. Show the first name and last name of the students from Washington (WA) who are enrolled in ‘elective’ subjects and the first name and last name of the professor who teaches those subjects.

SELECT DISTINCT
    st.name AS student_name,
    st.surname1 AS student_surname,
    p.name AS professor_name,
    p.surname1 AS professor_surname
FROM
    student st
        JOIN
    enrollment e ON st.idStudent = e.idStudent
        JOIN
    subject s ON e.idSubject = s.idSubject
        JOIN
    teach t ON s.idSubject = t.idSubject
        JOIN
    professor p ON t.idProfessor = p.idProfessor
WHERE
    st.province = 'WA'
        AND s.type = 'elective';

-- 23. Show the name and municipality of the professors who teach subjects in which there is at least one professor who teaches exactly 44 distinct students.

SELECT DISTINCT
    p.name, p.municipality
FROM
    professor p
WHERE
    p.idProfessor IN (SELECT 
            t.idProfessor
        FROM
            teach t
                JOIN
            enrollment e ON t.idSubject = e.idSubject
        GROUP BY t.idProfessor
        HAVING COUNT(DISTINCT e.idStudent) = 44);


-- 24. Show the ID and name of the elective subjects in which there are enrolled students born in May and that have students who are enrolled in exactly one subject.

SELECT DISTINCT
    s.idSubject, s.name AS subject_name
FROM
    subject s
        JOIN
    enrollment e ON s.idSubject = e.idSubject
        JOIN
    student st ON e.idStudent = st.idStudent
WHERE
    s.type = 'elective'
        AND st.idStudent IN (SELECT 
            st2.idStudent
        FROM
            student st2
        WHERE
            MONTH(st2.birthDate) = 5)
        AND st.idStudent IN (SELECT 
            e2.idStudent
        FROM
            enrollment e2
        GROUP BY e2.idStudent
        HAVING COUNT(e2.idSubject) = 1);


-- 25 How many students are there for each combination of the professor’s municipality and the name of the course to which the subject they are enrolled in belongs?

SELECT 
    p.municipality AS professor_city,
    c.descriptiveName AS course_name,
    COUNT(DISTINCT e.idStudent) AS number_of_students
FROM
    professor p
        JOIN
    teach t ON p.idProfessor = t.idProfessor
        JOIN
    subject s ON t.idSubject = s.idSubject
        JOIN
    course c ON s.course = c.idCourse
        JOIN
    enrollment e ON s.idSubject = e.idSubject
GROUP BY p.municipality , c.descriptiveName
ORDER BY p.municipality , c.descriptiveName;
