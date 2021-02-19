--set sqlformat loader
--SET TIMING ON;
--set serveroutput on



declare  
name_scheme varchar2(255) :='USPACE';
name_table_a varchar2(255) :='TRANSACTIONS'; 
name_table_b varchar2(255) :='TRANSA'; 
name_table_c varchar2(255) :='RES'; 
error_message varchar2(1000); 
create_error exception; 
pragma exception_init(create_error,-2003); 
 
begin  
<<PLSQL_BLOCK>> 
 
begin 
<<DROP_TABLES>> 
execute immediate 'drop table '||name_table_a; 
execute immediate 'drop table '||name_table_b; 
execute immediate 'drop table '||name_table_c; 
commit;
exception when others then null; 
end DROP_TABLES; 
    
begin
<<CREATE_TABLES>> 

execute immediate 'CREATE TABLE '||name_table_a|| 
'(  EVENT_DATE DATE, 
    TRID varchar(50) NOT NULL, 
    LID INTEGER, 
    DESCRIPTION VARCHAR(50))'; 
    
execute immediate 'CREATE TABLE '||name_table_b|| 
'(  TRID varchar(50) NOT NULL, 
      LID NUMBER(2) 
    )'; 
 
execute immediate 'CREATE TABLE '||name_table_c|| 
'(  TRID varchar(50) NOT NULL, 
      RESL NUMBER 
    )'; 
        
dbms_output.put_line('[info] table was created');

end CREATE_TABLES; 
     

begin 
<<insert_data>> 
execute immediate 'insert into '||name_table_a|| 
' select f.dat, a.r, b.s, e.tex 
from  
(select TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE ''2000-01-01'',''J'') ,TO_CHAR(DATE ''9999-12-31'',''J''))),''J'') dat from all_objects where rownum <= 15 ) f 
,(select rownum r from all_objects where rownum < 30 ) a 
,(select rownum s from all_objects where rownum <= 4 ) b 
,(select DBMS_RANDOM.STRING(''A'', 3) tex from all_objects where rownum <= 30 ) e 
where rownum < 3000 
order by 1,2,3 '; 
 
execute immediate 'insert into '||name_table_b|| 
' select a.r, d.val 
from  
(select rownum r from all_objects where rownum < 30 ) a 
,(select DBMS_RANDOM.VALUE(0, 3) val from all_objects where rownum <= 1000 ) d 
where rownum < 6000 
order by 1 '; 
commit; 

dbms_output.put_line('[info] table was inserted');
exception when others 
then error_message:=SQLERRM; 
raise create_error; 
end insert_data; 


declare  

cursor tab is select TRID from TRANSACTIONS; 
type lv_id is table of varchar(50); 
lvid lv_id; 
nt number :=dbms_utility.get_time; 


begin 
<<batch_processing>> 
open tab; 
fetch tab bulk collect into lvid limit 5; 
forall i in lvid.FIRST .. lvid.LAST 
insert into RES select t1.TRID, t2.LID from (select * from TRANSACTIONS where TRID=lvid(i)) t1 join TRANSA t2 on t1.TRID=t2.TRID; 
         
--execute immediate ' insert into '||name_table_c||' select t1.TRID, t2.LID from '||name_table_a||' t1  join '||name_table_b||' t2 on t1.TRID=t2.TRID where t2.TRID = '||lvid(i)||' 
     
close tab; 
dbms_output.put_line( ((dbms_utility.get_time-nt)/100) || ' seconds....' ); 
end batch_processing; 

end PLSQL_BLOCK; 
