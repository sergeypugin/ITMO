CREATE OR REPLACE FUNCTION sync_plan_title()
RETURNS TRIGGER AS $$
BEGIN
    SELECT title INTO NEW.plan_title FROM plan
    WHERE plan.id = NEW.plan_id;
    IF FOUND THEN
        RAISE EXCEPTION 'План с ID % не найден!', NEW.plan_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_plan_title
BEFORE INSERT OR UPDATE ON spaceship
FOR EACH ROW EXECUTE PROCEDURE sync_plan_title();
