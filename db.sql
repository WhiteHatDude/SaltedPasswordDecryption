CREATE OR REPLACE FUNCTION public.util_create_sequence_if_not_exists(_sequence text)
  RETURNS TEXT AS
$BODY$
DECLARE
   _kind "char";
   msg text;
BEGIN
   SELECT INTO _kind  c.relkind
   FROM   pg_class     c
   JOIN   pg_namespace n ON n.oid = c.relnamespace
   WHERE  c.relname = quote_ident(_sequence)  -- sequence name 
   AND    n.nspname = (current_schema());  -- schema name 

   IF NOT FOUND THEN       -- name is free
      EXECUTE 'CREATE SEQUENCE ' || _sequence;
      msg = _sequence || ' - created successfully, Tenant: ' || current_schema();
   ELSIF _kind = 'S' THEN 
      msg = _sequence || ' - sequence already exists!, Tenant: ' || current_schema();
   ELSE                   
      msg = _sequence || ' - conflicting object of different type exists!, Tenant: ' || current_schema();
   END IF;
   RAISE NOTICE '%', msg;
   RETURN msg;
END$BODY$
  LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------------------------------
  
CREATE TABLE IF NOT EXISTS passwords
(
  id bigserial,
  "visible" text,
  "hashed" text,
  "salt" text,
  PRIMARY KEY (id)
);;

SELECT public.util_create_sequence_if_not_exists('password_id_sequence');

------------------------------------------------------------------------------------------------------------------------
CREATE EXTENSION pgcrypto; --comment this line if you execute it again

CREATE OR REPLACE FUNCTION SHA1(_input TEXT)
RETURNS TEXT
AS $$
BEGIN
	return encode(digest(_input, 'sha1'), 'hex');
END
$$ LANGUAGE plpgsql;;

------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insertPassword(_password TEXT, _salt TEXT)
RETURNS TEXT
AS $$
BEGIN
   INSERT INTO passwords("visible", "hashed", "salt")
      VALUES (_password,SHA1(CONCAT(_salt, SHA1(CONCAT(_salt, SHA1(_password))))), _salt);
	  return SHA1(CONCAT(_salt, SHA1(CONCAT(_salt, SHA1(_password)))));
END
$$ LANGUAGE plpgsql;;

------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insertPassword(_password TEXT[], _salt TEXT)
RETURNS TEXT
AS $$

DECLARE _pass TEXT;

BEGIN
	FOREACH _pass IN ARRAY _password
	LOOP
		INSERT INTO passwords("visible", "hashed", "salt")
		  VALUES (_pass,SHA1(CONCAT(_salt, SHA1(CONCAT(_salt, SHA1(_pass))))), _salt);
	END LOOP;
	return 'Finished';
END
$$ LANGUAGE plpgsql;;

-- example: select * from insertPassword(array['admin', 'bla', 'test']::text[], 'CZYGmk2ED');
------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION findMatch(_hash TEXT, _salt TEXT)
RETURNS TABLE(
	"visible" text, 
	"salt" text)
AS $$
BEGIN
    RETURN QUERY(
		SELECT passwords.visible, passwords.salt
		FROM passwords
		WHERE _salt = passwords.salt and _hash = passwords.hashed
    );
END
$$ LANGUAGE plpgsql;;
