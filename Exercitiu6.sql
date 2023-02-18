--6. Formulati in limbaj natural o problema pe care sa o rezolvati folosind
--   un subprogram stocat independent care sa utilizeze doua tipuri diferite
--   de colectii studiate. Apelati subprogramul.

--Problema:
--Manager-ul vrea sa incerce o noua strategie de marketing.
--El vrea sa motiveze persoanele inactive sa foloseasca serviciile bancii mai mult asa ca
--acesta propune trimiterea de mail-uri cu oferte in functie de activitatea clientilor.
--Activitatea utilizatorului va fi un total de puncte, calculat astfel:
--  - 1 punct pentru fiecare depozit/retragere/transfer_trimis
--  - 5 puncte pentru fiecare card detinut
--  - 2 puncte * numarul de luni pe care este facut un depozit de economii
--Faceti o procedura si afisati email-ul, username-ul si punctajul clientilor pentru a
--oferi manager-ului informatii despre activitatea utilizatorilor.
--Procedura poate sa primeasca ca parametru un numar pozitiv reprezentand un prag superior,
--urmand sa se afiseze doar clientii cu punctajul mai mic sau egal cu cel dat ca parametru.


CREATE OR REPLACE PROCEDURE activitate_utilizatori(activ_max PLS_INTEGER DEFAULT -1)
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
/

EXECUTE activitate_utilizatori;
--lipsesc melis2_ si mihaita
EXECUTE activitate_utilizatori(100);