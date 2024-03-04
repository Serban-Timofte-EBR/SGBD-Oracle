-- Ecuatia de gradul 2
set serveroutput on;
DECLARE
    a NUMBER;
    b NUMBER;
    c NUMBER;
    delta NUMBER;
    x1 NUMBER;
    x2 NUMBER;
BEGIN
    a := &a_param;
    b := &b_param;
    c := &c_param;
    
    delta := b*b - 4*a*c;
    
    IF delta > 0 THEN
        x1 := (-b + SQRT(delta)) / (2*a);
        x2 := (-b - SQRT(delta)) / (2*a);
        DBMS_OUTPUT.PUT_LINE('Soluțiile ecuației sunt: ' || x1 || ' și ' || x2);
    ELSIF delta = 0 THEN
        x1 := -b / (2*a);
        DBMS_OUTPUT.PUT_LINE('Ecuația are o soluția: ' || x1);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ecuația nu are soluții reale.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;