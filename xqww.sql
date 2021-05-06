SET SERVEROUTPUT ON;

declare 

rows number;
cols number;
when_exist exception;
PRAGMA EXCEPTION_INIT(when_exist, -942);

begin
<<PLSQL_BLOCK>>

begin
<<bbb>>

-- drop if exists
execute immediate 'drop table TRANSACTIONS';
execute immediate 'drop table TRANSACTIONS_RESL';
exception when when_exist then DBMS_OUTPUT.PUT_LINE('Ignoring table or view does not exist');

-- create if exists
execute immediate 'create table TRANSACTIONS as ( ' 
||' select ''2019-09-30'' DATA_DANYCH, ''11111'' ID_T, ''a11111'' ID_KL, ''a12222'' ID_KL_R, 30000 W, 30 DPD, 0 F from dual union all '
||' select ''2019-09-30'' DATA_DANYCH, ''11111'' ID_T, ''a11111'' ID_KL, ''a13333'' ID_KL_R, 30000 W, 30 DPD, 0 F from dual union all '
||' select ''2019-09-30'' DATA_DANYCH, ''22222'' ID_T, ''a22222'' ID_KL, ''a13333'' ID_KL_R, 30000 W, 30 DPD, 0 F from dual union all '
||' select ''2019-09-30'' DATA_DANYCH, ''33333'' ID_T, ''a33333'' ID_KL, ''a12222'' ID_KL_R, 30000 W, 30 DPD, 0 F from dual union all '
||' select ''2019-09-30'' DATA_DANYCH, ''33333'' ID_T, ''a33333'' ID_KL, ''a13333'' ID_KL_R, 30000 W, 30 DPD, 0 F from dual )' ;

execute immediate 'create table TRANSACTIONS_RESL (ID_KL CHAR, F NUMBER)';

DBMS_OUTPUT.PUT_LINE('test table created');

EXCEPTION
WHEN OTHERS THEN dbms_output.put_line('Error in SELECT: '||SQLERRM);

RETURN;
                  
end bbb;


begin 
<<aaaa>>

FOR l1 IN (select unique(ID_KL) as ID_KL from TRANSACTIONS) loop

DBMS_OUTPUT.PUT_LINE('loop king '||l1.ID_KL|| ' sss ' );

end loop;

EXCEPTION
WHEN OTHERS THEN dbms_output.put_line('Error in SELECT: '||SQLERRM);
RETURN;
 
end aaaa;

EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
end PLSQL_BLOCK;
/

