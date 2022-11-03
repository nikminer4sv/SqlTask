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
	PRIMARY KEY (bank_id, client_id)
);

CREATE TABLE IF NOT EXISTS bank_cards (
	bank_id serial NOT NULL,
	client_id serial NOT NULL,
	number text NOT null,
	FOREIGN KEY (bank_id, client_id) 
		REFERENCES accounts (bank_id, client_id)
);

/* DATA INITIALIZATION */

/* cities */
INSERT INTO cities (title) VALUES('Minsk'),('Gomel'),('Brest'),('Mogilev'),('Grodno');

/* banks */
INSERT INTO banks (title) VALUES('Belarusbank'),('Belinvest'),('Alphabank'),('Tinkoff'),('Priorbank');

/* subsidiaries */
INSERT INTO subsidiaries (bank_id, city_id, address) VALUES(1, 1, 'Kurchatova 8'),(2,2,'Landera'),(3,3,'Papanina'),(4,4,'Molodezhnaya'),(5,5,'Bykhovskaya');

/* social_statuses */
INSERT INTO social_statuses (title) VALUES ('Status 1'),('Status 2'),('Status 3'),('Status 4'),('Status 5');

/* clients */
INSERT INTO clients (status_id, name, surname, patronymic, birth_date) VALUES(1, 'Nikita', 'Korotki', 'Denisovich', '04.11.2003'),(2, 'Nik', 'Dlinni', 'Hz', '04.11.2010'),(3, 'John', 'John', 'John', '11.08.1103'),(4, 'Adam', 'NeAdam', 'TochnoNeAdam', '01.08.1998'),(5, 'Leonardo', 'Donatelo', 'Rafael', '04.11.1000');

/* accounts */
INSERT INTO accounts(bank_id, client_id, username, password, email) VALUES(1,1,'nikminer4sv','7514895263q', 'nikminer4sv@gmail.com'),(2,2,'qwerty','263', 'nikm@gmail.com'),(3,3,'wasdddd','wasdpsw', 'wasd@gmail.com'),(4,4,'qwertyyuadsf','bbbbbbbbbb', 'adsfadsf@adsfadsf.com'),(5,5,'vvvvv','vvv', 'v@gmail.com');

/* bank_cards */
INSERT INTO bank_cards(bank_id, client_id, number) VALUES(1,1,'132131231311231231'),(2,2,'555555555555'),(3,3,'1234432112344321'),(4,4,'7890789078907890'),(5,5,'456613123123123123131123');
