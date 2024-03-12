DECLARE
  v_an NUMBER;
  v_text VARCHAR2(20);
BEGIN
  v_an := &an;

  IF (MOD(v_an, 4) = 0 AND MOD(v_an, 100) != 0) OR (MOD(v_an, 400) = 0) THEN
    v_text := 'An bisect';
  ELSE
    v_text := 'Nu este an bisect';
  END IF;

  DBMS_OUTPUT.PUT_LINE('Anul ' || TO_CHAR(v_an) || ' este: ' || v_text);
END;