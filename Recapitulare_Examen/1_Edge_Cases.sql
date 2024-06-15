-- FOUND se verifica dupa FETCH
-- In acest caz cursorl%FOUND este NULL pentru ca nu s-a facut FETCH
SET SERVEROUTPUT ON 
DECLARE
    CURSOR cursorl IS SELECT id_angajat, nume FROM Angajati; 
    vid angajati.id_angajat%TYPE;
    vnume CHAR (20);
BEGIN
    OPEN cursorl;
    WHILE cursorl%FOUND LOOP
        FETCH cursorl INTO vid, vnume;
        DBMS_OUTPUT.PUT_LINE('Aici este print');
        DBMS_OUTPUT.PUT_LINE('Angajatul ' || vnume);
    END LOOP;
END;
/