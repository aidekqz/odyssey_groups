ALTER SYSTEM SET password_encryption = 'md5';
SELECT pg_reload_conf();
SET password_encryption = 'md5';
ALTER ROLE postgres PASSWORD '123456';
CREATE DATABASE db1;
CREATE ROLE user1 WITH LOGIN PASSWORD '111111';
CREATE ROLE group1;
GRANT group1 TO user1;