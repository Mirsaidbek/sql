-- set search_path to lesson03;
--
-- 1. Пример
-- CREATE TABLE sales (
--    id SERIAL PRIMARY KEY,
--    region VARCHAR(20),
--    amount BIGINT,
--    sale_date DATE
-- );
--
-- INSERT INTO sales (region, amount, sale_date) VALUES
-- ('North', 1000, '2024-01-01'),
-- ('South', 700, '2024-01-02'),
-- ('North', 500, '2024-01-03'),
-- ('West', NULL, '2024-01-04'),
-- ('South', 900, '2024-01-05'),
-- ('North', 1500, '2024-01-06');

-- Найди сумму продаж по каждому региону.
select coalesce(sum(sales.amount), 0) as total_sum, region as region
from sales
group by region;

-- Покажи среднюю сумму продаж по регионам, где больше одной продажи.
select avg(amount) as average_sum, region as region
from sales
group by region
having avg(amount) > 0;

-- Найди регион с максимальной суммой продаж.
select coalesce(sum(amount), 0) as max_sum, region as region
from sales
group by region
order by sum desc
limit 1;

-- Выведи общее количество продаж и сколько из них имеют ненулевую сумму.
select count(*) as total_sales_count, (select count(*) from sales where amount is not null) as non_null_sales_count
from sales;

-- Покажи регионы, где продажи превышают среднюю по всем регионам.
select region as region, amount as sum
from sales
where amount > (select avg(amount) as average_sum from sales);


--
--
-- 2. Пример
-- CREATE TABLE students (
--                          student_id SERIAL PRIMARY KEY,
--                          first_name VARCHAR(50) NOT NULL,
--                          last_name VARCHAR(50) NOT NULL,
--                          birth_date DATE NOT NULL,
--                          email VARCHAR(100) UNIQUE,
--                          group_id INT NOT NULL
-- );
--

-- Напишите INSERT для заполнения таблицы
insert into students(first_name, last_name, birth_date, email, group_id)
values ('Bob', 'Marly', '2004-12-04', 'bob@gmail.com', 2),
       ('Jack', 'Richard', '2004-12-04', 'jack@gmail.com', 2),
       ('Ivan', 'Testov', '1998-05-11', 'ivan@gmail.com', 1),
       ('Bob', 'Marly', '1980-10-25', 'bobby@gmail.com', 2),
       ('Jack', 'Sparrow', '2000-01-05', 'jaspar@gmail.com', 1),
       ('Peter', 'Testov', '1999-03-01', 'peter@gmail.com', 3);

-- Найти дубликаты по имени и фамилии студента
select first_name, last_name, count(*)
from students
group by (first_name, last_name)
having count(*) > 1;

-- TODO Удалить дубликаты, оставить только первую запись
-- delete
-- from students
-- 
-- ;


--
-- 3. Пример
-- CREATE TABLE students
-- (
--     student_id INT PRIMARY KEY,
--     full_name  VARCHAR(100),
--     age        INT,
--     group_id   INT
-- );
--
-- CREATE TABLE groups
-- (
--     group_id   INT PRIMARY KEY,
--     group_name VARCHAR(50)
-- );
--
-- CREATE TABLE subjects
-- (
--     subject_id   INT PRIMARY KEY,
--     subject_name VARCHAR(50)
-- );
--
-- CREATE TABLE grades
-- (
--     grade_id   INT PRIMARY KEY,
--     student_id INT,
--     subject_id INT,
--     grade      INT,
--     FOREIGN KEY (student_id) REFERENCES students (student_id),
--     FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
-- );
--
-- Задание

-- Напишите INSERT для заполнения таблиц
-- groups
insert into groups
values (1, 'group_A'),
       (2, 'group_B'),
       (3, 'group_C'),
       (4, 'group_D');

-- students
insert into students (student_id, full_name, age, group_id)
values (1, 'Jack Sparrow', 20, 1),
       (2, 'Nikolai Robot', 20, 3),
       (3, 'Feruza Ozodova', 19, 2),
       (4, 'Said Saidov', 20, 1),
       (5, 'Tum Tum Sahur', 21, 3),
       (6, 'Nikolai Pier', 18, 1),
       (7, 'Ivan Petrov', 20, 1),
       (8, 'Anna Ivanova', 21, 4),
       (9, 'Sergey Kuznetsov', 22, 4),
       (10, 'Olga Smirnova', 20, 2),
       (11, 'Dmitry Sokolov', 23, 3);

-- subjects
INSERT INTO subjects (subject_id, subject_name)
VALUES (1, 'Databases'),
       (2, 'Java Programming'),
       (3, 'Machine Learning'),
       (4, 'Web Development'),
       (5, 'Data Structure');

-- grades
INSERT INTO grades (grade_id, student_id, subject_id, grade)
VALUES (1, 1, 1, 90),
       (2, 1, 2, 85),
       (3, 2, 2, 95),
       (4, 2, 1, 88),
       (5, 3, 3, 92),
       (6, 4, 3, 89),
       (7, 4, 1, 76),
       (8, 5, 4, 91),
       (9, 5, 2, 87),
       (10, 5, 3, 60),
       (11, 6, 1, 51),
       (12, 6, 2, 96),
       (13, 7, 5, 68),
       (14, 8, 5, 83),
       (15, 8, 1, 90),
       (16, 8, 3, 26),
       (17, 9, 4, 67),
       (18, 10, 4, 87),
       (19, 11, 2, 79),
       (20, 11, 4, 79),
       (21, 11, 1, 15),
       (22, 11, 3, 86);


-- Подсчитайте количество студентов в университете.
select count(student_id)
from students;

-- Найдите средний возраст студентов.
select avg(age)
from students;

-- Определите минимальный и максимальный возраст студентов.
select min(age) as min_age, max(age) as mas_age
from students;

-- Подсчитайте, сколько всего оценок выставлено.
select count(grade_id)
from grades;

-- Подсчитайте, сколько студентов учится в каждой группе.
select g.group_name, count(s.student_id)
from students s
         full join groups g on s.group_id = g.group_id
group by g.group_name;

-- Найдите средний возраст студентов по каждой группе.
select g.group_name, avg(s.age) as "avarage age"
from students s
         full join groups g on s.group_id = g.group_id
group by g.group_name;

-- Определите средний балл по каждому предмету.
select subject_name, avg(grade) as "average grade"
from grades
         full join subjects on grades.subject_id = subjects.subject_id
group by subject_name;

-- Найдите количество студентов, у которых есть оценки по каждому предмету.
WITH subject_ids AS (select subject_id from subjects)
select count(*)
from students s
         join grades g on s.student_id = g.student_id
where g.;


-- Выведите только те группы, где учится больше 1 студента.
select group_name, count(s.student_id)
from groups g
         join students s on g.group_id = s.group_id
group by group_name
having count(s.student_id) > 1;

-- Покажите предметы, где средний балл выше 8. => у меня 100 бальная система поэтому буду брать 80
select s.subject_name, avg(g.grade)
from subjects s
         join grades g on s.subject_id = g.subject_id
group by s.subject_name
having avg(g.grade) > 80;

-- Найдите студентов, у которых средний балл по всем предметам выше 8.5 => у меня 100 бальная система поэтому буду брать 85
select s.full_name, subj.subject_name, avg(g.grade)
from grades g
         join students s on g.student_id = s.student_id
         join subjects subj on g.subject_id = subj.subject_id
group by s.full_name, subj.subject_name
having avg(g.grade) > 85;
