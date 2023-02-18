--14. Definiti un pachet care sa includa tipuri de date complexe si obiecte necesare
--    unui flux de actiuni integrate, specifice bazei de date definite (minim 2
--    tipuri de date, minim 2 functii, minim 2 proceduri)

CREATE OR REPLACE PACKAGE utilitati_bancare
AS
    card_negasit EXCEPTION; 
    cont_negasit EXCEPTION;
    persoana_negasita EXCEPTION;
    insuficienti_bani EXCEPTION;
    ambiguitate EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(card_negasit, -20101);
    PRAGMA EXCEPTION_INIT(cont_negasit, -20102);
    PRAGMA EXCEPTION_INIT(persoana_negasita, -20103);
    PRAGMA EXCEPTION_INIT(insuficienti_bani, -20104);
    PRAGMA EXCEPTION_INIT(ambiguitate, -20105);

    TYPE info_locatie IS RECORD(
        cod_postal LOCATIE.cod_postal%TYPE,
        adresa LOCATIE.adresa%TYPE,
        oras LOCATIE.oras%TYPE,
        nume_tara TARA.nume_tara%TYPE
    );

    TYPE info_personal IS RECORD(
        nume PERSOANA.nume%TYPE,
        prenume PERSOANA.prenume%TYPE,
        email PERSOANA.email%TYPE,
        gen PERSOANA.gen%TYPE,
        locatie info_locatie
    );
    
    TYPE info_card IS RECORD(
        card_number CARD.card_number%TYPE,
        tip CARD.tip%TYPE
    );
    
    TYPE lista_carduri IS TABLE OF info_card;

    TYPE info_cont IS RECORD(
        iban CONT.iban%TYPE,
        sold CONT.sold%TYPE,
        carduri lista_carduri
    );
    
    TYPE lista_conturi IS TABLE OF info_cont;
    
    TYPE info_client IS RECORD(
        tag_utilizator CLIENT.tag_utilizator%TYPE,
        personal_data info_personal,
        conturi lista_conturi
    );
    
    TYPE info_contract IS RECORD(
        titlu_contract TIP_CONTRACT.titlu_contract%TYPE,
        client_data info_personal,
        angajat_data info_personal,
        locatie_semnat info_locatie
    );
    
    TYPE lista_contracte IS TABLE OF info_contract;
    
    TYPE info_angajat IS RECORD(
        job_titlu JOB.denumire_job%TYPE,
        personal_data info_personal,
        salariu ANGAJAT.salariu%TYPE,
        contracte_semnate lista_contracte
    );
    
    PROCEDURE depozit_bani(
        p_iban CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE,
        p_cod_bancomat DEPOZIT.cod_bancomat%TYPE,
        p_card_number CARD.card_number%TYPE
    );
    
    PROCEDURE retragere_bani(
        p_iban CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE,
        p_cod_bancomat DEPOZIT.cod_bancomat%TYPE,
        p_card_number CARD.card_number%TYPE
    );
    
    PROCEDURE transfer_bani(
        p_iban_sursa CONT.iban%TYPE,
        p_iban_destinatie CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE
    );
    
    FUNCTION get_client_info(tag_utilizator CLIENT.tag_utilizator%TYPE) RETURN info_client;
    
    FUNCTION get_angajat_info(p_nume PERSOANA.nume%TYPE, p_prenume PERSOANA.prenume%TYPE) RETURN info_angajat;
END utilitati_bancare;
/



CREATE OR REPLACE PACKAGE BODY utilitati_bancare
AS
    FUNCTION get_cod_persoana(p_nume PERSOANA.nume%TYPE, p_prenume PERSOANA.prenume%TYPE) RETURN PERSOANA.cod_persoana%TYPE
    AS
        v_cod PERSOANA.cod_persoana%TYPE;
    BEGIN
        SELECT cod_persoana INTO v_cod FROM PERSOANA WHERE nume = p_nume AND p_prenume = prenume;
        RETURN v_cod;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20103, 'Persoana cautata nu a fost gasita.');
        WHEN TOO_MANY_ROWS THEN
            RAISE_APPLICATION_ERROR(-20105, 'Ambiguitate, sunt mai multe persoane cu numele si prenumele ' || p_nume || ' ' || p_prenume);
    END;
    
    FUNCTION get_cod_client(p_tag_utilizator CLIENT.tag_utilizator%TYPE) RETURN CLIENT.cod_persoana%TYPE
    AS
        v_cod CLIENT.cod_persoana%TYPE;
    BEGIN
        SELECT cod_persoana INTO v_cod FROM CLIENT WHERE tag_utilizator = p_tag_utilizator;
        RETURN v_cod;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20103, 'Clientul cautat nu a fost gasit');
    END;
    
    FUNCTION get_cod_card(p_card_number CARD.card_number%TYPE) RETURN CARD.cod_card%TYPE
    AS
        v_cod CARD.cod_card%TYPE;
    BEGIN
        SELECT cod_card INTO v_cod FROM CARD WHERE card_number = p_card_number;
        RETURN v_cod;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20101, 'Cardul cautat nu a fost gasit');
    END;
    
    FUNCTION get_cod_cont(p_iban CONT.iban%TYPE) RETURN CONT.cod_cont%TYPE
    AS
        v_cod CONT.cod_cont%TYPE;
    BEGIN
        SELECT cod_cont INTO v_cod FROM CONT WHERE iban = p_iban;
        RETURN v_cod;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20102, 'Contul cautat nu a fost gasit');
    END;
    
    
    PROCEDURE depozit_bani(
        p_iban CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE,
        p_cod_bancomat DEPOZIT.cod_bancomat%TYPE,
        p_card_number CARD.card_number%TYPE
    )
    AS
        tranzactie_id TRANZACTIE.cod_tranzactie%TYPE;
        v_cod_cont CONT.cod_cont%TYPE;
        v_cod_card CARD.cod_card%TYPE;
    BEGIN
        v_cod_cont := get_cod_cont(p_iban);
        v_cod_card := get_cod_card(p_card_number);
        SELECT tranzactii_contor+1 INTO tranzactie_id FROM ISTORIC i WHERE i.cod_cont = v_cod_cont;
        
        INSERT INTO TRANZACTIE VALUES(tranzactie_id, v_cod_cont, valoare, SYSDATE, 'depozit');
        INSERT INTO DEPOZIT VALUES(tranzactie_id, v_cod_cont, p_cod_bancomat, v_cod_card);
        UPDATE CONT c SET sold = sold + valoare WHERE c.cod_cont = v_cod_cont;
        dbms_output.put_line('Depozit realizat cu succes!');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20056, 'Contul exista dar nu are un istoric asociat.');
        --nu poate da too_many_rows, verificam dupa cheia primara
    END;
    
    
    PROCEDURE retragere_bani(
        p_iban CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE,
        p_cod_bancomat DEPOZIT.cod_bancomat%TYPE,
        p_card_number CARD.card_number%TYPE
    )
    AS
        tranzactie_id TRANZACTIE.cod_tranzactie%TYPE;
        v_sold CONT.sold%TYPE;
        v_cod_cont CONT.cod_cont%TYPE;
        v_cod_card CARD.cod_cont%TYPE;
    BEGIN
        v_cod_cont := get_cod_cont(p_iban);
        v_cod_card := get_cod_card(p_card_number);
        SELECT tranzactii_contor+1 INTO tranzactie_id FROM ISTORIC i WHERE i.cod_cont = v_cod_cont;
        --daca trece de select-ul anterior, sigur exista si contul fiind conectate prin foreign key
        SELECT sold INTO v_sold FROM CONT c WHERE c.cod_cont = v_cod_cont;
        IF v_sold < valoare THEN
            RAISE_APPLICATION_ERROR(-20104, 'Contul nu are suficienti bani pentru a efectua retragerea: ' || v_sold || ' < ' || valoare);
        END IF;
        
        INSERT INTO TRANZACTIE VALUES(tranzactie_id, v_cod_cont, valoare, SYSDATE, 'retragere');
        INSERT INTO RETRAGERE VALUES(tranzactie_id, v_cod_cont, p_cod_bancomat, v_cod_card);
        UPDATE CONT c SET sold = sold - valoare WHERE c.cod_cont = v_cod_cont;
        dbms_output.put_line('Retragere realizata cu succes!');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20056, 'Contul exista dar nu are un istoric asociat.');
        --nu poate da too_many_rows, verificam dupa cheia primara
    END;
    
    
    PROCEDURE transfer_bani(
        p_iban_sursa CONT.iban%TYPE,
        p_iban_destinatie CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE
    )
    AS
        tranzactie_id TRANZACTIE.cod_tranzactie%TYPE;
        v_sold CONT.sold%TYPE;
        v_data DATE := SYSDATE;
        v_cod_cont_sursa CONT.cod_cont%TYPE;
        v_cod_cont_destinatie CONT.cod_cont%TYPE;
    BEGIN
        IF p_iban_sursa = p_iban_destinatie THEN
            RAISE_APPLICATION_ERROR(-20057, 'Nu se pot trimite bani dintr-un cont in acelasi cont.');
        END IF;
        
        BEGIN
            v_cod_cont_sursa := get_cod_cont(p_iban_sursa);
        EXCEPTION
            WHEN cont_negasit THEN
                RAISE_APPLICATION_ERROR(-20102, 'Contul sursa nu a fost gasit.');
        END;
        
        BEGIN
            v_cod_cont_destinatie := get_cod_cont(p_iban_destinatie);
        EXCEPTION
            WHEN cont_negasit THEN
                RAISE_APPLICATION_ERROR(-20102, 'Contul destinatie nu a fost gasit.');
        END;
        
        SAVEPOINT inceput_transfer;
        
        --inserare transfer trimis
        BEGIN
            SELECT tranzactii_contor+1 INTO tranzactie_id FROM ISTORIC i WHERE i.cod_cont = v_cod_cont_sursa;
            --daca trece de select-ul anterior, sigur exista si contul fiind conectate prin foreign key
            SELECT sold INTO v_sold FROM CONT c WHERE c.cod_cont = v_cod_cont_sursa;
            IF v_sold < valoare THEN
                RAISE_APPLICATION_ERROR(-20005, 'Contul nu are suficienti bani pentru a efectua transferul: ' || v_sold || ' < ' || valoare);
            END IF;
            
            INSERT INTO TRANZACTIE VALUES(tranzactie_id, v_cod_cont_sursa, valoare, v_data, 'transfer_trimis');
            INSERT INTO TRANSFER_TRIMIS VALUES(tranzactie_id, v_cod_cont_sursa, v_cod_cont_destinatie);
            UPDATE CONT c SET sold = sold - valoare WHERE c.cod_cont = v_cod_cont_sursa;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20005, 'Nu se poate efectua un transfer pentru un cont cu istoric inexistent. (1)');
        END;
        
        --inserare transfer primit
        BEGIN
            SELECT tranzactii_contor+1 INTO tranzactie_id FROM ISTORIC i WHERE i.cod_cont = v_cod_cont_destinatie;
            
            INSERT INTO TRANZACTIE VALUES(tranzactie_id, v_cod_cont_destinatie, valoare, v_data, 'transfer_primit');
            INSERT INTO TRANSFER_PRIMIT VALUES(tranzactie_id, v_cod_cont_destinatie, v_cod_cont_sursa);
            UPDATE CONT c SET sold = sold + valoare WHERE c.cod_cont = v_cod_cont_destinatie;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20006, 'Nu se poate efectua un transfer pentru un cont cu istoric inexistent. (2)');
        END;
        dbms_output.put_line('Transfer realizat cu succes!');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO inceput_transfer; --daca orice parte a transferului esueaza, nu vrem sa ramana fragmente de transfer in baza de date
            RAISE;
    END;
    
    FUNCTION get_client_info(tag_utilizator CLIENT.tag_utilizator%TYPE) RETURN info_client
    AS
        deReturnat info_client;
        v_cod_client CLIENT.cod_persoana%TYPE;
        v_i PLS_INTEGER;
    BEGIN
        v_cod_client := get_cod_client(tag_utilizator);
        FOR v_record IN (
            SELECT cod_postal, adresa, oras, nume_tara, nume, prenume, tag_utilizator, email, gen
            FROM TARA t, LOCATIE l, PERSOANA p, CLIENT c WHERE
            t.cod_tara = l.cod_tara AND l.cod_locatie = p.cod_locatie AND
            p.cod_persoana = c.cod_persoana AND c.cod_persoana = v_cod_client
        )
        LOOP
            deReturnat.tag_utilizator := v_record.tag_utilizator;
            deReturnat.personal_data.nume := v_record.nume;
            deReturnat.personal_data.prenume := v_record.prenume;
            deReturnat.personal_data.email := v_record.email;
            deReturnat.personal_data.gen := v_record.gen;
            deReturnat.personal_data.locatie.cod_postal := v_record.cod_postal;
            deReturnat.personal_data.locatie.adresa := v_record.adresa;
            deReturnat.personal_data.locatie.oras := v_record.oras;
            deReturnat.personal_data.locatie.nume_tara := v_record.nume_tara;
            deReturnat.conturi := lista_conturi();
            
            v_i := 0;
            FOR v_record_conturi IN (SELECT cod_cont, sold, iban FROM CONT WHERE cod_persoana = v_cod_client) LOOP
                deReturnat.conturi.extend;
                v_i := v_i + 1;
                deReturnat.conturi(v_i).sold := v_record_conturi.sold;
                deReturnat.conturi(v_i).iban := v_record_conturi.iban;
                
                SELECT card_number, tip BULK COLLECT INTO deReturnat.conturi(v_i).carduri FROM CARD WHERE cod_cont = v_record_conturi.cod_cont;
                
            END LOOP;
            
        END LOOP;
        
        return deReturnat;
    END;
    
    FUNCTION get_angajat_info(p_nume PERSOANA.nume%TYPE, p_prenume PERSOANA.prenume%TYPE) RETURN info_angajat
    AS
        deReturnat info_angajat;
        v_cod PERSOANA.cod_persoana%TYPE;
        v_i PLS_INTEGER;
    BEGIN
        v_cod := get_cod_persoana(p_nume, p_prenume);
        deReturnat.personal_data.nume := p_nume;
        deReturnat.personal_data.prenume := p_prenume;
        FOR v_record IN (
            SELECT email, gen, cod_postal, adresa, oras, nume_tara, denumire_job, salariu
            FROM PERSOANA p, LOCATIE l, TARA t, ANGAJAT a, JOB j
            WHERE p.cod_persoana = a.cod_persoana AND l.cod_locatie = p.cod_locatie
            AND t.cod_tara = l.cod_tara AND a.cod_job = j.cod_job AND p.cod_persoana = v_cod
        )
        LOOP
            deReturnat.job_titlu := v_record.denumire_job;
            deReturnat.salariu := v_record.salariu;
            deReturnat.personal_data.email := v_record.email;
            deReturnat.personal_data.gen := v_record.gen;
            deReturnat.personal_data.locatie.cod_postal := v_record.cod_postal;
            deReturnat.personal_data.locatie.adresa := v_record.adresa;
            deReturnat.personal_data.locatie.oras := v_record.oras;
            deReturnat.personal_data.locatie.nume_tara := v_record.nume_tara;
            
            deReturnat.contracte_semnate := lista_contracte();
            
            v_i := 0;
            
            FOR v_record_contract_cu_sediu IN(
                SELECT nume, prenume, email, gen, l.cod_postal, l.adresa, l.oras, t.nume_tara, titlu_contract,
                ls.cod_postal sediu_cod_postal, ls.adresa sediu_adresa, ls.oras sediu_oras, ts.nume_tara sediu_nume_tara
                FROM PERSOANA p, CLIENT c, LOCATIE l, SEMNEAZA_UN_CONTRACT sc, TIP_CONTRACT tc, SEDIU s, LOCATIE ls, TARA t, TARA ts
                WHERE p.cod_persoana = c.cod_persoana AND l.cod_locatie = p.cod_locatie AND sc.cod_client = p.cod_persoana
                AND t.cod_tara = l.cod_tara AND ls.cod_tara = ts.cod_tara
                AND tc.tip_contract = sc.tip_contract
                AND s.cod_sediu = sc.cod_sediu AND ls.cod_locatie = s.cod_locatie AND sc.cod_angajat = v_cod
            )
            LOOP
                deReturnat.contracte_semnate.extend;
                v_i := v_i + 1;
                deReturnat.contracte_semnate(v_i).titlu_contract := v_record_contract_cu_sediu.titlu_contract;
                deReturnat.contracte_semnate(v_i).angajat_data := deReturnat.personal_data;
                deReturnat.contracte_semnate(v_i).client_data.nume := v_record_contract_cu_sediu.nume;
                deReturnat.contracte_semnate(v_i).client_data.prenume := v_record_contract_cu_sediu.prenume;
                deReturnat.contracte_semnate(v_i).client_data.email := v_record_contract_cu_sediu.email;
                deReturnat.contracte_semnate(v_i).client_data.gen := v_record_contract_cu_sediu.gen;
                deReturnat.contracte_semnate(v_i).client_data.locatie.cod_postal := v_record_contract_cu_sediu.cod_postal;
                deReturnat.contracte_semnate(v_i).client_data.locatie.adresa := v_record_contract_cu_sediu.adresa;
                deReturnat.contracte_semnate(v_i).client_data.locatie.oras := v_record_contract_cu_sediu.oras;
                deReturnat.contracte_semnate(v_i).client_data.locatie.nume_tara := v_record_contract_cu_sediu.nume_tara;
                
                deReturnat.contracte_semnate(v_i).locatie_semnat.cod_postal := v_record_contract_cu_sediu.sediu_cod_postal;
                deReturnat.contracte_semnate(v_i).locatie_semnat.adresa := v_record_contract_cu_sediu.sediu_adresa;
                deReturnat.contracte_semnate(v_i).locatie_semnat.oras := v_record_contract_cu_sediu.sediu_oras;
                deReturnat.contracte_semnate(v_i).locatie_semnat.nume_tara := v_record_contract_cu_sediu.sediu_nume_tara;
            END LOOP;
            
            FOR v_record_contract IN(
                SELECT nume, prenume, email, gen, l.cod_postal, l.adresa, l.oras, t.nume_tara, titlu_contract
                FROM PERSOANA p, CLIENT c, LOCATIE l, SEMNEAZA_UN_CONTRACT sc, TIP_CONTRACT tc, TARA t
                WHERE p.cod_persoana = c.cod_persoana AND l.cod_locatie = p.cod_locatie AND sc.cod_client = p.cod_persoana
                AND t.cod_tara = l.cod_tara
                AND tc.tip_contract = sc.tip_contract
                AND sc.cod_sediu IS NULL AND sc.cod_angajat = v_cod
            )
            LOOP
                deReturnat.contracte_semnate.extend;
                v_i := v_i + 1;
                deReturnat.contracte_semnate(v_i).titlu_contract := v_record_contract.titlu_contract;
                deReturnat.contracte_semnate(v_i).angajat_data := deReturnat.personal_data;
                deReturnat.contracte_semnate(v_i).client_data.nume := v_record_contract.nume;
                deReturnat.contracte_semnate(v_i).client_data.prenume := v_record_contract.prenume;
                deReturnat.contracte_semnate(v_i).client_data.email := v_record_contract.email;
                deReturnat.contracte_semnate(v_i).client_data.gen := v_record_contract.gen;
                deReturnat.contracte_semnate(v_i).client_data.locatie.cod_postal := v_record_contract.cod_postal;
                deReturnat.contracte_semnate(v_i).client_data.locatie.adresa := v_record_contract.adresa;
                deReturnat.contracte_semnate(v_i).client_data.locatie.oras := v_record_contract.oras;
                deReturnat.contracte_semnate(v_i).client_data.locatie.nume_tara := v_record_contract.nume_tara;
            END LOOP;
        END LOOP;
        return deReturnat;
    END;
END utilitati_bancare;
/

SELECT * FROM CONT;
EXECUTE utilitati_bancare.depozit_bani('RO43PORL9543945186522245', 122, 1, '4539763856109249');
EXECUTE utilitati_bancare.retragere_bani('RO43PORL9543945186522245', 1122, 1, '4539763856109249');
EXECUTE utilitati_bancare.retragere_bani('RO43PORL9543945186522245', 122, 1, '4539763856109249');
EXECUTE utilitati_bancare.transfer_bani('RO80RZBR8845968383338826', 'RO93PORL7529645415765354', 1000);

DECLARE
    v_client utilitati_bancare.info_client;
BEGIN
    v_client := utilitati_bancare.get_client_info('UserInexistent');
EXCEPTION
    WHEN utilitati_bancare.persoana_negasita THEN
        dbms_output.put_line('A intrat aici.');
END;
/


DECLARE
    v_client utilitati_bancare.info_client;
BEGIN
    v_client := utilitati_bancare.get_client_info('melis2_');
    dbms_output.put_line('==== Client Info ====');
    dbms_output.put_line('> Nume: ' || v_client.personal_data.nume);
    dbms_output.put_line('> Prenume: ' || v_client.personal_data.prenume);
    dbms_output.put_line('> Email: ' || v_client.personal_data.email);
    dbms_output.put_line('> Gen: ' || UPPER(v_client.personal_data.gen));
    dbms_output.put_line('> Locatie: ');
    dbms_output.put_line('>> Cod Postal: ' || v_client.personal_data.locatie.cod_postal);
    dbms_output.put_line('>> Adresa: ' || v_client.personal_data.locatie.adresa);
    dbms_output.put_line('>> Oras: ' || v_client.personal_data.locatie.oras);
    dbms_output.put_line('>> Tara: ' || v_client.personal_data.locatie.nume_tara);
    
    IF v_client.conturi.count = 0 THEN
        dbms_output.put_line('> Clientul nu are conturi');
        RETURN;
    END IF;
    
    FOR i IN 1..v_client.conturi.count LOOP
        dbms_output.put_line('--- Cont Info ---');
        dbms_output.put_line('> IBAN: ' || v_client.conturi(i).iban);
        dbms_output.put_line('> Sold: ' || v_client.conturi(i).sold);
        
        IF v_client.conturi(i).carduri.count = 0 THEN
            dbms_output.put_line('> Contul nu are carduri asociate.');
            CONTINUE;
        END IF;
        
        dbms_output.put_line('> Carduri:');
        FOR j IN 1..v_client.conturi(i).carduri.count LOOP
            dbms_output.put_line(' - ' || v_client.conturi(i).carduri(j).card_number || ' (' || v_client.conturi(i).carduri(j).tip || ')');
        END LOOP;
    END LOOP;
EXCEPTION
    WHEN utilitati_bancare.persoana_negasita THEN
        dbms_output.put_line('A intrat aici.');
END;
/


DECLARE
    v_angajat utilitati_bancare.info_angajat;
BEGIN
    v_angajat := utilitati_bancare.get_angajat_info('Adam', 'Ioan');
    
    dbms_output.put_line('==== Angajat Info ====');
    dbms_output.put_line('> Nume: ' || v_angajat.personal_data.nume);
    dbms_output.put_line('> Prenume: ' || v_angajat.personal_data.prenume);
    dbms_output.put_line('> Email: ' || v_angajat.personal_data.email);
    dbms_output.put_line('> Gen: ' || UPPER(v_angajat.personal_data.gen));
    dbms_output.put_line('> Locatie: ');
    dbms_output.put_line('>> Cod Postal: ' || v_angajat.personal_data.locatie.cod_postal);
    dbms_output.put_line('>> Adresa: ' || v_angajat.personal_data.locatie.adresa);
    dbms_output.put_line('>> Oras: ' || v_angajat.personal_data.locatie.oras);
    dbms_output.put_line('>> Tara: ' || v_angajat.personal_data.locatie.nume_tara);
    dbms_output.put_line('> Job: ' || v_angajat.job_titlu);
    dbms_output.put_line('> Salariu: ' || v_angajat.salariu);
    
    IF v_angajat.contracte_semnate.count = 0 THEN
        dbms_output.put_line('> Angajatul nu a semnat niciun contract.');
        RETURN;
    END IF;
    
    FOR i IN 1..v_angajat.contracte_semnate.count LOOP
        dbms_output.put_line('--- Contract ' || v_angajat.contracte_semnate(i).titlu_contract || ' ---');
        dbms_output.put_line('> Client: ' || v_angajat.contracte_semnate(i).client_data.nume || ' ' || v_angajat.contracte_semnate(i).client_data.prenume);
        dbms_output.put('> A fost semnat ');
        IF v_angajat.contracte_semnate(i).locatie_semnat.adresa IS NULL THEN
            dbms_output.put('REMOTE');
        ELSE
            dbms_output.put('la ' || v_angajat.contracte_semnate(i).locatie_semnat.adresa || ' ' || v_angajat.contracte_semnate(i).locatie_semnat.oras || ' ' ||
                    v_angajat.contracte_semnate(i).locatie_semnat.nume_tara);
        END IF;
        dbms_output.new_line;
    END LOOP;
END;
/