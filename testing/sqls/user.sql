
DROP USER IF EXISTS 'terminator'@'localhost';
CREATE USER 'terminator'@'localhost' IDENTIFIED BY 'I am not root';
GRANT SELECT,UPDATE,INSERT,DELETE ON tgame.* TO 'terminator'@'localhost';
GRANT SELECT,UPDATE,INSERT,DELETE ON tlogs.* TO 'terminator'@'localhost';
