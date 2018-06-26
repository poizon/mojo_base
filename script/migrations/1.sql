--
-- !Comment: Создание основных таблиц приложения
--

-- !Apply:

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

CREATE TABLE IF NOT EXISTS `permissions` (
       `id` INTEGER NOT NULL,
       `title` ENUM('regular', 'moderator'),
       `comment` VARCHAR(200),
       UNIQUE (`title`),
       PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `user_permissions` (
       `user_id` INTEGER NOT NULL,
       `permission_id` INTEGER NOT NULL,
       FOREIGN KEY (`user_id`) REFERENCES users(`id`) ON DELETE NO ACTION,
       FOREIGN KEY (`permission_id`) REFERENCES permissions(`id`) ON DELETE NO ACTION
);

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

CREATE TABLE IF NOT EXISTS `stats` (
       `id` INTEGER NOT NULL,
       `name` VARCHAR(50) NOT NULL,
       `value` INTEGER NOT NULL DEFAULT 0,
       `dt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (`id`)
);
CREATE UNIQUE INDEX index_unique_on_a_and_b ON stats (`name`, `dt`);

-- !Revert:

DROP TABLE users;
DROP TABLE permissions;
DROP TABLE user_permissions;
DROP TABLE pages;
DROP TABLE stats;
