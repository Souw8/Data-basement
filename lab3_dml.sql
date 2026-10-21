create database advanced_lab;

create table employees(
    emp_id serial primary key,
    first_name varchar(30),
    last_name varchar(30),
    department varchar(30),
    salary int,
    hire_date date,
    status varchar(30) default 'Active'
);

create  table departments(
    dept_id serial primary key,
    dept_name varchar(30),
    budget  int,
    manager_id int
);

create  table projects(
    project_id serial primary key,
    project_name varchar(30),
    dept_id int,
    start_date date,
    end_date date,
    budget int
);


----2
insert into employees (first_name, last_name, department)
values ('san','batyrbek','it');


insert into employees (first_name, last_name, department, hire_date)
values ('kan','batyr','hr',current_date);

insert into departments(dept_name, budget, manager_id)
values ('it',150000,1),('hr',80000,2),('sales',120000,3);

insert into employees(first_name, last_name, department, salary, hire_date)
values ('san1','batyr','it',50000*1.1,current_date);

create temp table temp_employee as
select * from employees where 1=0;

insert into temp_employee
select * from employees where department='it';


----c

update employees
set salary=salary* 1.10;


update employees
set  status='senior'
where salary>600000
    and hire_date<'2020-01-01';

update employees
set department=case
    when salary>80000 then 'management'
    when salary between 50000 and 80000 then 'senior'
    else 'junior'
end;

alter table employees
alter column department set default  'unassigned';

update  employees
set department=default
where status='inactive';

update departments d
set budget=(
    select  avg(e.salary)*1.20
    from employees e
    where e.department=d.dept_name
    );
update employees
set salary=salary*1.15,status='promoted'
where department ='sales';


---d


delete  from employees
where salary<40000
    and hire_date>'2023-01-01'
    and department is null;

delete from departments
where dept_name not in (select distinct department from employees where department is not null);

delete from projects
where end_date<'2023-01-01'
returning *;

---e

insert into employees(first_name, last_name, department, salary, hire_date)
values ('nur','khan',null,null,current_date);


update employees
set department='unassigned'
where department is null;

delete from employees
where salary is null or department is null;


----f

insert into  employees(first_name, last_name, department, salary, hire_date)
values ('san','batyr','it','70000000',current_date)
returning  emp_id,first_name ||' '|| last_name as full_name;


update employees e
set salary=salary+5000
from(select emp_id,salary as old_salary from employees where department='it') sub
where e.emp_id=sub.emp_id
returning e.emp_id,sub.old_salary,e.salary as new_salary;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

delete from employees
where hire_date<'2020-01-01'
returning *;

--g

insert into employees(first_name, last_name, department, salary, hire_date)
select 'san','batyr','it',700000,current_date
where not exists(
    select 1 from employees
    where first_name ='san' and last_name='batyr'

);



update employees e
set salary=salary*case
    when(select budget from departments d where d.dept_name=e.department)>100000
        then 1.10
    else 1.05
end;


-- 5 сотрудников одним INSERT
INSERT INTO employees (first_name, last_name, department, salary, hire_date) VALUES
('A1','B1','IT',   50000, CURRENT_DATE),
('A2','B2','HR',   45000, CURRENT_DATE),
('A3','B3','Sales',55000, CURRENT_DATE),
('A4','B4','IT',   60000, CURRENT_DATE),
('A5','B5','HR',   47000, CURRENT_DATE)
returning *;

-- Один UPDATE — поднять зарплату на 10% только этим 5 (по last_name в списке)
UPDATE employees
SET salary = salary * 1.10
WHERE last_name IN ('B1','B2','B3','B4','B5')
returning *;

create table employee_archive (like employees including all);

with moved as(
    delete  from employees
    where status='inactive'
    returning *
)
insert into  employee_archive
select * from moved;


UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (
      SELECT COUNT(*) FROM employees e
      WHERE e.department = (
          SELECT dept_name FROM departments d WHERE d.dept_id = p.dept_id
      )
  ) > 3;