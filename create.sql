-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema iflyrics
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema iflyrics
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `iflyrics` DEFAULT CHARACTER SET utf8 ;
USE `iflyrics` ;

-- -----------------------------------------------------
-- Table `iflyrics`.`permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iflyrics`.`permissions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `permission` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `iflyrics`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iflyrics`.`users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(225) NOT NULL,
  `email` VARCHAR(225) NOT NULL,
  `birthdate` DATE NOT NULL,
  `permission_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_users_permissions_idx` (`permission_id` ASC) VISIBLE,
  CONSTRAINT `fk_users_permissions`
    FOREIGN KEY (`permission_id`)
    REFERENCES `iflyrics`.`permissions` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `iflyrics`.`artists`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iflyrics`.`artists` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `start_date` DATE NOT NULL,
  `user_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_artists_users1_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_artists_users1`
    FOREIGN KEY (`user_id`)
    REFERENCES `iflyrics`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `iflyrics`.`musics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iflyrics`.`musics` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `lyrics` TEXT NOT NULL,
  `user_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_musics_users1_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_musics_users1`
    FOREIGN KEY (`user_id`)
    REFERENCES `iflyrics`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `iflyrics`.`artist_music`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iflyrics`.`artist_music` (
  `music_id` INT NOT NULL,
  `artist_id` INT NOT NULL,
  PRIMARY KEY (`music_id`, `artist_id`),
  INDEX `fk_musics_has_artists_artists1_idx` (`artist_id` ASC) VISIBLE,
  INDEX `fk_musics_has_artists_musics1_idx` (`music_id` ASC) VISIBLE,
  CONSTRAINT `fk_musics_has_artists_musics1`
    FOREIGN KEY (`music_id`)
    REFERENCES `iflyrics`.`musics` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_musics_has_artists_artists1`
    FOREIGN KEY (`artist_id`)
    REFERENCES `iflyrics`.`artists` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
