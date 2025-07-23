-- #Having clause examples:

use youtube;
-- # duplicate emails count
select email
from emails
group by email
having count(email) > 1;

-- # class with 5 or more students
use employees;
select class from student group by class
having count(distinct student) >=5;
-- # we take distinct student and not distinct class to avoid duplicates