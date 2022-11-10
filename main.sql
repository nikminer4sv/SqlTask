CREATE TABLE IF NOT EXISTS social_statuses (
	id serial primary key,
	title text not null
);

CREATE TABLE IF NOT EXISTS clients (
	id serial primary key,
	status_id serial not null,
	name text not null,
	surname text not null,
	patronymic text not null,
	birth_date date not null,
	foreign key (status_id)
		references social_statuses(id)
);

CREATE TABLE IF NOT EXISTS banks (
    id serial PRIMARY KEY,
    title TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS cities (
	id serial PRIMARY KEY,
	Title text NOT NULL
);

CREATE TABLE IF NOT EXISTS subsidiaries (
    id serial PRIMARY KEY,
    bank_id serial NOT NULL,
    city_id serial NOT NULL,
    address TEXT NOT NULL,
    FOREIGN KEY (bank_id)
        REFERENCES banks (id),
	FOREIGN KEY (city_id)
		REFERENCES cities (id)
);

CREATE TABLE IF NOT EXISTS accounts (
	bank_id serial, 
	client_id serial,
	username text NOT NULL,
	password text NOT NULL,
	email text NOT NULL,
	balance serial NOT NULL,
	PRIMARY KEY (bank_id, client_id)
);

CREATE TABLE IF NOT EXISTS bank_cards (
	bank_id serial NOT NULL,
	client_id serial NOT NULL,
	number text NOT NULL,
	balance serial NOT NULL,
    PRIMARY KEY (number),
	FOREIGN KEY (bank_id, client_id) 
		REFERENCES accounts (bank_id, client_id)
);

/* DATA INITIALIZATION */

/* cities */
INSERT INTO 
    cities (title) 
VALUES
    ('Minsk'),
    ('Gomel'),
    ('Brest'),
    ('Mogilev'),
    ('Grodno');

/* banks */
INSERT INTO 
    banks (title) 
VALUES
    ('Belarusbank'),
    ('Belinvest'),
    ('Alphabank'),
    ('Tinkoff'),
    ('Priorbank');

/* subsidiaries */
INSERT INTO 
    subsidiaries (bank_id, city_id, address) 
VALUES
    (1, 1, 'Kurchatova 8'),
    (2,2,'Landera'),
    (3,3,'Papanina'),
    (4,4,'Molodezhnaya'),
    (5,5,'Bykhovskaya');

/* social_statuses */
INSERT INTO 
    social_statuses (title) 
VALUES 
    ('Status 1'),
    ('Status 2'),
    ('Status 3'),
    ('Status 4'),
    ('Status 5');

/* clients */
INSERT INTO 
    clients (status_id, name, surname, patronymic, birth_date) 
VALUES
    (1, 'Nikita', 'Korotki', 'Denisovich', '04.11.2003'),
    (2, 'Nik', 'Dlinni', 'Hz', '04.11.2010'),
    (3, 'John', 'John', 'John', '11.08.1103'),
    (4, 'Adam', 'NeAdam', 'TochnoNeAdam', '01.08.1998'),
    (5, 'Leonardo', 'Donatelo', 'Rafael', '04.11.1000');

/* accounts */
INSERT INTO accounts(bank_id, client_id, username, password, email) VALUES(1,1,'nikminer4sv','7514895263q', 'nikminer4sv@gmail.com'),(2,2,'qwerty','263', 'nikm@gmail.com'),(3,3,'wasdddd','wasdpsw', 'wasd@gmail.com'),(4,4,'qwertyyuadsf','bbbbbbbbbb', 'adsfadsf@adsfadsf.com'),(5,5,'vvvvv','vvv', 'v@gmail.com');

/* bank_cards */
INSERT INTO bank_cards(bank_id, client_id, number) VALUES(1,1,'132131231311231231'),(2,2,'555555555555'),(3,3,'1234432112344321'),(4,4,'7890789078907890'),(5,5,'456613123123123123131123');

/* Task 2 */
SELECT title 
FROM banks 
	JOIN (SELECT * FROM subsidiaries WHERE city_id = 3) subsidiaries on subsidiaries.bank_id = banks.id;

/* Task 3 */
SELECT bank_cards.number, banks.title AS bank, clients.name, accounts.balance 
FROM bank_cards 
	JOIN accounts ON bank_cards.bank_id = accounts.bank_id AND bank_cards.client_id = accounts.client_id
	JOIN banks ON bank_cards.bank_id = banks.id
	JOIN clients ON bank_cards.client_id = clients.id;

/* Task 4 */
SELECT 
	accounts.username,
	accounts.email,
	(accounts.balance - bank_cards.balance) AS balance_diff
FROM 
	bank_cards
JOIN
	accounts
ON
	bank_cards.bank_id = accounts.bank_id
	AND
	bank_cards.client_id = accounts.client_id
	AND
	bank_cards.balance != accounts.balance;

/* Task 5.1 */
SELECT 
	DISTINCT title,
	(SELECT COUNT(*) FROM bank_cards WHERE id = bank_cards.client_id)
FROM 
	bank_cards 
JOIN 
	(SELECT 
		clients.id, social_statuses.title, social_statuses.id as social_status_id
	FROM 
		clients 
	JOIN 
		social_statuses ON clients.status_id = social_statuses.id) t ON bank_cards.client_id = t.id;

/* Task 5.2 */
SELECT 
  DISTINCT s.status, 
  COUNT(client_id) 
from 
  (
    SELECT 
      social_statuses.title as status, 
      clients.id as client_id 
    FROM 
      social_statuses 
      JOIN clients ON clients.status_id = social_statuses.id 
      JOIN bank_cards ON bank_cards.client_id = clients.id
  ) s 
GROUP BY 
  s.status 
ORDER BY 
  status;

/* Task 6 */
create or replace procedure add_10_to_accounts(
   status_i int
)
language plpgsql    
as $$
begin
	if not exists(select * from social_statuses where id = status_i) then
		raise exception 'social status % not found', status_i;
	end if;
	
	if not exists(select * from clients where clients.status_id = status_i) then
		raise exception 'social status % not associated with clients', status_i;
	end if;
	
    update accounts 
    set balance = balance + 10 
    where (accounts.client_id, accounts.bank_id) in (select accounts.client_id, accounts.bank_id from accounts join clients on accounts.client_id = clients.id where clients.status_id = status_i);
    commit;
end;$$;

/* Task 7 */
select client_id, SUM(balance) from bank_cards group by client_id;

/* Task 8 */
CREATE PROCEDURE transfer_money_to_card(
	card_number text, 
	amount int,
	bank_id int,
	client_id int
)
LANGUAGE SQL
BEGIN ATOMIC  
	UPDATE bank_cards
	SET balance = balance + amount
	WHERE (bank_cards.client_id, bank_cards.bank_id) = (client_id, bank_id);
END;

/* Task 9 */
CREATE FUNCTION account_balance_control_procedure() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   
   IF new.balance < (select SUM(balance) from bank_cards where (client_id, bank_id) = (old.client_id, old.bank_id)) then
		raise exception 'balance cant be less than balance on the bank cards';
   END IF;
   return new;
END;
$$;

CREATE TRIGGER account_balance_control
	BEFORE UPDATE
   	ON accounts
   	for each row
       EXECUTE PROCEDURE account_balance_control_procedure();

CREATE or replace FUNCTION bank_cards_balance_control_procedure() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   
   IF (select balance from accounts where (client_id, bank_id) = (old.client_id, old.bank_id)) < (select SUM(new.balance) from bank_cards where (client_id, bank_id) = (old.client_id, old.bank_id) group by(client_id, bank_id) ) then
		raise exception 'balance cant be less than balance on the bank cards';
   END IF;
   return new;
END;
$$;

CREATE TRIGGER bank_cards_balance_control
	BEFORE UPDATE
   	ON bank_cards
   	for each row
       EXECUTE PROCEDURE bank_cards_balance_control_procedure();
