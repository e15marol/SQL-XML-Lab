drop database e15marol;
create database e15marol;
use e15marol;

# 3.1 Realisera databasen
create table skjutfalt(
	faltnamn varchar(20),
    telefonnummer char(11),
    stad varchar (20),
    primary key(faltnamn)
)engine=innodb;

create table skjutbana(
	skjutbanenr varchar(3),
    moment varchar(20),
    faltnamn varchar(20),
    primary key(skjutbanenr),
    foreign key(faltnamn) references skjutfalt(faltnamn)
)engine=innodb;

create table funktionar(
	funktionarPnr char(13),
    lon varchar(20), /* lön */
    funktionarNamn varchar(20),
    faltnamn varchar(20),
    skjutbanenr varchar(3),
    primary key(funktionarPnr),
	foreign key(skjutbanenr) references skjutbana(skjutbanenr),
    foreign key(faltnamn) references skjutfalt(faltnamn)
)engine=innodb;

create table skytt( /* Måste ligga framför gevär*/
	skyttPnr char(13),
    skyttNamn varchar(20),
    lag varchar(20),
    primary key(skyttPnr)
)engine=innodb;

create table gevar( /* Måste ligga framför ammunition table*/
	gevarsnamn varchar(20),
    vikt varchar(5),
    skyttPnr char(13),
    primary key(gevarsnamn, skyttPnr),
    foreign key(skyttPnr) references skytt(skyttPnr)
)engine=innodb;

create table ammunition(
	kaliber varchar(5),
    kalibernamn varchar(20),
    gevarsNamn varchar(20), /* gevärsnamn*/
    skyttPnr char(13),
    primary key(kaliber, gevarsNamn, skyttPnr), 
    foreign key(gevarsNamn) references gevar(gevarsNamn),
    foreign key(skyttPnr) references gevar(skyttPnr) #Främmande keys från svaga entiteter ska komma från en source table enbart, alltså från gevar i detta fallet.
)engine=innodb;
#Då alla främmande nycklar från svaga entiteter måste komma från enbart en tabell, hämtar vi den 
#nyckeln som lagras i gevar tabellen. Då trots att vi behöver skyttPnr, så går vi inte direkt och 
#hämtar den från den tabellen, utan tar den som ligger i gevar.

create table maltavla( /* Måste ligga framför skjutserie*/
	maltavlaNr varchar(3),
	antal char(1),
    primary key(maltavlaNr)
)engine=innodb;

create table skjutserie(
	starttid datetime,
    resultat varchar(3),
    skjutbanenr varchar(3),
    funktionarPnr char(13),
    maltavlaNr varchar(3),
    skyttPnr char(13),
    primary key(starttid, maltavlaNr, skyttPnr),
	foreign key(skjutbanenr) references skjutbana(skjutbanenr),
    foreign key(funktionarPnr) references funktionar(funktionarPnr),
	foreign key(maltavlaNr) references maltavla(maltavlaNr),
    foreign key(skyttPnr) references skytt(skyttPnr) 
)engine=innodb;

create table ammunitionAnsvar( /* Ansvarar för många till många relation mellan ammunition och funktionär */
	funktionarPnr char(13),
    kaliber varchar(20),
    gevarsnamn varchar(20),
    skyttPnr char(13),
    primary key(funktionarPnr, kaliber, gevarsnamn, skyttPnr),
    foreign key(funktionarPnr) references funktionar(funktionarPnr),
    foreign key(kaliber) references ammunition(kaliber),
    foreign key(gevarsnamn) references gevar(gevarsnamn),
    foreign key(skyttPnr) references gevar(skyttPnr) #Skyttpnr ligger redan lagrat i gevär tabellen så hämtar därifrån istället
)engine=innodb;

# 3.2 Transaktioner 

#1.	 Denna transaktion skapar ett nytt fält men namn, Kråk, ett telefonnummer och dess stad. Värdena matas in i skjutfalt tabellen som representerar fälten.
insert into skjutfalt(faltnamn, telefonnummer, stad) values ('Kråk','0500-999999','Skövde');

#2. /* Skjutbanorna måste skapas för att man ska kunna lägga till funktionärerna till dessa*/
insert into skjutbana(skjutbanenr, moment, faltnamn) values('1', 'Ligga', 'Kråk'); 
insert into skjutbana(skjutbanenr, moment ,faltnamn) values('2', 'Knä','Kråk');
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('790129-4444','18000','Per','Kråk','1');
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('810912-5555','18000','Kalle','Kråk','2');

#3. En ny skytt läggs till i skytt tabellen, med hjälp av värdena för vilket personnummer han har, vilket namn (Bosse) skytten har och vilket lag denna skytt tillhör.
insert into skytt(skyttPnr, skyttNamn, lag) values ('560123-6666','Bosse','Göteborg');

#4. 
#Eftersom att vi inte tidigare haft en transaktion där vi fört in en skytt med personnummer ’761223-5656’ så skapar vi en ny skytt vid namnet Kevin, som tillhör 
#laget Fjollträsk och har det personnumret som geväret knyts till. Vi skapar en ny skytt då geväret måste tillhöra någon, då gevär är en svag entitet. Dess vikt, namn och ägare läggs till i gevär-tabellen.
insert into skytt(skyttPnr, skyttNamn, lag) values ('761223-5656','Kevin','Fjollträsk'); /* Så geväret kan tillskrivas någon */
insert into gevar(gevarsnamn, vikt, skyttPnr) values ('Izhmash','4.5','761223-5656');

#5.  
#Skytten är bosse så han behöver inte läggas till igen eftersom att han läggs till i en transaktion ovan.
#För att ammunitionen ska kunna tillskrivas ett gevär så läggs geväret till först i en transaktion.
insert into gevar(gevarsnamn, vikt, skyttPnr) values ('Izhmash','4.5','560123-6666');
insert into ammunition(kaliber, kalibernamn, gevarsNamn, skyttPnr) values('22', 'x-act', 'Izhmash','560123-6666'); 

#6. Skytten Allan läggs till
#En skjutbana läggs till som funktionären är ansvarig för 
insert into skjutbana(skjutbanenr, moment, faltnamn) values('3', 'Ligga', 'Kråk');
#Ny funktionär för skjutbana 3
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('870923-3434','18000','Annika','Kråk','3'); 
insert into skytt(skyttPnr, skyttNamn, lag) values ('781222-2323','Allan','Skultorp'); 
insert into gevar(gevarsnamn, vikt, skyttPnr) values ('Elefantgewehr','7.2','781222-2323');
insert into ammunition(kaliber, kalibernamn, gevarsNamn, skyttPnr) values('.577', 'Midas+', 'Elefantgewehr','781222-2323');
insert into ammunitionAnsvar(funktionarPnr, kaliber, gevarsNamn, skyttPnr)values('870923-3434', '.577','Elefantgewehr','781222-2323'); 

#9. 
#Då en skjutserie läggs till med måltavla nummer två måste denna skapas innan skjutserien tar plats
#Eftersom att måltavlan ska användas utav en annan transaktion måste denna ligga före transaktion 3.7.
# Denna transaktion lägger helt enkelt till en ny måltavla med nummer två och ett antal på fem, så att den kan brukas.
insert into maltavla(maltavlaNr, antal) values('2', '5'); #Då måltavla ingår måste den också skapas

#7. 
#Ett datum läggs till för starttid så att formatet ska vara korrekt. Skjutbanan finns redan, det gör även skytten och funktionären
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2012-01-21 12:01:33', '5','3', '790129-4444', '2', '560123-6666');
#Gjort ett antagande här att 2012-01-21 13:01:33 ska vara 2012-01-21 12:01:33 istället, då det finns en uppgift i frågeoperationerna att ta bort denna skjutserie.

#8. 
#Ny skjutbana skapas, en där moment är att ligga
insert into skjutbana(skjutbanenr, moment ,faltnamn) values('4', 'Ligga','Kråk'); 
#Ny funktionär läggs till (och är ansvarig vid skjutbana 4)
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('560123-4455','18000','Frasse','Kråk','4'); 
#Nisse läggs till i skytt-tabellen
insert into skytt(skyttPnr, skyttNamn, lag) values ('671205-2727','Nisse','Umeå'); 
#Lägger till ett gevär till Allan
insert into gevar(gevarsnamn, vikt, skyttPnr) values ('Boomstick','5.1','671205-2727'); 
#Lägger till ammunition för nisse 
insert into ammunition(kaliber, kalibernamn, gevarsNamn, skyttPnr) values('19', 'PelletPunch', 'Boomstick','671205-2727'); 
#Frasse är ansvarig för Nisses ammunition 
insert into ammunitionAnsvar(funktionarPnr, kaliber, gevarsNamn, skyttPnr)values('560123-4455', '19','Boomstick','671205-2727');  
insert into maltavla(maltavlaNr, antal) values('6', '8'); #Då måltavla ingår måste den skapas innan skjutserien
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2015-04-01 12:00:34', '5', '4', '560123-4455', '6', '671205-2727');

#10.
#Skjutbana måste ligga först så funktionären kan tillskrivas denna
insert into skjutbana(skjutbanenr, moment ,faltnamn) values('5', 'stående','Kråk');
#Lägger till ny funktionär som ansvarar för skjutbana 5
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('670809-9999','18000','Jakob','Kråk','5'); 
#Ivar läggs till i skytte-tabellen
insert into skytt(skyttPnr, skyttNamn, lag) values ('860524-1313','Ivar','Lund'); 
#Lägger Ivars gevär
insert into gevar(gevarsnamn, vikt, skyttPnr) values ('Tikka','3.8','860524-1313'); 
 #Lägger till ammunition som tillhör Ivar
insert into ammunition(kaliber, kalibernamn, gevarsNamn, skyttPnr) values('308', 'Spinner', 'Tikka','860524-1313');
#Jakob ansvarar för Ivars ammunition
insert into ammunitionAnsvar(funktionarPnr, kaliber, gevarsNamn, skyttPnr)values('670809-9999', '308', 'Tikka','860524-1313'); 
#En tavla läggs till för skjutserien
insert into maltavla(maltavlaNr, antal) values('1', '5'); 
#Ivars skjutserie läggs till, i denna skjutserie står man då det sker på bana 5, ansvarig funktionär är Jakob
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2016-03-05 12:00:34', '2', '5', '670809-9999', '1', '860524-1313');

#Ligger redan ett antal transaktioner ovan som fyller i tabellerna för att göra vissa transaktioner logiska, men fyller på med 3-4+ transaktioner för varje tabell nedan
#skjutfalt 
insert into skjutfalt(faltnamn, telefonnummer, stad) values ('Sparre','0700-777777','Tibro'); #Skjutfält som finns, men som vi inte lagrar data för, bara för utfyllnad av data
insert into skjutfalt(faltnamn, telefonnummer, stad) values ('Stäppan','0400-444444','Kalmar');
insert into skjutfalt(faltnamn, telefonnummer, stad) values ('Stallplan','0800-888888','Kristianstad');

#skjutbana - Vi har 10 skjutbanor, för det nämndes i uppgiften
insert into skjutbana(skjutbanenr, moment ,faltnamn) values('6', 'Stående','Kråk');
insert into skjutbana(skjutbanenr, moment ,faltnamn) values('7', 'Ligga','Kråk');
insert into skjutbana(skjutbanenr, moment ,faltnamn) values('8', 'Knä','Kråk');
insert into skjutbana(skjutbanenr, moment ,faltnamn) values('9', 'Stående','Kråk');
insert into skjutbana(skjutbanenr, moment ,faltnamn) values('10', 'Knä','Kråk');

#funktionar - vi har 10 funktionärer, en för varje skjutbana
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('880809-2313','11000','Erika','Kråk','6');
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('631129-7452','11000','Kristoffer','Kråk','7');
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('770707-9762','21000','Yvonne','Kråk','8'); 
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('690419-3222','22000','Wåge','Kråk','9'); 
insert into funktionar(funktionarPnr, lon, funktionarNamn, faltnamn, skjutbanenr) values ('930822-6923','16000','Roger','Kråk','10'); 

#skytt Nya skyttar skapas för utfyllnad, men också för att uppfylla kravet att kunna testa frågeoperationer som introducerats.
insert into skytt(skyttPnr, skyttNamn, lag) values ('911221-6556','Alfred','Lund'); #Skapar nya skyttar
insert into skytt(skyttPnr, skyttNamn, lag) values ('820127-7667','Rebecka','Göteborg'); 
insert into skytt(skyttPnr, skyttNamn, lag) values ('770201-8778','Gunnar','Umeå'); 
insert into skytt(skyttPnr, skyttNamn, lag) values ('790211-9889','Pontus','Skultorp'); 
insert into skytt(skyttPnr, skyttNamn, lag) values ('490710-3287','Sally','Roslagen'); 
#Nedan skytt är en testskytt som är tillagd för att kunna testa en frågeoperation som hittar personnumren med fel formattering.
insert into skytt(skyttPnr, skyttNamn, lag) values ('49ds10d3dd7','Testare','Testlag');

#gevar Varje skytt har inte nödvändigtvis ett gevär eller ammunition tilldelat dem, detta kan tänkas vara skyttar som skrivit upp sig för att tävla men som inte kan ta del först än dem skaffat detta.
insert into gevar(gevarsnamn, vikt, skyttPnr) values ('Benelli','6.2','911221-6556');
insert into gevar(gevarsnamn, vikt, skyttPnr) values ('Beretta','4.4','820127-7667');
insert into gevar(gevarsnamn, vikt, skyttPnr) values ('Sauer','3.6','770201-8778');
insert into gevar(gevarsnamn, vikt, skyttPnr) values ('Ruger','3.4','790211-9889');

#ammunition Ammunition tilldelas de skyttar som kan tänkas ta del i skjutserier.
insert into ammunition(kaliber, kalibernamn, gevarsNamn, skyttPnr) values('4.5', 'Cobra', 'Benelli','911221-6556');
insert into ammunition(kaliber, kalibernamn, gevarsNamn, skyttPnr) values('9mm', 'JSB', 'Beretta','820127-7667');
insert into ammunition(kaliber, kalibernamn, gevarsNamn, skyttPnr) values('452', 'Meisterkugeln', 'Sauer','770201-8778');
insert into ammunition(kaliber, kalibernamn, gevarsNamn, skyttPnr) values('6mm', 'Jumbo', 'Ruger','790211-9889');

#maltavla Då varje skjutserie måste ha en måltavla skapades ett par för att kunna trycka in dessa i de.
insert into maltavla(maltavlaNr, antal) values('8', '5'); 
insert into maltavla(maltavlaNr, antal) values('12', '5'); 
insert into maltavla(maltavlaNr, antal) values('3', '5'); 
insert into maltavla(maltavlaNr, antal) values('4', '5'); 
insert into maltavla(maltavlaNr, antal) values('5', '5'); 

#skjutserie Ännu mer utfyllnad för att utöka datan bland tabellerna, det har även lagts till skjutserier i efterhand för att en frågeoperation ska kunna göras och presenteras.
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2015-09-08 09:00:00', '2', '6', '880809-2313', '12', '911221-6556'); #Se till att dem ansvarar för varsitt pnr
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2014-03-02 11:12:17', '4', '7', '631129-7452', '3', '820127-7667'); 
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2018-03-12 10:09:04', '1', '7', '631129-7452', '3', '911221-6556'); 
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2016-04-11 13:33:24', '5', '8', '690419-3222', '4', '770201-8778'); 
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2016-03-05 14:17:43', '3', '9', '690419-3222', '5', '790211-9889'); 
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2016-02-07 11:18:46', '4', '9', '690419-3222', '5', '820127-7667'); 
#Denna transaktion nedan används för att se till att frågeoperationen, #18 i kapitel 3.3 av inlämning, fungerar. För att testa, ändra dagens datum till dagen innan av vad datumet faktiskt är vid läsning.
insert into skjutserie(starttid, resultat, skjutbanenr, funktionarPnr, maltavlaNr, skyttPnr) values ('2021-05-26 12:18:46', '2', '9', '690419-3222', '5', '820127-7667'); 
 
#ammunitionAnsvar Här sätts de funktionärerna som har ansvar för viss ammunition som tillhör specifika skytte personer.
#Erika ansvarar för Alfreds ammunition
insert into ammunitionAnsvar(funktionarPnr, kaliber, gevarsNamn, skyttPnr)values('880809-2313', '4.5', 'Benelli','911221-6556'); 
#Kristoffer ansvarar för Rebeckas ammunition
insert into ammunitionAnsvar(funktionarPnr, kaliber, gevarsNamn, skyttPnr)values('631129-7452', '9mm', 'Beretta','820127-7667'); 
#Yvonne ansvarar för Gunnars ammunition
insert into ammunitionAnsvar(funktionarPnr, kaliber, gevarsNamn, skyttPnr)values('770707-9762', '452', 'Sauer','770201-8778'); 
#Wåge ansvarar för Pontus ammunition
insert into ammunitionAnsvar(funktionarPnr, kaliber, gevarsNamn, skyttPnr)values('690419-3222', '6mm', 'Ruger','790211-9889'); 
#Per ansvarar för Bosses ammunition. Denna transaktion lades till för att uppfylla uppgift #3 i 3.3, 
#då Bosse redan har gevär och ammunition från tidigare transaktioner 
#behöver han enbart någon som ansvarar för hans ammunition, vilket blir funktionären Per.
insert into ammunitionAnsvar(funktionarPnr, kaliber, gevarsNamn, skyttPnr)values('790129-4444', '22','Izhmash','560123-6666'); 

#3.3 - Frågeoperationer

#1. 
SELECT telefonnummer FROM skjutfalt WHERE faltnamn="Kråk";
#Med denna operation vill vi hämta telefonnumret som ligger lagrat i skjutfält tabellen där dess fältnamn överenstämmer med Kråk.

#2. 
SELECT lon, funktionarNamn FROM funktionar WHERE funktionarPnr="790129-4444";
#Med denna operation vill vi få fram lön och funktionärsnamn från tabellen funktionär, där funktionärens personnummer är 790129-4444.

#3. Vi behöver funktionär tabellen för funktionärens namn, vi behöver ammunitionAnsvar för relationen och vi behöver ammunition för kalibernamn
SELECT funktionarNamn FROM funktionar, ammunitionAnsvar, ammunition WHERE funktionar.funktionarPnr=ammunitionAnsvar.funktionarPnr AND ammunition.kaliber=ammunitionAnsvar.kaliber AND ammunition.kalibernamn='x-act';
/* För att hämta korrekt funktionärs namn, så måste vi ha med tre tabeller, först funktionär som innehåller funktionärens namn och personnummer, 
sedan ammunitonsansvar tabellen för att jämföra personnummer från vem som har ansvar mot de existerande personnumren samt att denna tabell håller 
information för vem som har ansvar för en viss kaliber vilket jämförs mot ammunition tabellen, slutligen kollar vi efter kalibernamnet ”x-act” som ligger lagrat i ammunitionstabellen.*/

#4.
SELECT skytt.skyttPnr FROM skytt, gevar, ammunition WHERE ammunition.skyttPnr=skytt.skyttPnr AND gevar.gevarsNamn="Izhmash" AND ammunition.gevarsnamn=gevar.gevarsnamn AND gevar.skyttPnr=skytt.skyttPnr AND ammunition.kaliber="22" AND ammunition.kalibernamn="x-act";
# Vi vill hämta skyttens personnummer med geväret Izhmash, och ammunition med kaliber 22 samt kalibernamnet x-act, för att göra detta behöver vi de tabeller som är beroende av varandra.
# Vi behöver alltså ammunition, som identifieras av geväret och en skytts personnummer, vi behöver också gevärs-tabellen som identifieras av skyttens personnummer. Sedan binder vi ihop dessa ända från ammunition till skytte tabellen, där vi först kollar
# i ammunitionen vilket personnumret är för att identifiera vem som äger ammunitionen, sedan fortsätter vi i vårt conditional där personnumret för ammunition överensstämmer med gevär, specifikt där personnumret är detsamma.
# Sedan jämför vi vem som äger geväret genom personnumret mot skytte-tabellen, och där hittar vi vår match.

#5. 
SELECT funktionarNamn FROM funktionar, skjutbana WHERE funktionar.skjutbanenr=skjutbana.skjutbanenr AND skjutbana.moment='stående';
#Vi hämtar funktionär namnen på alla som ansvarar för en skjutbana med momentet stående. Då funktionär tabellen innehåller 
#skjutbanornas nummer kan vi helt enkelt jämföra mot skjutbane tabellens skjutbanenummer och kolla skjutbanornas attribut för moment där de är stående.

#6.
SELECT funktionarPnr, lon FROM funktionar WHERE funktionar.lon IN ( SELECT lon FROM funktionar GROUP BY lon HAVING COUNT(*) > 1);
#Där det finns fler än en lönesummor som överensstämmer med varandra, så skrivs de löntagarnas personnummer ut. För detta krävs enbart funktionär tabellen, då all data finns lagrad där.
#Har även inkluderat lön i select för att underlätta vid jämförelse mellan de personer som har lika mycket i lön. Genom GROUP BY så grupperas rader som har lika värde och med COUNT säger vi 
#att vi bara vill ha fram instanser där lön är lika för mer än en person.

#7. Hämta personnumret för de skyttar som inte deltagit i en skjutserie. 
SELECT skytt.skyttPnr FROM skytt LEFT JOIN skjutserie ON skytt.skyttPnr = skjutserie.skyttPnr WHERE skjutserie.skyttPnr IS NULL;
#Här vill vi hämta personnumret för de skyttar som inte deltagit i en skjutserie. För detta behöver vi två tabeller, skytt tabellen
#och skjutserie tabellen, vi använder en LEFT JOIN för att returnera alla instanser från skytt tabellen och de matchande instanserna
#från skjutserie tabellen där skyttarnas personnummer jämförs mot dem som ligger i skjutserien, för att få fram de som inte 
#deltagit så sätter vi de motsvarande skytte personnumrena till IS NULL då dem inte ska finnas i skjutserien.

#8. De tables vi behöver: skjutserie, skytt
SELECT skytt.lag FROM skytt, skjutserie WHERE skytt.skyttPnr=skjutserie.skyttPnr AND skjutserie.resultat='5' GROUP BY skytt.lag; 
#För att hämta lag som har skyttar som träffat 5 måltavlor under sen serie behöver vi skytt tabellen, och skjutserie tabellen. 
#Vi jämför helt enkelt skyttarnas personnummer mot de som ligger lagrade i skjutserie tabellen och tar fram de som har 5 i resultat.
#Sedan grupperar vi dessa efter lag genom GROUP BY för att få summerande rader.

#9. 
SELECT skytt.skyttPnr, skyttNamn, lag FROM skytt LEFT JOIN skjutserie ON skytt.skyttPnr = skjutserie.skyttPnr WHERE skjutserie.skyttPnr IS NOT NULL GROUP BY skyttPnr;
#Denna är i princip densamma lösning som vi har i uppgift #7 ovan, skillnaden är dock att vi hämtar specifikt skyttarnas personnummer, 
#namn och lag och gör en jämförelse mellan de matchande personnumrena i skjutserie och skytt tabellen där vi säger att personnumret 
#inte får vara null, alltså skyttarnas personnummer måste existera i skjutserie.skyttPnr.

#10. 
SELECT funktionar.funktionarNamn, COUNT(skjutserie.funktionarPnr)
FROM funktionar INNER JOIN skjutserie ON funktionar.funktionarPnr=skjutserie.funktionarPnr
GROUP BY funktionar.funktionarNamn HAVING COUNT(skjutserie.funktionarPnr)=2;
#För denna frågeoperation behöver vi två tabeller, funktionär och skjutserie tabellen. 
#Med en INNER JOIN för skjutserien kollar vi för där de tabellerna matchar genom 
#funktionärs personnummer, sedan grupperar vi dem efter deras namn där de funktionärerna 
#deltagit i exakt två skjutserier genom COUNT funktionen.

#11.
SELECT funktionarNamn  FROM funktionar ORDER BY funktionarNamn DESC;
#Denna operation är simpel, genom tabellen funktionär tar vi fram alla funktionärers namn, 
#och sorterar dem med ORDER BY funktionen i nedstigande ordning med hjälp av DESC funktionen.
#En av huvudanledningarna till att inga variablar eller data skrivs med ÅÄÖ genom denna inlämning 
#är för att undvika konflikter med sorterarfunktioner.

#12. 
SELECT AVG(CAST(resultat AS DECIMAL)) FROM skjutserie;
#Även denna är relativt simpel, den använder sig ut av skjutserie tabellen och hämtar in alla 
#resultat och använder AVG funktionen på den för att få fram medelvärdet på alla resultat i decimal form.

#13.
SELECT skjutbana.skjutbanenr, AVG(CAST(resultat AS CHAR)) FROM skjutbana, skjutserie WHERE skjutbana.skjutbanenr=skjutserie.skjutbanenr GROUP BY skjutbana.skjutbanenr;
#För denna operation behöver vi skjutbana tabellen och skjutserie tabellen. Vi vill få fram skjutbanornas nummer, 
#och medelvärdet på det resultat av de skjutserier som skett på dessa banor.
#Detta görs enkelt genom att jämföra skjutbanans nummer mot skjutseriernas skjutbana nummer, 
#sedan grupperas de med GROUP BY för att få summerande rader för skjutbanornas skjutbanenummer.

#14.
SELECT * FROM skytt WHERE skytt.lag LIKE 'r%';
#Detta är en enkel operation som hämtar allt från skytt tabellen där skyttars lag börjar med bokstaven R, 
#detta görs genom LIKE som är en logisk operator som avgör ifall en karaktär sträng matchar ett specificerat format, i detta fallet, 
#ifall lagnamnet börjar med ett R. Behövde även lägga till en egenkomponerad transaktion för att uppfylla kravet för denna frågeoperation, 
#detta gjordes genom att lägga till en ny skytt som är del i laget ”Roslagen”.

#15. 
SELECT skyttNamn, lag FROM skytt WHERE skytt.skyttPnr NOT RLIKE '[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]';
#Denna operation kan vara något svårläslig men den representerar hur formatet ska se ut för personnummer, 
#där det först finns 6 karaktärer som är nummer följt av ett bindestreck, 
#och sedan de resterande 4 numren som personnummer består utav. För detta behövs 
#enbart skytt tabellen, där skyttarnas namn och personnummer ligger lagrade. 
#Skapade ännu en egenkomponerad transaktion (Testare heter skytten) för att kunna 
#redovisa att denna frågeoperation fungerar, alltså skapades en ny skytt med felaktigt personnummer.

#16.  
SELECT funktionarNamn FROM funktionar WHERE funktionar.lon = (SELECT MAX(lon) from funktionar); 
#Denna operation behöver enbart funktionär tabellen, vad som sker är att vi hämtar funktionärnamnet för den person som tjänar mest.
#Detta görs genom att använda subquery med MAX() funktionen för att returnera det högsta värdet av den valda kolumnen, 
#i detta fall, lön från funktionärtabellen, denna jämförs sedan mot de löner som finns och den som är motsvarande får sitt funktionärs namn utskrivet.

#17.
SELECT starttid, skyttNamn FROM skytt, skjutserie WHERE starttid = (SELECT Max(starttid) FROM  skjutserie WHERE skytt.skyttPnr = skjutserie.skyttPnr) ORDER BY starttid DESC LIMIT 1;
#Hämtar alla starttider som skyttar påbörjat sina skjutserier och listar dem från det äldsta datumet till det senaste, 
#dock begränsar vi antalet rader vi får ut och vi vänder på listan med hjälp av DESC. 
#En subquery används då vi behöver returnera max starttiden från skjutserien och jämföra mot starttiden.

#18. 
SELECT * FROM skjutserie WHERE date(starttid) = CURDATE() - INTERVAL 1 DAY;
#Eftersom inga skjutserier påbörjats dagen innan, så måste en sådan läggas till för att pröva denna frågeoperation, detta har gjorts bland de egenkomponerade skjutserierna.
#En simpel frågeoperation som listar allt från de skjutserierna som tagit plats en dag innan. 
#Date tar starttid som argument, vars datatyp är datetime som är kompatibla med varandra. 
#In i detta värde laddar vi  det aktuella datumet minus en dag, då får vi alltså den senaste dagen, 
#och på så vis får vi de skjutserier som skett dagen innan. (Förutsatt att dem satts för dagen innan i transaktionerna).

#19.  
SET SQL_SAFE_UPDATES=0; #Gör så att man kan uppdatera, annars blockeras uppdatering av safe mode
UPDATE funktionar SET lon=lon+(lon*3/100) WHERE lon BETWEEN 10000 AND 12000;
SELECT lon FROM funktionar WHERE funktionarPnr="880809-2313"; 
#Detta är bara för att visa att frågeoperationen fungerar, till en början har funktionären en lön på 11000, efter frågeoperationen ökas denna till 11330.
#För att kunna göra denna frågeoperation måste SQL_SAFE_UPDATES stängas ned, 
#då den tidigare förhindrade uppdateringar. Sedan för att öka lönen med 3% för 
#alla med en lön mellan 10000 och 12000 så används en SET operator som låter en 
#kombinera ett resultat av två queries in i en enda, vi tar alltså den lön de 
#redan har och ökar den med gånger 1,03 för att på så sätt öka den med 3%.

#20. 
DELETE FROM maltavla WHERE maltavlaNr='8';
SELECT * FROM maltavla WHERE maltavlaNr='8'; #Denna läggs till för att visa att den tagits bort
#Måltavla 8 går att ta bort, dock om den skulle tillhöra en skjutserie skulle det uppstå problem, 
#då skjutserie är en svag entitet som har en identifierande relation med måltavla.

#21. 
DELETE FROM skjutserie WHERE starttid='2012-01-21 12:01:33' AND skyttPnr="560123-6666"; 
#Denna skjutserie går bra att ta bort utan större konsekvenser eftersom att skjutserie är en svag entitet.