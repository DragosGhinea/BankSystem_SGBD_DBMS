--13. Definiti un pachet care sa detina toate obiectele definite in cadrul proiectului

CREATE OR REPLACE PACKAGE cerinte_proiect
AS
    --ex6
    PROCEDURE activitate_utilizatori(activ_max PLS_INTEGER DEFAULT -1);
    --ex7
    PROCEDURE info_client(tag_utilizator CLIENT.tag_utilizator%TYPE);
    --ex8
    FUNCTION cere_pin(cine_cere PERSOANA.cod_persoana%TYPE, p_card_number CARD.card_number%TYPE, p_cnp PERSOANA.cnp%TYPE) RETURN CARD.pin%TYPE;
    --ex9
    PROCEDURE statistici_sedii(p_nume_tara TARA.nume_tara%TYPE);
END cerinte_proiect;
/


CREATE OR REPLACE PACKAGE BODY cerinte_proiect
AS
    PROCEDURE activitate_utilizatori(activ_max PLS_INTEGER DEFAULT -1)
    AS
        TYPE t_info_user IS RECORD(
            email PERSOANA.email%TYPE,
            username CLIENT.tag_utilizator%TYPE,
            punctaj PLS_INTEGER DEFAULT 0
        );
        
        TYPE t_idx IS TABLE OF t_info_user INDEX BY PLS_INTEGER;
        v_useri t_idx;
        v_index_user PLS_INTEGER;
        
        TYPE t_punctaj IS RECORD(
            cod_persoana PERSOANA.cod_persoana%TYPE,
            punctaj PLS_INTEGER
        );
        
        TYPE t_imb_punctaj IS TABLE OF t_punctaj;
        v_adaos_punctaj t_imb_punctaj; --nu are rost sa initializam, folosim bulk collect
        
        TYPE t_info_user_cu_cod IS RECORD(
            cod_persoana PERSOANA.cod_persoana%TYPE,
            email PERSOANA.email%TYPE,
            username CLIENT.tag_utilizator%TYPE
        );
        
        TYPE t_vector_info_user IS VARRAY(2000) OF t_info_user_cu_cod; --suntem o banca mica, ne ajunge maxim 2000, marim la nevoie
        v_aux_1 t_vector_info_user; --nu are rost sa initializam, folosim bulk collect
    BEGIN
        --ne abtinem din a folosi un ciclu cursor, doar de dragul de a folosi un vector
        SELECT p.cod_persoana, email, tag_utilizator BULK COLLECT INTO v_aux_1 FROM PERSOANA p, CLIENT c WHERE p.cod_persoana = c.cod_persoana;
        
        IF v_aux_1.count = 0 THEN --nu exista utilizatori, nu are rost sa facem calcule
            dbms_output.put_line('Nu exista utilizatori care sa aiba activitate.');
            RETURN;
        END IF;
    
        FOR i IN 1..v_aux_1.count LOOP
            v_useri(v_aux_1(i).cod_persoana).email := v_aux_1(i).email;
            v_useri(v_aux_1(i).cod_persoana).username := v_aux_1(i).username;
        END LOOP;
        
        --calculam punctele din depozite/retrageri/transferuri trimise si stocam in v_adaos_punctaj
        WITH
        tranzactiiPerCont AS (SELECT cod_cont, COUNT(cod_tranzactie) tranzactii
                              FROM TRANZACTIE WHERE DECODE(lower(tip_tranzactie), 'depozit', 1, 'retragere', 1, 'transfer_trimis', 1, 0) = 1
                              GROUP BY cod_cont)
        SELECT c.cod_persoana, SUM(tranzactii) BULK COLLECT INTO v_adaos_punctaj FROM CONT c, tranzactiiPerCont
        WHERE c.cod_cont = tranzactiiPerCont.cod_cont GROUP BY c.cod_persoana;
        
    
        --fiind inserat cu bulk collect, stiu ca este dens
        FOR i IN 1..v_adaos_punctaj.count LOOP
            v_useri(v_adaos_punctaj(i).cod_persoana).punctaj := v_useri(v_adaos_punctaj(i).cod_persoana).punctaj + v_adaos_punctaj(i).punctaj;
            IF activ_max != -1 AND v_useri(v_adaos_punctaj(i).cod_persoana).punctaj>activ_max THEN
                v_useri.delete(v_adaos_punctaj(i).cod_persoana); --pragul superior s-a depasit, nu ne mai intereseaza utilizatorul
            END IF;
        END LOOP;
    
        
        --calculam punctele pentru carduri detinute
        WITH
        carduriPerCont AS (SELECT cod_cont, COUNT(cod_card) carduri FROM CARD GROUP BY cod_cont)
        SELECT c.cod_persoana, SUM(carduri)*5 BULK COLLECT INTO v_adaos_punctaj FROM CONT c, carduriPerCont
        WHERE c.cod_cont = carduriPerCont.cod_cont GROUP BY c.cod_persoana;
        
        --acum va trebui sa verificam si daca exista persoana in lista
        --daca nu exista inseamna ca a fost scoasa pentru ca limita a fost depasita
        --la un pas anterior
        FOR i IN 1..v_adaos_punctaj.count LOOP
            IF NOT v_useri.exists(v_adaos_punctaj(i).cod_persoana) THEN
                CONTINUE;
            END IF;
            
            v_useri(v_adaos_punctaj(i).cod_persoana).punctaj := v_useri(v_adaos_punctaj(i).cod_persoana).punctaj + v_adaos_punctaj(i).punctaj;
            IF activ_max != -1 AND v_useri(v_adaos_punctaj(i).cod_persoana).punctaj>activ_max THEN
                v_useri.delete(v_adaos_punctaj(i).cod_persoana); --pragul superior s-a depasit, nu ne mai intereseaza utilizatorul
            END IF;
        END LOOP;
        
        --schimbam din with in join pe 3 tabele
        SELECT c.cod_persoana, SUM(durata_luni)*2 BULK COLLECT INTO v_adaos_punctaj 
        FROM DEPOZIT_ECONOMII dE, DOBANDA d, CONT c WHERE c.cod_cont = dE.cod_cont AND dE.cod_dobanda = d.cod_dobanda GROUP BY c.cod_persoana;
        
        --neschimbat fata de for-ul anterior
        FOR i IN 1..v_adaos_punctaj.count LOOP
            IF NOT v_useri.exists(v_adaos_punctaj(i).cod_persoana) THEN
                CONTINUE;
            END IF;
            
            v_useri(v_adaos_punctaj(i).cod_persoana).punctaj := v_useri(v_adaos_punctaj(i).cod_persoana).punctaj + v_adaos_punctaj(i).punctaj;
            IF activ_max != -1 AND v_useri(v_adaos_punctaj(i).cod_persoana).punctaj>activ_max THEN
                v_useri.delete(v_adaos_punctaj(i).cod_persoana); --pragul superior s-a depasit, nu ne mai intereseaza utilizatorul
            END IF;
        END LOOP;
        
        IF v_useri.first IS NULL THEN
            dbms_output.put_line('Nu exista utilizatori care sa aiba activitate.');
            RETURN;
        END IF;
        
        dbms_output.put_line('=========== Puncte de activitate =============');
        v_index_user := v_useri.first;
        WHILE v_index_user IS NOT NULL LOOP
            dbms_output.put_line('> ' || v_useri(v_index_user).username || ' (' || v_useri(v_index_user).email || ') - ' || v_useri(v_index_user).punctaj);
            v_index_user := v_useri.next(v_index_user);
        END LOOP;
    END;

    PROCEDURE info_client(tag_utilizator CLIENT.tag_utilizator%TYPE)
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

    FUNCTION cere_pin(cine_cere PERSOANA.cod_persoana%TYPE, p_card_number CARD.card_number%TYPE, p_cnp PERSOANA.cnp%TYPE) RETURN CARD.pin%TYPE
    AS
        cnp_gresit_angajat EXCEPTION;
        cnp_gresit_client EXCEPTION;
        nu_detine_cont EXCEPTION; --are cnp-ul, are cardul, dar nu e detinatorul
        fara_privilegii EXCEPTION; --este angajat, dar nu este admin sau manager
        card_anonim EXCEPTION; --cardul exista dar nu e asociat unui cont, doar angajatii pot face rost de pin
        card_negasit EXCEPTION;
        PRAGMA EXCEPTION_INIT(card_negasit, -20010);
        
        v_cod_tara TARA.cod_tara%TYPE;
        v_cod_tara2 TARA.cod_tara%TYPE;
        v_cod_persoana PERSOANA.cod_persoana%TYPE;
        v_cod_cont CONT.cod_cont%TYPE;
        v_pin CARD.pin%TYPE;
        
        v_cod_sediu SEDIU.cod_sediu%TYPE;
        v_cnp PERSOANA.cnp%TYPE;
        v_aux PLS_INTEGER;
        v_aux2 PLS_INTEGER;
    BEGIN
        GOTO inceput;
        <<verificare_angajat>>
        --folosim count ca sa nu dea NO_DATA_FOUND
        --COUNT() poate da doar 0 sau 1 in acest caz pentru ca avem cine_cere cheie primara
        SELECT MAX(a.cod_sediu), MAX(l.cod_tara), MAX(p.cnp), COUNT(a.cod_persoana), MAX(DECODE(UPPER(a.cod_job), 'MANAGER', 1, 'ADMIN', 1, 0))
        INTO v_cod_sediu, v_cod_tara2, v_cnp, v_aux, v_aux2
        FROM ANGAJAT a, PERSOANA p, LOCATIE l
        WHERE p.cod_persoana = cine_cere AND a.cod_persoana = cine_cere AND p.cod_locatie = l.cod_locatie;
        
        IF v_aux = 0 THEN --nu exista angajatul
            IF v_cod_cont IS NULL THEN --cardul este anonim
                RAISE card_anonim;
            ELSE --angajatul nu exista dar un proprietar are daca a ajuns aici
                RAISE nu_detine_cont;
            END IF;
        ELSIF v_aux2 = 0 OR (v_cod_sediu IS NULL AND v_cod_tara2 != v_cod_tara) THEN --angajatul exista, dar nu este admin sau manager valid
            RAISE fara_privilegii;
        ELSIF v_cnp != p_cnp THEN --e angajat cu privilegii, dar n-a trecut validarea identitatii
            RAISE cnp_gresit_angajat;
        ELSE --in sfarsit a trecut si el toate validarile
            RETURN v_pin;
        END IF;
        
        <<inceput>>
        SELECT cod_tara INTO v_cod_tara FROM TARA WHERE lower(nume_tara) LIKE 'romania';
        
        BEGIN
            SELECT cod_cont, pin INTO v_cod_cont, v_pin FROM CARD WHERE card_number LIKE p_card_number;
            IF v_cod_cont IS NULL THEN
                --este un card anonim, verificam daca este angajat valid, altfel erori
                
                --acolo va da fie eroare fie return
                GOTO verificare_angajat;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20010, 'Cardul introdus nu exista.');
        END;
        
        --daca a ajuns aici, card-ul are un cont asociat
        BEGIN
            --luam persoana care detine contul
            SELECT p.cod_persoana, cnp INTO v_cod_persoana, v_cnp FROM PERSOANA p, CONT c WHERE p.cod_persoana = c.cod_persoana AND c.cod_cont = v_cod_cont;
            
            IF v_cod_persoana != cine_cere THEN
                GOTO verificare_angajat;
            ELSIF v_cnp != p_cnp THEN
                RAISE cnp_gresit_client;
            END IF;
        EXCEPTION
            --nu ar trebui sa se intample datorita cheilor externe, stiind ca v_cod_cont este nenul.
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20011, 'Detinatorul cardului este definit dar cumva nu exista');
        END;
        RETURN v_pin;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20012, 'Romania nu se afla in lista tarilor, reparati.');
        WHEN cnp_gresit_angajat THEN
            RAISE_APPLICATION_ERROR(-20013, 'Validarea identificarii angajatului a esuat.');
        WHEN cnp_gresit_client THEN
            RAISE_APPLICATION_ERROR(-20014, 'Validarea identificarii clientului a esuat.');
        WHEN nu_detine_cont THEN
            RAISE_APPLICATION_ERROR(-20015, 'Persoana nu este angajat si nici nu detine contul asociat cardului introdus.');
        WHEN fara_privilegii THEN
            RAISE_APPLICATION_ERROR(-20016, 'Angajatul nu are privilegiile necesare de a obtine PIN-ul acestui card.');
        WHEN card_anonim THEN
            RAISE_APPLICATION_ERROR(-20017, 'Cardul este anonim, iar utilizatorul nu este un angajat.');
        WHEN card_negasit THEN
            RAISE_APPLICATION_ERROR(-20018, 'Numarul introdus nu corespunde niciunui card.');
    
        WHEN OTHERS THEN
            RAISE;
    END;

    PROCEDURE statistici_sedii(p_nume_tara TARA.nume_tara%TYPE)
    AS
        v_cod_tara TARA.cod_tara%TYPE;
        tara_inexistenta EXCEPTION;
        v_cod_sediu SEDIU.cod_sediu%TYPE;
        
        v_aux PLS_INTEGER;
    BEGIN
        BEGIN
            SELECT cod_tara INTO v_cod_tara FROM TARA WHERE nume_tara = p_nume_tara;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE tara_inexistenta;
            --nu poate da TOO_MANY_ROWS, am pus UNIQUE pe nume_tara
        END;
        
        SELECT cod_sediu INTO v_cod_sediu FROM SEDIU s, LOCATIE l WHERE s.cod_locatie = l.cod_locatie AND l.cod_tara = v_cod_tara;
        dbms_output.put_line('Un sediu gasit in tara ' || INITCAP(p_nume_tara));
        dbms_output.put_line('La sediul din aceasta tara au fost semnate urmatoarele contracte: ');
        FOR v_detalii_contract IN (SELECT p1.nume angajat_nume, p1.prenume angajat_prenume, a.cod_job, p2.nume client_nume, p2.prenume client_prenume, c.tag_utilizator tag_client, c2.titlu_contract
            FROM SEMNEAZA_UN_CONTRACT s, ANGAJAT a, CLIENT c, TIP_CONTRACT c2, PERSOANA p1, PERSOANA p2
            WHERE s.cod_client = c.cod_persoana AND s.cod_angajat = a.cod_persoana AND s.tip_contract = c2.tip_contract
            AND p1.cod_persoana = a.cod_persoana AND p2.cod_persoana = c.cod_persoana AND s.cod_sediu = v_cod_sediu)
        LOOP
            dbms_output.put_line('> Contract de ''' || v_detalii_contract.titlu_contract || ''' pentru clientul ' || v_detalii_contract.client_nume || ' ' || v_detalii_contract.client_prenume
                || '(' || v_detalii_contract.tag_client || ') semnat de angajatul ' || v_detalii_contract.angajat_nume || ' ' || v_detalii_contract.angajat_prenume
                || '(' || v_detalii_contract.cod_job || ')'
            );
        END LOOP;
        
    EXCEPTION
        WHEN tara_inexistenta THEN
            dbms_output.put_line('Oops, tara introdusa nu se afla in baza de date.');
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('> Nu s-a gasit niciun sediu in tara ' || INITCAP(p_nume_tara));
            dbms_output.put_line('In aceasta tara avem inregistrati utilizatorii: ');
            --daca nu considerati ca aceasta este o singura instructiune
            --care contine 5 tabele pentru ca sunt subcereri
            --aveti <<alternativa ex9 select 1>> mai sus care e doar join-uri
            --si returneaza acelasi lucru
            v_aux := 0;
            FOR v_detalii_persoana IN (SELECT nume, prenume,
                (SELECT cod_job FROM ANGAJAT a WHERE a.cod_persoana(+) = p.cod_persoana) cod_job,
                (SELECT tag_utilizator FROM CLIENT cl WHERE cl.cod_persoana(+) = p.cod_persoana) tag_utilizator,
                (SELECT COUNT(cod_cont) FROM CONT c WHERE c.cod_persoana = p.cod_persoana) nrConturi,
                l.oras
                FROM PERSOANA p, LOCATIE l WHERE p.cod_locatie = l.cod_locatie AND l.cod_tara = v_cod_tara)
            LOOP
                dbms_output.put('>> ' || v_detalii_persoana.nume || ' ' || v_detalii_persoana.prenume || ' ');
                IF v_detalii_persoana.tag_utilizator IS NOT NULL THEN
                    dbms_output.put('este client (cu tag-ul ''' || v_detalii_persoana.tag_utilizator ||  '''), ');
                END IF;
                IF v_detalii_persoana.cod_job IS NOT NULL THEN
                    dbms_output.put('este angajat (avand job-ul cu codul ''' || v_detalii_persoana.cod_job || '''), ');
                END IF;
                dbms_output.put('are ' || v_detalii_persoana.nrConturi || ' conturi si este din orasul ' || v_detalii_persoana.oras);
                dbms_output.new_line;
                v_aux := v_aux + 1;
            END LOOP;
            IF v_aux = 0 THEN
                dbms_output.put_line('Nu exista utilizatori inregistrati in aceasta tara.');
            ELSE
                dbms_output.put_line('Un total de ' || v_aux || ' utilizatori inregistrati in aceasta tara.');
            END IF;
        WHEN TOO_MANY_ROWS THEN
            dbms_output.put_line('> In tara ' || INITCAP(p_nume_tara) || ' exista mai multe sedii.');
            dbms_output.put_line('Activitatea angajatilor care lucreaza fizic in aceasta tara: ');
            v_aux := 0;
            FOR v_detalii_angajat IN (
                SELECT nume, prenume, denumire_job,
                    (SELECT COUNT(cod_persoana) FROM TRANZACTIE_EXTERNA t WHERE t.cod_persoana = a.cod_persoana) nrTranzactiiExterne,
                    (SELECT COUNT(cod_angajat) FROM SEMNEAZA_UN_CONTRACT sc WHERE sc.cod_angajat = a.cod_persoana) nrContracte
                FROM ANGAJAT a, PERSOANA p, JOB j, SEDIU s, LOCATIE l
                WHERE p.cod_persoana = a.cod_persoana AND j.cod_job = a.cod_job
                AND a.cod_sediu = s.cod_sediu AND s.cod_locatie = l.cod_locatie
                AND l.cod_tara = v_cod_tara)
            LOOP
                dbms_output.put_line('> Angajatul ' || v_detalii_angajat.nume || ' ' || v_detalii_angajat.prenume || ' este ' || v_detalii_angajat.denumire_job
                    || ', a efectuat ' || v_detalii_angajat.nrTranzactiiExterne || ' tranzactii externe si a semnat ' || v_detalii_angajat.nrContracte || ' contracte.'
                );
                v_aux := 1;
            END LOOP;
            IF v_aux = 0 THEN
                dbms_output.put_line('Nu exista angajati in aceasta tara.');
            END IF;
    END;

END cerinte_proiect;
/

EXECUTE cerinte_proiect.activitate_utilizatori;
--lipsesc melis2_ si mihaita
EXECUTE cerinte_proiect.activitate_utilizatori(100);

EXECUTE cerinte_proiect.info_client('UnUserInexistent_');
EXECUTE cerinte_proiect.info_client('melis2_');

--clientul 1 cere pin-ul pentru cardul sau, folosind cnp-ul corect si numarul de card corect
SELECT cerinte_proiect.cere_pin(1, '4532962746090018', '2870816526255') pin FROM DUAL;
--clientul 1 cere pentru cardul sau, dar cnp-ul este gresit
SELECT cerinte_proiect.cere_pin(1, '4532962746090018', '2870816526256') pin FROM DUAL;
--managerul (id 16) cere pentru cardul clientul 1, cu toate datele corecte
SELECT cerinte_proiect.cere_pin(16, '4532962746090018', '1950122298018') pin FROM DUAL;

EXECUTE cerinte_proiect.statistici_sedii('TaraInexistenta');
EXECUTE cerinte_proiect.statistici_sedii('Japonia');
EXECUTE cerinte_proiect.statistici_sedii('Olanda');
EXECUTE cerinte_proiect.statistici_sedii('Romania');