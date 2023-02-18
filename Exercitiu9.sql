--9. Formulati in limbaj natural o problema pe care sa o rezolvati folosind
--   un subprogram stocat independent de tip procedura care sa utilizeze
--   intr-o singura comanda SQL 5 dintre tabelele definite. Tratati toate
--   exceptiile care pot aparea, incluzand exceptiile NO_DATA_FOUND si
--   TOO_MANY_ROWS. Apelati subprogramul astfel incat sa evidentiati toate
--   cazurile tratate.

--Problema:
--Managerul doreste sa faca iar modificari...
--De data asta are nevoie de informatii despre sediile bancii.
--Dandu-se un nume de tara dorim sa obtinem statistici.
--Daca nu avem sediu in tara respectiva, vrem sa stim cate persoane inregistrate
--locuiesc acolo si diverse detalii despre acestea.
--Daca avem un sediu, vrem sa stim detalii despre contractele semnate la acel sediu.
--Daca avem mai multe sedii, vrem sa stim detalii despre angajatii
--care lucreaza fizic in tara respectiva.


--alternativa ex9 select 1
--SELECT nume, prenume, a.cod_job, cl.tag_utilizator, COUNT(c.cod_persoana) nrConturi, l.oras
--FROM PERSOANA p, LOCATIE l, ANGAJAT a, CLIENT cl, CONT c
--WHERE p.cod_persoana = a.cod_persoana(+) AND cl.cod_persoana(+) = p.cod_persoana
--AND c.cod_persoana(+) = p.cod_persoana AND p.cod_locatie = l.cod_locatie AND l.cod_tara = 1
--GROUP BY p.cod_persoana, nume, prenume, a.cod_job, cl.tag_utilizator, l.oras;

CREATE OR REPLACE PROCEDURE statistici_sedii(p_nume_tara TARA.nume_tara%TYPE)
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
/

EXECUTE statistici_sedii('TaraInexistenta');
EXECUTE statistici_sedii('Japonia');
EXECUTE statistici_sedii('Olanda');
EXECUTE statistici_sedii('Romania');