CREATE USER flyway WITH CREATEUSER;
CREATE DATABASE stacklight_stage;
GRANT ALL PRIVILEGES ON DATABASE stacklight_stage TO flyway;