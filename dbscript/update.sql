DROP TABLE IF EXISTS `sa_currency`;
CREATE TABLE `sa_currency` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(20) DEFAULT NULL COMMENT '币种编码',
  `title` varchar(50) DEFAULT NULL COMMENT '币种名称',
  `symbol` varchar(2) DEFAULT NULL COMMENT '币种符号',
  `icon` varchar(150) DEFAULT NULL COMMENT '图标',
  `sort` int(11) DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_goods_category`;
CREATE TABLE `sa_goods_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pid` int(11) DEFAULT NULL COMMENT '父分类ID',
  `title` varchar(100) DEFAULT NULL COMMENT '分类名称',
  `short` varchar(20) DEFAULT NULL COMMENT '分类简称',
  `name` varchar(50) DEFAULT NULL COMMENT '分类别名',
  `icon` varchar(150) DEFAULT NULL COMMENT '图标',
  `image` varchar(100) DEFAULT NULL COMMENT '大图',
  `sort` int(11) DEFAULT 0 COMMENT '排序',
  `description` varchar(255) DEFAULT NULL COMMENT '分类描述',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_goods`;
CREATE TABLE `sa_goods` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(50) NOT NULL,
  `fullname` VARCHAR(100) DEFAULT '',
  `alianames` VARCHAR(200) DEFAULT '',
  `goods_no` VARCHAR(30) DEFAULT '',
  `cate_id` INT(11) DEFAULT 0 COMMENT '排序',
  `unit` VARCHAR(5) DEFAULT '斤',
  `image` VARCHAR(150) DEFAULT '',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`) USING BTREE,
  UNIQUE KEY `goods_no` (`goods_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sa_storage`;
CREATE TABLE `sa_storage` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(50) NOT NULL,
  `fullname` VARCHAR(100) DEFAULT '',
  `province` VARCHAR(50) DEFAULT '',
  `city` VARCHAR(30) DEFAULT '',
  `area` VARCHAR(50) DEFAULT '',
  `address` VARCHAR(200) DEFAULT '',
  `storage_no` VARCHAR(30) DEFAULT '',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`) USING BTREE,
  UNIQUE KEY `storage_no` (`storage_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_goods_storage`;
CREATE TABLE `sa_goods_storage` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `goods_id` INT(11) NOT NULL,
  `storage_id` INT(11) NOT NULL,
  `count` DECIMAL(14,4) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `goods_id` (`goods_id`),
  KEY `storage_id` (`storage_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_supplier`;
CREATE TABLE `sa_supplier` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `short` VARCHAR(50) NOT NULL,
  `province` VARCHAR(50) DEFAULT '',
  `city` VARCHAR(30) DEFAULT '',
  `area` VARCHAR(50) DEFAULT '',
  `address` VARCHAR(200) DEFAULT '',
  `phone` varchar(20) NULL,
	`website` varchar(100) NULL,
	`email` varchar(150) NULL,
	`fax` varchar(20) NULL,
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`) USING BTREE,
  UNIQUE KEY `short` (`short`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sa_purchase_order`;
CREATE TABLE `sa_purchase_order` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `supplier_id` INT(11) NOT NULL,
  `storage_id` INT(4) NOT NULL,
  `order_no` VARCHAR(30) NOT NULL,
  `status` TINYINT(4) NOT NULL,
  `amount` DECIMAL(14,2) DEFAULT '0',
  `payed_amount` DECIMAL(14,2) DEFAULT '0',
  `currency` VARCHAR(10) DEFAULT 'RMB',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `supplier_id` (`supplier_id`) USING BTREE,
  UNIQUE KEY `storage_id` (`storage_id`) USING BTREE,
  UNIQUE KEY `order_no` (`order_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_purchase_order_goods`;
CREATE TABLE `sa_purchase_order_goods` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `purchase_order_id` INT(11) NOT NULL,
  `goods_id` INT(11) NOT NULL,
  `storage_id` INT(4) NOT NULL,
  `goods_title` VARCHAR(50) NOT NULL,
  `goods_no` VARCHAR(30) DEFAULT '',
  `goods_unit` VARCHAR(5) DEFAULT '斤',
  `count` DECIMAL(14,2) DEFAULT '0',
  `amount` DECIMAL(14,2) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `goods_id` (`goods_id`) USING BTREE,
  UNIQUE KEY `purchase_order_id` (`purchase_order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sa_customer`;
CREATE TABLE `sa_customer` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `short` VARCHAR(50) NOT NULL,
  `province` VARCHAR(50) DEFAULT '',
  `city` VARCHAR(30) DEFAULT '',
  `area` VARCHAR(50) DEFAULT '',
  `address` VARCHAR(200) DEFAULT '',
  `phone` varchar(20) NULL,
	`website` varchar(100) NULL,
	`email` varchar(150) NULL,
	`fax` varchar(20) NULL,
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`) USING BTREE,
  UNIQUE KEY `short` (`short`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_sale_order`;
CREATE TABLE `sa_sale_order` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT(11) NOT NULL,
  `storage_id` INT(11) NOT NULL,
  `order_no` VARCHAR(30) NOT NULL,
  `status` TINYINT(4) NOT NULL,
  `amount` DECIMAL(14,2) DEFAULT '0',
  `payed_amount` DECIMAL(14,2) DEFAULT '0',
  `currency` VARCHAR(10) DEFAULT 'RMB',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_id` (`customer_id`) USING BTREE,
  UNIQUE KEY `order_no` (`order_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_sale_order_goods`;
CREATE TABLE `sa_sale_order_goods` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sale_order_id` INT(11) NOT NULL,
  `goods_id` INT(11) NOT NULL,
  `storage_id` INT(4) NOT NULL,
  `goods_title` VARCHAR(50) NOT NULL,
  `goods_no` VARCHAR(30) DEFAULT '',
  `goods_unit` VARCHAR(5) DEFAULT '斤',
  `count` DECIMAL(14,2) DEFAULT '0',
  `amount` DECIMAL(14,2) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `goods_id` (`goods_id`) USING BTREE,
  UNIQUE KEY `sale_order_id` (`sale_order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;