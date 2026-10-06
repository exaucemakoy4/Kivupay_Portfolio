create database kivupay
use kivupay
go
create table clients
(client_id varchar(10) primary key,
nom varchar(50),
prenom varchar(50),
ville varchar(50),
segment varchar(30)
)
go
create table agent
(agent_id varchar(10) primary key,
nom varchar(50),
prenom varchar(50),
ville varchar(50),
date_recrutement date
)
go
create table transactions
(transaction_id varchar(10) primary key,
date_transaction date,
client_id varchar(10),
agent_id varchar(10),
montant decimal(12,2),
frais decimal(12,2),
statut varchar(20),
motif_echec varchar(100),
foreign key (client_id) references clients(client_id),
foreign key (agent_id) references agent(agent_id)
)
go
create table incidents
(incident_id varchar(10) primary key,
transaction_id varchar(10),
type_incident varchar(50),
description varchar(150),
gravite varchar(20),
date_incident date,
foreign key (transaction_id) references transactions(transaction_id)
)
go

----------premiere requete-----
select*from clients
select*from agent
select*from transactions
select*from incidents
---- insertion des données-----
use kivupay
go

insert clients ( client_id,nom,prenom,ville,segment)
values
('CL002','MARTIN','JEAN','KINSHASA','MARCHAND'),
('CL003','Mbuyi','elie','KINSHASA','PME'),
('CL004','kongi','divine','BOMA','marchand'),
('CL005','luza','christ','goma','PME'),
('CL006','david','loya','matadi','particulier')
insert agent (agent_id,nom,prenom,ville,date_recrutement)
values
('AG001','lukaku','gloire','kinshasa','02/04/2012'),
('AG002','KITIMINI','BENITO','KINSHASA','04/04/2014'),
('AG003','MAKOY','EXAUCE','MATADI','04/04/2001'),
('AG004','MAVANGA','TOBY','GOMA','08/06/2000'),
('AG005','YONGELI','JEANNOT','BOMA','11/12/2020')
insert into transactions (transaction_id,date_transaction,client_id,agent_id,montant,frais,statut,motif_echec)
values
('TR001','2026/04/04','CL002','AG001','50000.00','500.00','REUSSIE','NULL'),
('TR002','2025/10/10','CL003','AG003','80000.00','3000.00','REUSSIE','NULL'),
('TR003','2020/03/01','CL005','AG005','10000.00','500.00','NON REUSSIE','REFUS'),
('TR004','2021/04/08','CL004','AG004','20000.00','600.00','NON REUSSIE','IMPREVU'),
('TR005','2022/08/25','CL006','AG002','30000.00','500.00','REUSSIE','NULL')
insert into incidents (incident_id,transaction_id,type_incident,description,gravite,date_incident)
values
('INC001','TR001',NULL,'TRANSACTION REUSSIE','NORMALE',NULL),
('INC002','TR002',NULL,'TRANSACTION REUSSIE','NORMALE',NULL),
('INC003','TR003','REFUS DE COOPERER','TRANSACTION ECHOUE','MOYENNE','2020/03/01'),
('INC004','TR004','IMPREVU','TRANSACTION ECHOUE','FAIBLE','2021/04/08'),
('INC005','TR005',NULL,'TRANSACTION REUSSIE','NORMALE',NULL)
------notre base kivupay fonctionne correctement-------
------on passe a l'analyse SQL-------
---premiere question business---
---combien avons nous de clients dans notre base ? -----
select COUNT(*)
From clients;
select count(*)
from agent
----- combien avons nous de transactions dans notre base---
select count(*)
from transactions
------quel est le montant total de toutes nos transactions ?-----
select SUM(montant)
from transactions
---quel est le montant total des frais generes par les transactions ?----
select sum(frais)
from transactions
----combien de transaction reussi ?----
select count(*)
from transactions
where statut ='reussie'
select count(*)
from transactions
where statut = 'echoue'
------cela affiche les requetes des valeurs differentes reellement presentes dans un statut----
select distinct statut
from transactions
---et on a refait avec une legere modification----
select count(*)
from transactions
where statut = 'non reussie'
select count(*)
from transactions
where statut = 'reussie'
-----quels sont les motifs d'echec enregistres pour ces transactions---
select motif_echec
from transactions
where statut = 'non reussie'
-----combien de transactions avons nous pour chaque statut ? apres BY on remet toujour ce qui vient apres select----
select statut, count(*)
from transactions
group by statut
----quel est le montant total des transactions pour chaque statut ? -----
select statut, SUM(montant)
from transactions
group by statut
------ qeuel est le montant total de frais pour chaque statut ? ----
select statut, sum(frais)
from transactions
group by statut
select motif_echec, count(*)
from transactions
where statut = 'non reussie'
group by motif_echec
---- quel est le taux de reussite des transactions ? ----
select count(case when statut ='reussie' then 1 end)*100.0/count(*) AS taux_reussite
from transactions
----- Q11/ pour chaque agent, combien de transactions a t il realisées ? -------
select agent_id, count(*)
from transactions
group by agent_id
----Q12/ quel est le montant total des transactions realisé par chaque agent ? -----
select agent_id, sum(montant)
from transactions
group by agent_id
----Q13/ combien de frais chaque agent a t il generes ? -----
select agent_id, sum(frais)
from transactions
group by agent_id
----Q14/ pour chaque agent, combien de transactions non reussie a t il eues ? ---
select agent_id, count(*)
from transactions
where statut = 'non reussie'
group by agent_id
----Q15/ combien d'incidents sont enregistrés au total dans kivupay ? -----
Select count(*)
from incidents
----Q16/ combien d'incidents avons nous pour chaque type d'incident ? -----
select type_incident, count(*)
from incidents
group by type_incident
-----Q17/ combien d'incidents avons nous pour chaque niveau de gravité ? ----
select gravite, count(*)
from incidents
group by gravite
-----Q18/ quel est le nom de chaque agent et combien de transactions a t il realisées ? -----
select agent.nom, count(*)
from transactions
join agent
on transactions.agent_id = agent.agent_id
group by agent.nom;
----NB: le join permet de dire : va chercher le nom de l'agent dans l'agent 
-----grace a son agent_id present dans la transaction----
----Q19/ afficher le nom de chaque agent et le montant total des transactions qu'il a realisées ? ---
select agent.nom, sum(montant)
from transactions
join agent
on transactions.agent_id = agent.agent_id
group by agent.nom
---Q20/ ajouter le nombre de transactions plus le montant total plus le frais le tout par agent--
select agent.nom, count(*), sum(montant), sum(frais)
from transactions
join agent
on transactions.agent_id = agent.agent_id
group by agent.nom 
----parce que les fonctions d'agregation comme count(*), sum(montant) et sum(frais) calculent de
---- nouvelles valeurs qui n'existent pas directement sous forme de colonne nommee dans la base de donnee---
---NB: pour leur attribuer unnom dans le resultat, il faut utiliser un alias de colonne avec le mot clé AS---
select agent.nom, count(*) AS nombre_transactions,
sum(montant) as total_montant, sum(frais) as total_frais
from transactions
join agent
on transactions.agent_id = agent.agent_id
group by agent.nom
----Q21/ analyse des echecs par agent----
--- d'ou on aura le nom de chaque agent + le nombre de transactions non reussie--
select agent.nom as nom_agent, count(*) as transactions_non_reussies
from transactions
join agent
on transactions.agent_id = agent.agent_id
where statut = 'non reussie'
group by agent.nom
---Q22/taux de reussite par agent ? ----
---afficher le nom de chaque agent et son taux de reussite--
select agent.nom as nom_agent, count(case when transactions.statut = 'reussie' then 1 end) * 100.0
/count(*) as taux_reussite
from transactions
join agent
on transactions.agent_id = agent.agent_id
group by agent.nom
-----Q23/ quel est le montant total des transactions reussies pour chaque agent ?---
select agent.nom as nom_agent, sum(transactions.montant) as montant_total_reussi
from transactions
join agent
on transactions.agent_id = agent.agent_id
where statut = 'reussie'
group by agent.nom
---Q24/ frais generes par agent sur les transactions reussies ?-----
select agent.nom as nom_agent, sum(transactions.frais) as montant_total_reussi
from transactions
join agent
on transactions.agent_id = agent.agent_id
where statut = 'reussie'
group by agent.nom
 ----Q25/ total des transactions par ville ---
 select agent.ville as ville, sum(transactions.montant) as montant_total
from transactions
join agent
on transactions.agent_id = agent.agent_id
group by agent.ville
-----Q27/ incidents par gravite ? ----
select gravite as niveau_gravite,count(*)
as nombre_incidents
from incidents
group by gravite
------Q28/ synthese finale par agent----
select agent.nom as nom_agent,
count(*) as nombre_transactions,
sum(transactions.montant) as montant_total,
sum(transactions.frais) as frais_total
from transactions
join agent
on transactions.agent_id = agent.agent_id
group by agent.nom


---- creation d'une vue de nos 3 tables ------
----notre vue concerne que la transaction ce qui nous amenes a choisir agents,clients et transactions 
select transactions.date_transaction as date_transactions,
agent.nom as nom_agent,
agent.ville as ville_agent,
clients.nom as nom_client,
transactions.montant as montant,
transactions.frais as frais,
transactions.statut	as statut,
transactions.motif_echec as motif_echec
from transactions
join agent
on transactions.agent_id = agent.agent_id
join clients
on transactions.client_id = clients.client_id
-------la creation d'une vraie VIEW OU VUE -------
go
create view vw_analyse_transactions as
select transactions.date_transaction as date_transactions,
agent.nom as nom_agent,
agent.ville as ville_agent,
clients.nom as nom_client,
transactions.montant as montant,
transactions.frais as frais,
transactions.statut	as statut,
transactions.motif_echec as motif_echec
from transactions
join agent
on transactions.agent_id = agent.agent_id
join clients
on transactions.client_id = clients.client_id

-----verifier notre vue -----
select *
from vw_analyse_transactions
-----le nombre de lignes de notre vue---
select count(*) as nombre_lignes
from vw_analyse_transactions
go
create view vw_analyse_incidents as
select incidents.incident_id,
incidents.transaction_id,
incidents.type_incident,
incidents.description,
incidents.gravite,
incidents.date_incident
from incidents
select *
from vw_analyse_incidents
