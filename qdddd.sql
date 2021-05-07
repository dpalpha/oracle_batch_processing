
declare 

rows number;
cols number;
when_exist exception;
PRAGMA EXCEPTION_INIT(when_exist, -942);

begin 

execute immediate 'drop table TRANSACTIONS ';
execute immediate 'drop table TRANSACTIONS_RESL ';
exception when when_exist then DBMS_OUTPUT.PUT_LINE('Ignoring table or view does not exist');
end;
/

-- create if exists
create table TRANSACTIONS as ( 
select '2019-09-30' DATA_DANYCH, '111' ID_T, 'a111' ID_KL, 'a122' ID_KL_R, 30000 W, 30 DPD, 0 F from dual union all 
select '2019-09-30' DATA_DANYCH, '111' ID_T, 'a111' ID_KL, 'a133' ID_KL_R, 30000 W, 30 DPD, 0 F from dual union all 
select '2019-09-30' DATA_DANYCH, '222' ID_T, 'a222' ID_KL, 'a133' ID_KL_R, 30000 W, 30 DPD, 0 F from dual union all 
select '2019-09-30' DATA_DANYCH, '333' ID_T, 'a333' ID_KL, 'a122' ID_KL_R, 30000 W, 30 DPD, 0 F from dual union all 
select '2019-09-30' DATA_DANYCH, '333' ID_T, 'a333' ID_KL, 'a133' ID_KL_R, 30000 W, 30 DPD, 0 F from dual ) ;

create table TRANSACTIONS_RESL (ID_KL CHAR(20), F NUMBER);



select unique(ID_KL) as ID_KL from TRANSACTIONS;
select l1.*, '1' DEF from TRANSACTIONS l1 where l1.ID_KL='a111'; --ab
select l2.*, '1' DEF from TRANSACTIONS l2 where l2.ID_KL_R in 'a122' and l2.ID_KL not in 'a111'; --a
select l3.*, '1' DEF from TRANSACTIONS l3  where l3.ID_KL in 'a333' and l3.ID_KL_R not in 'a122'; --b 

select l1.*, '1' DEF from TRANSACTIONS l1 where l1.ID_KL='a222'; 
select l2.*, '1' DEF from TRANSACTIONS l2 where l2.ID_KL_R in 'a133' and l2.ID_KL not in 'a222';
select l3.*, '1' DEF from TRANSACTIONS l3  where l3.ID_KL not in 'a222' and l3.ID_KL in 'a333' and l3.ID_KL_R not in 'a133'; 


begin
<<aaa>>

FOR l1 IN (select unique(ID_KL) as ID_KL from TRANSACTIONS) loop -- [a111], a222, a333

FOR l2 IN (select unique(ID_KL_R) as ID_KL_R from TRANSACTIONS where ID_KL /*a111*/ = l1.ID_KL /*a111*/ ) loop -- a111 = [a122], a133

FOR l3 IN (select unique(ID_KL) as ID_KL from TRANSACTIONS where ID_KL_R /* a122*/ = l2.ID_KL_R  /* a122*/ and ID_KL /*a111*/ not in l1.ID_KL /*a111*/) loop -- a122: -a111, [a333]

FOR l4 IN (select unique(ID_KL_R) as ID_KL_R from TRANSACTIONS where ID_KL /*a333*/ = l3.ID_KL /*a333*/ and ID_KL_R /* a122*/ not in l2.ID_KL_R /* a122*/) loop -- a333: [a133], -a122


DBMS_OUTPUT.PUT_LINE('loop king '||l1.ID_KL);
DBMS_OUTPUT.PUT_LINE('loop king '||l2.ID_KL_R);
DBMS_OUTPUT.PUT_LINE('loop king '||l3.ID_KL);
DBMS_OUTPUT.PUT_LINE('loop king '||l4.ID_KL_R);

end loop;
end loop;
end loop;
end loop;

end aaa;
