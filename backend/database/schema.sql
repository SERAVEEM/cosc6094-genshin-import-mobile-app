-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `genshin_import`;
USE `genshin_import`;

-- Table 1: users
CREATE TABLE IF NOT EXISTS `users` (
  `id` VARCHAR(36) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password` VARCHAR(255) DEFAULT NULL,
  `oauth_id` VARCHAR(255) DEFAULT NULL,
  `role` ENUM('admin', 'user') NOT NULL DEFAULT 'user',
  `session_token` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_session_token` (`session_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 2: weapons
CREATE TABLE IF NOT EXISTS `weapons` (
  `id` VARCHAR(36) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `type` VARCHAR(100) NOT NULL,
  `description` TEXT NOT NULL,
  `stock` INT NOT NULL DEFAULT 0,
  `image` VARCHAR(255) NOT NULL,
  `price` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `banner` VARCHAR(255) NOT NULL DEFAULT 'default_banner.png',
  `showcase1` VARCHAR(255) NOT NULL DEFAULT 'default_showcase1.png',
  `showcase2` VARCHAR(255) NOT NULL DEFAULT 'default_showcase2.png',
  `showcase3` VARCHAR(255) NOT NULL DEFAULT 'default_showcase3.png',
  `deleted_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Upgrade migrations for existing local databases
ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `session_token` VARCHAR(255) DEFAULT NULL;
ALTER TABLE `users` ADD INDEX IF NOT EXISTS `idx_session_token` (`session_token`);
ALTER TABLE `weapons` ADD COLUMN IF NOT EXISTS `banner` VARCHAR(255) NOT NULL DEFAULT 'default_banner.png';
ALTER TABLE `weapons` ADD COLUMN IF NOT EXISTS `showcase1` VARCHAR(255) NOT NULL DEFAULT 'default_showcase1.png';
ALTER TABLE `weapons` ADD COLUMN IF NOT EXISTS `showcase2` VARCHAR(255) NOT NULL DEFAULT 'default_showcase2.png';
ALTER TABLE `weapons` ADD COLUMN IF NOT EXISTS `showcase3` VARCHAR(255) NOT NULL DEFAULT 'default_showcase3.png';

-- Table 2.5: weapon_stats
CREATE TABLE IF NOT EXISTS `weapon_stats` (
  `weapon_id` VARCHAR(36) NOT NULL,
  `ratings` VARCHAR(50) NOT NULL DEFAULT '5.0',
  `dmg` VARCHAR(50) NOT NULL DEFAULT '0',
  `crit_rate` VARCHAR(50) NOT NULL DEFAULT '0%',
  `crit_dmg` VARCHAR(50) NOT NULL DEFAULT '0%',
  PRIMARY KEY (`weapon_id`),
  CONSTRAINT `fk_weapon_stats_weapons` FOREIGN KEY (`weapon_id`) REFERENCES `weapons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 2.6: product comments
CREATE TABLE IF NOT EXISTS `comments` (
  `id` VARCHAR(36) NOT NULL,
  `weapon_id` VARCHAR(36) NOT NULL,
  `user_id` VARCHAR(36) NOT NULL,
  `rating` TINYINT NOT NULL DEFAULT 5,
  `content` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_comments_weapon_created` (`weapon_id`, `created_at`),
  KEY `fk_comments_users` (`user_id`),
  CONSTRAINT `fk_comments_weapons` FOREIGN KEY (`weapon_id`) REFERENCES `weapons` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comments_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_comments_rating` CHECK (`rating` BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 3: transactions
CREATE TABLE IF NOT EXISTS `transactions` (
  `id` VARCHAR(36) NOT NULL,
  `user_id` VARCHAR(36) NOT NULL,
  `weapon_id` VARCHAR(36) NOT NULL,
  `quantity` INT NOT NULL,
  `total_price` DECIMAL(15,2) NOT NULL,
  `redeem_code` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_transactions_users` (`user_id`),
  KEY `fk_transactions_weapons` (`weapon_id`),
  CONSTRAINT `fk_transactions_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_transactions_weapons` FOREIGN KEY (`weapon_id`) REFERENCES `weapons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed Data (Bcrypt hashes represent password 'password123')
-- Admin User UUID: 'a8be354d-eb23-49ec-8cb3-7a9192461421'
-- Regular User UUID: 'b287955d-16ef-46e3-82bd-dfcdcf209b5a'
INSERT INTO `users` (`id`, `name`, `email`, `password`, `oauth_id`, `role`) VALUES
('a8be354d-eb23-49ec-8cb3-7a9192461421', 'Aimin Admin', 'admin@gachamerch.com', '$2a$10$D0LFIO59dLXz82ghvg1dkOUG6PFt1M6ZrECAkOF7mmxPIg2FnKfSO', NULL, 'admin'),
('b287955d-16ef-46e3-82bd-dfcdcf209b5a', 'Tabibito User', 'user@gachamerch.com', '$2a$10$D0LFIO59dLXz82ghvg1dkOUG6PFt1M6ZrECAkOF7mmxPIg2FnKfSO', NULL, 'user')
ON DUPLICATE KEY UPDATE `email`=`email`, `password`=VALUES(`password`);

-- Weapons Seed
INSERT INTO `weapons` (`id`, `name`, `type`, `description`, `stock`, `image`, `price`, `banner`, `showcase1`, `showcase2`, `showcase3`, `deleted_at`) VALUES
('w1000001-eb23-49ec-8cb3-7a9192461421', 'Wolf\'s Gravestone', 'Claymore', 'A longsword used by the Wolf Knight. Originally just a heavy sheet of iron, it gained legendary power through its close friendship with the wolf.', 5, 'assets/Product/Missplitter reforged.png', 1500000.00, 'assets/Product/mistsplitter Banner.png', 'assets/Product/Missplitter showcase.png', 'assets/Product/mistsplitter Banner.png', 'assets/Product/Missplitter showcase2.png', NULL),
('w1000002-eb23-49ec-8cb3-7a9192461421', 'Primordial Jade Winged-Spear', 'Polearm', 'A jade spear created by the Archons. Its light shines with the purity of primeval stone, capable of piercing dragons and sealing gods.', 3, 'assets/Product/Susano\'o sword.png', 1400000.00, 'assets/Product/mistsplitter Banner.png', 'assets/Product/Missplitter showcase.png', 'assets/Product/mistsplitter Banner.png', 'assets/Product/Missplitter showcase2.png', NULL),
('w1000003-eb23-49ec-8cb3-7a9192461421', 'Gladiator\'s Nostalgia', 'Artifact-Flower', 'A flower badge worn by the ancient gladiators. Symbolizes the dreams and nostalgia of the fighters who fought in the colosseum.', 10, 'assets/Product/Sword of destiny.png', 500000.00, 'assets/Product/mistsplitter Banner.png', 'assets/Product/Missplitter showcase.png', 'assets/Product/mistsplitter Banner.png', 'assets/Product/Missplitter showcase2.png', NULL)
ON DUPLICATE KEY UPDATE
`name`=VALUES(`name`),
`type`=VALUES(`type`),
`description`=VALUES(`description`),
`stock`=VALUES(`stock`),
`image`=VALUES(`image`),
`price`=VALUES(`price`),
`banner`=VALUES(`banner`),
`showcase1`=VALUES(`showcase1`),
`showcase2`=VALUES(`showcase2`),
`showcase3`=VALUES(`showcase3`),
`deleted_at`=VALUES(`deleted_at`);

-- Stats Seed
INSERT INTO `weapon_stats` (`weapon_id`, `ratings`, `dmg`, `crit_rate`, `crit_dmg`) VALUES
('w1000001-eb23-49ec-8cb3-7a9192461421', '5.0', '250', '40%', '150%'),
('w1000002-eb23-49ec-8cb3-7a9192461421', '4.8', '224', '35%', '130%'),
('w1000003-eb23-49ec-8cb3-7a9192461421', '4.9', '0', '15%', '80%')
ON DUPLICATE KEY UPDATE
`ratings`=VALUES(`ratings`),
`dmg`=VALUES(`dmg`),
`crit_rate`=VALUES(`crit_rate`),
`crit_dmg`=VALUES(`crit_dmg`);

-- Upgrade migration step for existing transactions tables
ALTER TABLE `transactions` ADD COLUMN IF NOT EXISTS `redeem_code` VARCHAR(255) DEFAULT NULL;
