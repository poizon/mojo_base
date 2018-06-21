--
-- COMMENT: Создание новой базы данных
---

-- Создаем базу данных, если таковой еще нет
CREATE DATABASE IF NOT EXISTS `mbasedb` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'mbase'@'localhost' IDENTIFIED BY 'qwerty';
GRANT ALL PRIVILEGES ON mbasedb . * TO 'mbase'@'localhost';
FLUSH PRIVILEGES;

-- Таблица с историей историей миграций
CREATE TABLE IF NOT EXISTS `migrations` (
	   `id` INTEGER NOT NULL,
	   `name` VARCHAR(120) NOT NULL,
	   `applied` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	   `comment` VARCHAR(250),
	   PRIMARY KEY (`id`)
);
CREATE INDEX `name__migrations_idx` ON `migrations` (`name`);

-- Таблица учетных записей пользователей
CREATE TABLE IF NOT EXISTS `users` (
	   `id` INTEGER NOT NULL,
	   `username` VARCHAR(50) NOT NULL UNIQUE,
	   `email` VARCHAR(50) NOT NULL UNIQUE,
	   `uid` VARCHAR(50) NOT NULL,
   	   `password` VARCHAR(32) NOT NULL,
   	   `first_name` VARCHAR(100),
   	   `last_name` VARCHAR(100),
	   `avatar` VARCHAR(100) NULL,
	   `created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	   `last_visited` DATETIME NULL,
	   `is_activated` BOOLEAN DEFAULT FALSE,
   	   `is_admin` BOOLEAN DEFAULT FALSE,
   	   PRIMARY KEY (`id`)
);
CREATE INDEX `uid__users_idx` ON `users` (`uid`);
CREATE INDEX `email__users_idx` ON `users` (`email`);
CREATE INDEX `username__users_idx` ON `users` (`username`);

-- Таблица сессий
CREATE TABLE IF NOT EXISTS `sessions` (
	   `id` INTEGER NOT NULL,
	   `session_key` VARCHAR(32) NOT NULL UNIQUE,
   	   `session_data` TEXT NULL,
	   `expired` DATETIME NOT NULL,
   	   PRIMARY KEY (`id`)
);
CREATE INDEX `session_key__sessions_idx` ON `sessions` (`session_key`);

-- Таблица контентных страниц
CREATE TABLE IF NOT EXISTS `pages` (
	   `id` INTEGER NOT NULL,
	   `title` VARCHAR(250) NOT NULL,
   	   `body` TEXT NOT NULL,
	   `dt_created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   	   `dt_modified` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   	   `dt_publication` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   	   `is_public` BOOLEAN DEFAULT FALSE,
	   `user_id` INT NOT NULL,
   	   PRIMARY KEY (`id`),
   	   FOREIGN KEY (`user_id`) REFERENCES users(`id`) ON DELETE CASCADE
);
CREATE INDEX `user_id__pages_idx` ON `pages` (`user_id`);

-- Таблица статистики
CREATE TABLE IF NOT EXISTS `stats` (
	   `id` INTEGER NOT NULL,
	   `name` VARCHAR(50) NOT NULL,
   	   `value` INTEGER NOT NULL DEFAULT 0,
	   `dt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   	   PRIMARY KEY (`id`)
);
CREATE UNIQUE INDEX index_unique_on_a_and_b ON stats (`name`, `dt`);
