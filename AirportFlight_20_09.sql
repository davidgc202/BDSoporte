-- Eliminar la base de datos si ya existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'AirportFlight')
BEGIN
    USE master;
    DROP DATABASE AirportFlight;
END
GO

-- Crear la base de datos
CREATE DATABASE AirportFlight;
GO
USE AirportFlight;
GO

-- Tabla: FrequentFlyerCard
IF OBJECT_ID('FrequentFlyerCard', 'U') IS NOT NULL DROP TABLE FrequentFlyerCard;
CREATE TABLE FrequentFlyerCard (
    FFCNumber INT PRIMARY KEY,
    Miles INT CHECK (Miles >= 0),  -- Las millas no pueden ser negativas
    MealCode VARCHAR(50) NOT NULL  -- No permitir valores nulos
);
GO

-- �ndice para MealCode
CREATE INDEX IX_FrequentFlyerCard_MealCode ON FrequentFlyerCard (MealCode);
GO

-- Tabla: CustomerCategory
IF OBJECT_ID('CustomerCategory', 'U') IS NOT NULL DROP TABLE CustomerCategory;
CREATE TABLE CustomerCategory (
    IDCustomerCategory INT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL  -- No permitir valores nulos
);
GO

-- �ndice para CategoryName
CREATE INDEX IX_CustomerCategory_CategoryName ON CustomerCategory (CategoryName);
GO

-- Tabla: Country
IF OBJECT_ID('Country', 'U') IS NOT NULL DROP TABLE Country;
CREATE TABLE Country (
    IDCountry INT PRIMARY KEY,
    CountryName VARCHAR(50) NOT NULL
);
GO

-- �ndice para CountryName
CREATE INDEX IX_Country_CountryName ON Country (CountryName);
GO

-- Tabla: City
IF OBJECT_ID('City', 'U') IS NOT NULL DROP TABLE City;
CREATE TABLE City (
    IDCity INT PRIMARY KEY,
    CityName VARCHAR(50) NOT NULL,
    IDCountry INT NOT NULL,
    FOREIGN KEY (IDCountry) REFERENCES Country(IDCountry)
);
GO

-- �ndices para CityName e IDCountry
CREATE INDEX IX_City_CityName ON City (CityName);
CREATE INDEX IX_City_IDCountry ON City (IDCountry);
GO

-- Tabla: Airport
IF OBJECT_ID('Airport', 'U') IS NOT NULL DROP TABLE Airport;
CREATE TABLE Airport (
    IDAirport INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    IDCity INT NOT NULL,
    FOREIGN KEY (IDCity) REFERENCES City(IDCity)
);
GO

-- �ndices para Name e IDCity
CREATE INDEX IX_Airport_Name ON Airport (Name);
CREATE INDEX IX_Airport_IDCity ON Airport (IDCity);
GO

-- Tabla: Airline
IF OBJECT_ID('Airline', 'U') IS NOT NULL DROP TABLE Airline;
CREATE TABLE Airline (
    IDAirline INT PRIMARY KEY,
    AirlineName VARCHAR(50) NOT NULL  -- Nombre de la aerol�nea
);
GO

-- �ndice para AirlineName
CREATE INDEX IX_Airline_AirlineName ON Airline (AirlineName);
GO

-- Tabla intermedia: AirportAirline
IF OBJECT_ID('AirportAirline', 'U') IS NOT NULL DROP TABLE AirportAirline;
CREATE TABLE AirportAirline (
    IDAirport INT NOT NULL,
    IDAirline INT NOT NULL,
    PRIMARY KEY (IDAirport, IDAirline),
    FOREIGN KEY (IDAirport) REFERENCES Airport(IDAirport),
    FOREIGN KEY (IDAirline) REFERENCES Airline(IDAirline)
);
GO

-- Tabla: PlaneModel
IF OBJECT_ID('PlaneModel', 'U') IS NOT NULL DROP TABLE PlaneModel;
CREATE TABLE PlaneModel (
    IDPlaneModel INT PRIMARY KEY,
    Description VARCHAR(50) NOT NULL,
    Graphic VARCHAR(MAX) NULL
);
GO

-- �ndice para Description
CREATE INDEX IX_PlaneModel_Description ON PlaneModel (Description);
GO

-- Tabla: Airplane
IF OBJECT_ID('Airplane', 'U') IS NOT NULL DROP TABLE Airplane;
CREATE TABLE Airplane (
    RegistrationNumber VARCHAR(50) PRIMARY KEY,
    BeginOfOperation DATE CHECK (BeginOfOperation <= GETDATE()),  -- Fecha v�lida
    status VARCHAR(50) CHECK (Status IN ('Activo', 'Inactivo')),  -- Restringir valores a 'Activo' o 'Inactivo'
    IDPlaneModel INT NOT NULL,
    FOREIGN KEY (IDPlaneModel) REFERENCES PlaneModel(IDPlaneModel)
);
GO

-- �ndices para Status y BeginOfOperation
CREATE INDEX IX_Airplane_Status ON Airplane (Status);
CREATE INDEX IX_Airplane_BeginOfOperation ON Airplane (BeginOfOperation);
GO

-- Tabla: Seat
IF OBJECT_ID('Seat', 'U') IS NOT NULL DROP TABLE Seat;
CREATE TABLE Seat (
    IDSeat INT, 
    Size VARCHAR(50) NOT NULL,
    Number INT NOT NULL CHECK (Number > 0),  -- N�mero de asiento positivo
    Location VARCHAR(50) NOT NULL,
    IDPlaneModel INT NOT NULL,
    FOREIGN KEY (IDPlaneModel) REFERENCES PlaneModel(IDPlaneModel),
    PRIMARY KEY (IDSeat, IDPlaneModel)
);
GO

-- �ndices para Size, Number y Location
CREATE INDEX IX_Seat_Size ON Seat (Size);
CREATE INDEX IX_Seat_Number ON Seat (Number);
CREATE INDEX IX_Seat_Location ON Seat (Location);
GO

-- Tabla: FlightNumber
IF OBJECT_ID('FlightNumber', 'U') IS NOT NULL DROP TABLE FlightNumber;
CREATE TABLE FlightNumber (
    IDFlightNumber INT PRIMARY KEY,
    Description VARCHAR(50) NOT NULL,
    Type VARCHAR(50) NOT NULL,
    DepartureTime DATETIME NOT NULL CHECK (DepartureTime > GETDATE()),  -- Hora de salida futura
    IDAirportStart INT NOT NULL,
    IDAirportGoal INT NOT NULL,
    IDPlaneModel INT NOT NULL,
    IDAirline INT NOT NULL,  -- Agregamos la relaci�n con Airline
    FOREIGN KEY (IDAirportStart) REFERENCES Airport(IDAirport),
    FOREIGN KEY (IDAirportGoal) REFERENCES Airport(IDAirport),
    FOREIGN KEY (IDPlaneModel) REFERENCES PlaneModel(IDPlaneModel),
    FOREIGN KEY (IDAirline) REFERENCES Airline(IDAirline),
    CHECK (IDAirportStart <> IDAirportGoal)  -- Inicio y destino diferentes
);
GO

-- �ndices para FlightNumber
CREATE INDEX IX_FlightNumber_Description ON FlightNumber (Description);
CREATE INDEX IX_FlightNumber_Type ON FlightNumber (Type);
CREATE INDEX IX_FlightNumber_DepartureTime ON FlightNumber (DepartureTime);
CREATE INDEX IX_FlightNumber_IDAirportStart ON FlightNumber (IDAirportStart);
CREATE INDEX IX_FlightNumber_IDAirportGoal ON FlightNumber (IDAirportGoal);
CREATE INDEX IX_FlightNumber_IDAirline ON FlightNumber (IDAirline);
GO

-- Tabla: Flight
IF OBJECT_ID('Flight', 'U') IS NOT NULL DROP TABLE Flight;	
CREATE TABLE Flight (
    IDFlight INT PRIMARY KEY,
    FlightDate DATE NOT NULL CHECK (FlightDate >= GETDATE()),  -- Fecha futura o actual
    BoardingTime DATETIME NOT NULL,
    Gate VARCHAR(50) NOT NULL,
    CheckinCounter VARCHAR(50) NOT NULL,
    IDFlightNumber INT NOT NULL,
    FOREIGN KEY (IDFlightNumber) REFERENCES FlightNumber(IDFlightNumber)
);
GO

-- �ndices para Flight
CREATE INDEX IX_Flight_FlightDate ON Flight (FlightDate);
CREATE INDEX IX_Flight_BoardingTime ON Flight (BoardingTime);
CREATE INDEX IX_Flight_Gate ON Flight (Gate);
CREATE INDEX IX_Flight_CheckinCounter ON Flight (CheckinCounter);
GO

-- Tabla: FlightLayover (Escalas)
IF OBJECT_ID('FlightLayover', 'U') IS NOT NULL DROP TABLE FlightLayover;
CREATE TABLE FlightLayover (
    IDFlight INT NOT NULL,
    IDAirport INT NOT NULL,
    LayoverTime DATETIME NOT NULL,  -- Tiempo de la escala
    PRIMARY KEY (IDFlight, IDAirport),
    FOREIGN KEY (IDFlight) REFERENCES Flight(IDFlight),
    FOREIGN KEY (IDAirport) REFERENCES Airport(IDAirport)
);
GO

-- Tabla: CrewMember
IF OBJECT_ID('CrewMember', 'U') IS NOT NULL DROP TABLE CrewMember;
CREATE TABLE CrewMember (
    IDCrewMember INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);
GO

-- Tabla: FlightCrew
IF OBJECT_ID('FlightCrew', 'U') IS NOT NULL DROP TABLE FlightCrew;
CREATE TABLE FlightCrew (
    IDFlight INT NOT NULL,
    IDCrewMember INT NOT NULL,
    PRIMARY KEY (IDFlight, IDCrewMember),
    FOREIGN KEY (IDFlight) REFERENCES Flight(IDFlight),
    FOREIGN KEY (IDCrewMember) REFERENCES CrewMember(IDCrewMember)
);
GO

-- Tabla: FlightLayoverCrew
IF OBJECT_ID('FlightLayoverCrew', 'U') IS NOT NULL DROP TABLE FlightLayoverCrew;
CREATE TABLE FlightLayoverCrew (
    IDFlight INT NOT NULL,
    IDAirport INT NOT NULL,
    IDCrewMember INT NOT NULL,
    PRIMARY KEY (IDFlight, IDAirport, IDCrewMember),
    FOREIGN KEY (IDFlight) REFERENCES Flight(IDFlight),
    FOREIGN KEY (IDAirport) REFERENCES Airport(IDAirport),
    FOREIGN KEY (IDCrewMember) REFERENCES CrewMember(IDCrewMember)
);
GO

-- �ndice para Name en CrewMember
CREATE INDEX IX_CrewMember_Name ON CrewMember (Name);
GO

-- �ndices para FlightCrew
CREATE INDEX IX_FlightCrew_IDFlight ON FlightCrew (IDFlight);
CREATE INDEX IX_FlightCrew_IDCrewMember ON FlightCrew (IDCrewMember);
GO

-- �ndices para FlightLayoverCrew
CREATE INDEX IX_FlightLayoverCrew_IDFlight ON FlightLayoverCrew (IDFlight);
CREATE INDEX IX_FlightLayoverCrew_IDAirport ON FlightLayoverCrew (IDAirport);
CREATE INDEX IX_FlightLayoverCrew_IDCrewMember ON FlightLayoverCrew (IDCrewMember);
GO

-- Tabla: Customer
IF OBJECT_ID('Customer', 'U') IS NOT NULL DROP TABLE Customer;
CREATE TABLE Customer (
    IdCustomer INT PRIMARY KEY,
    DateOfBirth DATE NOT NULL CHECK (DateOfBirth <= GETDATE()),  -- Fecha de nacimiento v�lida
    Name VARCHAR(50) NOT NULL,
    FFCNumber INT NULL,
    IDCustomerCategory INT NOT NULL,
    FOREIGN KEY (FFCNumber) REFERENCES FrequentFlyerCard(FFCNumber),
    FOREIGN KEY (IDCustomerCategory) REFERENCES CustomerCategory(IDCustomerCategory)
);
GO

-- �ndice para Name
CREATE INDEX IX_Customer_Name ON Customer (Name);
GO

-- Tabla: TicketCategory
IF OBJECT_ID('TicketCategory', 'U') IS NOT NULL DROP TABLE TicketCategory;
CREATE TABLE TicketCategory (
    IDTicketCategory INT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL  -- No permitir valores nulos
);
GO

-- �ndice para CategoryName
CREATE INDEX IX_TicketCategory_CategoryName ON TicketCategory (CategoryName);
GO

-- Tabla: Ticket
IF OBJECT_ID('Ticket', 'U') IS NOT NULL DROP TABLE Ticket;
CREATE TABLE Ticket (
    IDTicket INT PRIMARY KEY,
    TicketingCode VARCHAR(50) NOT NULL,
    IDCustomer INT NOT NULL,
    IDTicketCategory INT NOT NULL,
    FOREIGN KEY (IDCustomer) REFERENCES Customer(IdCustomer),
    FOREIGN KEY (IDTicketCategory) REFERENCES TicketCategory(IDTicketCategory)
);
GO

-- �ndices para Ticket
CREATE INDEX IX_Ticket_IDTicket ON Ticket (IDTicket);
CREATE INDEX IX_Ticket_IDCustomer ON Ticket (IDCustomer);
CREATE INDEX IX_Ticket_TicketingCode ON Ticket (TicketingCode);
CREATE INDEX IX_Ticket_IDTicketCategory ON Ticket (IDTicketCategory);
GO

-- Tabla: Reservation
IF OBJECT_ID('Reservation', 'U') IS NOT NULL DROP TABLE Reservation;
CREATE TABLE Reservation (
    IDReservation INT PRIMARY KEY,
    IDFlight INT NOT NULL,
    IDCustomer INT NOT NULL,
    ReservationDate DATETIME NOT NULL DEFAULT GETDATE(),  -- Fecha de reserva
    StatusReservation VARCHAR(50) NOT NULL CHECK (StatusReservation IN ('Reservado', 'Cancelado')),  -- Estado de la reserva
    FOREIGN KEY (IDFlight) REFERENCES Flight(IDFlight),
    FOREIGN KEY (IDCustomer) REFERENCES Customer(IdCustomer)
);
GO

-- Tabla: Coupon
IF OBJECT_ID('Coupon', 'U') IS NOT NULL DROP TABLE Coupon;
CREATE TABLE Coupon (
    IDCoupon INT NOT NULL,
    IDTicket INT NOT NULL,
    DateOfRedemption DATE CHECK (DateOfRedemption >= GETDATE()),  -- Fecha de redenci�n futura o actual
    Class VARCHAR(50) NOT NULL CHECK (Class IN ('Economy', 'Business', 'First')),  -- Solo permitir valores v�lidos
    PRIMARY KEY (IDCoupon, IDTicket),
    FOREIGN KEY (IDTicket) REFERENCES Ticket(IDTicket)
);
GO

-- �ndices para Coupon
CREATE INDEX IX_Coupon_DateOfRedemption ON Coupon (DateOfRedemption);
CREATE INDEX IX_Coupon_Class ON Coupon (Class);
GO

-- Tabla: PieceOfLuggage
IF OBJECT_ID('PieceOfLuggage', 'U') IS NOT NULL DROP TABLE PieceOfLuggage;
CREATE TABLE PieceOfLuggage (
    IDPieceOfLuggage INT PRIMARY KEY,
    Weight DECIMAL(10, 2) CHECK (Weight >= 0),  -- El peso no puede ser negativo
    Material VARCHAR(50) NOT NULL,
    Color VARCHAR(50) NOT NULL,
    IDCoupon INT NOT NULL,
    IDTicket INT NOT NULL,  -- A�adimos IDTicket para que coincida con la clave compuesta de Coupon
    FOREIGN KEY (IDCoupon, IDTicket) REFERENCES Coupon(IDCoupon, IDTicket)  -- Clave for�nea compuesta
);
GO

-- �ndices para PieceOfLuggage
CREATE INDEX IX_PieceOfLuggage_Weight ON PieceOfLuggage (Weight);
CREATE INDEX IX_PieceOfLuggage_Material ON PieceOfLuggage (Material);
CREATE INDEX IX_PieceOfLuggage_Color ON PieceOfLuggage (Color);
GO

-- Tabla: AvailableSeat
IF OBJECT_ID('AvailableSeat', 'U') IS NOT NULL DROP TABLE AvailableSeat;
CREATE TABLE AvailableSeat (
    IDFlight INT NOT NULL,
    IDSeat INT NOT NULL,
    IDPlaneModel INT NOT NULL,
    StatusSeat VARCHAR(50) NOT NULL CHECK (StatusSeat IN ('Disponible', 'Reservado')),
    PRIMARY KEY (IDFlight, IDSeat, IDPlaneModel),
    FOREIGN KEY (IDFlight) REFERENCES Flight(IDFlight),
    FOREIGN KEY (IDSeat, IDPlaneModel) REFERENCES Seat(IDSeat, IDPlaneModel)
);
GO

-- �ndice para StatusSeat
CREATE INDEX IX_AvailableSeat_StatusSeat ON AvailableSeat (StatusSeat);
GO

-- Tabla: ReservationSeat
IF OBJECT_ID('ReservationSeat', 'U') IS NOT NULL DROP TABLE ReservationSeat;
CREATE TABLE ReservationSeat (
    IDReservation INT NOT NULL,
    IDFlight INT NOT NULL,
    IDSeat INT NOT NULL,
    IDPlaneModel INT NOT NULL,
    PRIMARY KEY (IDReservation, IDFlight, IDSeat, IDPlaneModel),
    FOREIGN KEY (IDReservation) REFERENCES Reservation(IDReservation),
    FOREIGN KEY (IDFlight) REFERENCES Flight(IDFlight),
    FOREIGN KEY (IDSeat, IDPlaneModel) REFERENCES Seat(IDSeat, IDPlaneModel)
);
GO

-- Tabla: CheckIn
IF OBJECT_ID('CheckIn', 'U') IS NOT NULL DROP TABLE CheckIn;
CREATE TABLE CheckIn (
    IDCheckIn INT PRIMARY KEY,
    IDTicket INT NOT NULL,
    CheckInTime DATETIME NOT NULL,
    FOREIGN KEY (IDTicket) REFERENCES Ticket(IDTicket)
);
GO

-- �ndice para CheckIn
CREATE INDEX IX_CheckIn_IDTicket ON CheckIn (IDTicket);
CREATE INDEX IX_CheckIn_CheckInTime ON CheckIn (CheckInTime);
GO
