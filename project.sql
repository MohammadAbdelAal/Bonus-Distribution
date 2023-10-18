set serveroutput on size 1000000
create or replace function get_city_bonus(v_city_id number)return number
is
v_city_bonus number(10,2);
begin
select city_bonus into v_city_bonus from cities where city_id=v_city_id;
return v_city_bonus;
end;

create or replace function get_city_branches_count(v_city_id number)return number
is
v_branches_count number(3):=0;
cursor branches_c is select city_id from branches;
begin
for branches_r in branches_c loop
if branches_r.city_id=v_city_id then
v_branches_count:=v_branches_count+1;
end if;
end loop;
return v_branches_count;
end;

create or replace function calc_branch_bonus(v_city_bonus number,v_branch_count number) return number
is
v_branch_bonus number(10,2);
begin
v_branch_bonus:=v_city_bonus/v_branch_count;
return v_branch_bonus;
end;

create or replace procedure update_branches_city_bonus(v_city_id number,v_branch_bonus number)
is
begin
update branches
set branch_bonus=v_branch_bonus
where city_id=v_city_id;
end;

create or replace function get_branch_bonus(v_branch_id number) return number
is
v_branch_bonus number (10,2);
begin
select branch_bonus into v_branch_bonus from branches where branch_id=v_branch_id;
return v_branch_bonus;
end;

create or replace function get_branch_MGRS_count(v_branch_id number) return number
is
cursor branch_employees_c is select employee_position, branch_id from branch_employees;
v_MGRS_count number:=0;
begin
for branch_employees_r in branch_employees_c loop
if branch_employees_r.employee_position = 'MGR' and branch_employees_r.branch_id = v_branch_id then
v_MGRS_count:=v_MGRS_count+1;
end if;
end loop;
return v_MGRS_count;
end;

create or replace function get_branch_EMPS_count(v_branch_id number) return number
is
cursor branch_employees_c is select employee_position, branch_id from branch_employees;
v_EMPS_count number:=0;
begin
for branch_employees_r in branch_employees_c loop
if branch_employees_r.employee_position = 'EMP' and branch_employees_r.branch_id = v_branch_id then
v_EMPS_count:=v_EMPS_count+1;
end if;
end loop;
return v_EMPS_count;
end;

create or replace function calc_branch_MGRS_bonus(v_branch_bonus number,v_branch_MGRS_count number) return number
is
v_branch_MGRS_bonus number(10,2);
begin
v_branch_MGRS_bonus:=v_branch_bonus*0.5/v_branch_MGRS_count;
return v_branch_MGRS_bonus;
end;

create or replace function calc_branch_EMPS_bonus(v_branch_bonus number,v_branch_EMPS_count number) return number
is
v_branch_EMPS_bonus number(10,2);
begin
v_branch_EMPS_bonus:=v_branch_bonus*0.5/v_branch_EMPS_count;
return v_branch_EMPS_bonus;
end;

create or replace procedure update_MGRS_bonus(v_branch_id number,v_branch_MGRS_bonus number)
is
begin
update branch_EMPLOYEES
set employee_bonus=v_branch_MGRS_bonus
where branch_id=v_branch_id and EMPLOYEE_POSITION='MGR';
end;

create or replace procedure update_EMPS_bonus(v_branch_id number,v_branch_EMPS_bonus number)
is
begin
update branch_EMPLOYEES
set employee_bonus=v_branch_EMPS_bonus
where branch_id=v_branch_id and EMPLOYEE_POSITION='EMP';
end;

declare

v_city_bonus number(10,2);
v_branches_count number(3);
v_branch_bonus number(10,2);

v_MGRS_count number;
v_EMPS_count number;

v_branch_MGRS_bonus number(10,2);
v_branch_EMPS_bonus number(10,2);

cursor cities_c is select city_id from cities;
cursor branches_c is select branch_id from branches;
begin

for cities_r in cities_c loop
v_city_bonus:=get_city_bonus(cities_r.city_id);
dbms_output.put_line(v_city_bonus);
v_branches_count:=get_city_branches_count(cities_r.city_id);
dbms_output.put_line(v_branches_count);
v_branch_bonus:=calc_branch_bonus(v_city_bonus,v_branches_count);
dbms_output.put_line(v_branch_bonus);
update_branches_city_bonus(cities_r.city_id,v_branch_bonus);
end loop;

for branches_r in branches_c loop
v_branch_bonus:=get_branch_bonus(branches_r.branch_id);
dbms_output.put_line(v_branch_bonus);

v_MGRS_count:=get_branch_MGRS_count(branches_r.branch_id);
dbms_output.put_line(v_MGRS_count);

v_EMPS_count:=get_branch_EMPS_count(branches_r.branch_id);
dbms_output.put_line(v_EMPS_count);

v_branch_MGRS_bonus:=calc_branch_MGRS_bonus(v_branch_bonus,v_MGRS_count);
dbms_output.put_line(v_branch_MGRS_bonus);

v_branch_EMPS_bonus:=calc_branch_EMPS_bonus(v_branch_bonus,v_EMPS_count);
dbms_output.put_line(v_branch_EMPS_bonus);

update_MGRS_bonus(branches_r.branch_id,v_branch_MGRS_bonus);
update_EMPS_bonus(branches_r.branch_id,v_branch_EMPS_bonus);
end loop;
end;