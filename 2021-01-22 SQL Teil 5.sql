-- 05.12.2020

-- SELECT

-- Daten aus einer Tabelle:
SELECT artnr, bezeichnung, vkpreis, ekpreis
FROM artikel;

-- besser: mit Schema-Angabe als Präfix
SELECT artnr, bezeichnung, vkpreis, ekpreis
FROM wawi.artikel;

-- SELECT ohne FROM?
SELECT NOW();
SELECT CURRENT_USER();


-- Alle Spalten einer Tabelle ausgeben: *
SELECT *
FROM wawi.personal;


DESC wawi.personal;


-- Ausdrücke in der SELECT-Klausel nutzen

SELECT artnr, bezeichnung, vkpreis, ekpreis, mwst
FROM wawi.artikel;

-- > netto VK errechnen:
SELECT artnr, bezeichnung, vkpreis, ekpreis, mwst, vkpreis / (100 + mwst) * 100
FROM wawi.artikel;

SELECT 	artnr, bezeichnung, vkpreis, ekpreis, mwst, 
		ROUND(vkpreis / (100 + mwst) * 100, 2) 
FROM wawi.artikel;

-- mit Aliasname
SELECT 	artnr, bezeichnung, vkpreis AS vk_brutto,
		ROUND(vkpreis / (100 + mwst) * 100, 2) AS vk_netto,
		ekpreis, mwst
FROM wawi.artikel;

-- AS ist optional (leider ...)
SELECT 	artnr, bezeichnung, vkpreis vk_brutto,
		ROUND(vkpreis / (100 + mwst) * 100, 2) vk_netto,
		ekpreis, mwst
FROM wawi.artikel;

-- Achtung:
SELECT	artnr, bezeichnung, gruppe, ekpreis
		vkpreis, mwst, lief, lieferzeit				-- > hier wird "vkpreis" zum Alias, weil Komma nach ekpreis fehlt :-(((
FROM wawi.artikel;



 -- Übungsbeispiel: Gesamtpreis für jede Zeile (menge, preis, rabatt)
 SELECT * FROM wawi.bestellpositionen;
 
 SELECT bestnr, pos, artikel, text AS bezeichnung,
		menge, preis, rabatt, 
        ROUND(menge * preis * (100 - rabatt) / 100, 2) AS gesamtpreis
 FROM wawi.bestellpositionen;
 
 
-- Stringoperationen

-- Beispiel: Akad + VN + NN in Grossbuchstaben

SELECT 	persnr, nachname, vorname, akadgrad,
		CONCAT(akadgrad, ' ', vorname, ' ', nachname) AS gesamtname
FROM wawi.personal;

-- Achtung: NULL in Ausdrücken
SELECT 1 + 4 + 3 + 0 AS acht, 1 + 4 + 3 + NULL AS auch_acht_oje_leider_nicht;

-- NULL unterdrücken:
-- > MySQL: IFNULL(wert, ersatzwert)  --> Wenn(wert = NULL; ersatzwert; wert)
-- > MS SQL Server: ISNULL(wert, ersatzwert)  
-- > Oracle: NVL(wert, ersatzwert)  
-- > MS Access: NZ(wert, ersatzwert)  
 
SELECT 1 + 4 + 3 + 0 AS acht, 1 + 4 + 3 + IFNULL(NULL, 0) AS doch_auch_acht;

DESC wawi.personal;

SELECT 	persnr, nachname, vorname, akadgrad,
		CONCAT(IFNULL(akadgrad, ''), ' ', vorname, ' ', nachname) AS gesamtname
FROM wawi.personal;
 
-- Variante 1: GLÄTTEN() / TRIM() 
SELECT 	persnr, nachname, vorname, akadgrad,
		TRIM(CONCAT(IFNULL(akadgrad, ''), ' ', vorname, ' ', UPPER(nachname))) AS gesamtname
FROM wawi.personal;

-- Variante 2: NULL nutzen, um ' ' zu "schlucken"
SELECT 	persnr, nachname, vorname, akadgrad,
		CONCAT(IFNULL(CONCAT(akadgrad, ' '), ''), vorname, ' ', UPPER(nachname)) AS gesamtname
FROM wawi.personal;



-- Berechnung mit Datumswerten

SELECT 	persnr, nachname, vorname, gebdatum, eintritt,
		TIMESTAMPDIFF(YEAR, gebdatum, NOW()) AS "alter",
        DATE_ADD(eintritt, INTERVAL 15 YEAR) AS jubilaeum
FROM wawi.personal;

-- Uhrzeit entfernen:
SELECT 	persnr, nachname, vorname, 
		CAST(gebdatum AS date) AS gebdatum, 
		TIMESTAMPDIFF(YEAR, gebdatum, NOW()) AS "alter",
		CAST(eintritt AS date) AS eintritt,        
        DATE_ADD(CAST(eintritt AS date), INTERVAL 15 YEAR) AS jubilaeum
FROM wawi.personal;


-- Sortierung: ORDER BY
SELECT 	persnr, nachname, vorname, 
		CAST(gebdatum AS date) AS gebdatum, 
		TIMESTAMPDIFF(YEAR, gebdatum, NOW()) AS "alter",
		CAST(eintritt AS date) AS eintritt,        
        DATE_ADD(CAST(eintritt AS date), INTERVAL 15 YEAR) AS jubilaeum
FROM wawi.personal
-- ORDER BY gebdatum;
ORDER BY eintritt DESC, nachname;


-- Filtern mit WHERE

-- Artikel mit einem VK-Preis ab 400,--

SELECT artnr, bezeichnung, vkpreis, ekpreis, gruppe
FROM wawi.artikel
WHERE vkpreis >= 400
ORDER BY vkpreis;

SELECT artnr, bezeichnung, vkpreis, ekpreis, gruppe
FROM wawi.artikel
WHERE vkpreis >= '400'	-- > eigentlich falsch, funktioniert aber ;-)
ORDER BY vkpreis;

SELECT artnr, bezeichnung, vkpreis, ekpreis, gruppe
FROM wawi.artikel
WHERE vkpreis >= '4x00'	-- > eigentlich falsch, funktioniert aber ;-)
ORDER BY vkpreis;


-- Mehrere Kriterien: AND, OR

SELECT artnr, bezeichnung, vkpreis, ekpreis, gruppe
FROM wawi.artikel
WHERE vkpreis >= 4.5 AND vkpreis <= 10
ORDER BY vkpreis;


-- Filtern nach Charakter-Spalten
SELECT artnr, bezeichnung, vkpreis, ekpreis, gruppe
FROM wawi.artikel
WHERE gruppe = 'BE';

SELECT artnr, bezeichnung, vkpreis, ekpreis, gruppe
FROM wawi.artikel
WHERE gruppe = 'be';

-- Besteck und Geschirr (BE, GE)
SELECT artnr, bezeichnung, vkpreis, ekpreis, gruppe
FROM wawi.artikel
WHERE gruppe = 'be' OR gruppe = 'ge'
ORDER BY vkpreis, bezeichnung;


-- Datum: Eingabe als Char! Format: ISO-Format YYYY-MM-DD
 
SELECT persnr, nachname, vorname, gebdatum
FROM wawi.personal
WHERE gebdatum >= '1980-01-01'
ORDER BY gebdatum;


-- Beispiel
-- Welche Mitarbeiter(innen) aus der Abteilg Verkauf (VK), sind 2007 eingestellt worden?
-- > nr, nn, vn, eintritt

SELECT persnr, nachname, vorname, eintritt
FROM wawi.personal
WHERE abtlg = 'vk' 
AND eintritt >= '2007-01-01' 
AND eintritt < '2008-01-01'
ORDER BY eintritt;

SELECT persnr, nachname, vorname, eintritt
FROM wawi.personal
WHERE abtlg = 'vk' 
AND eintritt >= '2007-01-01' 
AND eintritt <= '2007-12-31'
ORDER BY eintritt;

SELECT persnr, nachname, vorname, eintritt
FROM wawi.personal
WHERE eintritt = '2007-07-01';  -- > '2007-07-01 00:00:00'

SELECT persnr, nachname, vorname, eintritt
FROM wawi.personal
WHERE eintritt = '2007-07-01 08:00:00';

-- Achtung bei Uhrzeiten: eventuell gibt es Uhrzeit(en)!
SELECT persnr, nachname, vorname, eintritt
FROM wawi.personal
WHERE eintritt >= '2007-07-01' AND eintritt < '2007-07-02';


-- Spezielle Operatoren

-- LIKE

-- Artikel, deren Bezeichnung mit "Koch" beginnt
SELECT artnr, bezeichnung, vkpreis, gruppe
FROM wawi.artikel
WHERE bezeichnung LIKE 'koch%'
ORDER BY bezeichnung;


-- Artikel, deren Bezeichnung auf "Koch" endet
SELECT artnr, bezeichnung, vkpreis, gruppe
FROM wawi.artikel
WHERE bezeichnung LIKE '%koch'
ORDER BY bezeichnung;

-- Artikel, deren Bezeichnung "Koch" enthält
SELECT artnr, bezeichnung, vkpreis, gruppe
FROM wawi.artikel
WHERE bezeichnung LIKE '%koch%'
ORDER BY bezeichnung;

-- Artikel, deren Bezeichnung "Koch" enthält, aber nicht am Beginn und Ende
SELECT artnr, bezeichnung, vkpreis, gruppe
FROM wawi.artikel
WHERE bezeichnung LIKE '%_koch%_'
ORDER BY bezeichnung;


-- > Artikel 'Kochschürze mit Muster Kochmesser'
-- > ... und dieser soll NICHT dabei sein:
SELECT artnr, bezeichnung, vkpreis, gruppe
FROM wawi.artikel
WHERE bezeichnung LIKE '%koch%' AND bezeichnung NOT LIKE 'koch%' AND bezeichnung NOT LIKE '%koch' 
ORDER BY bezeichnung;


-- #########################################################################################################
-- 11.12.2020 Teil 2


-- > Grundsatz für DW-Developer: immer nur das auslesen, was gerade benötigt wird

-- > z.B: Sie benötigen in Ihrem Frontend die Information, was jeweils der aktuelle VK von den Artikeln mit den 
--        Artikelnummern 1234, 1579 und 1248 

-- > ganz schlecht:
SELECT *
FROM wawi.artikel;

-- > besser:
SELECT artnr, vkpreis
FROM wawi.artikel;

SELECT *
FROM wawi.artikel
WHERE artnr = 1234 OR artnr = 1579 OR artnr = 1248;

-- > optimal
SELECT artnr, vkpreis
FROM wawi.artikel
WHERE artnr = 1234 OR artnr = 1579 OR artnr = 1248
ORDER BY artnr;


-- Mustervergleiche mit LIKE

-- > Bsp.: Kunden aus der Steiermark mit ihrer Adresse

SELECT *
FROM wawi.kunden;

SELECT kdnr, nachname, vorname, land, plz, ort, strasse
FROM wawi.kunden
WHERE plz LIKE '8%' AND land = 'A'
ORDER BY nachname;

SELECT kdnr, nachname, vorname, land, plz, ort, strasse
FROM wawi.kunden
WHERE plz LIKE '8%' AND land LIKE 'A'
ORDER BY nachname;

SELECT kdnr, nachname, vorname, land, plz, ort, strasse
FROM wawi.kunden
WHERE plz NOT LIKE '8%' AND land LIKE 'A'
ORDER BY nachname;



-- Alle Mitarbeiter(innen), die in den 70ern geboren sind
SELECT persnr, nachname, vorname, gebdatum
FROM wawi.personal
WHERE gebdatum LIKE '197%';

SELECT persnr, nachname, vorname, gebdatum
FROM wawi.personal
WHERE gebdatum >= '1970-01-01' AND gebdatum <= '1979-12-31';

SELECT persnr, nachname, vorname, gebdatum
FROM wawi.personal
WHERE gebdatum >= '1970-01-01' AND gebdatum < '1980-01-01';

SELECT persnr, nachname, vorname, gebdatum
FROM wawi.personal
WHERE gebdatum >= 1970 AND gebdatum < 1980; 	-- > keine gute Idee, da impliziter Cast

SELECT CAST(1970 AS datetime);
SELECT CAST('1970-01-01' AS datetime);

SELECT date_format(gebdatum, '%d.%m.%Y') FROM wawi.personal;


-- Werterbereiche filtern: BETWEEN

SELECT persnr, nachname, vorname, gebdatum
FROM wawi.personal
WHERE gebdatum BETWEEN '1970-01-01' AND '1979-12-31';

-- Artikel mit einem Preis von 35 bis 60 Euro
SELECT artnr, bezeichnung, gruppe, vkpreis
FROM wawi.artikel
WHERE vkpreis BETWEEN 35 and 60
ORDER BY vkpreis, bezeichnung;

-- Gegenteil: NOT
SELECT artnr, bezeichnung, gruppe, vkpreis
FROM wawi.artikel
WHERE vkpreis NOT BETWEEN 35 and 60
ORDER BY vkpreis, bezeichnung;


-- Mitarbeiter(innen) aus den Abteilungen Marketing (MA), Einkauf (EK),
-- Verkauf (VK) und der Geschäftsleitung (GL)

SELECT persnr, nachname, vorname, abtlg
FROM wawi.personal
WHERE abtlg = 'ma' OR abtlg = 'ek' OR abtlg = 'vk' OR abtlg = 'gl'
ORDER BY abtlg, nachname;

SELECT persnr, nachname, vorname, abtlg
FROM wawi.personal
WHERE abtlg IN('ma','ek','vk','gl')
ORDER BY abtlg, nachname;

SELECT persnr, nachname, vorname, abtlg
FROM wawi.personal
WHERE abtlg NOT IN('ma','ek','vk','gl')
ORDER BY abtlg, nachname;


-- NULL-Werte filtern: IS NULL bzw. IS NOT NULL

-- Kunden, bei denen keine E-Mailadresse hinterlegt ist
SELECT kdnr, vorname, nachname, email
FROM wawi.kunden
WHERE email IS NULL;

SELECT kdnr, vorname, nachname, email
FROM wawi.kunden
WHERE email IS NOT NULL;

-- Akademiker untern Kunden
SELECT kdnr, vorname, nachname, akadgrad
FROM wawi.kunden
WHERE akadgrad IS NOT NULL;

-- > NULL <> '' <> 0
SELECT kdnr, vorname, nachname, akadgrad
FROM wawi.kunden
WHERE akadgrad IS NOT NULL;

UPDATE wawi.kunden
SET akadgrad = ''
WHERE kdnr = 130;

SELECT kdnr, vorname, nachname, akadgrad
FROM wawi.kunden
WHERE akadgrad IS NULL OR akadgrad = '';

SELECT kdnr, vorname, nachname, akadgrad
FROM wawi.kunden
WHERE NOT (akadgrad IS NULL OR akadgrad = '');


-- OR vs. XOR

SELECT bezeichnung
FROM wawi.artikel
WHERE bezeichnung LIKE 'koch%'
OR bezeichnung LIKE '%pfanne%';

SELECT bezeichnung
FROM wawi.artikel
WHERE bezeichnung LIKE 'koch%'
XOR bezeichnung LIKE '%pfanne%';

-- Variante A
SELECT bezeichnung
FROM wawi.artikel
WHERE bezeichnung LIKE 'koch%' AND bezeichnung NOT LIKE '%pfanne%'
OR bezeichnung NOT LIKE 'koch%' AND bezeichnung LIKE '%pfanne%';

-- Variante B
SELECT bezeichnung
FROM wawi.artikel
WHERE (bezeichnung LIKE 'koch%' AND bezeichnung NOT LIKE '%pfanne%')
OR (bezeichnung NOT LIKE 'koch%' AND bezeichnung LIKE '%pfanne%');


-- Filtern mit mehreren Kriterien

-- Bsp.: Artikel der Gruppen Besteck (BE), Geschirr (GE) und Küchengeschirr (KG),
-- 	     mit einem Preis von 20,-- bis 40,-- sowie Gartenartikel (GA) und
--       Heimwerkerartikel (HW) mit einem Preis unter 40 sowie über 100,-- und
--       schließlich Haushaltsartikel (HH), die mindestens 60,-- kosten.
--       Sortiert nach Artikelgruppe, Preis und Bezeichnung

SELECT artnr, bezeichnung, gruppe, vkpreis
FROM wawi.artikel
WHERE (gruppe = 'BE' OR gruppe = 'GE' OR gruppe = 'KG') AND vkpreis >= 20 AND vkpreis <= 40
OR (gruppe = 'GA' OR gruppe = 'HW') AND (vkpreis < 40 OR vkpreis > 100)
OR gruppe = 'HH' AND vkpreis >= 60
ORDER BY gruppe, vkpreis, bezeichnung;

-- Variante
SELECT artnr, bezeichnung, gruppe, vkpreis
FROM wawi.artikel
WHERE gruppe IN('BE','GE','KG') AND vkpreis BETWEEN 20 AND 40
OR gruppe IN('GA','HW') AND vkpreis NOT BETWEEN 40 AND 100
OR gruppe = 'HH' AND vkpreis >= 60
ORDER BY gruppe, vkpreis, bezeichnung;


-- Anzahl der angezeigten Ergebniszeilen einschränken: LIMIT

SELECT *
FROM wawi.artikel
LIMIT 10;

SELECT *
FROM wawi.artikel;

SELECT * FROM wawi.artikel LIMIT 10;
SELECT * FROM wawi.artikel ORDER BY artnr LIMIT 0,10;
SELECT * FROM wawi.artikel ORDER BY artnr LIMIT 10,10;
SELECT * FROM wawi.artikel ORDER BY artnr LIMIT 20,10;		-- > Z.B. für Paging

-- Welche 4 Mitarbeiter sind zuletzt eingestellt worden?
SELECT persnr, nachname, vorname, eintritt
FROM wawi.personal
ORDER BY eintritt DESC
LIMIT 4;

SELECT persnr, nachname, vorname, eintritt
FROM wawi.personal
ORDER BY eintritt 
LIMIT 4;

SELECT persnr, nachname, vorname, eintritt, akadgrad
FROM wawi.personal
ORDER BY akadgrad, nachname
LIMIT 7, 5;



-- mehrere Tabellen verwenden

SELECT artnr, bezeichnung, gruppe, vkpreis
FROM wawi.artikel
WHERE vkpreis >= 15
ORDER BY bezeichnung;

SELECT * FROM wawi.artikelgruppen;


SELECT artnr, bezeichnung, gruppe, vkpreis, grtext
FROM wawi.artikel INNER JOIN wawi.artikelgruppen ON gruppe = artgr
WHERE vkpreis >= 15
ORDER BY bezeichnung;


SELECT artnr, bezeichnung, vkpreis, grtext AS artikelgruppe
FROM wawi.artikel INNER JOIN wawi.artikelgruppen ON gruppe = artgr
WHERE vkpreis >= 15
ORDER BY bezeichnung;


-- Achtung bei Namensgleichheit von Spalten

SELECT kdnr, nachname, vorname, intcode
FROM wawi.kunden INNER JOIN wawi.kundeninteressen ON kdnr = kdnr
ORDER BY nachname;

-- Minimallösung: Tabellennamen voranstellen
SELECT wawi.kunden.kdnr, nachname, vorname, intcode
FROM wawi.kunden INNER JOIN wawi.kundeninteressen ON wawi.kunden.kdnr = wawi.kundeninteressen.kdnr
ORDER BY nachname;

-- Empfehlung: Tabellennamen bei Allen voranstellen
SELECT wawi.kunden.kdnr, wawi.kunden.nachname, wawi.kunden.vorname, wawi.kundeninteressen.intcode AS interesse
FROM wawi.kunden INNER JOIN wawi.kundeninteressen ON wawi.kunden.kdnr = wawi.kundeninteressen.kdnr
ORDER BY wawi.kunden.nachname;

-- Optimal: Tabellenaliasnamen nutzen :-)
SELECT k.kdnr, k.nachname, k.vorname, i.intcode AS interesse
FROM wawi.kunden k INNER JOIN wawi.kundeninteressen i ON k.kdnr = i.kdnr
ORDER BY k.nachname;


-- Reihenfolge von Tabellen und Spalten ist frei tauschbar ...
SELECT k.kdnr, k.nachname, k.vorname, i.intcode AS interesse
FROM wawi.kundeninteressen i INNER JOIN wawi.kunden k ON k.kdnr = i.kdnr
ORDER BY k.nachname;

SELECT k.kdnr, k.nachname, k.vorname, i.intcode AS interesse
FROM wawi.kundeninteressen i INNER JOIN wawi.kunden k ON i.kdnr = k.kdnr
ORDER BY k.nachname;


-- Artikel mit den Namen der Lieferanten
-- > artnr, bezeichnung, ekpreis, lieferant
-- SELECT * FROM wawi.artikel WHERE lief != 1001;
SELECT * FROM wawi.artikel;
SELECT * FROM wawi.lieferanten;

SELECT a.artnr, a.bezeichnung, a.ekpreis, l.firma1, l.firma2
FROM wawi.artikel a INNER JOIN wawi.lieferanten l ON a.lief = l.liefnr
ORDER BY a.bezeichnung;

SELECT a.artnr, a.bezeichnung, a.ekpreis, CONCAT(l.firma1, IFNULL(CONCAT(' ', l.firma2), '')) AS lieferant
FROM wawi.artikel a INNER JOIN wawi.lieferanten l ON a.lief = l.liefnr
ORDER BY a.bezeichnung;


-- Bestellungen und Personal

SELECT p.persnr, p.nachname, p.vorname, p.abtlg, b.bestnr, b.datum
FROM wawi.bestellungen b INNER JOIN wawi.personal p ON b.bearbeiter = p.persnr
ORDER BY b.bestnr;

-- ##############################################################################################################
-- 12.12.2020 Teil 3

SELECT * FROM wawi.bestellungen;
SELECT * FROM wawi.bestellpositionen;

SELECT b.bestnr, b.datum, p.pos, p.text AS artikel, p.menge
FROM wawi.bestellungen b INNER JOIN wawi.bestellpositionen p ON b.bestnr = p.bestnr
ORDER BY b.bestnr, p.pos;



-- Beispiel: Bestände der Artikel
-- Tabellen: artikel, lagerstand
-- Spalten: artnr, bez, gruppe, ek, lagnr, menge, optional: bestandswert


SELECT a.artnr, a.bezeichnung, a.gruppe, a.ekpreis, l.lagnr, l.menge, a.ekpreis * l.menge AS bestandswert
FROM wawi.artikel a INNER JOIN wawi.lagerstand l ON a.artnr = l.artnr
ORDER BY a.artnr, l.lagnr;



-- JOIN mit mehr als 2 Tabellen

-- Wer aus welcher Abteilung hat wann, was bei wem gestellt?
-- > Tabellen: personal, abteilungen, anrede, bestellungen, bestellpositionen, lieferanten
SELECT * FROM wawi.anreden;


SELECT 	a.text AS anrede, p.vorname, p.nachname, ab.text AS abteilung, b.datum,
		bp.artikel, bp.text AS artikelbezeichnung, bp.menge,
        CONCAT(l.firma1, IFNULL(CONCAT(' ', l.firma2), '')) AS lieferant
FROM wawi.personal p 																	-- > Ausgangspunkt/Startpflock
INNER JOIN wawi.anreden a ON p.geschlecht = a.anrnr										-- > 1. Lasso
INNER JOIN wawi.abteilungen ab ON p.abtlg = ab.abtnr									-- > 2. Lasso	
INNER JOIN wawi.bestellungen b ON p.persnr = b.bearbeiter								-- > 3. Lasso
INNER JOIN wawi.bestellpositionen bp ON b.bestnr = bp.bestnr							-- > 4. Lasso
INNER JOIN wawi.lieferanten l ON b.lieferant = l.liefnr;								-- > 5. Lasso

-- "INNER" ist optional
SELECT 	a.text AS anrede, p.vorname, p.nachname, ab.text AS abteilung, b.datum,
		bp.artikel, bp.text AS artikelbezeichnung, bp.menge,
        CONCAT(l.firma1, IFNULL(CONCAT(' ', l.firma2), '')) AS lieferant
FROM wawi.personal p 																	-- > Ausgangspunkt/Startpflock
JOIN wawi.anreden a ON p.geschlecht = a.anrnr										-- > 1. Lasso
JOIN wawi.abteilungen ab ON p.abtlg = ab.abtnr									-- > 2. Lasso	
JOIN wawi.bestellungen b ON p.persnr = b.bearbeiter								-- > 3. Lasso
JOIN wawi.bestellpositionen bp ON b.bestnr = bp.bestnr							-- > 4. Lasso
JOIN wawi.lieferanten l ON b.lieferant = l.liefnr;								-- > 5. Lasso


-- Bsp.: Kund(inne)n aus Deutschland mit ihren Interesse
-- Tabellen: kunden, anreden, kundeninteressen, interessen

SELECT a.text AS anrede, k.nachname, k.vorname, i.text AS interesse
FROM wawi.kunden k
INNER JOIN wawi.anreden a ON k.geschlecht = a.anrnr
INNER JOIN wawi.kundeninteressen ki ON k.kdnr = ki.kdnr
INNER JOIN wawi.interessen i ON ki.intcode = i.intcode
WHERE k.land = 'D' 
ORDER BY k.nachname, interesse;


-- OUTER JOIN

-- Kunden und ihre Interessen - alle Kunden sollen angezeigt werden, auch wenn ihnen kein einziges Interesse zugrordnet ist.

/*
LEFT/RIGHT?
Steht die Tabelle, aus der auch Zeilen OHNE Entsprechung in der anderen dabei sein soll weiter LINKS/früher --> LEFT
Steht die Tabelle, aus der auch Zeilen OHNE Entsprechung in der anderen dabei sein soll weiter RECHT/später --> RIGHT
*/

SELECT k.nachname, k.vorname, i.intcode AS interesse
FROM wawi.kunden k
INNER JOIN wawi.kundeninteressen i ON k.kdnr = i.kdnr
ORDER BY k.nachname;

SELECT k.nachname, k.vorname, i.intcode AS interesse
FROM wawi.kunden k LEFT OUTER JOIN wawi.kundeninteressen i ON k.kdnr = i.kdnr
ORDER BY k.nachname;

SELECT k.nachname, k.vorname, i.intcode AS interesse
FROM wawi.kundeninteressen i RIGHT OUTER JOIN wawi.kunden k ON k.kdnr = i.kdnr
ORDER BY k.nachname;

-- "OUTER" ist optional
SELECT k.nachname, k.vorname, i.intcode AS interesse
FROM wawi.kunden k LEFT JOIN wawi.kundeninteressen i ON k.kdnr = i.kdnr
ORDER BY k.nachname;


-- Wer hat keine Zuordnung?
SELECT k.nachname, k.vorname, i.intcode AS interesse
FROM wawi.kunden k LEFT JOIN wawi.kundeninteressen i ON k.kdnr = i.kdnr
-- WHERE i.kdnr IS NULL;
WHERE i.intcode IS NULL;







-- Beispiel:
-- Alle Artikel mit Artikelgruppe und Lagerständen, auch wenn Sie keine Lagerstände haben
-- > arrtnr, bezeichnung, bez. der Gruppe, bestand --> Bestand mit IFNULL auf 0

select a.artnr, a.bezeichnung, g.grtext as gruppe, ifnull(l.menge, 0) as bestand
from wawi.artikel a
join wawi.artikelgruppen g on g.artgr = a.gruppe
left join wawi.lagerstand l on l.artnr = a.artnr
order by bestand desc;


-- > welchen Artikelgruppen ist im Moment kein einziger Artikel zugeodnet?
SELECT g.grtext AS artikelgruppe
FROM wawi.artikelgruppen g
LEFT OUTER JOIN wawi.artikel a ON g.artgr = a.gruppe
WHERE a.gruppe IS NULL; 

select g.grtext as artikelgruppe
from wawi.artikel a
right join wawi.artikelgruppen g on g.artgr = a.gruppe
where a.artnr is null;


-- Beispiel für einen NONEQUI-JOIN

SELECT * FROM wawi.gehaltstufen;

SELECT p.persnr, p.nachname, p.vorname, p.eintritt, p.gehalt, g.stufe, g.von, g.bis
FROM wawi.personal p
INNER JOIN wawi.gehaltstufen g ON p.gehalt BETWEEN g.von AND g.bis
ORDER by p.gehalt;

UPDATE wawi.personal
SET gehalt = 35000
WHERE persnr = 674;

SELECT p.persnr, p.nachname, p.vorname, p.eintritt, p.gehalt, g.stufe, g.von, g.bis
FROM wawi.personal p
LEFT JOIN wawi.gehaltstufen g ON p.gehalt BETWEEN g.von AND g.bis
ORDER by p.gehalt;



-- Gruppenfunktionen

-- Ohne Gruppierung: GESAMT -summe, -anzahl, ....alter

SELECT 	COUNT(vkpreis) AS anzahl,
		MIN(vkpreis) AS minimum,
        MAX(vkpreis) AS maximum,
        ROUND(AVG(vkpreis), 2) AS mittelwert,
        SUM(vkpreis) AS summe
FROM wawi.artikel;

SELECT 	COUNT(vkpreis) AS anzahl,
		MIN(vkpreis) AS minimum,
        MAX(vkpreis) AS maximum,
        ROUND(AVG(vkpreis), 2) AS mittelwert,
        SUM(vkpreis) AS summe
FROM wawi.artikel
WHERE gruppe IN('BE','GE');


SELECT * FROM wawi.artikel WHERE gruppe = 'xy';

SELECT 	COUNT(vkpreis) AS anzahl,
		MIN(vkpreis) AS minimum,
        MAX(vkpreis) AS maximum,
        ROUND(AVG(vkpreis), 2) AS mittelwert,
        SUM(vkpreis) AS summe
FROM wawi.artikel
WHERE gruppe = 'xy';


-- wie viele Zeilen gibt es in einer Tabelle?
SELECT COUNT(*) FROM wawi.personal;
SELECT COUNT(*) FROM wawi.artikel;

SELECT 	COUNT(*) AS anzahl_zeilen,
		COUNT(persnr) AS eintraege,
        COUNT(akadgrad) AS eintraege_nicht_leer,
        COUNT(DISTINCT akadgrad) AS varianten
FROM wawi.personal;


-- SELECT artnr, bezeichnung, gruppe, vkpreis 
SELECT COUNT(*)
FROM wawi.artikel
WHERE (gruppe = 'BE' OR gruppe = 'GE' OR gruppe = 'KG') AND vkpreis >= 20 AND vkpreis <= 40
OR (gruppe = 'GA' OR gruppe = 'HW') AND (vkpreis < 40 OR vkpreis > 100)
OR gruppe = 'HH' AND vkpreis >= 60;


-- Gruppieren: GROUP BY

-- ... je Artikelgruppe
SELECT 	gruppe,
		COUNT(vkpreis) AS anzahl,
		MIN(vkpreis) AS minimum,
        MAX(vkpreis) AS maximum,
        ROUND(AVG(vkpreis), 2) AS mittelwert,
        SUM(vkpreis) AS summe
FROM wawi.artikel
GROUP BY gruppe;

-- Wie viele Mitarbeiter(innen) arbeiten in jeder Abteilung?

SELECT abtlg, COUNT(persnr) AS "mitarbeiter(innen)"
FROM wawi.personal
GROUP BY abtlg;

SELECT a.text AS abteilung, COUNT(*) AS "mitarbeiter(innen)"
FROM wawi.personal p
INNER JOIN wawi.abteilungen a ON p.abtlg = a.abtnr
GROUP BY a.text;

-- naja .... ;-)
SELECT a.text AS abteilung, COUNT(*) AS "mitarbeiter(innen)"
FROM wawi.personal p
INNER JOIN wawi.abteilungen a ON p.abtlg = a.abtnr
GROUP BY p.abtlg;	-- funktioniert NUR UND AUSSCHLIEFLICH bei MySQL

SELECT a.text AS abteilung, COUNT(*) AS "mitarbeiter(innen)"
FROM wawi.personal p
INNER JOIN wawi.abteilungen a ON p.abtlg = a.abtnr
GROUP BY abteilung;	-- funktioniert NUR UND AUSSCHLIEFLICH bei MySQL

-- Wie viele Zuordnungen gibt es je Kundeninteresse? 

SELECT intcode AS interesse, COUNT(*) AS anzahl
FROM wawi.kundeninteressen
GROUP BY intcode
ORDER BY anzahl DESC;

SELECT i.text AS interesse, COUNT(i.intcode) AS anzahl
FROM wawi.kundeninteressen k
INNER JOIN wawi. interessen i ON k.intcode = i.intcode
GROUP BY i.text
ORDER BY interesse;


-- Wie viele männlich Mitarbeiter gibt es je Abteilung?

SELECT a.text AS abteilung, COUNT(*) AS "mitarbeiter(innen)"
FROM wawi.personal p
INNER JOIN wawi.abteilungen a ON p.abtlg = a.abtnr
WHERE p.geschlecht = 2
GROUP BY a.text;

SELECT a.text AS abteilung, COUNT(*) AS "mitarbeiter(innen)"
FROM wawi.personal p
INNER JOIN wawi.abteilungen a ON p.abtlg = a.abtnr
WHERE p.geschlecht = 1
GROUP BY a.text;

-- Anzahl der Interessen je Kunde/Kundin aus Deutschland
-- > nn, vn, anz

SELECT k.nachname, k.vorname, COUNT(*) AS interessen
FROM wawi.kunden k
INNER JOIN wawi.kundeninteressen i ON k.kdnr = i.kdnr
WHERE k.land = 'D'
GROUP BY k.nachname, k.vorname
ORDER BY k.nachname, k.vorname;

-- alle Kunden, auch ohne Interessse
SELECT 	k.nachname, k.vorname, 
		COUNT(*) AS interessen_hier_falsch,			-- Achtung bei OUTER JOIN, * zählt Zeilen!
        COUNT(i.intcode) AS interessen_korrekt
FROM wawi.kunden k
LEFT JOIN wawi.kundeninteressen i ON k.kdnr = i.kdnr
WHERE k.land = 'A'
GROUP BY k.nachname, k.vorname
ORDER BY k.nachname, k.vorname;


-- In welchen Abteilungen arbeiten zumindest 2 Damen?

SELECT a.text AS abteilung, COUNT(*) AS damen
FROM wawi.personal p
INNER JOIN wawi.abteilungen a ON p.abtlg = a.abtnr
WHERE p.geschlecht = 1 
GROUP BY a.text
HAVING COUNT(*) >= 2;		-- > funktioniert bei allen DBMS

-- NUR bei MySQL möglich:
SELECT a.text AS abteilung, COUNT(*) AS damen
FROM wawi.personal p
INNER JOIN wawi.abteilungen a ON p.abtlg = a.abtnr
WHERE p.geschlecht = 1 
GROUP BY a.text
HAVING damen >= 2;

-- > Bei welchen Lieferanten hat der Umsatz im Jänner 2011 3000,-- überstiegen?
-- Step 1: Bestellungen, Bestellpositionen und Lieferanten JOINen
-- Step 2: Filter auf Jänner 2011
-- Step 3: Berechnen (SELECT) fa1 + fa2 zu Lieferant, Umsatz: menge, preis, rabatt
-- Step 4: Gruppieren nach Lieferant und Summe vom Umsatz bilden
-- Step 5: Summe des Umsatzes filtern


SELECT 'wir setzen um 12:55 fort ...' AS "Mahlzeit!";


-- Step 1: Bestellungen, Bestellpositionen und Lieferanten JOINen
SELECT l.firma1, l.firma2, b.datum, p.menge	, p.preis, p.rabatt
FROM wawi.bestellungen b
INNER JOIN wawi.bestellpositionen p ON b.bestnr = p.bestnr
INNER JOIN wawi.lieferanten l ON b.lieferant = l.liefnr;

-- Step 2: Filter auf Jänner 2011
SELECT l.firma1, l.firma2, b.datum, p.menge	, p.preis, p.rabatt
FROM wawi.bestellungen b
INNER JOIN wawi.bestellpositionen p ON b.bestnr = p.bestnr
INNER JOIN wawi.lieferanten l ON b.lieferant = l.liefnr
WHERE b.datum BETWEEN '2011-01-01' AND '2011-01-31';

-- Step 3: Berechnen (SELECT) fa1 + fa2 zu Lieferant, Umsatz: menge, preis, rabatt
SELECT	CONCAT(l.firma1, IFNULL(CONCAT(' ', l.firma2), '')) AS lieferant,
		b.datum, 
        ROUND(p.menge * p.preis * (100 - p.rabatt) / 100, 2) AS umsatz
FROM wawi.bestellungen b
INNER JOIN wawi.bestellpositionen p ON b.bestnr = p.bestnr
INNER JOIN wawi.lieferanten l ON b.lieferant = l.liefnr
WHERE b.datum BETWEEN '2011-01-01' AND '2011-01-31';

-- Step 4: Gruppieren nach Lieferant und Summe vom Umsatz bilden
SELECT	CONCAT(l.firma1, IFNULL(CONCAT(' ', l.firma2), '')) AS lieferant,
		-- b.datum, 
        SUM(ROUND(p.menge * p.preis * (100 - p.rabatt) / 100, 2)) AS umsatz
FROM wawi.bestellungen b
INNER JOIN wawi.bestellpositionen p ON b.bestnr = p.bestnr
INNER JOIN wawi.lieferanten l ON b.lieferant = l.liefnr
WHERE b.datum BETWEEN '2011-01-01' AND '2011-01-31'
GROUP BY l.firma1, l.firma2;

-- Step 5: Summe des Umsatzes filtern
SELECT	CONCAT(l.firma1, IFNULL(CONCAT(' ', l.firma2), '')) AS lieferant,
		-- b.datum, 
        SUM(ROUND(p.menge * p.preis * (100 - p.rabatt) / 100, 2)) AS umsatz
FROM wawi.bestellungen b
INNER JOIN wawi.bestellpositionen p ON b.bestnr = p.bestnr
INNER JOIN wawi.lieferanten l ON b.lieferant = l.liefnr
WHERE b.datum BETWEEN '2011-01-01' AND '2011-01-31'
GROUP BY l.firma1, l.firma2
-- HAVING umsatz >= 3000;
HAVING SUM(ROUND(p.menge * p.preis * (100 - p.rabatt) / 100, 2)) >= 3000
ORDER BY umsatz DESC;




-- Unterabfragen in der WHERE-Klausel

-- Wer sind die Kollegen von Anita Kosseg?

SELECT persnr, nachname, vorname, abtlg
FROM wawi.personal
WHERE abtlg = (	SELECT abtlg
				FROM wawi.personal
				WHERE nachname = 'kossegg')
AND nachname != 'kossegg';

-- Achtung! UA darf in dieser Konstellation imemr nur eine Zeile liefern!
SELECT persnr, nachname, vorname, abtlg
FROM wawi.personal
WHERE abtlg = (	SELECT abtlg
				FROM wawi.personal
				WHERE nachname LIKE 'k%');

-- möglich nur mit: IN()
SELECT persnr, nachname, vorname, abtlg
FROM wawi.personal
WHERE abtlg IN (SELECT abtlg
				FROM wawi.personal
				WHERE nachname LIKE 'k%');


-- Bsp.: Welche Mitarbeiter(innnen) sind schon länger im Unternehmen als Gernot Obermann (persnr=101) ?
--       nn, vn, eintritt; sortiert nach eintritt

SELECT persnr, nachname, vorname, eintritt
FROM wawi.personal
WHERE eintritt < (	SELECT eintritt
					FROM wawi.personal
                    WHERE persnr = 101)
ORDER BY eintritt;


-- Korrelierte/synchronisierte UA --> bekommt einen Wert aus der Hauptabfrage

-- Welche Artikel kosten mehr als der Durchschnitt ihrer Artikelgruppe

SELECT artnr, bezeichnung, gruppe, vkpreis
FROM wawi.artikel h
WHERE vkpreis > (	SELECT AVG(vkpreis)
					FROM wawi.artikel u
                    WHERE u.gruppe = h.gruppe)		-- Verweis auf eine Spalte der Hauptabfrage aus der UA heraus
ORDER BY gruppe, vkpreis;


-- Unterabfrage in der FROM - Klausel

SELECT bezeichnung, vkpreis
FROM (	SELECT artnr, bezeichnung, gruppe, vkpreis
		FROM wawi.artikel) x
WHERE vkpreis > 50;

SELECT *
FROM (	SELECT bezeichnung, vkpreis
		FROM (	SELECT artnr, bezeichnung, gruppe, vkpreis
				FROM wawi.artikel) x
		WHERE vkpreis > 50) y;

-- Bsp: Wiederverwendbarkeit von Ausdrücken

SELECT 	artnr, bezeichnung, 
		ekpreis AS ek_netto, 
        ROUND(vkpreis / (100 + mwst) * 100, 2) AS vk_netto, 
        -- vk_netto - ek_netto AS db,							-- Alias kann nicht weiterwendet werden ... :-((
        mwst
FROM wawi.artikel;

-- Lösung 1: copy/paste ...
SELECT 	artnr, bezeichnung, 
		ekpreis AS ek_netto, 
        ROUND(vkpreis / (100 + mwst) * 100, 2) AS vk_netto, 
        ROUND(vkpreis / (100 + mwst) * 100, 2) - ekpreis AS db,							-- Alias kann nicht weiterwendet werden ... :-((
        mwst
FROM wawi.artikel;

-- Lösung 2: neue Ebene durch UA
SELECT artnr, bezeichnung, ek_netto, vk_netto, vk_netto - ek_netto AS db
FROM (	SELECT 	artnr, bezeichnung, 
				ekpreis AS ek_netto, 
				ROUND(vkpreis / (100 + mwst) * 100, 2) AS vk_netto, 
				mwst
		FROM wawi.artikel) x;


-- Welche Artikel kosten mehr als der Durchschnitt ihrer Artikelgruppe

SELECT gruppe, ROUND(AVG(vkpreis), 2) AS schnitt
FROM wawi.artikel
GROUP BY gruppe;

SELECT a.artnr, a.bezeichnung, a.gruppe, a.vkpreis, d.schnitt, a.vkpreis - d.schnitt AS differenz
FROM wawi.artikel a
INNER JOIN (	SELECT gruppe, ROUND(AVG(vkpreis), 2) AS schnitt
				FROM wawi.artikel
				GROUP BY gruppe) d ON a.gruppe = d.gruppe
WHERE a.vkpreis > d.schnitt
ORDER BY a.gruppe, a.vkpreis;


-- Anzahl der Damen je Abteilung

SELECT a.text AS abteilung, COUNT(*) AS damen
FROM wawi.personal p
INNER JOIN wawi.abteilungen a ON p.abtlg = a.abtnr
WHERE p.geschlecht = 1
GROUP BY a.text;

SELECT a.text AS abteilung, COUNT(*) AS damen
FROM wawi.personal p
RIGHT JOIN wawi.abteilungen a ON p.abtlg = a.abtnr
WHERE p.geschlecht = 1		-- > macht den OUTER JOIN wieder "kaputt"
GROUP BY a.text;

SELECT a.text AS abteilung, COUNT(p.persnr) AS damen
FROM wawi.personal p
RIGHT JOIN wawi.abteilungen a ON p.abtlg = a.abtnr AND p.geschlecht = 1		-- (Filtern nicht NACH sondern BEIM Join)
GROUP BY a.text;


SELECT a.text AS abteilung, IFNULL(d.damen, 0) AS damen
FROM wawi.abteilungen a
LEFT JOIN (	SELECT abtlg, COUNT(*) AS damen
			FROM wawi.personal
			WHERE geschlecht = 1
			GROUP BY abtlg) d ON a.abtnr = d.abtlg;
            
            

-- Sichten/Views (DDL)
-- > SELECT, das in der DB als Objekt abgelegt wird



/*
Vorteile / Nutzen von Views: --> wird genutzt wie eine Tabelle
	- Wiederverwendbarkeit
    - Reduktion von Komplexität
	- Ausblenden von nicht benötigten Daten
    - Umbennenen von Objekten und Spalten
	- Differnzierte indirekte Berechtigungen
*/


-- artikel
-- tblArtikel
-- t_artikel
-- artikel_t
-- ...


CREATE VIEW wawi.v_durchschnittspreise
AS
	SELECT 	gruppe, 
			ROUND(AVG(vkpreis), 2) AS schnitt
	FROM wawi.artikel
	GROUP BY gruppe;


SELECT *
FROM wawi.v_durchschnittspreise;

-- Welche Artikel kosten mehr als der Durchschnitt ihrer Artikelgruppe
SELECT a.artnr, a.bezeichnung, a.gruppe, a.vkpreis, d.schnitt, a.vkpreis - d.schnitt AS differenz
FROM wawi.artikel a
INNER JOIN wawi.v_durchschnittspreise d ON a.gruppe = d.gruppe
WHERE a.vkpreis > d.schnitt
ORDER BY a.gruppe, a.vkpreis;


-- Ändern einer Sicht
CREATE OR REPLACE VIEW wawi.v_durchschnittspreise
AS
	SELECT 	a.gruppe, g.grtext AS bezeichnung,
			ROUND(AVG(a.vkpreis), 2) AS schnitt,
            COUNT(a.artnr) AS anzahl
	FROM wawi.artikel a
    JOIN wawi.artikelgruppen g ON a.gruppe = g.artgr
	GROUP BY a.gruppe, g.grtext;


SELECT gruppe, bezeichnung, schnitt, anzahl
FROM wawi.v_durchschnittspreise
WHERE gruppe IN('BE', 'GE', 'KG');


SELECT '14:46' AS "Pause bis"
UNION ALL
SELECT '--> Kaffee';

-- Bsp: Erfstellen einer Sicht v_artikel, welche nur die aktiven Artikel und zusätzlich den berechneten
--      Netto-Verkaufspreis enthält

UPDATE wawi.artikel SET aktiv = 0 WHERE artnr = 1234;

CREATE OR REPLACE VIEW wawi.v_artikel
AS
	SELECT 	artnr, bezeichnung, gruppe, 
			vkpreis AS vk_brutto,
            ROUND(vkpreis / (100 + mwst) * 100, 1) AS vk_netto,
            ekpreis AS ek_netto, 
            mwst AS ust,
            lief, lieferzeit, mindbestand,
			hinweis, mengebestellt
    FROM wawi.artikel
    WHERE aktiv <> 0;



SELECT * FROM wawi.v_artikel WHERE artnr = 1234;
SELECT * FROM wawi.v_artikel WHERE artnr = 1240;

UPDATE wawi.artikel SET aktiv = 0 WHERE artnr BETWEEN 1230 AND 1239;

SELECT COUNT(*) FROM wawi.artikel;
SELECT COUNT(*) FROM wawi.v_artikel;


-- Löschen einer Sicht: DROP
DROP VIEW wawi.v_artikel;

-- Schreiben in DB - DML

-- Einfügen von Daten in eine Tabelle: INSERT

-- z.B. neue Abteilungen

SELECT * FROM wawi.abteilungen;

INSERT INTO wawi.abteilungen
VALUES ('KA', 'Kantine');

INSERT INTO wawi.abteilungen
VALUES ('ABCDEF', 'Kantine');

-- Defintion der Tabellenstruktur muss genau berücksichtigt werden

ALTER TABLE wawi.abteilungen
ADD aktiv tinyint DEFAULT 1;

INSERT INTO wawi.abteilungen
VALUES ('FE', 'Forschung und Entwicklung');

-- besser Zielspaltenangabe
INSERT INTO wawi.abteilungen (abtnr, text)
VALUES ('FE', 'Forschung und Entwicklung');

SELECT * FROM wawi.abteilungen;

-- Mehrere Zeile einfügen
INSERT INTO wawi.abteilungen (abtnr, text)
VALUES 	('IT', 'Informationstechnologie'),
		('FM', 'Facilty Management'),
        ('PE', 'Pesonalwesen');



-- Bsp: drei neue Artikelgruppen einfügen

INSERT INTO wawi.artikelgruppen (grtext, artgr)
VALUES 	('Sportartikel', 'SA'),
		('Werkzeug', 'WZ'),
        ('Reinigungsmittel', 'RM');

SELECT *
FROM wawi.artikelgruppen
WHERE artgr IN('SA', 'WZ', 'RM');

COMMIT;
ROLLBACK;

-- Datensatz löchen: DELETE

DELETE FROM wawi.artikelgruppen;	-- > ganze Tabelle leeren

DELETE FROM wawi.artikelgruppen WHERE artgr = 'RM';

-- Einfügen mit SELECT aus AUTOINCREMENT

SELECT * FROM wawi.bestellungen ORDER BY bestnr DESC;

INSERT INTO wawi.bestellungen (bearbeiter)
VALUES (285);	-- > Fehler: lieferant muss einen Wert bekommen (NOT NULL) und hat aber keinen DEFAULT-Wert

INSERT INTO wawi.bestellungen (bearbeiter, lieferant)
VALUES (285, 1002);

SELECT LAST_INSERT_ID();

INSERT INTO wawi.bestellungen (bearbeiter, lieferant, bestnr)
VALUES (285, 1002, 1999);

DELETE FROM wawi.bestellungen WHERE bestnr = 1999;


-- Bestellung "duplizieren": neue Bestellung mit den Positionen der Bestellung 1004 befüllen

SELECT * FROM wawi.bestellpositionen WHERE bestnr = 1004;

INSERT INTO wawi.bestellpositionen(bestnr, pos, artikel, text, menge, preis, rabatt)
SELECT 1008 AS bestnr, p.pos, p.artikel, a.bezeichnung, p.menge, a.ekpreis, 5 AS rabatt
FROM wawi.bestellpositionen p 
INNER JOIN wawi.artikel a ON p.artikel = a.artnr
WHERE p.bestnr = 1004;

SELECT * FROM wawi.bestellpositionen WHERE bestnr = 1008;




-- 18.12.2020

-- Referentielle Integrität

SELECT * FROM wawi.bestellungen;
SELECT * FROM wawi.bestellpositionen  WHERE bestnr = 1004;

INSERT INTO wawi.bestellpositionen(bestnr, pos, artikel, text, menge, preis, rabatt)
SELECT 3000 AS bestnr, p.pos, p.artikel, a.bezeichnung, p.menge, a.ekpreis, 5 AS rabatt
FROM wawi.bestellpositionen p 
INNER JOIN wawi.artikel a ON p.artikel = a.artnr
WHERE p.bestnr = 1004;

DELETE FROM wawi.bestellungen WHERE bestnr = 1004;


-- Anweisung in sich ist die kleinste Form einer Transaktion


DELETE FROM wawi.bestellungen; 

SELECT * FROM wawi.bestellungen; 

-- Autmatische Transaktionen --> Start automatisch, Ende automatisch (Standardarverhalten  durch WorkBenk)
-- Implizite Transaktionen	--> Start automatisch, Ende manuell (Standardarverhalten bei MySQL)
-- Explizite Trasnaktionen	--> Start manuell, Ende manuell

DELETE FROM wawi.bestellpositionen
WHERE bestnr IN(1004, 1008);		-- 1. Anweisung startet eine Transaktion

SELECT * FROM wawi.bestellpositionen
WHERE bestnr IN(1004, 1008, 1003); 

DELETE FROM wawi.bestellungen
WHERE bestnr IN(1004, 1008);		-- 2. Anweisung erweitert die Transaktion

SELECT * FROM wawi.bestellungen
WHERE bestnr IN(1004, 1008, 1003); 

-- Rückgängig machen: ROLLBACK
ROLLBACK;


-- Ändern von Daten: UPDATE

-- Beispiel für UPDATE:
-- Preise aller Artikel der Gruppen Gartenartikel (GA) und Heimwerkerartikel (HW)
-- sollen um 5% gesenkt werden

SELECT artnr, bezeichnung, vkpreis
FROM wawi.artikel
WHERE gruppe IN('GA', 'HW')
ORDER BY bezeichnung
LIMIT 5;

UPDATE wawi.artikel
SET vkpreis = ROUND(vkpreis * 0.95, 2)
WHERE gruppe IN('GA', 'HW');

COMMIT;


-- Filtern nach dem PK-Eintrag

-- CK für Artikel 1579 um 3,-- senken, ek um 7%

SELECT artnr, bezeichnung, vkpreis, ekpreis
FROM wawi.artikel
WHERE artnr = 1579;


UPDATE wawi.artikel
SET vkpreis = vkpreis - 3, 
	ekpreis = ROUND(ekpreis * 0.93, 2)
WHERE artnr = 1579;


COMMIT;


-- Beispiel: Gernot Obermann und Marion heiraten
-- > Doppelname für sie
-- > geinsame neue Adresse für beide: land, plz, ort, strasse, telefon


SELECT persnr, vorname, nachname, land, plz, ort, strasse, telefon
FROM wawi.personal 
WHERE persnr IN(101, 238);

-- Nachname
UPDATE wawi.personal
-- SET nachname = CONCAT(nachname, '-', (SELECT nachname FROM wawi.personal WHERE persnr = 101))
SET nachname = CONCAT(nachname, '-', 'Obermann')
WHERE persnr = 238;

-- gemeinsame Adresse
UPDATE wawi.personal
SET land = 'A',
	plz = '9700',
    ort = 'Leoben',
    strasse = 'Bierbrauerstrasse 17',
    telefon = '03xx 1234567'
WHERE persnr IN(101, 238);
    
COMMIT;



-- Neuen Artikel anlegen
-- diesem dann 20 Stück ins Lager 1 einbuchen,
-- danach 3 davon ins Lager 5 umbuchen

INSERT INTO wawi.artikel(bezeichnung, ekpreis, vkpreis, gruppe, lief, mwst)
VALUES ('Testartikel SDJ', 17.30, 29.99, 'GA', 1002, 20);

-- > Gefährlich bei Multiuserbetrieb: SELECT MAX(artnr) FROM wawi.artikel;  

SELECT LAST_INSERT_ID();

SELECT * FROM wawi.lagerstand;

INSERT INTO wawi.lagerstand (artnr, lagnr, menge)
VALUES (LAST_INSERT_ID(), 1, 20);

SELECT * FROM wawi.lagerstand WHERE artnr = last_insert_id();

INSERT INTO wawi.lagerstand (artnr, lagnr, menge)
VALUES (LAST_INSERT_ID(), 5, 3);

UPDATE wawi.lagerstand
SET menge = menge - 3
WHERE artnr = LAST_INSERT_ID()
AND lagnr = 1;

COMMIT;

DELETE FROM wawi.lagerstand WHERE artnr = 2113;
DELETE FROM wawi.artikel WHERE artnr = 2113;

COMMIT;


-- Erstellen und verwalten von Tabellen: DDL


-- Erstellen einer Tabelle

CREATE TABLE wawi.kategorien
(	kat_id tinyint,
	bezeichnung varchar(40),
    aktiv enum('j', 'n')
);

DROP TABLE wawi.kategorien;

-- > NULL / NOT NULL
-- > PK

CREATE TABLE wawi.kategorien
(	kat_id tinyint PRIMARY KEY,
	bezeichnung varchar(40) NOT NULL,
    aktiv enum('j', 'n') NOT NULL
);

INSERT INTO wawi.kategorien (kat_id, bezeichnung, aktiv)
VALUES 	(1, 'Projektmanagement', 'j'),
		(2, 'SW-Entwicklung', 'j'),
        (3, 'Vertrieb', 'j');

SELECT * FROM wawi.kategorien;

COMMIT;

DROP TABLE wawi.kategorien;

CREATE TABLE wawi.kategorien
(	kat_id tinyint PRIMARY KEY,
	bezeichnung varchar(40) NOT NULL,
    aktiv enum('J', 'N') NOT NULL DEFAULT 'J'
);

INSERT INTO wawi.kategorien (kat_id, bezeichnung)
VALUES 	(1, 'Projektmanagement'),
		(2, 'SW-Entwicklung'),
        (3, 'Vertrieb');

SELECT @@version;


-- Constraints ergänzen (eigene Objekte, die aber zu einer Tabelle gehören)
/*
Primärschlüssel: 	pk_tabellenname
Unique Key:			uk_tabellenname_spaltenname
Fremschlüssel:		fk_ausgangstabelle_zieltabelle
Check:				ck_tabellenname_spaltenname
*/


DROP TABLE wawi.kategorien;



CREATE TABLE wawi.kategorien
(	kat_id tinyint,
	bezeichnung varchar(40) NOT NULL,
    aktiv enum('J', 'N') NOT NULL DEFAULT 'J',
    CONSTRAINT pk_kategorien PRIMARY KEY (kat_id),
    CONSTRAINT uk_kategorien UNIQUE (bezeichnung),
    CONSTRAINT ck_kategorien_bezeichnung CHECK (bezeichnung LIKE '___%')
);

INSERT INTO wawi.kategorien (kat_id, bezeichnung)
VALUES 	(1, 'Projektmanagement'),
		(2, 'SW-Entwicklung'),
        (3, 'Vertrieb');


SELECT * FROM wawi.kategorien;

-- Primärschlüssel
INSERT INTO wawi.kategorien (kat_id, bezeichnung)
VALUES 	(1, 'Einkaufswesen');

-- Unique:
INSERT INTO wawi.kategorien (kat_id, bezeichnung)
VALUES 	(4, 'Vertrieb');

-- Check:
INSERT INTO wawi.kategorien (kat_id, bezeichnung)
VALUES 	(4, 'XY');


-- Beziehung zwischen 2 Tabellen herstellen

CREATE TABLE wawi.schulungen
(	sch_id int AUTO_INCREMENT,
	titel varchar(100) NOT NULL,
    untertitel varchar(300),
    kat_id tinyint NOT NULL,
    einheiten smallint NOT NULL CONSTRAINT ck_schulungen_einheiten CHECK (einheiten BETWEEN 1 AND 1000),
    stufe enum('A','B','C','D','E','F') NOT NULL DEFAULT 'A',
    CONSTRAINT pk_schulungen PRIMARY KEY (sch_id),
    CONSTRAINT fk_schulungen_kategorien FOREIGN KEY (kat_id) REFERENCES wawi.kategorien (kat_id)
);


ALTER TABLE wawi.schulungen
DROP CONSTRAINT ck_schulungen_einheiten;

ALTER TABLE wawi.schulungen
ADD CONSTRAINT ck_schulungen_einheiten CHECK (einheiten BETWEEN 1 AND 1100);

    
-- Einfügen ...

INSERT INTO wawi.schulungen(titel, kat_id, stufe, einheiten)
VALUES ('DB-Grundlagen', 2, 'B', 32);

SELECT * FROM wawi.schulungen;

-- Fehler:
INSERT INTO wawi.schulungen(titel, kat_id, stufe, einheiten)
VALUES ('DB-Grundlagen', 2, 'X', 32);

INSERT INTO wawi.schulungen(titel, kat_id, stufe, einheiten)
VALUES ('DB-Grundlagen', NULL, 'A', 32);

INSERT INTO wawi.schulungen(titel, kat_id, stufe, einheiten)
VALUES ('DB-Grundlagen', 9, 'A', 32);




-- 22.01.2021

-- Tabelle "Anmeldungen"

-- V1
CREATE TABLE wawi.anmeldungen
(	persnr int,
	sch_id int,
    anmeldung datetime NOT NULL DEFAULT now(),
    abmeldung datetime,
    CONSTRAINT pk_anmeldungen PRIMARY KEY (persnr, sch_id),
    CONSTRAINT fk_anmeldungen_personal FOREIGN KEY (persnr) REFERENCES wawi.personal (persnr),
    CONSTRAINT fk_anmeldungen_schulungen FOREIGN KEY (sch_id) REFERENCES wawi.schulungen (sch_id)
);

-- > Vorteil dieser Variante: gemeinsam Eindeutig --> Doppelanmeldung ausgeschlossen :-)

-- V2
DROP TABLE wawi.anmeldungen;

CREATE TABLE wawi.anmeldungen
(	anm_id int AUTO_INCREMENT,
	persnr int NOT NULL,
	sch_id int NOT NULL,
    anmeldung datetime NOT NULL DEFAULT now(),
    abmeldung datetime,
    CONSTRAINT pk_anmeldungen PRIMARY KEY (anm_id),
    CONSTRAINT fk_anmeldungen_personal FOREIGN KEY (persnr) REFERENCES wawi.personal (persnr),
    CONSTRAINT fk_anmeldungen_schulungen FOREIGN KEY (sch_id) REFERENCES wawi.schulungen (sch_id)
);

-- > Vorteil: wenn es weitere Tabellen gibt, die darauf referenzieren, dann ist ein einspaltiger PK einfacher
--   Bsp.: Anwesenheit zu einzelnen Terminen

/*
-- > JOIN

... wawi.anmeldungen a INNER JOIN wawi.anwesenheiten w ON a.anm_id = w.anm_id ...
... wawi.anmeldungen a INNER JOIN wawi.anwesenheiten w ON a.persnr = w.persnr AND asch_id = w.sch_id ....

*/


-- V3: eigener PK, aber dennoch Doppelanmeldungen unterbinden
DROP TABLE wawi.anmeldungen;

CREATE TABLE wawi.anmeldungen
(	anm_id int AUTO_INCREMENT,
	persnr int NOT NULL,
	sch_id int NOT NULL,
    anmeldung datetime NOT NULL DEFAULT now(),
    abmeldung datetime,
    CONSTRAINT pk_anmeldungen PRIMARY KEY (anm_id),
    CONSTRAINT fk_anmeldungen_personal FOREIGN KEY (persnr) REFERENCES wawi.personal (persnr),
    CONSTRAINT fk_anmeldungen_schulungen FOREIGN KEY (sch_id) REFERENCES wawi.schulungen (sch_id)
);

-- CONSTRAINT ergänzen
ALTER TABLE wawi.anmeldungen
ADD CONSTRAINT uk_anmeldungen_persnr_sch_id UNIQUE (persnr, sch_id);

ALTER TABLE wawi.anmeldungen
DROP CONSTRAINT uk_anmeldungen_persnr_sch_id;


-- Spalten ergänzen, ändern oder löschen

-- neue Spalte
ALTER TABLE wawi.anmeldungen
ADD teilgenommen enum('j','n');

-- Spalte löschen
ALTER TABLE wawi.anmeldungen
DROP COLUMN teilgenommen;

-- Datentyp ändern
ALTER TABLE wawi.anmeldungen
ADD bemerkung varchar(50);

ALTER TABLE wawi.anmeldungen
MODIFY bemerkung varchar(200);

ALTER TABLE wawi.anmeldungen
MODIFY bemerkung varchar(200) NOT NULL;


-- > Achtung: Spaltenlänge auf 250 Zeichen erweitern
ALTER TABLE wawi.anmeldungen
MODIFY bemerkung varchar(250); -- > jetzt ist NULL aber wieder erlaubt!


-- AUTO_INCREMENT hinaufschrauben bzw. zurücksetzen:
SELECT * FROM wawi.schulungen;

INSERT INTO wawi.schulungen(titel, kat_id, stufe, einheiten)
VALUES ('DB-Grundlagen', 2, 'B', 32);

COMMIT;
ROLLBACK;


-- vor einem TRUNCATE müssen Beziehungen die auf diese Tabelle zeigen entfernt werden ...
ALTER TABLE wawi.anmeldungen
DROP CONSTRAINT fk_anmeldungen_schulungen;

-- setzt eine Tabelle auf den Status wie gerade neu erzeugt
TRUNCATE TABLE wawi.schulungen;	-- > setzt auch den AUTO_INCREMENT wieder zurück

ALTER TABLE wawi.anmeldungen
ADD CONSTRAINT fk_anmeldungen_schulungen FOREIGN KEY (sch_id) REFERENCES wawi.schulungen (sch_id);


-- Dummyeintrag zum Heraufsetzen

INSERT INTO wawi.schulungen(sch_id, titel, kat_id, stufe, einheiten)
VALUES (999, 'dummy ;-)', 2, 'B', 32);

SELECT * FROM wawi.schulungen;

ROLLBACK;

INSERT INTO wawi.schulungen(titel, kat_id, stufe, einheiten)
VALUES ('DB-Grundlagen', 2, 'B', 32);

COMMIT;


-- Index 
-- > Beschleunigen von Suchvorgängen
-- > typischerweise für 1 Spalte, manchmal Splatenkombination
-- > mögl. Verwendung: indizierte Spalte auf linker Seite in WHERE-Klausel

SELECT artnr, bezeichnung, vkpreis
FROM wawi.artikel
WHERE artnr = 1357;			-- > Indexverwendung möglich (PK!)

SELECT artnr, bezeichnung, vkpreis
FROM wawi.artikel
WHERE vkpreis > 500;		-- > kein Index vorhanden ...

SELECT artnr, bezeichnung, vkpreis
FROM wawi.artikel
WHERE bezeichnung LIKE 'gardena%';		-- > Indexverwendung möglich ...

SELECT artnr, bezeichnung, vkpreis
FROM wawi.artikel
WHERE bezeichnung LIKE '%koch%';		-- > Indexverwendung NICHT möglich ... SOTIERUNG NICHT MÖGLICH!



-- nur sinnvoll bei einer niedrigen erwarteten Trefferanzahl!

CREATE INDEX ix_artikel_vkpreis ON wawi.artikel(vkpreis);

DROP INDEX ix_artikel_vkpreis ON wawi.artikel;


-- zusammengesetzter Index

CREATE INDEX ix_personal_nn_vn_plz ON wawi.personal(nachname, vorname, plz);

SELECT *
FROM wawi.personal
WHERE nachname LIKE 'oberm%'
AND vorname LIKE 'gerno%'
AND plz LIKE '9%';

-- wird auch bei führenden Kopfspalten:
SELECT *
FROM wawi.personal
WHERE nachname LIKE 'oberm%'
AND vorname LIKE 'gerno%';

SELECT *
FROM wawi.personal
WHERE nachname LIKE 'oberm%';

-- TURBO schlechthin: Ergebnis wir NUR aus dem Index gebildet
SELECT nachname, vorname, plz
FROM wawi.personal
WHERE nachname LIKE 'oberm%'
AND vorname LIKE 'gerno%'
AND plz LIKE '9%';



-- CONSTRAINT ergänzen
ALTER TABLE wawi.anmeldungen
ADD CONSTRAINT uk_anmeldungen_persnr_sch_id UNIQUE (persnr, sch_id);

-- hier: zuerst FKs löschen !?!
ALTER TABLE wawi.anmeldungen DROP CONSTRAINT fk_anmeldungen_personal;
ALTER TABLE wawi.anmeldungen DROP CONSTRAINT fk_anmeldungen_schulungen;

-- Index oder UK löschen
DROP INDEX uk_anmeldungen_persnr_sch_id ON wawi.anmeldungen;
-- oder:
ALTER TABLE wawi.anmeldungen
DROP CONSTRAINT uk_anmeldungen_persnr_sch_id;


-- danach: FKs wieder erzeugen
ALTER TABLE wawi.anmeldungen 
ADD CONSTRAINT fk_anmeldungen_personal FOREIGN KEY (persnr) REFERENCES wawi.personal (persnr);

ALTER TABLE wawi.anmeldungen 
ADD CONSTRAINT fk_anmeldungen_schulungen FOREIGN KEY (sch_id) REFERENCES wawi.schulungen (sch_id);
    
    
-- Befüllen eines Listenfeldes  (Lookup-Tables)
    
CREATE TABLE wawi.arten
(	id int AUTO_INCREMENT,
	bezeichnung varchar(50) NOT NULL,
    CONSTRAINT pk_arten PRIMARY KEY (id)
);


INSERT INTO wawi.arten (bezeichnung)
VALUES ('blond');

INSERT INTO wawi.arten (bezeichnung)
VALUES ('brünett');

INSERT INTO wawi.arten (bezeichnung)
VALUES ('grau');

SELECT * FROM wawi.arten ORDER BY bezeichnung;

INSERT INTO wawi.arten (bezeichnung)
VALUES ('schwarz'), ('weiß');




-- Übungsbeispiel:

create table wawi.projekte
( projekt_nr int Auto_increment primary key,
bezeichnung varchar(100) NOT NULL,
beginn date NOT NULL,
ende_soll date NOT NULL,
ende_ist date,
budget float
);

create table wawi.projektzeiten
( zeit_id int Auto_increment primary key,
datum date NOT NULL,
dauer int NOT NULL,
stundensatz float NOT NULL,
projekt_nr int,
pers_nr int,
constraint fk_projektzeiten_projekte foreign key (projekt_nr) references wawi.projekte (projekt_nr),
constraint fk_projektzeiten_personal foreign key (pers_nr) references wawi.personal (persnr)
);

create table wawi.taetigkeitsgruppen
( gruppen_nr int Auto_increment primary key,
bezeichnung varchar(50) NOT NULL,
stundensatz float NOT NULL
);

select * from wawi.personal;
alter table wawi.personal
add gruppen_nr int,
add constraint fk_personal_taetigkeitsgruppen foreign key (gruppen_nr) references wawi.taetigkeitsgruppen (gruppen_nr);