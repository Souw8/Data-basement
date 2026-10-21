CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary NUMERIC(10,2),
    hire_date DATE,
    manager_id INTEGER,
    email VARCHAR(100)
);
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    budget NUMERIC(12,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);
CREATE TABLE assignments (
    assignment_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    project_id INTEGER REFERENCES projects(project_id),
    hours_worked NUMERIC(5,1),
    assignment_date DATE
);
-- Insert sample data
INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');
INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');


--task1


select first_name ||' '|| last_name as full_name,department,salary
from employees;

select distinct department
from employees;

select project_name,
       budget,
       case
           when budget>150000 then 'Large'
           when budget between 100000 and 150000 then 'Medium'
           else 'Small'
       end as budget_category
from projects;


SELECT first_name || ' '|| last_name as  full_name,
       coalesce(email,'No email provided') as email
from employees;

--task2

select *
from employees
where hire_date>'2020-01-01';

select *
from employees
where salary between 60000 and 70000;

select *
from employees
where last_name like 'S%' or last_name like 'J%';


SELECT *
from employees
where manager_id is not null and department='IT';

---TASK3

SELECT  upper(first_name ||' '||last_name) as full_name,
        length(last_name) as last_name_length,
        substring(email from 1 for 3) as email_prefix
from employees;


select first_name ||' '|| last_name as full_name,
       salary*12 as annual_salary,
       round(salary/12,2) as monthly_salary,
       salary * 0,10 as raise_amount
from employees;

select format('Project: %s - Budget:$%s - Status:%s',project_name,budget,status) as project_info
from projects;

SELECT first_name || ' ' || last_name AS full_name,
       hire_date,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_with_company
FROM employees;


---task4

select department,
       avg(salary) as avg_salary
from employees
group by  department;

select p.project_name,
       coalesce(sum(a.hours_worked),0) as total_hours
from projects p
left join assignments a on p.project_id = a.project_id
group by p.project_id,p.project_name;


select department,
       count(*) as employee_count
from employees
group by department
having count(*)>1;


select max(salary) as max,min(salary) as min,sum(salary) as total_payroll
from employees;


---5

select employee_id,first_name||' '||last_name as full_name,salary
from employees
where salary>65000
union
select  employee_id,first_name||' '|| last_name as full_name,salary
from employees
where hire_date>'2020-01-01';

SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE department = 'IT'
INTERSECT
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > 65000;

SELECT employee_id, first_name || ' ' || last_name AS full_name
FROM employees
EXCEPT
SELECT e.employee_id, e.first_name || ' ' || e.last_name
FROM employees e
JOIN assignments a ON a.employee_id = e.employee_id;


----task6
SELECT e.*
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM assignments a
    WHERE a.employee_id = e.employee_id
);

-- Task 6.2
SELECT *
FROM employees
WHERE employee_id IN (
    SELECT a.employee_id
    FROM assignments a
    WHERE a.project_id IN (
        SELECT project_id
        FROM projects
        WHERE status = 'Active'
    )
);
-- Task 6.3
SELECT *
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales');
-- Task 6.3

-- ============================================================
-- Part 7: Complex Queries
-- ============================================================

-- Task 7.1
SELECT e.first_name || ' ' || e.last_name AS employee_name,
       e.department,
       AVG(a.hours_worked) AS avg_hours,
       RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS salary_rank_in_dept
FROM employees e
LEFT JOIN assignments a ON a.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary
ORDER BY e.department, e.salary DESC;

-- Task 7.2
SELECT p.project_name,
       SUM(a.hours_worked) AS total_hours,
       COUNT(DISTINCT a.employee_id) AS employees_assigned
FROM projects p
JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;

-- Task 7.3
SELECT e.department,
       COUNT(*) AS total_employees,
       ROUND(AVG(e.salary), 2) AS avg_salary,
       (SELECT e2.first_name || ' ' || e2.last_name
        FROM employees e2
        WHERE e2.department = e.department
        ORDER BY e2.salary DESC
        LIMIT 1) AS highest_paid_employee,
       GREATEST(MAX(e.salary), AVG(e.salary)) AS upper_pay_bound,
       LEAST(MIN(e.salary), AVG(e.salary)) AS lower_pay_bound
FROM employees e
GROUP BY e.department;