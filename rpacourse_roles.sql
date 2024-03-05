CREATE USER 'robotuser'@'localhost' IDENTIFIED BY 'password'; 

create role robotrole; 

grant robotrole to 'robotuser'@'localhost';

set default role all to 'robotuser'@'localhost';

use rpacourse2;

grant select, insert, update on invoiceheaders to robotrole; 
grant select, insert, update on invoicerows to robotrole; 
grant select on invoicestatus to robotrole; 

