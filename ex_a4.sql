
--drop table example;
create  table example as select b.ID_TR, c.ID_PR, d.TEX from
(select rownum ID_TR from all_objects where rownum < 3000 ) b 
,(select rownum ID_PR from all_objects where rownum <= 4 ) c 
,(select rownum TEX from all_objects where rownum <= 4 ) d 
where rownum < 3000
order by 1, 2;


declare 
type obj_rec is record
(obj_id all_objects.object_id%TYPE
,obj_type all_objects.object_type%TYPE
);

type obj_tab is table of obj_rec;
t_all_obj obj_tab;

cursor c_rec(i_rec_ida in example.ID_TR%type,
             i_rec_idb in example.ID_PR%type)
             is select ID_TR from example where ID_TR=i_rec_ida and ID_PR=i_rec_idb
             for update;

cursor c_ins is select ID_TR, ID_PR from example;

begin 

for ind in c_ins

loop
    for c_id in c_rec(ind.ID_TR, ind.ID_PR)
    loop
    update example
    set TEX=0
    where ID_TR=ind.ID_TR and ID_PR=ind.ID_PR;
    --and current of c_id;
    end loop;
end loop;
end;
/
