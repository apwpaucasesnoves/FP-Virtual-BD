-- ===========
-- EXERCICE 1
-- ===========

USE Faculty;

-- Drop the trigger if it already exists
DROP TRIGGER IF EXISTS before_insert_unique_coordinator_per_course;

-- Create the trigger
DELIMITER $$

CREATE TRIGGER before_insert_unique_coordinator_per_course
BEFORE INSERT ON subject
FOR EACH ROW
BEGIN
    -- Check whether the coordinator already coordinates another subject in the same course
    IF (SELECT COUNT(*)
        FROM subject
        WHERE course = NEW.course
          AND coordinator = NEW.coordinator) > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A professor can only coordinate one subject per course';
    END IF;
END $$

DELIMITER ;

-- ==================
-- TESTING EXERCISE 1 
-- ==================

-- Insert the first subject coordinated by PR001 in course 2
-- This should succeed because there is no other coordinated subject in that course
INSERT INTO subject (course, idSubject, name, semester, credits, type, coordinator)
VALUES (2, 'S0001', 'Introduction to Databases', '1', 6, 'mandatory', 'PR001'); 
-- Expected: Success

-- Attempt to insert another subject in the SAME course coordinated by PR001
-- This should fail because the professor already coordinates a subject in that course
INSERT INTO subject (course, idSubject, name, semester, credits, type, coordinator)
VALUES (1, 'S0002', 'Databases and AI', '2', 6, 'mandatory', 'PR001'); 
-- Expected: Error

-- ===========
-- EXERCICE 2
-- ===========

-- Drop the trigger if it already exists
DROP TRIGGER IF EXISTS before_insert_max_10_enrollments;

DELIMITER $$

-- Create the trigger
CREATE TRIGGER before_insert_max_10_enrollments
BEFORE INSERT ON enrollment
FOR EACH ROW
BEGIN
    -- Check if the student already has 10 or more enrollments
    IF (SELECT COUNT(*)
        FROM enrollment
        WHERE idStudent = NEW.idStudent) >= 10 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A student cannot be enrolled in more than 10 subjects at the same time';
    END IF;
END $$

DELIMITER ;

-- ==================
-- TESTING EXERCISE 2 
-- ==================

-- Expected: ERROR
-- "A student cannot be enrolled in more than 10 subjects at the same time"

INSERT INTO enrollment (idStudent, idSubject, grade)
VALUES ('AL003', 'AS003', 5);


-- Expected: SUCCESS
INSERT INTO enrollment (idStudent, idSubject, grade)
VALUES ('AL009', 'AS003', 5);

-- ===========
-- EXERCICE 3
-- ===========

DROP TRIGGER IF EXISTS before_insert_teach_limit_by_semester;

-- Create trigger

DELIMITER $$

CREATE TRIGGER before_insert_teach_limit_by_semester
BEFORE INSERT ON teach
FOR EACH ROW
BEGIN
    DECLARE sem ENUM('1','2');
    DECLARE currentCount INT;

    -- 1) Prevent duplicate assignment (same professor + same subject)
    IF (SELECT COUNT(*)
        FROM teach
        WHERE idProfessor = NEW.idProfessor
          AND idSubject   = NEW.idSubject) > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: This professor is already assigned to teach this subject';
    END IF;

    -- 2) Get the semester of the subject being assigned
    SELECT semester
      INTO sem
    FROM subject
    WHERE idSubject = NEW.idSubject;

    -- 3) Count how many subjects the professor already teaches in that semester
    SELECT COUNT(*)
      INTO currentCount
    FROM teach t
    JOIN subject s ON s.idSubject = t.idSubject
    WHERE t.idProfessor = NEW.idProfessor
      AND s.semester = sem;

    -- 4) Enforce max 3 subjects per semester
    IF currentCount >= 3 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: A professor cannot teach more than 3 subjects in the same semester';
    END IF;
END $$

DELIMITER ;


-- ==================
-- TESTING EXERCISE 3 
-- ==================

-- ERROR EXPECTED

INSERT INTO teach (idProfessor, idSubject)
VALUES ('PR001', 'AS002');

-- SUCCESS EXPECTED

INSERT INTO teach (idProfessor, idSubject)
VALUES ('PR002', 'AS001');

-- ===========
-- EXERCICE 4
-- ===========

-- Drop the procedure if it already exists
DROP PROCEDURE IF EXISTS delete_professor;
-- CREATE PROCEDURE
DELIMITER $$

CREATE PROCEDURE delete_professor (IN pIdProfessor CHAR(5))
BEGIN
    DECLARE prof_name VARCHAR(200);
    DECLARE sup_id CHAR(5);
    DECLARE sup_name VARCHAR(200);
    DECLARE message TEXT;

    -- 1) Check if professor exists and get supervisor
    SELECT CONCAT(name, ' ', surname1, ' (', idProfessor, ')'), SupervisorId
      INTO prof_name, sup_id
    FROM professor
    WHERE idProfessor = pIdProfessor;

    -- Professor does not exist
    IF prof_name IS NULL THEN
        SET message = CONCAT('Professor ID ', pIdProfessor, ' does not exist');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = message;

    -- Professor has no supervisor (cannot delete)
    ELSEIF sup_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The professor has no supervisor and cannot be deleted';

    ELSE
        -- Get supervisor name (for message)
        SELECT CONCAT(name, ' ', surname1, ' (', idProfessor, ')')
          INTO sup_name
        FROM professor
        WHERE idProfessor = sup_id;

        -- 2) Reassign coordinated subjects to the supervisor
        UPDATE subject
        SET coordinator = sup_id
        WHERE coordinator = pIdProfessor;

        -- 3) Reassign teaching assignments in teach to the supervisor
        -- (Teacher reassignment: replace professor in teach by SupervisorId)
        UPDATE teach
        SET idProfessor = sup_id
        WHERE idProfessor = pIdProfessor;

        -- 4) Reassign supervised professors to the supervisor
        UPDATE professor
        SET SupervisorId = sup_id
        WHERE SupervisorId = pIdProfessor;

        -- 5) Delete professor phone numbers
        -- (This is redundant if FK has ON DELETE CASCADE, but required by statement and safe)
        DELETE FROM profContactPhone
        WHERE idProfessor = pIdProfessor;

        -- 6) Delete the professor
        DELETE FROM professor
        WHERE idProfessor = pIdProfessor;

        -- 7) Return a descriptive result
        SELECT CONCAT(
            'Subjects coordinated by ', prof_name, ' are now coordinated by ', sup_name, '.\n',
            'Teaching assignments of ', prof_name, ' are now assigned to ', sup_name, '.\n',
            'Supervised professors of ', prof_name, ' are now supervised by ', sup_name, '.\n',
            'Phone numbers of ', prof_name, ' deleted.\n',
            '---> ', prof_name, ' deleted successfully!'
        ) AS result;
    END IF;

END $$

DELIMITER ;


-- ==================
-- TESTING EXERCISE 4 
-- ==================

-- Expected: Error "Professor ID PR050 does not exist"
CALL delete_professor('PR050');

-- Expected: Error "The professor has no supervisor and cannot be deleted"
CALL delete_professor('PR001');

-- Expected: Success message + reassignment in subject/teach/professor and phone deletionLuego ejecútalo 
CALL delete_professor('PR002');

-- ============
-- EXERCISE 5 
-- ============

DROP PROCEDURE IF EXISTS course_teaching_report;

-- CREATE PROCEDURE

DELIMITER $$

CREATE PROCEDURE course_teaching_report(
    IN  course_name VARCHAR(50),
    OUT report_text TEXT
)
BEGIN
    DECLARE finished BOOLEAN DEFAULT FALSE;

    DECLARE v_subjectName VARCHAR(200);
    DECLARE v_coordinatorFull VARCHAR(200);
    DECLARE v_teachersFull TEXT;
    DECLARE v_semester ENUM('1','2');
    DECLARE v_courseId NUMERIC(2);
    DECLARE v_courseName VARCHAR(50);
    DECLARE v_studentsCount INT;

    DECLARE line_text TEXT;

    -- Cursor: one row per subject in the course,
    -- with coordinator name, list of teachers, and total enrolled students.
    DECLARE cur CURSOR FOR
        SELECT
            s.name AS subjectName,

            -- Coordinator full name
            (SELECT CONCAT(pco.name, ' ', pco.surname1, IFNULL(CONCAT(' ', pco.surname2), ''))
             FROM professor pco
             WHERE pco.idProfessor = s.coordinator) AS coordinatorFullName,

            -- Teachers full names (can be multiple)
            (SELECT GROUP_CONCAT(
                        DISTINCT CONCAT(pt.name, ' ', pt.surname1, IFNULL(CONCAT(' ', pt.surname2), ''))
                        ORDER BY pt.surname1, pt.name
                        SEPARATOR ', '
                    )
             FROM teach t
             JOIN professor pt ON pt.idProfessor = t.idProfessor
             WHERE t.idSubject = s.idSubject) AS teachersFullNames,

            s.semester,
            s.course AS courseId,
            c.descriptiveName AS courseName,

            -- Total enrolled students in the subject
            (SELECT COUNT(*)
             FROM enrollment e
             WHERE e.idSubject = s.idSubject) AS totalEnrolled

        FROM subject s
        JOIN course c ON c.idCourse = s.course
        WHERE c.descriptiveName = course_name
        ORDER BY s.idSubject;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = TRUE;

    SET report_text = '';

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_subjectName, v_coordinatorFull, v_teachersFull,
                       v_semester, v_courseId, v_courseName, v_studentsCount;

        IF finished THEN
            LEAVE read_loop;
        END IF;

        IF v_teachersFull IS NULL OR v_teachersFull = '' THEN
            SET v_teachersFull = 'No teachers assigned';
        END IF;

        SET line_text = CONCAT(
            '** Subject: ', v_subjectName,
            ' | Coordinator: ', v_coordinatorFull,
            ' | Teachers: ', v_teachersFull,
            ' | Semester: ', v_semester,
            ' | CourseId: ', v_courseId,
            ' | CourseName: ', v_courseName,
            ' | Total Enrolled: ', v_studentsCount
        );

        SET report_text = CONCAT(report_text, line_text, '\n');
    END LOOP;

    CLOSE cur;

    IF report_text = '' THEN
        SET report_text = CONCAT('No information available for course "', course_name, '".');
    END IF;
END $$

DELIMITER ;



-- ==================
-- TESTING EXERCISE 5 
-- ==================

--  Run the report

CALL course_teaching_report('First', @report);
SELECT @report;

-- Test the “no data available” branch
CALL course_teaching_report('NOCOURSE', @report);
SELECT @report;

-- ============
-- EXERCISE 6 
-- ============

-- Drop the function if it already exists
DROP FUNCTION IF EXISTS student_summary;
-- CREATE FUNCTION
DELIMITER $$

-- Create the function
CREATE FUNCTION student_summary (p_idStudent CHAR(5))
RETURNS VARCHAR(255)
READS SQL DATA
BEGIN
    DECLARE result_text VARCHAR(255);
    DECLARE subjects_count INT;
    DECLARE courses_count INT;

    -- Count total subjects the student is enrolled in
    SELECT COUNT(*)
    INTO subjects_count
    FROM enrollment
    WHERE idStudent = p_idStudent;

    -- Count distinct courses where the student has enrolled subjects
    SELECT COUNT(DISTINCT s.course)
    INTO courses_count
    FROM enrollment e
    JOIN subject s ON s.idSubject = e.idSubject
    WHERE e.idStudent = p_idStudent;

    -- Build the result text
    IF subjects_count > 0 THEN
        SET result_text = CONCAT(
            subjects_count, ' subject(s) in ',
            courses_count, ' course(s)'
        );
    ELSE
        SET result_text = 'No subjects enrolled';
    END IF;

    RETURN result_text;
END $$

DELIMITER ;


-- ==================
-- TESTING EXERCISE 6 
-- ==================

-- Student with enrollments
SELECT student_summary('AL003');

-- Student without enrollments
SELECT student_summary('AL999');

