--    1. Create a gender field in the ACTOR table. Its domain is M (male), F (female) and O (other).

alter table ACTOR add column gender char(1) check (gender in ('M','F','O'));

alter table ACTOR add column gender enum ('M','F','O');



/* Establish the following constraints: */

-- 2. The rating field must be between 0 and 10.

alter table FILM add check (rating between 0 and 10);

alter table FILM add check (rating >=0 and rating <= 10);



-- 3. The actors' birthdate must be later than year 1900.

alter table ACTOR add check (year(birthdate) > 1900);

alter table ACTOR add check (birthdate > '1900-12-31');



-- 4. A film cannot be created unless his running time is lesser than 300 minutes.

alter table FILM add constraint CH_running_time check (running_time < 300);



-- 5. Remove the previous constraint about the running time.

alter table FILM drop constraint CH_running_time;

alter table FILM drop check CH_running_time;


-- 6. Delete the soundtrack column of the FILM table.

alter table FILM drop column soundtrack;


-- 7. Create an index for directors field on FILM table.

alter table FILM add index (directors);

CREATE INDEX index_directors ON Film (directors);


-- 8. Two characters cannot have the same full name.

alter table `CHARACTER` add unique (fullname);


-- 9. Change the CHARACTER table primary key for film and actor fields.

alter table `CHARACTER` drop primary key;

alter table `CHARACTER` add primary key (film,actor);


-- 10. Rename ACTOR table for STAR.

rename table ACTOR to STAR;

alter table ACTOR rename to STAR;


-- 11. Remove the CHARACTER table.

drop table `CHARACTER`;

-- 12. Create a user with your name and RETAKE02 as a password. Give SELECT privileges on the FILM table to that user.
create user 'walter' identified by 'TASK02';

grant SELECT on FILM TO walter;

drop user walter;
