create database salesanalytics
go
use salesanalytics
go
create table clients
(client_id int primary key, 
nom_client varchar(100) not null,
ville varchar(100) not null,
segment_client varchar(30)
)
go
insert into clients (client_id, nom_client, ville, segment_client)
values
('1','mbuyi patrick','kinshasa','particulier'),
('2','kanku services','kinshasa','entreprise'),
('3','ilunga sarah','lubumbashi','particulier'),
('4','katanga business','lumbubashi','entreprise'),
('5','mukendi jean','kisangani','particulier'),
('6','congo tech SARL','kisangani','entreprise'),
('7','kabeya mireille','goma','particulier'),
('8','virunga solutions','goma','entreprise'),
('9','tshibanga alain','kinshasa','particulier'),
('10','digital plus RDC','lubumbashi','entreprise')
go
select*from clients
create table produits
(produits_id int primary key, 
nom_produit varchar(100) not null,
categorie varchar(50) not null,
cout_achat decimal (12,2) not null)
go
insert into produits (produits_id, nom_produit,categorie,cout_achat)
values
('1','samsung galaxy A15','telephones','150.00'),
('2','iphone 13','telephones','450.00'),
('3','techno spark 20','telephones','110.00'),
('4','redmi note 13','telephones','100.00'),
('5','chargeur USB-C','accessoires','5.00'),
('6','ecouteurs bluethooth','accessoires','12.00'),
('7','coque de telephone','accessoires','3.00'),
('8','clavier sans fil','informatique','18.00'),
('9','souris sans fil','informatique','8.00'),
('10','ordinateur portable HP','informatique','520.00')
go
select * from produits
create table villes
(ville_id int primary key,
nom_ville varchar(50) not null,
province varchar(50) not null)
go
insert into villes (ville_id,nom_ville,province)
values 
('1','kinshasa','kinshasa'),
('2','lubumbashi','haut-katanga'),
('3','kisangani','tshopo'),
('4','goma','nord-kivu')
go
select*from villes
create table vente
(vente_id int primary key,
date_vente date not null,
client_id int not null,
produit_id int not null,
quantite int not null,
prix_vente decimal(12,2) not null,
remise decimal(12,2) not null default 0,
constraint fk_vente_clients foreign key (client_id) 
references clients(client_id),
constraint fk_vente_produits foreign key (produit_id)
references produits(produits_id),
constraint ck_vente_prix
check (prix_vente >=0),
constraint ck_ventes_remise
check (remise>= 0 and remise<= 100)
)
go
insert into vente (vente_id,date_vente,client_id,produit_id,quantite,prix_vente, remise)
values 
('1','2026-01-05','1','1','2','190.00','0'),
('2','2026-01-12','2','5','10','8.00','5'),
('3','2026-01-20','3','3','3','140.00','0'),
('4','2026-02-03','4','10','1','650.00','10'),
('5','2026-02-15','5','6','5','20.00','0'),
('6','2026-02-02','6','8','4','28.00','5'),
('7','2026-03-18','7','2','1','520.00','0'),
('8','2026-04-07','8','7','15','00','0'),
('9','2026-04-22','9','4','2','20.00','5'),
('10','2026-05-11','10','9','6','15.00','0'),
('11','2026-05-25','1','10','2','640.00','5'),
('12','2026-06-09','2','3','4','135.00','0'),
('13','2026-06-21','3','5','20','7.50','10'),
('14','2026-07-04','4','1','3','185.00','0'),
('15','2026-07-19','5','8','5','30.00','5'),
('16','2026-08-06','6','2','2','510.00','10'),
('17','2026-08-17','7','6','8','18.00','0'),
('18','2026-09-03','8','4','3','210.00','5'),
('19','2026-09-16','9','10','1','680.00','0'),
('20','2026-09-28','10','7','25','4.50','0')
go
select*from vente
-----calcule de chiffre d'affaires----
select
SUM(quantite*prix_vente) as chiffre_affaires_brut
from vente
----calcule de chiffre d'affaires apres remise --
select 
SUM(quantite* prix_vente * (1 - remise/ 100.00)
)as chiffre_affaire_net
from vente
----analyser le chiffre d'affaires par mois ---
select 
YEAR(date_vente) as annee,
MONTH(date_vente) as mois,
SUM(quantite* prix_vente * (1- remise / 100.00)
)as chiffre_affaire_net
from vente
group by 
YEAR(date_vente),
MONTH(date_vente)
order by
annee, mois
---chiffre d'affaires net par produit---
select
P.produits_id,
P.nom_produit,
P.categorie,
SUM(V.quantite) as quantite_vendue,
SUM(V.quantite * V.prix_vente * (1 -V.remise / 100.00)
) as chiffre_affaire_net
from vente as V inner join produits as P
on V.produit_id = P.produits_id
group by 
P.produits_id,
P.nom_produit,
P.categorie
order by
chiffre_affaire_net DESC
----calcule de la matge brute par produit---
select 
P.nom_produit,
SUM(V.quantite) as quantite_vendue,
SUM(V.quantite * V.prix_vente * (1- V.remise / 100.00)
) as chiffre_affaire_net,
SUM(V.quantite* P.cout_achat
) as cout_total_achat,
SUM(V.quantite* V.prix_vente * (1- V.remise / 100.00)
)- SUM(V.quantite * P.cout_achat) as marge_brute
from vente as V
inner join produits as P
on V.produit_id = P.produits_id
group by 
P.nom_produit
order by
marge_brute DESC
---- chiffre d'affaire par client---
select
C.client_id,
C.nom_client,
C.ville,
C.segment_client,
COUNT(V.vente_id) as nombre_vente,
sum(V.quantite * V.prix_vente * (1 -V.remise /100.00)
) as chiffre_affaire_net
from vente as V
inner join clients as C
on V.client_id = C.client_id
group by 
C.client_id,
C.nom_client,
C.segment_client,
C.ville
order by 
chiffre_affaire_net DESC
-----analyser l'impact des remises sur la marge---
with venteavecremise as (
select
V.*,
P.cout_achat,
CASE
WHEN V.remise = 0 then 'sans remise '
WHEN V.remise <+ 5 then 'remise jusqu''a 5%'
ELSE 'remise superieure a 5%' end categorie_remise
from vente as V
inner join produits as P
on V.produit_id = V.produit_id
)
select 
categorie_remise,
COUNT(vente_id) as nombre_vente,
SUM(quantite * prix_vente) as chiffre_affaire_brut,
sum(quantite*cout_achat) as cout_total_achat,
sum(quantite * prix_vente *(1- remise / 100.0)) 
- SUM(quantite *cout_achat) as marge_brute
from venteavecremise
group by categorie_remise
order by marge_brute DESC
 ----nous allons creer une vue maintenant pour congo distribution, elle nous permettra de reutiliser 
 ---facilement les informations de ventes, clients et produits sans reecrire les join a chaque fois---
 create view vw_analyse_vente AS
 select 
 V.vente_id,
 V.date_vente,
 C.nom_client,
 C.ville,
 C.segment_client,
 SUM(V.quantite) as quantite_total,
 sum(quantite * V.prix_vente * (1- V.remise / 100.00)) as chiffre_affaire_net,
 V.remise
 from vente as V
 inner join clients as C 
 on V.client_id = V.client_id
 group by 
 V.vente_id,
 V.date_vente,
 C.nom_client,
 C.ville,
 C.segment_client,
 V.remise
 go
 select * from vw_analyse_vente
 select
 V.vente_id,
 V.produit_id,
 P.produits_id,
 P.nom_produit
 from dbo.vente as V
 inner join dbo.produits as P
 on V.produit_id = P.produits_id
 order by V.vente_id
 -----voici une solution : exporter les ventes directement depuis les tables d'origine, 
 ----sans utiliser la vue qui produit les doublons----
 select
 V.vente_id,
 V.date_vente,
 V.client_id,
 V.produit_id,
 V.quantite,
 V.prix_vente,
 V.remise,
 P.cout_achat,
 V.quantite*V.prix_vente as chiffre_affaires_brut,
 V.quantite*V.prix_vente * V.remise / 100.0 as montant_remise,
 V.quantite* V.prix_vente * (1 - V.remise / 100.0) as chiffre_affaires_net
 from dbo.vente as V
 LEFT join ( 
 select produits_id, MAX(cout_achat) as cout_achat
 from dbo.produits
 group by produits_id
 ) as P
 on V.produit_id = P.produits_id
 ORDER BY V.vente_id
