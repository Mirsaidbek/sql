-- Задания для практики подзапросов:
-- Вывести сотрудников с зарплатой выше средней по компании
select *
from employees
where salary > (select avg(salary) from employees)
order by id desc;

-- Вывести продукты дороже среднего
select *
from products
where price > (select avg(price) from products)
order by id desc;

-- Вывести отделы, где есть хотя бы один сотрудник с зарплатой > 10 000
select d.*
from departments d
where d.id in (select e.department_id
               from employees e
               where e.salary > 10000);

-- Вывести продукты, которые чаще всего встречаются в заказах
select *
from products
where id in
      (select product_id
       from (select product_id,
                    count(product_id) as ordered_products_count
             from order_items
             group by product_id) as res
       where res.ordered_products_count = (select max(res2.ordered_products_count)
                                           from (select product_id,
                                                        count(product_id) as ordered_products_count
                                                 from order_items
                                                 group by product_id) as res2));

-- Вывести для каждого клиента количество его заказов
select c.name, count(product_id)
from orders o
         join customers c on c.id = o.customer_id
         join (select *
               from order_items oi
                        join products p on oi.product_id = p.id) res on res.product_id = o.id
group by c.name;

-- Вывести топ 3 отдела по средней зарплате
select res.department_id, res.avg_salary
from (select e.department_id, avg(e.salary) as avg_salary
      from employees e
      group by e.department_id) as res
order by res.avg_salary desc
limit 3;

-- Вывести клиентов без заказов
select *
from customers с
where с.id not in (select distinct customer_id
                   from orders);

-- Вывести сотрудников, зарабатывающих больше, чем любой из менеджеров.
select *
from employees e
where e.salary > (select salary
                  from employees
                  where id in (select distinct manager_id
                               from employees
                               where manager_id is not null)
                  order by salary desc
                  limit 1);

-- Вывести отделы, где все сотрудники зарабатывают выше 5000.
select *
from departments d
where id in (select department_id
             from employees e
             where e.salary > 5000)
