create database  univercity
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';
create database university_archive
    CONNECTION LIMIT = 50
    TEMPLATE = template0;
create database university_test1
    IS_TEMPLATE =true
    connection limit=10;


CREATE TABLESPACE student_data
    LOCATION '/data/students';

CREATE TABLESPACE course_data
    OWNER = CURRENT_USER
    LOCATION '/data/courses';

CREATE DATABASE university_distributed
    TABLESPACE = student_data
    ENCODING = 'LATIN9'
    TEMPLATE = template0;
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(3,2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);
CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number varchar(20),
    hire_date DATE,
    salary numeric(8,2),
    is_tenured boolean,
    years_experience INT
);
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code char(8),
    course_title varchar(100),
    description TEXT,
    credits SMALLINT,
    max_enrollment int,
    course_fee NUMERIC(7,2),
    is_online boolean,
    created_at timestamp
);
create table class_schedule(
    schedule_id serial primary key,
    course_id int,
    professor_id int,
    classroom varchar(20),
    class_date DATE,
    start_time time,
    end_time time,
    duration interval
);
create table student_records(
    record_id serial primary key,
    student_id int,
    course_id int,
    year int,
    semester varchar(20),
    grade char(2),
    attendance_percentage numeric(4,1),
    submission_timestamp timestamptz,
    last_updated timestamptz
);


----3
alter table students
add column middle_name varchar(30);
alter table students
add column student_status varchar(20);

alter table students
alter column phone type varchar(20);

alter table students
alter column student_status set default 'active';

alter table students
alter column gpa set default 0.00;


---professors table
alter table professors
add column department_code char(5);

alter table professors
add column research_area text;

alter table professors
alter column years_experience type smallint;

alter table professors
alter column is_tenured set default false;

alter table professors
add column last_promotion_date date;


---courses

alter table courses
add column prerequisite_course_id int;

alter table courses
add column difficulty_level smallint;

alter table  courses
alter column course_code type  varchar(10);

alter table courses
alter column credits set default 3;

alter table courses
add column lab_required boolean default false;


---3.2
alter table class_schedule
add column room_capacity int;

alter table class_schedule drop column duration;

alter table class_schedule
alter column classroom type varchar(30);

alter table class_schedule
add column session_type varchar(15);

alter table class_schedule
add column equipment_needed text;


--students_records
alter table student_records
add column extra_credit_points  numeric(2,1);

alter table student_records
alter column grade type varchar(5);

alter table  student_records
alter column extra_credit_points set default  0.0;

alter table student_records
add column final_exam_date date;

alter table student_records
drop column last_updated;



--4.1

create table departments(
    department_id serial primary key,
    department_name varchar(100),
    department_code char(5),
    building varchar(50),
    phone varchar(15),
    budget numeric(9,2),
    established_year int
);

create table library_books(
    book_id serial primary key,
    isbn char(13),
    title varchar (200),
    author varchar(100),
    publisher varchar(100),
    publication_date date,
    price numeric(5,2),
    is_available boolean,
    acquisition_timestamp timestamp
);

create table student_book_loans(
    loan_id serial primary key,
    student_id int,
    book_id int,
    loan_date date,
    due_date date,
    return_date date,
    fine_amount numeric(4,2),
    loan_status varchar(20)
);
ALTER TABLE professors
ADD COLUMN department_id INT;

ALTER TABLE students
ADD COLUMN advisor_id INT;

ALTER TABLE courses
ADD COLUMN department_id INT;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(3,1),
    max_percentage NUMERIC(3,1),
    gpa_points NUMERIC(3,2)
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INT,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMPTZ,
    is_current BOOLEAN
);


--5
--5.1
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(4,1),
    max_percentage NUMERIC(4,1),
    gpa_points NUMERIC(3,2),
    description TEXT
);

DROP TABLE grade_scale CASCADE;


CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(4,1),
    max_percentage NUMERIC(4,1),
    gpa_points NUMERIC(3,2),
    description TEXT
);
--5.2
DROP DATABASE IF EXISTS university_test;

DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
    TEMPLATE = univercity;
