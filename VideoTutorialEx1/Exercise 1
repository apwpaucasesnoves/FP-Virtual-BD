/* EXERCISE 1

We are going to create the tables of a Filmography. We will start by creating the following tables with SQL using the following information:

    • The FILM table includes information about the films: film identifier, title, running time (in minutes), genres, rating, synopsis, directors, country, release date, language, soundtrack (composed by), screenwriters.

    • The ACTOR table includes information about the actors: actor identifier, full name, birthdate, death date, nationality, biography (brief biography).

    • The CHARACTER table includes information about fictional characters played by actors: character identifier, full name, description, actor (that plays this character), film (where this character is), protagonist (yes or no), oscar (oscar given to the actor/actress for this role).

Consider the following:


    a. Choose the most adequate attribute types depending on their content.

    b. Establish the following constraints:

1. We can distinguish rows in the tables by the identifiers

2. An actor has to be assigned to a character.

3. A film has to be assigned to a character.

4. Every actor must have a different full name.

5. The title field of the FILM table cannot be empty.

6. Actors' birthdate must be previous to their death date.

7. The oscar attribute is AO (Best Actor), AE (Best Actress), SO (Best Supporting Actor) and SE (Best Supporting Actress).

8. The rating default value is zero.

*/


create database Filmography;

use Filmography;



create table FILM (

id_film       int,

    title         varchar(100) not null, -- 5  The title field of the FILM table cannot be empty.

    running_time  smallint,

    genres        varchar(50),

    rating        decimal(3,1) default 0, -- 8 The rating default value is zero.

    synopsis      varchar(500),

    directors     varchar(100),

    country       varchar(80),

    release_date  date,

    `language`    varchar(80),

    soundtrack    varchar(80),

    screenwriters varchar(100),

    primary key (id_film) -- 1   We can distinguish rows in the tables by the identifiers

);


create table ACTOR (

id_actor    int,

    fullname    varchar(80) unique, -- 4 Every actor must have a different full name.

    birthdate   date,

    deathdate   date,

nationality varchar(30),

    biography   varchar(500),

    primary key (id_actor), -- 1 We can distinguish rows in the tables by the identifiers

    check (birthdate < deathdate) -- 6  Actors' birthdate must be previous to their death date.

);



create table `CHARACTER` (

id_character  int,

    fullname      varchar(80),

    `description` varchar(200),

    actor         int,

    film          int,

    protagonist   boolean, -- també enum('SI','NO')

    oscar         char(2) check(oscar in ('AO','AE','SO','SE')), -- 7 The oscar attribute is AO (Best Actor), AE (Best Actress), SO (Best Supporting Actor) and SE (Best Supporting Actress)

    primary key (id_character), -- 1  We can distinguish rows in the tables by the identifiers

    foreign key (actor) references ACTOR (id_actor), -- 2. An actor has to be assigned to a character.

    foreign key (film) references FILM (id_film) -- 3. A film has to be assigned to a character.

);

