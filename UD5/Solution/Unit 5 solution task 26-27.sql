-- exercice 1: solved using the graphical tool. 

-- Exercise 2

INSERT INTO enrollment (idStudent, idSubject, grade)
VALUES ('AL001', 'AS060', 7.50);

INSERT INTO enrollment (idStudent, idSubject, grade)
VALUES ('AL002', 'AS061', 4.75);

INSERT INTO enrollment (idStudent, idSubject, grade)
VALUES ('AL003', 'AS062', 9.00);

-- exercice 3: solved using the graphical tool. 

-- Exercise 4

UPDATE enrollment e
JOIN student s ON e.idStudent = s.idStudent
SET e.grade = e.grade - 1
WHERE s.birthDate = '2006-09-08';

-- Exercise 5
UPDATE professor
SET SupervisorId = NULL
WHERE category = 'Adjunct';

-- Exercice 6

UPDATE subject
SET name = CONCAT(name, ' (code ', idSubject, ')')
WHERE type = 'elective';

-- Exercice 7

DELETE FROM enrollment
WHERE idSubject IN (
    SELECT s.idSubject
    FROM subject s
    JOIN professor p ON s.coordinator = p.idProfessor
    WHERE p.surname1 = 'Patterson'
);

-- Exercice 8

DELETE
FROM student
WHERE idStudent NOT IN (SELECT DISTINCT idStudent FROM enrollment)
  AND municipality = 'Cupertino';

-- Exercice 9

INSERT INTO student (
    idStudent,
    NIF,
    name,
    surname1,
    surname2,
    email,
    address,
    postalCode,
    municipality,
    province,
    scholarship,
    emergencyContactId,
    birthDate
)
SELECT
    CONCAT(
        'AL',
        CAST(SUBSTRING(idProfessor, 3) AS UNSIGNED) + 500
    ) AS idStudent,
    NIF,
    name,
    surname1,
    surname2,
    email,
    address,
    postalCode,
    municipality,
    province,
    'Y' AS scholarship,
    NULL AS emergencyContactId,
    '1995-01-01' AS birthDate
FROM professor
WHERE category = 'Adjunct';

-- Exercice 10

-- UPDATE 1 — Reassign the subjects she teaches
UPDATE teach t
JOIN professor p ON t.idProfessor = p.idProfessor
SET t.idProfessor = p.SupervisorId
WHERE p.name = 'Elizabeth'
  AND p.surname1 = 'Campbell'
  AND p.SupervisorId IS NOT NULL;

-- UPDATE 2 — Reassign the subjects she coordinates
UPDATE subject s
JOIN professor p ON s.coordinator = p.idProfessor
SET s.coordinator = p.SupervisorId
WHERE p.name = 'Elizabeth'
  AND p.surname1 = 'Campbell'
  AND p.SupervisorId IS NOT NULL;

