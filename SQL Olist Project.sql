use olist;

Select * from olist.olist_orders_dataset;
select * from olist.olist_order_payments_dataset;
select
kpi1.day_end,
concat(round(kpi1.total_payment /(select sum(payment_value) from olist_order_payments_dataset) *100,2), '%') as percentage_values
from
(select ord.day_end, sum(pmt.payment_value) as total_payment
from olist_order_payments_dataset as pmt
join
(select distinct order_id,
case
when weekday(order_purchase_timestamp) in (5,6) then "weekend"
else "weekday"
end as Day_end
from olist_orders_dataset) as ord
on ord.order_id = pmt.order_id
group by ord.day_end) as kpi1;



select
prod.product_category_name,
avg(ord.order_delivered_customer_date)as Avg_delivery_days
from olist_orders_dataset ord
join
(select product_id ,order_id , product_category_name
from olist_products_dataset
join olist_order_items_dataset using(product_id)) as prod
on ord.order_id = prod.order_id
where prod.product_category_name = "Pet_shop"
group by prod.product_category_name ;


create table olist_orders_dataset(
order_id text not null,
customer_id text not null,
order_status text not null,
order_purchase_timestamp datetime not null,
order_delivered_customer_date datetime not null);

Select * from olist.olist_orders_dataset;
Select * from olist.olist_order_payments_dataset;

Alter table olist_order_payments_dataset
Add kpi1total_payment
VARCHAR(255);
#KPI 1 Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
select kpi1.Day_End,round(kpi1.Total_pmt/(select sum(payment_value) from
olist_order_payments_dataset)*100,2) as perc_pmtvalue
from
(select ord.Day_End,sum(pmt.payment_value) as Total_pmt
from olist_order_payments_dataset as pmt join
(select distinct(order_id), case when weekday(order_purchase_timestamp) in (5,6) then "Weekend"
else "Weekday" end as Day_End from olist_orders_dataset) as ord on ord.order_id = pmt.order_id
group by ord.Day_End)
as kpi1;

#KPI 2 Number of Orders with review score 5 and payment type as credit card.
Select 
count(pmt.order_id) as Total_Orders
from
olist_order_payments_dataset pmt
inner join olist_order_reviews_dataset rev on pmt.order_id = rev.order_id
where
rev.review_score = 5
and pmt.payment_type = "Credit_Card" ;

Select pmt.payment_type,count(pmt.order_id)
As Total_orders from olist_order_payments_dataset as pmt join
(select distinct ord.order_id, rw.review_score from olist_orders_dataset as ord
join olist_order_reviews_dataset rw on ord.order_id = rw.order_id where review_score=5) as rw5
on pmt.order_id = rw5.order_id 
group by pmt.payment_type
order by Total_orders desc;

#KPI 3 Average number of days taken for order_delivered_customer_date for pet_shop
select
prod.product_category_name,
avg(datediff(ord.order_delivered_customer_date , ord.order_purchase_timestamp)) as Avg_delivery_days
from olist_orders_dataset ord
join
(SELECT product_id ,order_id , product_category_name
from olist_products_dataset
join olist_order_items_dataset using(product_id)) as prod
on ord.order_id = prod.order_id
where prod.product_category_name = "Pet_shop"
group by prod.product_category_name ; 

#KPI  4 Average price and payment values from customers of sao paulo city
with orderItemsAvg AS (
 select round(AVG(item.price)) AS avg_order_item_price
 from olist_order_items_dataset item
 join olist_orders_dataset ord ON item.order_id = ord.order_id
 join olist_customers_dataset cust ON ord.customer_id = cust.customer_id
 where cust.customer_city = "Sao Paulo"
 )
 select
 (select avg_order_item_price from orderItemsAvg) AS avg_order_item_price,
 round(AVG(pmt.payment_value)) AS avg_payment_value
 from olist_order_payments_dataset pmt
 join olist_orders_dataset ord ON pmt.order_id = ord.order_id
 join olist_customers_dataset cust ON ord.customer_id = cust.customer_id
 where cust.customer_city = "Sao Paulo" ;

#KPI 5  Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
select 
rew.review_score,
round(avg(datediff(ord.order_delivered_customer_date , order_purchase_timestamp)),0) as "Avg shipping days"
from olist_orders_dataset as ord
join olist_order_reviews_dataset as rew on rew.order_id = ord.order_id
group by rew.review_score
order by rew.review_score ;

