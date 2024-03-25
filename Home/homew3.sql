set serveroutput on
declare
    client_id number      := &id_client;
    client_name clienti.NUME_CLIENT%type;
    cursor orders_cursor(p_client_id number) is
        select c.ID_COMANDA, c.DATA, sum(rc.PRET * rc.CANTITATE) total_value
        from COMENZI c, clienti cl, RAND_COMENZI rc
        where c.ID_CLIENT = cl.ID_CLIENT
          and rc.ID_COMANDA = c.ID_COMANDA
          and cl.ID_CLIENT = p_client_id
        group by c.ID_COMANDA, c.DATA;
    orders_count pls_integer := 0;
begin
    select nume_client into client_name from CLIENTI where ID_CLIENT = client_id;
    DBMS_OUTPUT.put_line('Clientul: ' || client_name);
    for order_record in orders_cursor(client_id)
        loop
            orders_count := orders_count + 1;
            dbms_output.put_line('Comanda: ' || order_record.ID_COMANDA || ' ' || order_record.data || ' ' || order_record.total_value);
        end loop;
    if orders_count = 0 then
        dbms_output.put_line('Clientul nu are comenzi');
    elsif orders_count = 1 then
        dbms_output.put_line('Clientul are o comanda');
    else
        dbms_output.put_line('Clientul are ' || orders_count || ' comenzi');
    end if;
exception
    when no_data_found then
        dbms_output.put_line('Clientul nu exista');
end;
/

DECLARE
    exep exception ;
    PRAGMA EXCEPTION_INIT(exep, -20001);
    CURSOR curs IS SELECT nume
                FROM angajati where ID_DEPARTAMENT =1;
    r curs%ROWTYPE;
BEGIN
    BEGIN
        OPEN curs;
        fetch curs into r;
        if curs%NOTFOUND then
            RAISE exep;
        end if;
        DBMS_OUTPUT.PUT_LINE('Numele: ' || r.nume);
        loop
        FETCH curs INTO r;
        exit when curs%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Numele: ' || r.nume);
        END LOOP;
        close curs;
    EXCEPTION
        WHEN exep THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista randuri');
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('A');
    END;
    DBMS_OUTPUT.PUT_LINE('B');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(sqlerrm);
        DBMS_OUTPUT.PUT_LINE('C');
END;
/

