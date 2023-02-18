--8. Formulati in limbaj natural o problema pe care sa o rezolvati folosind un
--   subprogram stocat independent de tip functie care sa utilizeze intr-o singura
--   comanda SQL 3 dintre tabelele definite. Definiti minim 2 exceptii.
--   Apelati subprogramul astfel incat sa evidentiati toate cazurile tratate.

--Problema:
--PIN-urile cardurilor se uita constant, manager-ul ne-a cerut o metoda de a le recupera
--dupa mai multe criterii.
--1. PIN-ul poate fi cerut de un client, care isi va confirma
--identitatea cu CNP-ul (in mod normal am folosi hash-ul parolei, dar nu avem in model
--deci ne adaptam si presupunem ca CNP-urile se afla la fel de greu ca parolele)
--2. PIN-ul poate fi cerut de un angajat, care se identifica tot cu CNP-ul sau, doar daca
--este admin sau manager.
--Din motive de securitate, daca angajatul lucreaza online ii permitem sa ceara pin-ul
--doar daca are domiciliul in Romania, in caz contrar, se considera ca nu are privilegii.

CREATE OR REPLACE FUNCTION cere_pin(cine_cere PERSOANA.cod_persoana%TYPE, p_card_number CARD.card_number%TYPE, p_cnp PERSOANA.cnp%TYPE)
RETURN CARD.pin%TYPE
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
/

--clientul 1 cere pin-ul pentru cardul sau, folosind cnp-ul corect si numarul de card corect
SELECT cere_pin(1, '4532962746090018', '2870816526255') pin FROM DUAL;

--clientul 1 cere pentru cardul sau, dar cnp-ul este gresit
SELECT cere_pin(1, '4532962746090018', '2870816526256') pin FROM DUAL;

--clientul 1 cere pentru cardul sau, dar numarul de card este gresit
SELECT cere_pin(1, '4532962746090019', '2870816526255') pin FROM DUAL;

--clientul 1 cere pentru cardul altui client
SELECT cere_pin(1, '5336340664664640', '2870816526255') pin FROM DUAL;

--managerul (id 16) cere pentru cardul clientul 1, cu toate datele corecte
SELECT cere_pin(16, '4532962746090018', '1950122298018') pin FROM DUAL;

--managerul (id 16) cere pentru cardul clientul 1, cu cnp-ul gresit
SELECT cere_pin(16, '4532962746090018', '1950122298011') pin FROM DUAL;

--casierul cu id-ul 21 incearca sa obtina pin-ul cardului clientului 1
SELECT cere_pin(21, '4532962746090018', '1950122298018') pin FROM DUAL;

COMMIT;

--pentru a testa card_anonim, facem un card anonim, cel cu cod_number-ul: 5491696102956307
UPDATE CARD SET cod_cont = NULL WHERE card_number LIKE '5491696102956307';

--clientul apeleaza cardul anonim
SELECT cere_pin(1, '5491696102956307', '2870816526255') pin FROM DUAL;

--managerul apeleaza cardul anonim
SELECT cere_pin(16, '5491696102956307', '1950122298018') pin FROM DUAL;

--sa testam si eroarea care "invalideaza" intreaga functie, inexistenta Romaniei
UPDATE TARA SET nume_tara = 'Romania2' WHERE lower(nume_tara) = 'romania';

--clientul 1, cardul sau, date corecte
SELECT cere_pin(1, '4532962746090018', '2870816526255') pin FROM DUAL;

ROLLBACK;