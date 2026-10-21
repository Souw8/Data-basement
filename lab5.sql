DROP SCHEMA IF EXISTS shop CASCADE;
DROP TABLE IF EXISTS order_items, orders, products_fk, categories,
                     books, publishers, authors, employees_dept,
                     student_courses, departments, course_enrollments, users,
                     inventory, customers, bookings, products_catalog, employees CASCADE;

CREATE TABLE employees (
    employee_id INTEGER,
    first_name  TEXT,
    last_name   TEXT,
    age         INTEGER CHECK (age BETWEEN 18 AND 65),
    salary      NUMERIC CHECK (salary > 0)
);

CREATE TABLE products_catalog (
    product_id     INTEGER,
    product_name   TEXT,
    regular_price  NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

CREATE TABLE bookings (
    booking_id     INTEGER,
    check_in_date  DATE,
    check_out_date DATE,
    num_guests     INTEGER,
    CONSTRAINT chk_num_guests CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT chk_dates      CHECK (check_out_date > check_in_date)
);
INSERT INTO employees VALUES (1, 'Aigerimm', 'Nurlanovaа', 17, 450000); --coinstraint work good
INSERT INTO employees VALUES (1, 'Aigerim', 'Nurlanova', 25, 450000);
INSERT INTO employees VALUES (2, 'Dmitry',  'Petrov',    40, 600000.50);

INSERT INTO products_catalog VALUES (1, 'Laptop',  500000, 450000);
INSERT INTO products_catalog VALUES (2, 'Phone',   300000, 299999.99);

INSERT INTO bookings VALUES (1, '2026-07-01', '2026-07-05', 2);
INSERT INTO bookings VALUES (2, '2026-08-10', '2026-08-11', 10);

CREATE TABLE customers (
    customer_id       INTEGER NOT NULL,
    email             TEXT    NOT NULL,
    phone             TEXT,
    registration_date DATE    NOT NULL
);

CREATE TABLE inventory (
    item_id      INTEGER   NOT NULL,
    item_name    TEXT      NOT NULL,
    quantity     INTEGER   NOT NULL CHECK (quantity >= 0),
    unit_price   NUMERIC   NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO customers VALUES (1, 'a@example.com', '+77010000001', '2026-01-15');
INSERT INTO customers VALUES (2, 'b@example.com', '+77010000002', '2026-02-20');
INSERT INTO inventory VALUES (1, 'Notebook', 100, 1.50, '2026-06-01 10:00:00');
INSERT INTO inventory VALUES (2, 'Pen',      500, 0.25, '2026-06-02 11:30:00');

INSERT INTO customers VALUES (3, 'c@example.com', NULL, '2026-03-01');
INSERT INTO customers (customer_id, email, registration_date) VALUES (4, 'd@example.com', '2026-03-02');

CREATE TABLE users (
    user_id    INTEGER,
    username   TEXT UNIQUE,
    email      TEXT UNIQUE,
    created_at TIMESTAMP
);

INSERT INTO users VALUES (1, 'alice', 'alice@example.com', '2026-01-01 08:00:00');
INSERT INTO users VALUES (2, 'bob',   'bob@example.com',   '2026-01-02 09:00:00');

CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id    INTEGER,
    course_code   TEXT,
    semester      TEXT,
    UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES (1, 100, 'CS101', 'Fall 2026');
INSERT INTO course_enrollments VALUES (2, 100, 'CS101', 'Spring 2027');
INSERT INTO course_enrollments VALUES (3, 100, 'MA101', 'Fall 2026');
INSERT INTO course_enrollments VALUES (4, 101, 'CS101', 'Fall 2026');
INSERT INTO course_enrollments VALUES (4, 101, 'CS101', 'Fall 2026');


ALTER TABLE users DROP CONSTRAINT users_username_key;
ALTER TABLE users DROP CONSTRAINT users_email_key;
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email    UNIQUE (email);

INSERT INTO users VALUES (5, 'erin',  NULL, now());
INSERT INTO users VALUES (6, 'frank', NULL, now());

CREATE TABLE departments (
    dept_id   INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location  TEXT
);

INSERT INTO departments VALUES (1, 'Engineering', 'Almaty');
INSERT INTO departments VALUES (2, 'Marketing',   'Astana');
INSERT INTO departments VALUES (3, 'Finance',     'Almaty');
INSERT INTO departments VALUES (4, 'HR',          NULL);

CREATE TABLE student_courses (
    student_id      INTEGER,
    course_id       INTEGER,
    enrollment_date DATE,
    grade           TEXT,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES (1, 10, '2026-09-01', 'A');
INSERT INTO student_courses VALUES (1, 11, '2026-09-01', 'B');
INSERT INTO student_courses VALUES (2, 10, '2026-09-02', NULL);

CREATE TABLE employees_dept (
    emp_id    INTEGER PRIMARY KEY,
    emp_name  TEXT NOT NULL,
    dept_id   INTEGER REFERENCES departments,
    hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'Aigerim', 1, '2025-03-01');
INSERT INTO employees_dept VALUES (2, 'Dmitry',  2, '2025-06-15');
INSERT INTO employees_dept VALUES (3, 'Aruzhan', 1, '2026-01-10');
INSERT INTO employees_dept VALUES (4, 'John',    NULL, '2026-02-01');

CREATE TABLE authors (
    author_id   INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country     TEXT
);

CREATE TABLE publishers (
    publisher_id   INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city           TEXT
);

CREATE TABLE books (
    book_id          INTEGER PRIMARY KEY,
    title            TEXT NOT NULL,
    author_id        INTEGER REFERENCES authors,
    publisher_id     INTEGER REFERENCES publishers,
    publication_year INTEGER,
    isbn             TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'Leo Tolstoy',       'Russia');
INSERT INTO authors VALUES (2, 'Abai Kunanbayev',   'Kazakhstan');
INSERT INTO authors VALUES (3, 'George Orwell',     'United Kingdom');
INSERT INTO authors VALUES (4, 'Haruki Murakami',   'Japan');

INSERT INTO publishers VALUES (1, 'Penguin Books',  'London');
INSERT INTO publishers VALUES (2, 'Zhazushy',       'Almaty');
INSERT INTO publishers VALUES (3, 'Vintage',        'New York');

INSERT INTO books VALUES (1, 'War and Peace',       1, 1, 1869, '978-0140447934');
INSERT INTO books VALUES (2, 'Book of Words',       2, 2, 1909, '978-6010000001');
INSERT INTO books VALUES (3, '1984',                3, 1, 1949, '978-0451524935');
INSERT INTO books VALUES (4, 'Animal Farm',         3, 1, 1945, '978-0451526342');
INSERT INTO books VALUES (5, 'Norwegian Wood',      4, 3, 1987, '978-0375704024');

CREATE TABLE categories (
    category_id   INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id   INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id  INTEGER REFERENCES categories ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id   INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id    INTEGER PRIMARY KEY,
    order_id   INTEGER REFERENCES orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk,
    quantity   INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO categories VALUES (2, 'Books');
INSERT INTO categories VALUES (3, 'Toys');

INSERT INTO products_fk VALUES (1, 'Laptop',  1);
INSERT INTO products_fk VALUES (2, 'Phone',   1);
INSERT INTO products_fk VALUES (3, 'Novel',   2);

INSERT INTO orders VALUES (1, '2026-06-01');
INSERT INTO orders VALUES (2, '2026-06-02');

INSERT INTO order_items VALUES (1, 1, 1, 2);
INSERT INTO order_items VALUES (2, 1, 2, 1);
INSERT INTO order_items VALUES (3, 2, 3, 5);

DELETE FROM categories WHERE category_id = 3;

SELECT * FROM order_items ORDER BY item_id;
DELETE FROM orders WHERE order_id = 1;
SELECT * FROM order_items ORDER BY item_id;

CREATE SCHEMA shop;
SET search_path TO shop;

CREATE TABLE customers (
    customer_id       INTEGER PRIMARY KEY,
    name              TEXT NOT NULL,
    email             TEXT NOT NULL UNIQUE,
    phone             TEXT,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE products (
    product_id     INTEGER PRIMARY KEY,
    name           TEXT NOT NULL,
    description    TEXT,
    price          NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id     INTEGER PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES customers ON DELETE RESTRICT,
    order_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    status       TEXT NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders ON DELETE CASCADE,
    product_id      INTEGER NOT NULL REFERENCES products ON DELETE RESTRICT,
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO customers VALUES (1, 'Aigerim Nurlanova', 'aigerim@example.com', '+77011111111', '2026-01-10');
INSERT INTO customers VALUES (2, 'Dmitry Petrov',     'dmitry@example.com',  '+77022222222', '2026-02-15');
INSERT INTO customers VALUES (3, 'Aruzhan Sadykova',  'aruzhan@example.com', NULL,           '2026-03-01');
INSERT INTO customers VALUES (4, 'John Smith',        'john@example.com',    '+14155550123', '2026-04-20');
INSERT INTO customers VALUES (5, 'Elena Ivanova',     'elena@example.com',   '+77055555555', '2026-05-05');

INSERT INTO products VALUES (1, 'Laptop',     '15-inch laptop',        450000.00, 15);
INSERT INTO products VALUES (2, 'Mouse',      'Wireless mouse',          5000.00, 100);
INSERT INTO products VALUES (3, 'Keyboard',   'Mechanical keyboard',    15000.00, 50);
INSERT INTO products VALUES (4, 'Monitor',    '27-inch 4K monitor',    120000.00, 20);
INSERT INTO products VALUES (5, 'Headphones', 'Noise-cancelling',       25000.00, 0);

INSERT INTO orders VALUES (1, 1, '2026-06-01', 455000.00, 'delivered');
INSERT INTO orders VALUES (2, 2, '2026-06-05',  30000.00, 'shipped');
INSERT INTO orders VALUES (3, 3, '2026-06-10', 120000.00, 'processing');
INSERT INTO orders VALUES (4, 4, '2026-06-15',  25000.00, 'pending');
INSERT INTO orders VALUES (5, 1, '2026-06-20',  10000.00, 'cancelled');

INSERT INTO order_details VALUES (1, 1, 1, 1, 450000.00);
INSERT INTO order_details VALUES (2, 1, 2, 1,   5000.00);
INSERT INTO order_details VALUES (3, 2, 3, 2,  15000.00);
INSERT INTO order_details VALUES (4, 3, 4, 1, 120000.00);
INSERT INTO order_details VALUES (5, 4, 5, 1,  25000.00);
INSERT INTO order_details VALUES (6, 5, 2, 2,   5000.00);

SELECT order_detail_id, order_id FROM order_details WHERE order_id = 5;
DELETE FROM orders WHERE order_id = 5;
SELECT order_detail_id, order_id FROM order_details WHERE order_id = 5;
SELECT count(*) AS orders_left, (SELECT count(*) FROM order_details) AS details_left FROM orders;

DELETE FROM customers WHERE customer_id = 5;
SELECT customer_id, name FROM customers ORDER BY customer_id;

RESET search_path;