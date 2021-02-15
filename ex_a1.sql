--set sqlformat loader
--SET TIMING ON;
--set serveroutput on



DECLARE 
name_table_a VARCHAR2(255) :='TRANSACTIONS';
name_table_b VARCHAR2(255) :='TRANSA';
name_table_c VARCHAR2(255) :='RES';
error_message VARCHAR2(1000);
create_error EXCEPTION;
emx all_objects%ROWTYPE;
bulk_error EXCEPTION;
PRAGMA exception_init(create_error,-2003);
PRAGMA exception_init(bulk_error,-24381);

begin 
<<PLSQL_BLOCK>>

    begin
    <<DROP_TABLES>>
        execute immediate 'drop table '||name_table_a;
        execute immediate 'drop table '||name_table_b;
        execute immediate 'drop table '||name_table_c;
    exception when others
        then null;
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
            
    exception when others
            then error_message:=SQLERRM;
            raise create_error;
    end CREATE_TABLES;
    

    begin
    <<insert_data>>
       execute immediate 'insert into '||name_table_a||
            ' select f.dat, a.r, b.s, e.tex
            from 
            (select TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE ''2000-01-01'',''J'') ,TO_CHAR(DATE ''9999-12-31'',''J''))),''J'') dat from all_objects where rownum <= 15 ) f
            ,(select rownum r from all_objects where rownum < 20000 ) a
            ,(select rownum s from all_objects where rownum <= 1000 ) b
            ,(select DBMS_RANDOM.STRING(''A'', 3) tex from all_objects where rownum <= 30 ) e
            where rownum < 20000
            order by 1,2,3 ';
            
        execute immediate 'insert into '||name_table_b||
            ' select a.r, d.val
            from 
            (select rownum r from all_objects where rownum < 10000 ) a
            ,(select DBMS_RANDOM.VALUE(0, 3) val from all_objects where rownum <= 1000 ) d
            where rownum < 10000
            order by 1 ';
        commit;
        
    exception when others
        then error_message:=SQLERRM;
        raise create_error;
    end insert_data;
    
    
    declare 
        cursor tab is select distinct LID from TRANSACTIONS;
        type lv_id is table of varchar(50);
        lvid lv_id;
        nt number :=dbms_utility.get_time;

    
    begin
    <<batch_processing>>
    open tab;
    loop
        FETCH tab BULK COLLECT INTO lvid LIMIT 5;
        EXIT WHEN lvid.COUNT = 0;
        FORALL i IN lvid.FIRST .. lvid.LAST SAVE EXCEPTIONS
        
            INSERT INTO RES SELECT max(t1.TRID) TRID, median(t2.LID) LID FROM (SELECT * FROM TRANSACTIONS WHERE LID IN lvid(i)) t1 JOIN TRANSA t2 ON t1.TRID=t2.TRID
            group by t1.LID, t1.TRID;
            --execute immediate ' insert into '||name_table_c||' select t1.TRID, t2.LID from '||name_table_a||' t1  join '||name_table_b||' t2 on t1.TRID=t2.TRID where t2.TRID = '||lvid(i)||'
        end loop;
    dbms_output.put_line( ((dbms_utility.get_time-nt)/100) || ' seconds....' );
    close tab;
    exception
        when bulk_error THEN
            dbms_output.put_line('['||SQL%ROWCOUNT||'] inserted rows');
            for x in 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                dbms_output.put_line('['
                ||SQL%BULK_EXCEPTIONS(x).ERROR_INDEX ||'] ['
                ||SQLERRM(-1*SQL%BULK_EXCEPTIONS(x).ERROR_CODE) ||']');
            end loop;
    end batch_processing;

exception
    when others then 
        DBMS_OUTPUT.PUT_LINE('# error: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('mesg error: ' || SQLERRM);
        raise;
        
end PLSQL_BLOCK;
/

--select count(TRID) from RES;
