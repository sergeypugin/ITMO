DROP TABLE IF EXISTS study_drawing CASCADE;
DROP TABLE IF EXISTS work_experience CASCADE;
DROP TABLE IF EXISTS transition CASCADE;
DROP TABLE IF EXISTS hatch CASCADE;
DROP TABLE IF EXISTS role CASCADE;
DROP TABLE IF EXISTS spaceship CASCADE;
DROP TABLE IF EXISTS plan CASCADE;
DROP TABLE IF EXISTS astronaut CASCADE;

CREATE TABLE astronaut (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(20),
  last_name VARCHAR(20),
  satisfaction_level SMALLINT CHECK (satisfaction_level >= 0 AND satisfaction_level <= 10)
);
CREATE TABLE plan (
  id SERIAL PRIMARY KEY,
  title VARCHAR(50) NOT NULL
);
CREATE TABLE spaceship (
  id SERIAL PRIMARY KEY,
  name VARCHAR(20) UNIQUE NOT NULL,
  is_finished BOOLEAN NOT NULL DEFAULT false,
  plan_id INTEGER NOT NULL REFERENCES plan(id)
);
CREATE TABLE role (
  id SERIAL PRIMARY KEY,
  role_name VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE hatch (
  id SERIAL PRIMARY KEY,
  spaceship_id INTEGER NOT NULL REFERENCES spaceship(id) ON DELETE CASCADE,
  is_opened BOOLEAN NOT NULL DEFAULT false
);
CREATE TABLE transition (
  id SERIAL PRIMARY KEY,
  spaceship_id INTEGER NOT NULL REFERENCES spaceship(id) ON DELETE CASCADE,
  is_tight BOOLEAN NOT NULL DEFAULT false
);
CREATE TABLE work_experience (
  id SERIAL PRIMARY KEY,
  astronaut_id INTEGER NOT NULL REFERENCES astronaut(id) ON DELETE CASCADE,
  spaceship_id INTEGER NOT NULL REFERENCES spaceship(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES role(id) ON DELETE SET NULL,
  duration_months INTEGER DEFAULT 0 CHECK (duration_months >= 0)
);
CREATE TABLE study_drawing (
  astronaut_id INTEGER NOT NULL REFERENCES astronaut(id) ON DELETE CASCADE,
  plan_id INTEGER NOT NULL REFERENCES plan(id) ON DELETE CASCADE,
  success_rate SMALLINT CHECK (success_rate >= 1 AND success_rate <= 10),
  PRIMARY KEY (astronaut_id, plan_id)
);



INSERT INTO astronaut (first_name, last_name, satisfaction_level) VALUES 
(null, 'Curnow', 10),
('Max', 'Brailovsky', 5);
INSERT INTO plan (title) VALUES
('Discovery Main Plan'),
('Discovery-2 Construction Plan');
INSERT INTO spaceship (name, is_finished, plan_id) VALUES 
('Discovery', true, 1),
('Discovery-2', false, 2);
INSERT INTO role (role_name) VALUES ('Engineer'), ('Navigator');
INSERT INTO work_experience (astronaut_id, spaceship_id, role_id, duration_months) VALUES 
(1, 1, 1, 2), (2, 1, 2, 0);
