ALTER SYSTEM SET password_encryption = 'md5';
SELECT pg_reload_conf();
SET password_encryption = 'md5';

ALTER ROLE postgres PASSWORD 'postgres123';
-- CREATE ROLE group_checker WITH LOGIN PASSWORD 'group_checker123' SUPERUSER;
-- CREATE ROLE auth_query_user WITH LOGIN PASSWORD 'auth_query_user123' SUPERUSER;
CREATE DATABASE db1;
CREATE ROLE user1 WITH LOGIN PASSWORD 'user1123';
CREATE ROLE group1;
GRANT group1 TO user1;