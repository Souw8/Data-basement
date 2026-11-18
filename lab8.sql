drop  view if exists index_documentation;
drop table if exists  projects,employees,departments;

create table departments(
    dept_id int primary key ,
    dept_name varchar(50),
    location varchar(50)
);

create table employees(
    emp_id int primary key,
    emp_name varchar(100),
    dept_id int,
    salary decimal(10,2),
    foreign key (dept_id) references  departments(dept_id)
);


create table projects(
    proj_id int primary key,
    proj_name varchar(100),
    budget decimal(12,2),
    dept_id int,
    foreign key (dept_id) references  departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');

INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);


---2

--2/1

create index emp_salary_idx on employees(salary);

select indexname,indexdef from pg_indexes where tablename='employees';


--2/2
create index emp_dept_idx on employees(dept_id);

select *from employees where dept_id=101;


---2/3

select
    tablename,
    indexname,
    indexdef
from pg_indexes
where schemaname='public'
order by tablename,indexname;


--3

--3/1
create index emp_dept_salary_idx on employees(dept_id,salary);

select emp_name,salary
from employees
where dept_id=101 and salary>52000;

--3/2

create index emp_salary_dept_idx on employees(salary,dept_id);

select * from employees where dept_id=102 and salary>50000;


--4
alter table employees add column  email varchar(100);

UPDATE employees SET email = 'john.smith@company.com'     WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com'       WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com'   WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com'      WHERE emp_id = 5;


create unique index  emp_email_unique_idx on employees(email);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');


--4/2

alter table employees add column phone varchar(20) unique;

select indexname,indexdef
from  pg_indexes
where tablename='employees' and indexname like '%phone%';

---5/1
create  index emp_salary_desc_idx on employees(salary desc);

select emp_name,salary
from employees
order by  salary desc;

--5/2
create index proj_budget_nulls_first_idx on projects(budget nulls first);

select proj_name,budget
from projects
order by budget nulls first;

---6/1
create index emp_name_lower_idx on employees(lower(emp_name));


select *  from employees where lower(emp_name)='john smith';

--6/2
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;



create index emp_hire_year_idx on employees(extract(year from hire_date));

select emp_name,hire_date
from employees
where extract(year from hire_date)=2020;


--7
--7/1
alter index emp_salary_idx rename to employees_salary_idx;
select indexname from pg_indexes where tablename='employees';

--7/2
drop index emp_salary_dept_idx;

--7/3
reindex index employees_salary_idx;

--8
select e.emp_name,e.salary,d.dept_name
from employees e
join departments d on e.dept_id = d.dept_id
where e.salary>50000
order by  e.salary desc;


create index emp_salary_filter_idx on employees(salary)
where salary>50000;

--8/2

create index proj_high_budget_idx on projects(budget)
where budget>80000;

select proj_name,budget
from projects
where budget>80000;

---8/3
explain select *  from employees where salary >52000;

--9

--9/1
create index dept_name_hash_idx on departments using hash(dept_name);


select * from departments where dept_name='IT';



--9/2

--B-TYPE

CREATE INDEX proj_name_btree_idx on projects(proj_name);

---using hash

create index proj_name_hash_idx on projects using hash(proj_name);


select * from projects where proj_name= 'Website Redesign';

select * from projects where proj_name>'Database';


---10


SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- Q: Which index is the largest? Why?
-- A: dept_name_hash_idx and proj_name_hash_idx — 32 kB each; all B-tree indexes
--    are 16 kB. On such tiny tables size does not depend on data: a B-tree needs
--    a metapage + one leaf page (2 x 8 kB), while a hash index is created with a
--    metapage, a bitmap page and an initial set of bucket pages (4 x 8 kB).
--    On large tables the biggest indexes would be those on wide columns or with
--    many columns (e.g. text columns, multicolumn/covering indexes).

-- Exercise 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;
-- proj_name_hash_idx duplicates proj_name_btree_idx: the B-tree already serves
-- equality AND range queries, so the hash index only adds write overhead.

-- Exercise 10.3
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;

