SET SERVEROUTPUT ON
DECLARE
    v_a NUMBER := &a;
    v_b NUMBER := &b;
    v_c NUMBER := &c;
    v_delta NUMBER;
    v_rez1 NUMBER;
    v_rez2 NUMBER;
BEGIN
    v_delta := v_b * v_b - 4*v_a*v_c;
    
    dbms_output.put_line('Delta: ' || v_delta);
    
    IF v_delta > 0 THEN
        v_rez1 := (-v_b + SQRT(v_delta)) / (2*v_a);
        v_rez2 := (-v_b - SQRT(v_delta)) / (2*v_a);
        
        dbms_output.put_line('Două soluții reale și distincte: x1 = ' || v_rez1 || ', x2 = ' || v_rez2);
    
    ELSIF v_delta = 0 THEN
        v_rez1 := -v_b / (2*v_a);
        
       dbms_output.put_line('O soluție reală și unică: x = ' || v_rez1);
    ELSE 
        dbms_output.put_line('Nu există soluții reale!');
    END IF;
END;
