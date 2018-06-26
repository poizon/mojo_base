--
-- !Comment: Удаление таблицы со статистикой
--

-- !Apply:

DROP TABLE `stats`;

-- !Revert:

CREATE TABLE IF NOT EXISTS `stats` (
       `id` INTEGER NOT NULL,
       `name` VARCHAR(50) NOT NULL,
       `value` INTEGER NOT NULL DEFAULT 0,
       `dt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (`id`)
);
CREATE UNIQUE INDEX index_unique_on_a_and_b ON stats (`name`, `dt`);
