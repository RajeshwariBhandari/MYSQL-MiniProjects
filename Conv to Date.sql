#CONVERT TO DATE WITHOUT USING ANY READYMADE FUNCTIONS

/*
select cast(10000101 As DATE) ;
set @new_date = cast('10000101' As DATE);
select @new_date;
select date_format(cast('10000101' As DATE) ,'%Y %M %d');

*/
/*
drop function convToDate;
DELIMITER //
CREATE FUNCTION convToDate (original int)
RETURNS varchar(20)
deterministic
BEGIN
DECLARE new_date date;
DECLARE new_date2 varchar(20);
set new_date = cast(original as date);
set new_date2 = date_format(new_date,'%Y %M %d');

RETURN new_date2;
END ;
//

select convToDate(19991002);*/

drop function convToDate;
DELIMITER //
CREATE FUNCTION convToDate (original int)
RETURNS varchar(20)
deterministic
BEGIN
DECLARE new_date date;
DECLARE new_date2 varchar(20);
DECLARE msg varchar(20);
set new_date = cast(original as date);
if new_date is null
then
return null;
else
set new_date2 = date_format(new_date,'%Y %M %d');
RETURN new_date2;
end if;
END ;
//

select convToDate(20233223);


  set @new_date = cast(20233212 as date); 
  select @new_date;
  Select Extract (year from @new_date);
