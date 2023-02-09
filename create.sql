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


-- -----------------------------------------------------
-- Inserts, Functions and Triggers
-- -----------------------------------------------------

use iflyrics;

insert into permissions values (default, 'Admin');
insert into permissions values (default, 'Common User');

drop trigger tr_checkAdmin;

# Trigger para verificar permissão
# Só quem tem permission_id = 1 (Por ventura só que é um administrador) pode adicionar um novo artista

delimiter $$
	create trigger tr_checkAdmin before insert on artists
	for each row
	begin
			set @permission = (select permissions.id from users join permissions on permissions.id = users.permission_id where users.id = new.user_id);
            
            if @permission != 1 then
				signal sqlstate '45000' set message_text = 'Não foi possível efetuar essa operação pois o seu usuário não é administrador!';
            end if;
	end $$
delimiter ;

# Function para listar informações de um artista
# Passa-se o id de um artista e a função vai retornar um texto formatado mostrando os dados relacionados a ele

drop function fn_artistToString;

delimiter $$
	create function fn_artistToString(artistId int) returns varchar(1000)
    deterministic
    begin
		set @artist = (select name from artists where artists.id = artistId);
        set @startDate = (select start_date from artists where artists.id = artistId);
        set @dateAux = replace(@startDate, '-', '/');
        set @musicsCount = (select count(artist_id) from artist_music where artist_music.artist_id = artistId);
        
        set @message = (select concat('Nome: ', @artist, '\nData que iniciou a carreira: ', fn_dateFormat(@dateAux), '\nMúsicas cadastradas no site: ', @musicsCount));
		return @message;
    end $$
delimiter ;

# Função auxiliar para formatar data

drop function fn_dateFormat;

create function fn_dateFormat(dateAux varchar(12)) returns varchar(12)
	deterministic return concat(substring_index(@dateAux, '/', -1), '/', substring_index(substring_index(@dateAux, '/', 2), '/', -1), '/', substring_index(@dateAux, '/', 1));