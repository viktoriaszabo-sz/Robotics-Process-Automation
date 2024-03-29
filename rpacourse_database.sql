-- MySQL Script generated by MySQL Workbench
-- Fri Mar  1 14:59:58 2024
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema rpacourse
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema rpacourse
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `rpacourse` DEFAULT CHARACTER SET utf8 ;
USE `rpacourse` ;

-- -----------------------------------------------------
-- Table `rpacourse`.`invoiceStatus`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `rpacourse`.`invoiceStatus` (
  `id` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `rpacourse`.`invoiceHeaders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `rpacourse`.`invoiceHeaders` (
  `invoiceNumber` INT NOT NULL,
  `companyCode` VARCHAR(45) NOT NULL,
  `referenceNumber` VARCHAR(45) NOT NULL,
  `ibanNumber` VARCHAR(45) NOT NULL,
  `dueDate` DATE NOT NULL,
  `amountExcl` DECIMAL NOT NULL,
  `vat` DECIMAL NOT NULL,
  `totalAmount` DECIMAL NOT NULL,
  `invoiceStatus_id` INT NOT NULL,
  `comments` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`invoiceNumber`),
  INDEX `fk_invoiceHeaders_invoiceStatus1_idx` (`invoiceStatus_id` ASC) VISIBLE,
  CONSTRAINT `fk_invoiceHeaders_invoiceStatus1`
    FOREIGN KEY (`invoiceStatus_id`)
    REFERENCES `rpacourse`.`invoiceStatus` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `rpacourse`.`invoiceRows`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `rpacourse`.`invoiceRows` (
  `invoiceNumber` INT NOT NULL,invoiceheaders
  `item` VARCHAR(45) NOT NULL,
  `quantity` INT NOT NULL,
  `unit` VARCHAR(45) NOT NULL,
  `unitPrice` DECIMAL NOT NULL,
  `vatPercent` DECIMAL NOT NULL,
  `lineVat` DECIMAL NOT NULL,
  `lineItemAmount` DECIMAL NOT NULL,
  PRIMARY KEY (`invoiceNumber`),
  CONSTRAINT `fk_table1_invoiceHeaders`
    FOREIGN KEY (`invoiceNumber`)
    REFERENCES `rpacourse`.`invoiceHeaders` (`invoiceNumber`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
