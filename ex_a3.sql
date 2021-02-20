create  table example1 as select a.DATE_DATE, b.ID_TR, c.ID_PR, d.ID_CUS, e.ID_UNGR, f.INFO
from  
(select TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2000-01-01','J') ,TO_CHAR(DATE '9999-12-31','J'))),'J') DATE_DATE from all_objects where rownum <= 15 ) a 
,(select rownum ID_TR from all_objects where rownum < 30 ) b 
,(select rownum ID_PR from all_objects where rownum <= 4 ) c 
,(select rownum ID_CUS from all_objects where rownum <= 4 ) d 
,(select rownum ID_UNGR from all_objects where rownum <= 4 ) e 
,(select DBMS_RANDOM.STRING('A', 3) INFO from all_objects where rownum <= 30 ) f 
where rownum < 3000 
order by 1,2,3;

declare 
cursor cur_a is select * from example1;
type tabl is table of example1%rowtype index by binary_integer;
tab tabl;
inter INTEGER;

begin
<<global_space>>
dbms_output.put_line('n elements :'||tab.count);

begin
<<loop_cursor>>
for  x in cur_a loop
tab(cur_a%rowcount):=x;
end loop;
dbms_output.put_line('n elements :'||tab.count);
end loop_cursor;

begin
<<fetching_cursor>>
open cur_a;
fetch cur_a bulk collect into tab;
close cur_a;
dbms_output.put_line('n elements :'||tab.count);
end fetching_cursor;

begin
<<fetching_rows>>
open cur_a;
loop
exit when cur_a%notfound;
fetch cur_a bulk collect into tab limit 50000;
dbms_output.put_line('n elements :'||tab.count);
end loop;
close cur_a;
end fetching_rows;


begin
<<bulk_for_insert>>
inter:=1;
open cur_a;
loop
exit when cur_a%notfound;
fetch cur_a bulk collect into tab limit 50000;
dbms_output.put_line('n elements :'||tab.count);
    for x in tab.first..tab.last loop
        if inter = 1
            create table example2 as tab(x);
        else 
            insert into example2 values tab(x);
        end if;
        
        inter := inter + 1;
    end loop;
end loop;
close cur_a;
end bulk_for_insert;


begin
<<bulk_forall_insert>>
inter:=1;
open cur_a;
loop
exit when cur_a%notfound;
fetch cur_a bulk collect into tab limit 50000;
dbms_output.put_line('n elements :'||tab.count);
    forall x in tab.first..tab.last loop
        if inter = 1
            create table example2 as tab(x);
        else 
            insert into example2 values tab(x);
        end if;
        
        inter := inter + 1;
    end loop;
end loop;
close cur_a;
end bulk_forall_insert;

end global_space;
