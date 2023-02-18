--7. Formulati in limbaj natural o problema pe care sa o rezolvati
--   folosind un subprogram stocat independent care sa utilizeze
--   2 tipuri diferite de cursoare studiate, unul dintre acestea fiind
--cursor parametrizat. Apelati subprogramul.


--Problema:
--Dorim sa afisam informatii despre un client anume, al carui tag de utilizator se da ca parametru:
--Informatii personale: nume, prenume, email, gen
--Informatii despre conturile asociate persoanei: iban, sold, carduri daca exista
--Pentru carduri se va afisa tipul si numarul si toate tranzactiile efectuate cu acel card (data, tip_tranzactie, suma)

CREATE OR REPLACE PROCEDURE info_client(tag_utilizator CLIENT.tag_utilizator%TYPE)
AS
    CURSOR personal_client(p_tag_utilizator CLIENT.tag_utilizator%TYPE) IS SELECT p.cod_persoana, nume, prenume, email, gen
        FROM PERSOANA p, CLIENT c WHERE p.cod_persoana = c.cod_persoana AND c.tag_utilizator = p_tag_utilizator;
    
    CURSOR conturi(cod_client PERSOANA.cod_persoana%TYPE) IS SELECT cod_cont, iban, sold,
                CURSOR(SELECT cod_card, tip, card_number FROM CARD WHERE CARD.cod_cont = CONT.cod_cont)
            FROM CONT WHERE cod_persoana = cod_client;
            
    CURSOR tranzactii_cu_card(p_cod_card CARD.cod_card%TYPE, p_cod_cont CONT.cod_cont%TYPE) IS
        WITH tranzactii AS (
                (SELECT cod_tranzactie FROM DEPOZIT d WHERE d.cod_cont = cod_cont AND d.cod_card = p_cod_card)
                UNION ALL
                (SELECT cod_tranzactie FROM RETRAGERE r WHERE r.cod_cont = cod_cont AND r.cod_card = p_cod_card)
            )
        SELECT data_tranzactie, tip_tranzactie, valoare FROM TRANZACTIE t
        WHERE t.cod_cont = p_cod_cont AND t.cod_tranzactie IN (SELECT * FROM tranzactii);
    
    TYPE t_personal_info IS RECORD(
        cod_persoana PERSOANA.cod_persoana%TYPE,
        nume PERSOANA.nume%TYPE,
        prenume PERSOANA.prenume%TYPE,
        email PERSOANA.email%TYPE,
        gen PERSOANA.gen%TYPE
    );
    
    v_personal_info t_personal_info;
    
    v_cod_cont CONT.cod_cont%TYPE;
    v_iban CONT.iban%TYPE;
    v_sold CONT.sold%TYPE;
    carduri SYS_REFCURSOR;
    
    v_cod_card CARD.cod_card%TYPE;
    v_tip CARD.tip%TYPE;
    v_card_number CARD.card_number%TYPE;
    
    v_verifica BOOLEAN;
BEGIN
    OPEN personal_client(tag_utilizator);
    FETCH personal_client INTO v_personal_info;
    IF personal_client%ROWCOUNT = 0 THEN
        CLOSE personal_client;
        RAISE_APPLICATION_ERROR(-20008, 'Nu s-a gasit persoana cu tag-ul ' || tag_utilizator);
    END IF;
    CLOSE personal_client;
    
    --a trecut de primul cursor, avem date in v_personal_info
    dbms_output.put_line('=========== Info Client ===========');
    dbms_output.put_line('> Nume: ' || v_personal_info.nume);
    dbms_output.put_line('> Prenume: ' || v_personal_info.prenume);
    dbms_output.put_line('> Email: ' || v_personal_info.email);
    dbms_output.put_line('> Gen: ' || UPPER(v_personal_info.gen));
    dbms_output.new_line;
    OPEN conturi(v_personal_info.cod_persoana);
    LOOP
        FETCH conturi INTO v_cod_cont, v_iban, v_sold, carduri;
        EXIT WHEN conturi%NOTFOUND;
        
        dbms_output.put_line('-=-=-=- Cont Info -=-=-=-');
        dbms_output.put_line('>> IBAN: ' || v_iban);
        dbms_output.put_line('>> SOLD: ' || v_sold);
        dbms_output.new_line;
        
        LOOP
            FETCH carduri INTO v_cod_card, v_tip, v_card_number;
            EXIT WHEN carduri%NOTFOUND;
            dbms_output.put_line('----- Card Info -----');
            dbms_output.put_line('>>> Card Number: ' || v_card_number);
            dbms_output.put_line('>>> Tip: ' || v_tip);
            dbms_output.put_line('>>> Tranzactii: ');
            v_verifica := FALSE;
            FOR v_tranzactie_info IN tranzactii_cu_card(v_cod_card, v_cod_cont) LOOP
                dbms_output.put_line(' - Tranzactie (' || v_tranzactie_info.tip_tranzactie || ') efectuata pe ' || v_tranzactie_info.data_tranzactie || ' in valoare de ' || v_tranzactie_info.valoare);
                v_verifica := TRUE;
            END LOOP;
            IF NOT v_verifica THEN
                dbms_output.put_line('>>>> Nu are tranzactii efectuate cu acest card');
            END IF;
            dbms_output.new_line;
        END LOOP;
        IF carduri%ROWCOUNT = 0 THEN
            dbms_output.put_line('Clientul nu are carduri.');
        END IF;
        CLOSE carduri;
    END LOOP;
    
    IF conturi%ROWCOUNT = 0 THEN
        dbms_output.put_line('Clientul nu are conturi.');
    END IF;
    CLOSE conturi;
END;
/

EXECUTE info_client('UnUserInexistent_');
EXECUTE info_client('melis2_');