
--create sequence rep_stock_market_seq start with 100;

create table rep_stock_market 
(
CLOSE_DATE timestamp,
TRANSACTION_ID number not null,
TRADER varchar2(255));
comment on table rep_stock_market is 'model data analitics of stock_market';
create unique index rep_stock_market_pk on rep_stock_market(TRANSACTION_ID);
alter table rep_stock_market add constraint pk_rep_stock_market primary key (TRANSACTION_ID);
 

create table stock_market 
(
CLOSE_DATE timestamp,
TRANSACTION_ID number not null,
STOCK_ID number not null,
SECTOR_ID number not null,
STOCK_NAME varchar2(300),
CLOSE_PRICE number(3,1),
CLOSE_VOLUME number(5)
);


comment on table stock_market is 'model data stock_market';
create unique index stock_market_pk on stock_market(TRANSACTION_ID);
alter table stock_market add constraint pk_stock_market primary key (TRANSACTION_ID);
  
create index stock_market_stock_fk on stock_market(STOCK_ID);
alter table stock_market add constraint fk_stock_market_stoc foreign key (STOCK_ID)
  references rep_stock_market(TRANSACTION_ID);
  
create index stock_market_sector_fk on stock_market(SECTOR_ID);
alter table stock_market add constraint fk_stock_market_sec foreign key (SECTOR_ID)
  references rep_stock_market(TRANSACTION_ID);
  

-- desc stock_market;
/* firts insert to this table */
insert into rep_stock_market
select f.CLOSE_DATE, aa.TRANSACTION_ID, e.TRADER
from  
(select TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2000-01-01','J'),TO_CHAR(DATE '9999-12-31','J'))),'J') CLOSE_DATE from all_objects where rownum <= 15 ) f 
,(select rownum TRANSACTION_ID from all_objects where rownum < 3000 ) aa
,(select DBMS_RANDOM.STRING('A', 3) TRADER from all_objects where rownum <= 30 ) e 
where rownum < 3000 
order by 1,2,3; 
  

/* second inserting to this table */
insert into stock_market
select f.CLOSE_DATE, aa.TRANSACTION_ID, a.STOCK_ID, b.SECTOR_ID, e.STOCK_NAME, d.CLOSE_PRICE, j.CLOSE_VOLUME
from  
(select TO_DATE(SYSDATE, 'DD/MM/YY HH24:MI:SS') + 
       dbms_random.value(0, TO_DATE(SYSDATE, 'DD/MM/YY HH24:MI:SS') - 
       TO_DATE(SYSDATE, 'DD/MM/YY HH24:MI:SS')+1) CLOSE_DATE from all_objects where rownum <= 15 ) f 
,(select rownum TRANSACTION_ID from all_objects where rownum < 3000 ) aa
,(select rownum STOCK_ID from all_objects where rownum < 30 ) a 
,(select rownum SECTOR_ID from all_objects where rownum <= 4 ) b 
,(select DBMS_RANDOM.STRING('A', 3) STOCK_NAME from all_objects where rownum <= 30 ) e 
,(select cast(DBMS_RANDOM.VALUE(0, 3) as number(3,2)) CLOSE_PRICE from all_objects where rownum <= 1000 ) d 
,(select cast(DBMS_RANDOM.VALUE(20,100) as number(5)) CLOSE_VOLUME from all_objects where rownum <= 1000 ) j
where rownum < 3000 
order by 1,2,3;

  
