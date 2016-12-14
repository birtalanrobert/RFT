-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema sql7149018
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema sql7149018
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `sql7149018` DEFAULT CHARACTER SET utf8 ;
USE `sql7149018` ;

-- -----------------------------------------------------
-- Table `sql7149018`.`TRAINS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`TRAINS` (
  `ID` INT AUTO_INCREMENT,
  `TYPE` VARCHAR(45) NOT NULL,
  `SPEED` INT NOT NULL,
  `STATUS` VARCHAR(200) NOT NULL DEFAULT 'OK',
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `ID_UNIQUE` (`ID` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`WAGONS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`WAGONS` (
  `ID` VARCHAR(50) NOT NULL,
  `SEATS_NUMBER` INT NOT NULL,
  `CLASS` INT NOT NULL DEFAULT 1,
  `SERVICES` VARCHAR(100) NOT NULL DEFAULT 0,
  `EXTRA_PRICE` INT NOT NULL DEFAULT 0,
  `STATUS` VARCHAR(200) NOT NULL DEFAULT 'OK',
  `TRAINS_ID` INT NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `ID_UNIQUE` (`ID` ASC),
  INDEX `fk_WAGONS_TRAINS1_idx` (`TRAINS_ID` ASC),
  CONSTRAINT `fk_WAGONS_TRAINS1`
    FOREIGN KEY (`TRAINS_ID`)
    REFERENCES `sql7149018`.`TRAINS` (`ID`)
    ON DELETE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`SEATS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`SEATS` (
  `ID` INT AUTO_INCREMENT,
  `RESERVED` TINYINT(1) NOT NULL,
  `NUMBER` INT NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `ID_UNIQUE` (`ID` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`WAGON_SEAT_CONNECTION`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`WAGON_SEAT_CONNECTION` (
  `SEATS_ID` INT NOT NULL,
  `WAGONS_ID` VARCHAR(50) NOT NULL,
  INDEX `fk_WAGON_SEAT_CONNECTION_SEATS1_idx` (`SEATS_ID` ASC),
  INDEX `fk_WAGON_SEAT_CONNECTION_WAGONS1_idx` (`WAGONS_ID` ASC),
  CONSTRAINT `fk_WAGON_SEAT_CONNECTION_SEATS1`
    FOREIGN KEY (`SEATS_ID`)
    REFERENCES `sql7149018`.`SEATS` (`ID`)
    ON DELETE NO ACTION,
  CONSTRAINT `fk_WAGON_SEAT_CONNECTION_WAGONS1`
    FOREIGN KEY (`WAGONS_ID`)
    REFERENCES `sql7149018`.`WAGONS` (`ID`)
    ON DELETE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`ROUTES`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`ROUTES` (
  `ID` INT AUTO_INCREMENT,
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `ID_UNIQUE` (`ID` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`TRAIN_ROUTE_CONNECTION`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`TRAIN_ROUTE_CONNECTION` (
  `START` DATETIME NOT NULL,
  `TRAINS_ID` INT NOT NULL,
  `ROUTES_ID` INT NOT NULL,
  INDEX `fk_TRAIN_ROUTE_CONNECTION_TRAINS1_idx` (`TRAINS_ID` ASC),
  INDEX `fk_TRAIN_ROUTE_CONNECTION_ROUTES1_idx` (`ROUTES_ID` ASC),
  CONSTRAINT `fk_TRAIN_ROUTE_CONNECTION_TRAINS1`
    FOREIGN KEY (`TRAINS_ID`)
    REFERENCES `sql7149018`.`TRAINS` (`ID`)
    ON DELETE NO ACTION,
  CONSTRAINT `fk_TRAIN_ROUTE_CONNECTION_ROUTES1`
    FOREIGN KEY (`ROUTES_ID`)
    REFERENCES `sql7149018`.`ROUTES` (`ID`)
    ON DELETE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`STATIONS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`STATIONS` (
  `ID` INT AUTO_INCREMENT,
  `NAME` VARCHAR(250) NOT NULL,
  `PLATFORMS` INT NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `ID_UNIQUE` (`ID` ASC),
  UNIQUE INDEX `NAME_UNIQUE` (`NAME` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`NEIGHBOURS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`NEIGHBOURS` (
  `NEIGHBOUR_ID` INT NOT NULL,
  `DISTANCE` INT NOT NULL,
  `STATIONS_ID` INT NOT NULL,
  INDEX `fk_NEIGHBOURS_STATIONS1_idx` (`STATIONS_ID` ASC),
  CONSTRAINT `fk_NEIGHBOURS_STATIONS1`
    FOREIGN KEY (`STATIONS_ID`)
    REFERENCES `sql7149018`.`STATIONS` (`ID`)
    ON DELETE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`ROUTE_STATIONS_CONNECTION`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`ROUTE_STATIONS_CONNECTION` (
  `PLATFORM` INT NOT NULL,
  `EXPLETIVE_TICKET` TINYINT(1) NOT NULL,
  `ROUTES_ID` INT NOT NULL,
  `STATIONS_ID` INT NOT NULL,
  `STATION_INDEX_IN_ROUTE` INT NOT NULL,
  `TYPE_OF_TRAINS_STOPS` VARCHAR(500) NOT NULL,
  INDEX `fk_ROUTE_STATIONS_CONNECTION_ROUTES1_idx` (`ROUTES_ID` ASC),
  INDEX `fk_ROUTE_STATIONS_CONNECTION_STATIONS1_idx` (`STATIONS_ID` ASC),
  CONSTRAINT `fk_ROUTE_STATIONS_CONNECTION_ROUTES1`
    FOREIGN KEY (`ROUTES_ID`)
    REFERENCES `sql7149018`.`ROUTES` (`ID`)
    ON DELETE NO ACTION,
  CONSTRAINT `fk_ROUTE_STATIONS_CONNECTION_STATIONS1`
    FOREIGN KEY (`STATIONS_ID`)
    REFERENCES `sql7149018`.`STATIONS` (`ID`)
    ON DELETE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`TICKETS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`TICKETS` (
  `PRICE` INT NOT NULL,
  `TYPE` VARCHAR(100) NOT NULL,
  `DISTANCE` INT NOT NULL,
  INDEX `TYPE` (`TYPE` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`USERS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`USERS` (
  `FIRSTNAME` VARCHAR(100) NOT NULL,
  `LASTNAME` VARCHAR(100) NOT NULL,
  `NICKNAME` VARCHAR(45) NOT NULL,
  `PASSWORD` VARCHAR(45) NOT NULL,
  `SALT1` VARCHAR(45) NOT NULL,
  `SALT2` VARCHAR(45) NOT NULL,
  `TYPE` VARCHAR(45) NOT NULL,
  `EMAIL` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`NICKNAME`),
  UNIQUE INDEX `NICKNAME_UNIQUE` (`NICKNAME` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sql7149018`.`PURCHASES`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sql7149018`.`PURCHASES` (
  `ID` INT AUTO_INCREMENT,
  `DATE` DATETIME NOT NULL,
  `USER_NICKNAME` VARCHAR(45) NOT NULL,
  `FROM` VARCHAR(250) NOT NULL,
  `TO` VARCHAR(250) NOT NULL,
  `WAGON_SEAT` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`ID`),
  INDEX `fk_USERS_PURCHASES_idx` (`USER_NICKNAME` ASC),
  CONSTRAINT `fk_USERS_PURCHASES`
    FOREIGN KEY (`USER_NICKNAME`)
    REFERENCES `sql7149018`.`USERS` (`NICKNAME`)
    ON DELETE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;