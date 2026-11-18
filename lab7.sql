create table employees(
    emp_id int primary key ,
    emp_name varchar(50),
    dept_id int ,
    salary decimal(10,2)
);

create table departments(
    dept_id int primary key,
    dept_name varchar(50),
    location varchar(50)
);

create table projects(
    project_id int primary key ,
    project_name varchar(50),
    dept_id int,
    budget decimal(10,2)
);


INSERT INTO employees VALUES
    (1, 'John Smith',     101, 50000),
    (2, 'Jane Doe',       102, 60000),
    (3, 'Mike Johnson',   101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown',      NULL, 45000);

INSERT INTO departments VALUES
    (101, 'IT',        'Building A'),
    (102, 'HR',        'Building B'),
    (103, 'Finance',   'Building C'),
    (104, 'Marketing', 'Building D');

INSERT INTO projects VALUES
    (1, 'Website Redesign',  101, 100000),
    (2, 'Employee Training', 102,  50000),
    (3, 'Budget Analysis',   103,  75000),
    (4, 'Cloud Migration',   101, 150000),
    (5, 'AI Research',       NULL, 200000);


--2.1
create view  employees_details as
    select e.emp_name,
           e.salary,
           d.dept_name,
           d.location
from employees e
inner join departments d on e.dept_id=d.dept_id;


select * from employees_details;

--2.2

create view dept_statistics as
select  d.dept_name,
           count(e.emp_id) as employee_count,
           round(avg(e.salary),2) as mean_salary,
           max(e.salary) as max_salary,
           min(e.salary) as min_salary
from departments d
left join employees e on d.dept_id=e.dept_id
group by  d.dept_id,d.dept_name;

select * from dept_statistics
order by  employee_count desc;


--2.3
create view project_view as
    select p.project_name,
           p.budget,
           d.dept_name,
           d.location,
           count(e.emp_id) as employees
from  projects p
left join departments d on p.dept_id=d.dept_id
left join employees e on d.dept_id=e.dept_id
group by p.project_id,p.project_name,p.budget,d.dept_name,d.location;


select * from project_view
order by budget desc;


--2.4
create view high_earners as
    select e.emp_name,
           e.salary,
           d.dept_name
from employees e
inner join departments d on e.dept_id = d.dept_id
where e.salary>55000;

select * from high_earners;

--3


create or replace view employees_details as
    select e.emp_name,
           e.salary,
           d.dept_name,
           d.location,
           case
               when e.salary>60000 then 'high'
               when e.salary>50000 then 'medium'
               else 'standard'
            end  as  salary_grade
from employees e
inner join departments d on e.dept_id =  d.dept_id;

select * from employees_details;

--3.2
alter view high_earners rename to top_performers;
select * from top_performers;


--3.3

create view short_view as
    select e.emp_name ,
           e.emp_id,
           e.salary
from  employees e
where e.salary <50000;


select * from short_view;

drop view short_view;

---4

create view employee_details as
    select e.emp_name,
           e.emp_id,
           e.salary,
           e.dept_id
from employees e;

update employee_details
set salary =54000
where emp_name='Tom Brown';


select * from employees where emp_name = 'Tom Brown';

--4.3

insert into employee_details(emp_name, emp_id, salary, dept_id)
values ('Sanzhar Batyrbek',8,1000000,101);


select * from employees;

--4.4

CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;


insert into it_employees(emp_id, emp_name, dept_id, salary)
values (9,'V',101,70000);


---5

-- ❌ НЕПРАВИЛЬНО, просто посмотрите результат
SELECT d.dept_name,
       COUNT(e.emp_id)  AS total_employees,
       SUM(e.salary)    AS total_salaries
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects  p ON d.dept_id = p.dept_id
GROUP BY d.dept_name;


--5.1
create materialized view  dept_summary as
    select d.dept_id ,
           d.dept_name,
           coalesce(e.total_employees,0) as total_employees,
           coalesce(e.total_salaries,0) as total_salaries,
           coalesce(p.total_projects,0) as total_projects,
           coalesce(p.total_budget,0) as total_budget
from departments d
left join (
    select dept_id ,count(*) as total_employees,sum(salary) as total_salaries
    from employees
    group by  dept_id
) e on d.dept_id=e.dept_id
left join(
    select dept_id ,count(*) as total_projects ,sum(budget) as total_budget
    from projects
    group by dept_id
) p on d.dept_id  = p.dept_id
with data;

select * from dept_summary order by  total_employees;


INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (10, 'Charlie Brown', 101, 54000);


SELECT * FROM dept_summary ORDER BY total_employees DESC;

refresh materialized view dept_summary;

SELECT * FROM dept_summary ORDER BY total_employees DESC;

--5.3

CREATE UNIQUE INDEX idx_dept_summary_mv_dept_id
ON dept_summary (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary;


----5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       COUNT(e.emp_id) AS assigned_employees
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees  e ON p.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
WITH NO DATA;

select * from project_stats_mv;


refresh materialized view project_stats_mv;

select * from project_stats_mv;


--6
create role analyst;
create role data_viewer with login password 'viewer1234';
create  user report_user with  password  'report456';


select rolname from pg_roles where rolname not like 'pg_%';

--6.2

create  role db_creator with login  createdb  password 'cool_bro';
create  role user_manager with login createrole  password 'wise';
create role admin_user with login  superuser  password 'pova11r';


SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin
FROM pg_roles
WHERE rolname IN ('db_creator', 'user_manager', 'admin_user');

---6.3
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

SET ROLE report_user;

SELECT * FROM employees;                -- ✅ работает, есть SELECT
DELETE FROM employees WHERE emp_id = 999;
-- ❌ ERROR: permission denied for table employees (DELETE не выдавали)

RESET ROLE;
-- снова становимся postgres


---6.4

-- 1. Группы (без LOGIN — это «должности»)
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

-- 2. Конкретные пользователи
CREATE USER hr_user1      WITH PASSWORD 'hr001';
CREATE USER hr_user2      WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

-- 3–4. Добавляем пользователей в группы
GRANT hr_team      TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

-- 5–6. Права группам
GRANT SELECT, UPDATE ON employees       TO hr_team;
GRANT SELECT         ON dept_statistics TO finance_team;

SELECT r.rolname AS user_name, g.rolname AS group_name
FROM pg_auth_members m
JOIN pg_roles r ON m.member = r.oid
JOIN pg_roles g ON m.roleid = g.oid
WHERE g.rolname IN ('hr_team', 'finance_team');
--6.5
REVOKE UPDATE ON employees FROM hr_team;               -- у группы забрали UPDATE (SELECT остался)
REVOKE hr_team FROM hr_user2;                          -- hr_user2 исключён из группы
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;  -- забрали всё


ALTER ROLE analyst      WITH LOGIN PASSWORD 'analyst123';  -- теперь может входить
ALTER ROLE user_manager WITH SUPERUSER;                    -- стал суперпользователем
ALTER ROLE analyst      WITH PASSWORD NULL;                -- пароль удалён
ALTER ROLE data_viewer  WITH CONNECTION LIMIT 5;           -- не больше 5 подключенийя



CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE USER junior_analyst WITH PASSWORD 'junior123';
CREATE USER senior_analyst WITH PASSWORD 'senior123';
GRANT read_only TO junior_analyst, senior_analyst;

GRANT INSERT, UPDATE ON employees TO senior_analyst;


CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';
ALTER VIEW  dept_statistics OWNER TO project_manager;
ALTER TABLE projects        OWNER TO project_manager;

GRANT SELECT ON employees, departments TO project_manager;
-- ⚠️ ловушка


CREATE ROLE temp_owner WITH LOGIN;
CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;  -- передать всё postgres
DROP OWNED BY temp_owner;                  -- удалить то, что осталось
DROP ROLE temp_owner;


CREATE VIEW hr_employee_view AS
SELECT * FROM employees WHERE dept_id = 102;          -- только строки HR
GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary FROM employees;       -- только 3 столбца
GRANT SELECT ON finance_employee_view TO finance_team;

CREATE VIEW dept_dashboard AS
SELECT d.dept_name, d.location,
       COALESCE(e.cnt, 0)                         AS employee_count,
       ROUND(COALESCE(e.avg_sal, 0), 2)           AS avg_salary,
       COALESCE(p.cnt, 0)                         AS active_projects,
       COALESCE(p.budget, 0)                      AS total_project_budget,
       ROUND(COALESCE(p.budget, 0) / NULLIF(COALESCE(e.cnt, 0), 0), 2) AS budget_per_employee
FROM departments d
LEFT JOIN (SELECT dept_id, COUNT(*) cnt, AVG(salary) avg_sal FROM employees GROUP BY dept_id) e
       ON d.dept_id = e.dept_id
LEFT JOIN (SELECT dept_id, COUNT(*) cnt, SUM(budget) budget FROM projects GROUP BY dept_id) p
       ON d.dept_id = p.dept_id;



ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT p.project_name, p.budget, d.dept_name, p.created_date,
       CASE WHEN p.budget > 150000 THEN 'Critical Review Required'
            WHEN p.budget > 100000 THEN 'Management Approval Needed'
            ELSE 'Standard Process' END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

CREATE ROLE viewer_role;   GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;
CREATE ROLE entry_role;    GRANT viewer_role  TO entry_role;   GRANT INSERT ON employees, projects TO entry_role;
CREATE ROLE analyst_role;  GRANT entry_role   TO analyst_role; GRANT UPDATE ON employees, projects TO analyst_role;
CREATE ROLE manager_role;  GRANT analyst_role TO manager_role; GRANT DELETE ON employees, projects TO manager_role;

CREATE USER alice   WITH PASSWORD 'alice123';    GRANT viewer_role  TO alice;    -- только читает
CREATE USER bob     WITH PASSWORD 'bob123';      GRANT analyst_role TO bob;      -- читает, добавляет, меняет
CREATE USER charlie WITH PASSWORD 'charlie123';  GRANT manager_role TO charlie;  -- всё, включая DELETE


-- ===========================================================================
--  In-Class Task: Stale Data and Role Membership  —  solution
--  Database Systems, Laboratory Work 7 (SQL Views and Roles)
--
--  Run as postgres (superuser):   createdb wh
--                                 psql -U postgres -d wh -f surname_task8.sql
--
--  !! Role names are server-wide. Replace the suffix _xx with YOUR initials
--     everywhere (Find & Replace "_xx" -> "_ab", for example).
--
--  Several statements are SUPPOSED to fail (that is the point of the task);
--  psql prints the error and continues. The real messages are copied into the
--  "ANSWER" comments below.
-- ===========================================================================


-- ===========================================================================
-- Step 0 — build the database
-- ===========================================================================
DROP MATERIALIZED VIEW IF EXISTS mv_wh_totals, mv_wh_empty;
DROP VIEW IF EXISTS v_wh_totals;
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS shipments, warehouses CASCADE;

CREATE TABLE warehouses (
    wh_id   char(2)     PRIMARY KEY,
    wh_name varchar(10) NOT NULL,
    city    varchar(10) NOT NULL
);

CREATE TABLE shipments (
    ship_id   char(2) PRIMARY KEY,
    wh_id     char(2) REFERENCES warehouses,
    ship_date date NOT NULL,
    weight_kg int  NOT NULL,
    cost      int  NOT NULL
);

INSERT INTO warehouses VALUES
('W1','Central','Almaty'),
('W2','North',  'Astana'),
('W3','South',  'Shymkent');   -- no shipments

INSERT INTO shipments VALUES
('P1','W1','2026-01-10',120, 45000),
('P2','W1','2026-01-15', 80, 30000),
('P3','W2','2026-02-01',200, 70000),
('P4','W1','2026-02-20', 50, 20000),
('P5','W2','2026-03-05',150, 55000);


-- ===========================================================================
-- Part A: The same query, stored two ways
-- ===========================================================================
CREATE VIEW v_wh_totals AS
  SELECT w.wh_id, w.wh_name, count(s.ship_id) AS trips,
         COALESCE(sum(s.weight_kg),0) AS kg, COALESCE(sum(s.cost),0) AS cost
  FROM warehouses w LEFT JOIN shipments s ON s.wh_id = w.wh_id
  GROUP BY w.wh_id, w.wh_name;

CREATE MATERIALIZED VIEW mv_wh_totals AS SELECT * FROM v_wh_totals;

-- A1. Insert one more shipment for W1, then read W1 from each.
INSERT INTO shipments VALUES ('P6','W1','2026-03-10', 100, 40000);

SELECT 'view'    AS source, * FROM v_wh_totals  WHERE wh_id = 'W1';
SELECT 'matview' AS source, * FROM mv_wh_totals WHERE wh_id = 'W1';
-- ANSWER: The VIEW moved: W1 = 4 trips, 350 kg, 135000.
--         The MATERIALIZED VIEW did not: W1 = 3 trips, 250 kg, 95000.
-- A view stores only the query and runs it again on every SELECT, so it
-- always sees the current data. A materialized view stores the RESULT
-- (a snapshot) from when it was created or last refreshed. New rows in
-- shipments do not reach it until REFRESH MATERIALIZED VIEW.


-- A2. Try to update the materialized view directly.
UPDATE mv_wh_totals SET trips = 99 WHERE wh_id = 'W1';
-- ANSWER: ERROR:  cannot change materialized view "mv_wh_totals"
-- The error calls it a "materialized view" that cannot be changed: it is
-- read-only. You never edit a matview by hand. You change the base table
-- (shipments) and then REFRESH it.


-- A3. Concurrent refresh.
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_wh_totals;
-- ANSWER: ERROR:  cannot refresh materialized view "public.mv_wh_totals" concurrently
--         HINT:  Create a unique index with no WHERE clause on one or more
--                columns of the materialized view.
-- CONCURRENTLY compares old and new rows and changes only the differences,
-- so it needs a unique key to match each old row with its new version.
-- Do what the HINT says:
CREATE UNIQUE INDEX mv_wh_totals_wh_id_uq ON mv_wh_totals (wh_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_wh_totals;

SELECT * FROM mv_wh_totals WHERE wh_id = 'W1';
-- ANSWER: Now W1 = 4 trips, 350 kg, 135000, the same as the view.
-- With CONCURRENTLY, readers can keep running SELECTs on the old data
-- while the refresh runs (a plain REFRESH locks them out).


-- A4. A second matview WITH NO DATA.
CREATE MATERIALIZED VIEW mv_wh_empty AS SELECT * FROM v_wh_totals WITH NO DATA;

SELECT * FROM mv_wh_empty;
-- ANSWER: ERROR:  materialized view "mv_wh_empty" has not been populated
--         HINT:  Use the REFRESH MATERIALIZED VIEW command.

SELECT matviewname, ispopulated FROM pg_matviews;
-- ANSWER:  mv_wh_totals | t     (filled, can be read)
--          mv_wh_empty  | f     (only the structure exists, no data yet)
-- WITH NO DATA creates the definition but does not run the query.
-- It becomes readable after:  REFRESH MATERIALIZED VIEW mv_wh_empty;
-- (CONCURRENTLY cannot be used for that first fill.)


-- ===========================================================================
-- Part B: Belonging to a group is not enough
-- ===========================================================================
-- B1. Group role + two members
CREATE ROLE ops_team_xx;
GRANT SELECT ON mv_wh_totals TO ops_team_xx;

CREATE ROLE ops_a_xx INHERIT;
CREATE ROLE ops_b_xx NOINHERIT;
GRANT ops_team_xx TO ops_a_xx, ops_b_xx;

-- B2. ops_a (INHERIT)
SET ROLE ops_a_xx;
SELECT * FROM mv_wh_totals;          -- works
RESET ROLE;

-- B3. ops_b (NOINHERIT)
SET ROLE ops_b_xx;
SELECT * FROM mv_wh_totals;          -- ERROR: permission denied for materialized view mv_wh_totals
SET ROLE ops_team_xx;                -- still allowed: ops_b IS a member of the group
SELECT * FROM mv_wh_totals;          -- works now
RESET ROLE;
-- ANSWER: Both roles are members of ops_team, but only ops_a could read
-- right away. INHERIT does NOT control membership. It controls whether the
-- member uses the group's privileges AUTOMATICALLY.
--   * INHERIT   (ops_a): the group's privileges apply all the time.
--   * NOINHERIT (ops_b): membership only lets the role SWITCH into the
--     group with SET ROLE ops_team. Only after that switch can it use the
--     group's privileges.
-- So belonging to a group is not enough: with NOINHERIT you must also
-- "put on" the group role explicitly.


-- ===========================================================================
-- Part C: A role you cannot delete
-- ===========================================================================
-- C1. A role that owns a table
CREATE ROLE keeper_xx;
CREATE TABLE audit_log (id int);
ALTER TABLE audit_log OWNER TO keeper_xx;

DROP ROLE keeper_xx;
-- ANSWER: ERROR:  role "keeper_xx" cannot be dropped because some objects depend on it
--         DETAIL:  owner of table audit_log
-- A role that OWNS objects cannot be dropped: the table would be left
-- without an owner.

-- C2. Hand the table back and drop again
REASSIGN OWNED BY keeper_xx TO CURRENT_USER;
DROP ROLE keeper_xx;                 -- works now

-- C3. A role that only has a PRIVILEGE (owns nothing)
CREATE ROLE reader_xx;
GRANT SELECT ON audit_log TO reader_xx;

DROP ROLE reader_xx;
-- ANSWER: ERROR:  role "reader_xx" cannot be dropped because some objects depend on it
--         DETAIL:  privileges for table audit_log
-- This time the DETAIL says "privileges for", not "owner of". REASSIGN
-- OWNED would not help, because the role owns nothing. The single command
-- that clears it is:
DROP OWNED BY reader_xx;             -- also revokes every privilege granted to the role
DROP ROLE reader_xx;                 -- works now
-- (REVOKE SELECT ON audit_log FROM reader_xx; would also work here, but
--  DROP OWNED BY removes ALL of the role's privileges everywhere at once.)
--
-- Safe order to remove any role:
--   REASSIGN OWNED BY r TO someone;   -- keep its objects
--   DROP OWNED BY r;                  -- drop the rest + revoke its privileges
--   DROP ROLE r;


-- ===========================================================================
-- Cleanup of Part B roles (optional — run if you need to rerun the script)
-- ===========================================================================
-- DROP OWNED BY ops_team_xx;
-- DROP ROLE IF EXISTS ops_a_xx, ops_b_xx, ops_team_xx;