--questio 1 -- Our portal is live and it’s been quite some time now. Could you please help me in 
understanding from where the bulk of our website sessions are coming from? I want to see
specifically breakdown of UTM source, campaign and referring domain ;

select * , 
sum(Nu_of_Traffic) over (order by http_referer) as cum_sum from
(select count(distinct website_session_id) as Nu_of_Traffic,
utm_source,
utm_campaign, 
http_referer
from website_sessions
where date(created_at) < '2012-04-12' 
group by utm_source,utm_campaign,http_referer
order by Nu_of_Traffic desc)a;

-- question 2 It looks like gsearch nonbrand is the major traffic source, but we need to understand if we are
get sales out of it. Is it possible for you to calculate the conversion rate from session to order? 
We will require to manage bids based on CVR;

select * ,
(c.orders/c.sessions)*100  as CNV_ratio
from
(select 
utm_source,
utm_campaign,
count( distinct a.website_session_id) as sessions,
count(distinct b.order_id) as orders
from 
website_sessions a
left join 
orders b
on 
a.website_session_id=b.website_session_id
where date(a.created_at) < '2012-04-14'
and utm_source ='gsearch' 
and utm_campaign ='nonbrand')c;


-- question 3 -- Hey, Based on our last conversation where we analyzed conversion rate, we bid down gsearch 
non brand on 15th April 2012 because we were over bidding for g search non brand. Now, can 
you find gsearch non brand trended session, volume by week to see if the bid changes has 
caused the volume to drop at all;


select *, 
((b.volume-b.lag_volume)/b.volume)*100 as diff from
(select a.*, 
lag(a.volume) over(order by session_date) as lag_volume
from 
(select 
date(created_at) as session_date,
week(created_at) as week,
count(distinct website_session_id) as volume
from website_sessions
where created_at < '2012-05-10' 
and utm_source = 'gsearch' 
and utm_campaign ='nonbrand'
group by week(created_at))a)b;  


-- question 4 -- Hi There, I was just going through the mobile and realized that the UI is not that great, I did not 
have the satisfactory experience. Can you figure out the conversion rates from session to order
by device type? In case the performance is better for desktop then we will bid more for desktop 
to bring more volume ;

select * , (c.orders/c.num_session)*100 as cnv_ratio
from (select 
a.device_type,
count(distinct a.website_session_id) as num_session,
count(distinct b.created_at) as orders
from 
website_sessions a
left join 
orders b
on 
a.website_session_id=b.website_session_id
where month(a.created_at) = '05' 
and a.utm_source = 'gsearch' 
and a.utm_campaign ='nonbrand'
group by device_type ) c;


-- question 5 -- Hi There, Based on device level analysis of conversion rates, desktop was doing well, so we 
raised the bid for gsearch nonbrand desktop on 19th May 2012. Can you figure out weekly 
trends by device type to see the impact on volume? Baseline: 15th April 2012; 

select 
date(a.created_at) as seprated_by_week,
count(distinct 
			  case when device_type='desktop' then a.website_session_id else null end) as desktop,
count(distinct 
              case when device_type='mobile' then a.website_session_id else null end) as mobile
from
website_sessions a 
left join
orders b
on 
a.website_session_id=b.website_session_id
where date(a.created_at)  between '2012-04-15' and '2012-06-09' 
and a.utm_source = 'gsearch' 
and a.utm_campaign ='nonbrand'
group by week(a.created_at);