Libname disk '/home/u59554701/my_shared_file_links/mingma13690/Data/'; /*mine*/

/* Copy the dataset from disk to temporary 'work' folder  */
proc sql;
create table Txn_Data as
select * from disk.txn_data_v9;
quit;

/* use case when to rename MCC*/
proc sql;
create table data_list_mcc as
select *, case
when MCC = 7055 then 'Grocery'
when MCC = 6011 then 'Transportation'
when MCC = 2314 then 'Financial'
when MCC = 2600 then 'Tax Service'
when MCC = 3300 then 'Hospitals'
when MCC = 4408 then 'Schools'
when MCC = 6237 then 'Automobile'
when MCC = 6845 then 'Travel'
when MCC = 9202 then 'Household Appliance Stores'
else 'None' end as MCC_Desc
from Txn_Data;
quit;

/* correct dataset*/
proc sql;
create table clean_data as
select a.*, case
when cty = 'North Yrko' then 'North York'
when substr(cty,1,10) = 'North York' then 'North York'
else cty end as City_New
from data_list_mcc as a ;
quit;


/* Calcualte fraud count and dollar grouped by different City and MCC */
proc sql;
create table summary as
select City_New as City,MCC_desc, count(*) as Fraud_count format=6.0, sum(amount) as Fraud_amount format=dollar9.
from clean_data
WHERE FRAUD = 'Yes' and product = 'POS'
/* group by City_New */
group by City_New, MCC_desc
having count(*)>10
/* order by City_New, Mcc_desc; */
order by calculated fraud_count desc;
;
quit;


/* Join with Master Table to get client age*/
/* Left */
proc sql;
create table left_join_master as
select a.*, b.card_num as card_num_v1, b.age, b.gender
from clean_data as a left join disk.master_v1 as b
on a.card_num = b.card_num
/* where b.card_num is null */
;
quit;


/* part #1a */
/* list of ABM machine id that had over 10 distinct ABM fraud cards. */
proc sql;
create table ABM_fraud as
select product, fraud, machine_id, card_num_v1
from left_join_master
where fraud = 'Yes' and product = 'ABM';
quit;

proc sql;
create table ABM_fraud_machine as
select machine_id, count( distinct card_num_v1) as num_of_distinct_fraud_ABM_Card
from ABM_fraud
group by machine_id
having num_of_distinct_fraud_ABM_Card >10;
quit;

/* part #1b */
/* find the number of victim of ABM fraud for over 20 years */
/* add time of year */
proc sql;
create table Fraud_time as
select a.*, b.account_open_year, year(datepart(timestamp)) - account_open_year as lasting_time
from clean_data a, disk.master_v1 b
where a.card_num = b.card_num;
quit;

/* find the victim */
proc sql;
create table Fraud_10 as
select count(distinct card_num) as num_of_victim
from Fraud_time
where product = 'ABM' and fraud = 'Yes' and lasting_time > 20;
quit;

/* part #2 */
/* we compare the frequency of fraud in different time period */
proc sql;
create table temp_add_hour as
select *, hour(timepart(timestamp)) as hour
from left_join_master
quit;

/* we separate the time */
proc sql;
create table table_summary as
select *, case
when hour = 0 or hour = 1 then '0am-1am'
when hour = 2 or hour = 3 then '2am-3am'
when hour = 4 or hour = 5 then '4am-5am'
when hour = 6 or hour = 7 then '6am-7am'
when hour = 8 or hour = 9 then '8am-9am'
when hour = 10 or hour = 11 then '10am-11am'
when hour = 12 or hour = 13 then '12am-1pm'
when hour = 14 or hour = 15 then '2pm-3pm'
when hour = 16 or hour = 17 then '4pm-5pm'
when hour = 18 or hour = 19 then '6pm-7pm'
when hour = 20 or hour = 21 then '8pm-9pm'
when hour = 22 or hour = 23 then '10pm-11pm'
else 'error' end as time_period
from temp_add_hour
where fraud = 'Yes' and product = 'ABM';
quit;

/* we calculate the sum based on time period */
proc sql;
create table time_summary as
select time_period, count(*) as total
from table_summary
group by time_period
order by calculated total desc;
quit;

/* part #3 */
/* calculate fraud ratio */
proc sql;
create table amount_summary as
select *, case
when 0 <= amount<100 then '0-99'
when 100 <= amount<200 then '100-199'
when 200 <= amount<300 then '200-299'
when 300 <= amount<400 then '300-399'
when 400 <= amount<500 then '400-499'
when 500 <= amount<600 then '500-599'
when 600 <= amount<700 then '600-699'
when 700 <= amount<800 then '700-799'
when 800 <= amount<900 then '800-899'
when 900 <= amount<1000 then '800-999'
else '1000+' end as amount_group
from left_join_master
where txn_type = 'Withdraw' and Product = 'ABM';
quit;

/* proc sql;
select distinct txn_type
from left_join_master;
quit; */

/* we count fraud and calculate the percent*/
proc sql;
create table fraud_amount_summary as
select amount_group,
sum(case when fraud = 'Yes' then 1 else 0 end) as count_Fraud,
count(*) as count,
calculated count_fraud / calculated count as Pt_fraud format=percent8.2
from amount_summary
group by amount_group
order by calculated Pt_fraud desc;
quit;

/* part #4 */

/* add two features to calculate the accumulated ABM withdraws (depletion amount
and the number of depletion) if the amount is greater or equal than $800 in the past
120 hours. */

proc sql;
create table ABM as
select * from left_join_master
where Product = 'ABM' and txn_type = 'Withdraw';
quit;

/* we find the fraud machine number first*/
proc sql;
create table Fraud_800amount as
select a.txn_id, b.txn_id as txn_id_b, b.amount
from ABM a, ABM b
where a.card_num = b.card_num
and a.timestamp >= b.timestamp
and a.timestamp - b.timestamp <24*5*3600
and (b.amount >=800);
quit;

/* we calculate the amount */
proc sql;
create table Machine_fraud_amount as
select txn_id, count(*) as deple_abm_amount , sum(amount) as deple_abm_sum
from Fraud_800amount
group by txn_id;
quit;

/* we group it back */
proc sql;
create table add_deple_cleandata as
select a.*, b.deple_abm_amount, b.deple_abm_sum
from ABM a left join Machine_fraud_amount b
on a.txn_id = b.txn_id;
quit;

/* part #5 */
/* Create one feature to indicate the ABM withdraw followed with taxi
transaction in the past 120 hours. If exist, output 1, else output 0. */

/* find taxi transaction */
proc sql;
create table Trans_summary as
select retail_id, min(amount) as min, avg(amount) as avg format=8.0, max(amount) as max,
std(amount) as std format=8.0
from left_join_master
where MCC_desc = 'Transportation'
group by retail_id
order by retail_id;
quit;

proc sql;
create table taxi as
select *
from left_join_master
where
MCC_desc = 'Transportation' and
retail_id in (select retail_id from Trans_summary where avg>20 and std>10)
order by retail_id;
quit;

proc sql;
create table Fraud_120hours_taxi as
select distinct a.txn_id
from add_deple_cleandata a, taxi b /* why taxi as b */
where a.card_num = b.card_num
and a.timestamp >= b.timestamp
and a.timestamp - b.timestamp <24*5*3600
and b.txn_type = 'Chip';
quit;

proc sql;
create table add_taxi_fraud_120hour_cleandata as
select a.*, /* we keep the clean data */
case when b.txn_id is not null then 1 else 0 end as taxi_Ind_chip
/* we get the info we want from b here as ind_chip already, we do not need to select b again*/
from add_deple_cleandata a left join Fraud_120hours_taxi b
on a.txn_id = b.txn_id;
quit;

proc sql;
create table add_taxifraud_cleandata as
select taxi_ind_chip, fraud, count(*)
from add_taxi_fraud_120hour_cleandata
group by taxi_ind_chip, fraud;
quit;

/* part #6 */
/* Create a rule logic with using the data from Apr 30th to May 4, 2020;
calculate hit rate and benefit of the rule*/
/* my Rule:
1. from ABM_fraud_machine
2. taxi_Ind_chip = 1
3. amount is from 800 - 1000+
4. from time 4pm-9pm & 2-3pm
*/

PROC SQL;
CREATE TABLE ALERT_ABM AS
SELECT *
FROM add_taxi_fraud_120hour_cleandata
WHERE amount>=800 AND
taxi_ind_chip = 1 AND (22>=HOUR(timestamp)>=16 or 14>=HOUR(timestamp)>=13) and decision = 'Approve' and
datepart(timestamp) >= input('20200430',yymmdd8.) and
datepart(timestamp) <= input('20200504',yymmdd8.);
QUIT;

proc sql;
create table perform as
select count(*) as alert,
count(distinct datepart(timestamp)) as days,
sum(case when fraud = 'No' then 1 else 0 end) as legit,
sum(case when fraud = 'Yes' then 1 else 0 end) as fraud,
sum(case when fraud = 'Yes' then amount else 0 end) as benefit,
calculated alert/calculated fraud as hit_rate format=5.2
from ALERT_ABM;
quit;


/* part #7 */
/* Use the data from May 5th to May 6th, 2020 to back test the rule’s
performance */


PROC SQL;
CREATE TABLE ALERT_ABM_VAL AS
SELECT *
FROM add_taxi_fraud_120hour_cleandata
WHERE amount>=800 AND
taxi_ind_chip = 1 AND (22>=HOUR(timestamp)>=16 or 14>=HOUR(timestamp)>=13) and decision = 'Approve' and
datepart(timestamp) > input('20200504',yymmdd8.);
QUIT;


proc sql;
create table perform as
select count(*) as alert,
count(distinct datepart(timestamp)) as days,
sum(case when fraud = 'No' then 1 else 0 end) as legit,
sum(case when fraud = 'Yes' then 1 else 0 end) as fraud,
sum(case when fraud = 'Yes' then amount else 0 end) as benefit,
calculated alert/calculated fraud as hit_rate format=5.2
from ALERT_ABM_VAL;
quit;
