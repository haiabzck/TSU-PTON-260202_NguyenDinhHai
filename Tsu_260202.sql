CREATE DATABASE tsu_pton_260202;
USE tsu_pton_260202;
-- CÂU 1
CREATE TABLE Passengers(
	passenger_id VARCHAR(5) PRIMARY KEY NOT NULL,
	passenger_full_name VARCHAR(100) NOT NULL,
	passenger_email  VARCHAR(100) NOT NULL,
	passenger_phone  VARCHAR(15) NOT NULL,
	passenger_cccd  VARCHAR(20) NOT NULL
);

CREATE TABLE Trains(
	train_id VARCHAR(5) PRIMARY KEY NOT NULL,
	train_name VARCHAR(100) NOT NULL,
	train_type VARCHAR(10) NOT NULL,
	total_seats INT NOT NULL
);

CREATE TABLE Tickets(
	ticket_id VARCHAR(5) PRIMARY KEY NOT NULL,
	passenger_id VARCHAR(5) NOT NULL,
	train_id VARCHAR(5) NOT NULL,
	departure_date DATE NOT NULL,
	seat_number VARCHAR(10) NOT NULL,
	ticket_price DECIMAL(10,2) NOT NULL,
	FOREIGN KEY(passenger_id) REFERENCES Passengers(passenger_id) ON DELETE CASCADE,
    FOREIGN KEY(train_id) REFERENCES Trains(train_id) ON DELETE CASCADE
);

CREATE TABLE PaymentTransactions(
	transaction_id VARCHAR(5) PRIMARY KEY NOT NULL,
	ticket_id VARCHAR(5) NOT NULL,
	payment_method VARCHAR(50) NOT NULL,
	transaction_date DATE NOT NULL,
	amount DECIMAL(10,2) NOT NULL,
	FOREIGN KEY(ticket_id) REFERENCES Tickets(ticket_id) ON DELETE CASCADE
);
-- CÂU 2
INSERT INTO Passengers 
VALUE 
	('P001','Nguyen Van An','an.nguyen@example.com','0912345678','001234567890'),
	('P002','Tran Thi Binh','binh.tran@example.com','0923456789','002345678901'),
	('P003','Le Minh Chau','chau.le@example.com','0934567890','003456789012'),
	('P004','Pham Quoc Dat','dat.pham@example.com','0945678901','004567890123'),
	('P005','Vo Thanh Em','em.vo@example.com','0956789012','005678901234');
    
INSERT INTO Trains 
VALUE
	('T001','Tau Thong Nhat 1','SE',500),
	('T002','Tau Thong Nhat 2','TN',450),
	('T003','Tau Sai Gon - Hue','SE',400),
	('T004','Tau Ha Noi - Lao Cai','TN',350),
	('T005','Tau Da Nang Express','SE',300);
    
INSERT INTO Tickets
VALUE
	('TK001','P001','T001','2025-06-10','A01',850000),
	('TK002','P002','T002','2025-06-11','B05',650000),
	('TK003','P003','T003','2025-06-12','C10',720000),
	('TK004','P004','T004','2025-06-13','D12',500000),
	('TK005','P005','T005','2025-06-14','E08',900000);    
    
INSERT INTO PaymentTransactions
VALUE
	('TR001','TK001','Credit Card','2025-06-01',850000),
	('TR002','TK002','Cash','2025-06-02',650000),
	('TR003','TK003','Bank Transfer','2025-06-03',720000),
	('TR004','TK004','E-Wallet','2025-06-04',500000),
	('TR005','TK005','Credit Card','2025-06-05',900000);

-- CÂU 3
UPDATE Tickets
SET ticket_price = ticket_price * 0.85
WHERE departure_date < '2025-05-01' ;
-- CÂU 4
DELETE FROM PaymentTransactions WHERE payment_method = 'E-Walle' AND amount < 200000;

-- CÂU 5
SELECT passenger_id,passenger_full_name,passenger_email,passenger_phone
FROM Passengers
ORDER BY passenger_full_name DESC;

-- CÂU 6
SELECT train_id,train_name,total_seats
FROM Trains
ORDER BY total_seats ASC;

-- CÂU 7
SELECT passenger_full_name,train_name,departure_date,seat_number
FROM Tickets
INNER JOIN Trains ON Trains.train_id=Tickets.train_id
INNER JOIN Passengers ON Passengers.passenger_id=Tickets.passenger_id;

-- CÂU 8
SELECT ti.passenger_id,passenger_full_name,payment_method,amount
FROM Tickets AS ti
INNER JOIN Passengers ON Passengers.passenger_id=ti.passenger_id
INNER JOIN PaymentTransactions ON PaymentTransactions.ticket_id=ti.ticket_id
ORDER BY amount ASC ;

-- CÂU 9
SELECT * FROM Passengers ORDER BY passenger_full_name DESC LIMIT 3 OFFSET 2;

-- CÂU 10
SELECT passenger_id,COUNT(ticket_id) AS 'Số lần đặt vé' FROM Tickets 
GROUP BY passenger_id
HAVING COUNT(ticket_id) >=3 ;

-- CÂU 11
SELECT train_id,COUNT(ticket_id) AS 'Số lượt đặt vé' FROM Tickets 
GROUP BY train_id
HAVING COUNT(ticket_id) > 10 ;

-- CÂU 12
SELECT p.passenger_id,p.passenger_full_name,tr.train_id,SUM(ti.ticket_price) AS 'Tổng tiền' FROM Passengers AS p
INNER JOIN  Tickets AS ti ON p.passenger_id = ti.passenger_id
INNER JOIN Trains AS tr ON tr.train_id = ti.train_id
GROUP BY p.passenger_id,tr.train_id
HAVING SUM(ticket_price) > 2000000 ;

-- CÂU 13
SELECT * FROM Passengers
WHERE passenger_full_name LIKE'%Hoàng%' OR passenger_email LIKE '%@gmail.com%'
ORDER BY passenger_full_name ASC;

-- CÂU 14
SELECT * FROM Trains 
ORDER BY train_type ASC
LIMIT 5 OFFSET 5;

-- CÂU 15 
CREATE VIEW vw_UpcomingTrips 
AS
SELECT passenger_full_name,train_name,seat_number,ticket_price,departure_date
FROM Tickets
INNER JOIN Trains ON Trains.train_id=Tickets.train_id
INNER JOIN Passengers ON Passengers.passenger_id=Tickets.passenger_id
WHERE departure_date > 2025-06-01;

SELECT * FROM vw_UpcomingTrips;

-- CÂU 16
CREATE VIEW vw_HighValueTickets 
AS
SELECT passenger_full_name,train_name,seat_number,ticket_price
FROM Tickets
INNER JOIN Trains ON Trains.train_id=Tickets.train_id
INNER JOIN Passengers ON Passengers.passenger_id=Tickets.passenger_id
WHERE ticket_price > 500000;

SELECT * FROM vw_HighValueTickets;

-- CÂU 17
DELIMITER //
CREATE TRIGGER tg_check_ticket_date 
BEFORE INSERT ON Tickets
FOR EACH ROW
BEGIN
	IF NEW.departure_date < NOW() THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=  'Ngày khởi hành không hợp lệ';
	END IF;
END //
DELIMITER ;
DROP trigger tg_check_ticket_date

-- CÂU 18
DELIMITER //
CREATE TRIGGER tg_update_seats  
AFTER INSERT ON Tickets 
FOR EACH ROW
BEGIN
	UPDATE Trains SET total_seats = total_seats -1 WHERE train_id = New.train_id;
END //
DELIMITER ;

-- CÂU 19 
DELIMITER //
CREATE PROCEDURE sp_add_passenger() 
BEGIN
	INSERT INTO Passengers 
	VALUE 
		('P006','Nguyen Thi Anh','tanh.nguyen@example.com','0912345671','001234567111');
END //
DELIMITER ;

CALL sp_add_passenger();

-- CÂU 20 
DELIMITER //
CREATE PROCEDURE sp_cancel_ticket (IN p_ticket_id VARCHAR(15)) 
BEGIN
	DELETE FROM Tickets WHERE ticket_id = p_ticket_id;
END //
DELIMITER ;

CALL sp_cancel_ticket('TK001');