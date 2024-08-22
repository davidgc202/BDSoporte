CREATE DATABASE AIRPORTFLIGHT
USE AIRPORTFLIGHT
-- DAVID GARCIA CABALLERO 217058795
--DROP DATABASE AIRPORTFLIGHT
Create table Country(
ID int primary key not null,
Nombre varchar(30) not null,
)

CREATE TABLE City(
ID varchar(5) primary key not null,
Nombre varchar(30) not null,
ID_Country int not null,
foreign key(ID_Country) references Country(ID),
-- como composicion tambien 
)
CREATE TABLE Airport (
ID INT PRIMARY KEY,
NameAirport varchar(50),
ID_City varchar(5) not null,
foreign key(ID_City) references City(ID),
)

 CREATE TABLE PlaneModel(
 IDPM int primary key not null,
DescriptionPM varchar(300) not null,
-- Graphic  varchar(200),
 )

 CREATE TABLE Airplane(
 Registration_Number Varchar(50) PRIMARY KEY not null,
 Begin_of_Operation datetime not null,--yyyy/mm/dd hh:mm:ss
 statusplane varchar(20) not null,
 IDPModel int not null,
 foreign key(IDPModel) references PlaneModel(IDPM),
 )
 CREATE TABLE Seat(
 size int  not null,
 IDPS int not null,
 number int not null,
 LocationSeat int not null,
 primary key(IDPS,size), 
 foreign key (IDPS) references PlaneModel(IDPM),
 )
 CREATE TABLE Document(
 ID int primary key not null,
 FechaEmision date not null,
 FechaExpiracion date not null,
 )
 create table ClassCustomer(
 ID int primary key not null,
 Tipo varchar(30) not null,
 nivel varchar(30) not null,
 ID_Customer int not null,
 foreign key(ID_Customer) references Customer(IDC),
 )

  CREATE TABLE Customer(
 IDC int primary key not null ,
 Date_of_Birth date not null, --yyyy/mm/dd
 namec varchar(50) not null,
 ID_Document int not null,
 foreign key(ID_Document) references Document(ID),
 )
 CREATE TABLE Frequent_Flyer_Card(
 FFC_Number int primary key not null,
 miles decimal not null,
 meal_code smallint not null,
 FIDC int not null,
 foreign key (FIDC) references Customer(IDC) ,

 --    FOREIGN KEY (CI) REFERENCES Persona(CI) ON UPDATE CASCADE ON DELETE CASCADE
 )

 CREATE TABLE Flight_Number(
 ID_Flight int primary key not null,
 DepartureTime time not null,
 descriptionf Varchar(300),
 typef Varchar(20),
 airline varchar(20),
IDAirportStart int not null,
IDAirportGoal int not null,
IDPlaneMod int not null,
foreign key (IDAirportStart) references Airport (ID), 
foreign key (IDAirportGoal) references Airport (ID), 
foreign key (IDPlaneMod) references PLaneModel (IDPM), 
 )
 CREATE TABLE Flight(
 IDF int primary key  not null,
 BoardingTime time not null,
 FlightDate date not null,
 Gate smallint not null,
 Check_in_Counter int not null,
 FNumber int not null,
 Foreign key(FNumber) references Flight_Number(ID_Flight),
)

CREATE TABLE Ticket(
TicketCode int primary key not null,
Number int not null,
IDCustomer int not null,
foreign key(IDCustomer) references Customer(IDC),
-- IDC int primary key not null ,
)
CREATE TABLE Coupon(
ID int primary key  not null,
DateOfRedemption date not null,
Class varchar(30) not null,
standbyf varchar(20) not null,
MealCode varchar(30) not null,
CodeTicket int not null,
ID_F int not null,
foreign key (ID_F) references Flight_Number(ID_Flight),
foreign key(CodeTicket) references Ticket(TicketCode),
)
CREATE TABLE PieceofLuggage(
Number int primary key not null,
weight decimal(10,2) not null,
ID_Coupon int not null,
foreign key (ID_Coupon) references Coupon (ID),
)

--------------------------------INSERCION DE DATOS ----------------------------------------
INSERT INTO Country (ID, Nombre) VALUES 
(1, 'United States'),
(2, 'Germany'),
(3, 'Mexico');


INSERT INTO City (ID, Nombre, ID_Country) VALUES 
('NYC', 'New York', 1),
('BER', 'Berlin', 2),
('MEX', 'Mexico City', 3);


INSERT INTO Airport (ID, NameAirport, ID_City) VALUES 
(1, 'John F. Kennedy International Airport', 'NYC'),
(2, 'Berlin Brandenburg Airport', 'BER'),
(3, 'Mexico City International Airport', 'MEX');


INSERT INTO PlaneModel (IDPM, DescriptionPM) VALUES 
(1, 'Boeing 737'),
(2, 'Airbus A320');

INSERT INTO Airplane (Registration_Number, Begin_of_Operation, statusplane, IDPModel) VALUES 
('N12345', '2015-05-20 00:00:00', 'Active', 1),
('D54321', '2017-11-15 00:00:00', 'Active', 2);


INSERT INTO Seat (size, IDPS, number, LocationSeat) VALUES 
(1, 1, 1, 1),
(1, 1, 2, 2),
(1, 2, 1, 1),
(1, 2, 2, 2);

INSERT INTO Document (ID, FechaEmision, FechaExpiracion) VALUES 
(1, '2023-01-01', '2028-01-01'),
(2, '2021-06-15', '2026-06-15');

INSERT INTO Customer (IDC, Date_of_Birth, namec, ID_Document) VALUES 
(1, '1985-07-14', 'John Doe', 1),
(2, '1990-12-05', 'Maria Gonzalez', 2);

INSERT INTO Frequent_Flyer_Card (FFC_Number, miles, meal_code, FIDC) VALUES 
(1, 12000, 1, 1),
(2, 15000, 2, 2);

INSERT INTO Flight_Number (ID_Flight, DepartureTime, descriptionf, typef, airline, IDAirportStart, IDAirportGoal, IDPlaneMod) VALUES 
(1, '08:00:00', 'NYC to BER', 'International', 'Delta', 1, 2, 1),
(2, '12:30:00', 'MEX to NYC', 'International', 'Aeromexico', 3, 1, 2);

INSERT INTO Flight (IDF, BoardingTime, FlightDate, Gate, Check_in_Counter, FNumber) VALUES 
(1, '07:30:00', '2024-09-01', 10, 5, 1),
(2, '12:00:00', '2024-09-01', 12, 3, 2);

INSERT INTO Ticket (TicketCode, Number, IDCustomer) VALUES 
(1, 1, 1),
(2, 2, 2);


INSERT INTO Coupon (ID, DateOfRedemption, Class, standbyf, MealCode, CodeTicket, ID_F) VALUES 
(1, '2024-08-01', 'Economy', 'Yes', 'Vegetarian', 1, 1),
(2, '2024-08-02', 'Economy', 'Yes', 'Standard', 2, 2);


INSERT INTO PieceofLuggage (Number, weight, ID_Coupon) VALUES 
(1, 23.5, 1),
(2, 18.0, 2);



