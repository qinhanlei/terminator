
CREATE DATABASE IF NOT EXISTS `tgame` DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS `tlogs` DEFAULT CHARSET utf8 COLLATE utf8_general_ci;


CREATE USER 'terminator'@'localhost' IDENTIFIED BY 'I am not root';
GRANT SELECT,UPDATE,INSERT,DELETE ON tgame.* TO 'terminator'@'localhost';
GRANT SELECT,UPDATE,INSERT,DELETE ON tlogs.* TO 'terminator'@'localhost';


SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

use tgame;

CREATE TABLE `user` (
  `userid` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `record_time` datetime NOT NULL,
  PRIMARY KEY (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


use tlogs;

CREATE TABLE `login` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `record_time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE `logout` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `record_time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


SET FOREIGN_KEY_CHECKS = 1;
