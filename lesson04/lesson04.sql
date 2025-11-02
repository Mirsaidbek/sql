-- SQL. Lesson 04
-- Таблицы для ДЗ

--
-- CREATE TABLE departments
-- (
--     id       SERIAL PRIMARY KEY,
--     name     VARCHAR(50) NOT NULL,
--     location VARCHAR(50)
-- );
--
-- CREATE TABLE employees
-- (
--     id            SERIAL PRIMARY KEY,
--     name          VARCHAR(50) NOT NULL,
--     position      VARCHAR(50),
--     salary        NUMERIC(10, 2),
--     department_id INTEGER     REFERENCES departments (id) ON DELETE SET NULL,
--     manager_id    INTEGER     REFERENCES employees (id) ON DELETE SET NULL
-- );
--
-- CREATE TABLE customers
-- (
--     id   SERIAL PRIMARY KEY,
--     name VARCHAR(100) NOT NULL,
--     city VARCHAR(50)
-- );
--
-- CREATE TABLE orders
-- (
--     id          SERIAL PRIMARY KEY,
--     order_date  DATE    NOT NULL,
--     amount      NUMERIC(10, 2),
--     employee_id INTEGER REFERENCES employees (id) ON DELETE SET NULL,
--     customer_id INTEGER REFERENCES customers (id) ON DELETE SET NULL
-- );
--
-- CREATE TABLE products
-- (
--     id    SERIAL PRIMARY KEY,
--     name  VARCHAR(100) NOT NULL,
--     price NUMERIC(10, 2)
-- );
--
-- CREATE TABLE order_items
-- (
--     id         SERIAL PRIMARY KEY,
--     order_id   INTEGER REFERENCES orders (id) ON DELETE CASCADE,
--     product_id INTEGER REFERENCES products (id) ON DELETE SET NULL,
--     quantity   INTEGER NOT NULL
-- );


-- Задания
-- Вывести employee.id, employee.name, department.name — сотрудники без отдела должны показать No Department.
select employee.id, employee.name, coalesce(department.name, 'No Department')
from employees employee
         join departments department
              on department.id = employee.department_id
order by employee.id;

-- Сотрудники, у которых есть менеджер (показать имя сотрудника и имя менеджера).
select e.name "имя сотрудника", (select em.name name from employees em where em.id = e.manager_id) "имя менеджера"
from employees e
where e.manager_id is not null;

-- Отделы без сотрудников.
select *
from departments
where id not in (select distinct department_id from employees);

-- Все заказы с именем сотрудника и именем клиента — если employee или customer отсутствует, показывать No Employee / No Customer.
select coalesce((select name from employees where id = o.employee_id), 'No Employee') "employee",
       coalesce((select name from customers where id = o.customer_id), 'No Customer') "customer"
from orders o;

-- Список заказов с товарами: для каждого заказа вывести order_id, product_name, quantity. Показать также заказы без позиций.
select (select o.id from orders o where id = ot.order_id)         as "order_id",
       (select p.name from products p where p.id = ot.product_id) as "product_name",
       quantity                                                   as "quantity"
from order_items ot;

-- Для каждого отдела — все заказы (через сотрудников этого отдела); включать отделы с нулём заказов.\
select d.name "Dep name", o "order"
from orders o
         join employees e on o.employee_id = e.id
         join departments d on d.id = e.department_id;

-- Найти пары клиентов и продуктов, которые этот клиент никогда не покупал (т.е. построить Cartesian клиент×продукт и исключить реальные покупки).
select c.name as customer_name,
       p.name as product_name
from customers c
         cross join products p
         left join orders o on o.customer_id = c.id
         left join order_items oi on oi.order_id = o.id and oi.product_id = p.id
where oi.id is null;


-- Показать, какие продукты никогда не продавались.
select name
from products
where id not in (select product_id from order_items);

-- Для каждого менеджера — показать суммарную сумму заказов, оформленных его подчинёнными.
--todo

-- Общее количество заказов и суммарная выручка (amount).
select count(id), sum(amount)
from orders;

-- Средняя и максимальная зарплата по отделам.
select d.name, avg(e.salary), max(e.salary)
from employees e
         join departments d on d.id = e.department_id
group by d.name;

-- Для каждого заказа — общее количество товаров (sum quantity) и уникальных позиций (count distinct product_id).
select o.id                          as "заказ",
       sum(oi.quantity)              as "общее количество товаров",
       count(distinct oi.product_id) as "уникальных позиций"
from orders o
         left join order_items oi on o.id = oi.order_id
group by o.id
order by o.id;

-- Топ-3 продукта по суммарной выручке (price*quantity).
select p.name, p.price
from products p
         join order_items oi on p.id = oi.product_id
group by p.name, p.price
order by (p.price * count(oi.product_id)) desc
limit 3;


-- Количество клиентов, у которых есть хотя бы один заказ.
select count(с.id)
from customers с
         join orders o on o.customer_id = с.id
         join order_items oi on o.id = oi.id

-- Для каждого отдела — количество сотрудников, средняя зарплата, суммарная сумма заказов (через сотрудников этого отдела).
select d.name, count(e.id), coalesce(avg(e.salary), 0), coalesce(sum(o.id), 0)
from departments d
         left join employees e on d.id = e.department_id
         left join orders o on e.id = o.employee_id
group by d.name;

-- Найти клиентов, чья средняя сумма заказа выше средней по всем заказам.
select c.name, avg(o.amount)
from customers c
         join orders o on c.id = o.customer_id
group by c.name
having avg(o.amount) > (select avg(amount) from orders);

-- Сформировать полное имя сотрудника
select name "full name"
from employees;

-- Вывести дату заказа в формате DD.MM.YYYY HH24:MI.
select id                                        as order_id,
       to_char(order_date, 'dd.mm.yyyy hh24:mi') as formatted_date
from orders
order by id;

-- Найти заказы старше N дней (параметр)
select *
from orders
where order_date < (current_date - interval '12 day');

-- Для таблицы employees: заменить NULL в salary на 0 в вычислениях и вывести salary + bonus (bonus = 10% для определённой позиции).
select id,
       name,
       position,
       case
           when position = 'Sales Manager' then coalesce(salary, 0) * 1.1
           else coalesce(salary, 0)
           end salary_plus_bonus
from employees e
where position in ('Sales Manager', 'IT Specialist', 'Software Engineer');
-- Дата сдачи ДЗ: 03.11.25 15:30

create schema lesson05;