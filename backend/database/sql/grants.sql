SET search_path TO public;

-- Jalankan 2 baris ini jika role belum dibuat
CREATE ROLE svc_lansia LOGIN PASSWORD '12345678';
CREATE ROLE svc_admin LOGIN PASSWORD 'admin123';

-- Least privilege: tidak ada CREATE/DROP/ALTER utk role aplikasi.
REVOKE ALL ON SCHEMA public FROM svc_lansia, svc_admin;
GRANT USAGE ON SCHEMA public TO svc_lansia, svc_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO svc_lansia, svc_admin;

-- user (menggunakan petik ganda karena kata kunci reserved PostgreSQL)
GRANT SELECT, INSERT ON "user" TO svc_lansia;
GRANT SELECT, UPDATE, DELETE ON "user" TO svc_admin;

-- admin
GRANT SELECT, INSERT, UPDATE, DELETE ON admin TO svc_admin;

-- konten
GRANT SELECT ON konten TO svc_lansia;
GRANT SELECT, INSERT, UPDATE, DELETE ON konten TO svc_admin;

-- history
GRANT SELECT, INSERT, DELETE ON history TO svc_lansia;
GRANT SELECT ON history TO svc_admin;

-- user_setting
GRANT SELECT, INSERT, UPDATE ON user_setting TO svc_lansia;
GRANT SELECT, UPDATE ON user_setting TO svc_admin;

-- usage_logs
GRANT INSERT ON usage_logs TO svc_lansia;
GRANT SELECT, DELETE ON usage_logs TO svc_admin;

-- service_credentials
GRANT SELECT, UPDATE ON service_credentials TO svc_admin;