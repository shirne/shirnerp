DROP TABLE IF EXISTS `sa_currency`;
CREATE TABLE `sa_currency` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(20) DEFAULT NULL COMMENT '币种编码',
  `title` varchar(50) DEFAULT NULL COMMENT '币种名称',
  `symbol` varchar(10) DEFAULT NULL COMMENT '币种符号',
  `icon` varchar(150) DEFAULT NULL COMMENT '图标',
  `is_base` tinyint(11) DEFAULT 0 COMMENT '基准货币',
  `exchange_rate` DECIMAL(18,8) DEFAULT 1 COMMENT '汇率',
  `sort` int(11) DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_currency_rate`;
CREATE TABLE `sa_currency_rate` (
  `id` bigint(11) NOT NULL AUTO_INCREMENT,
  `currency` varchar(20) DEFAULT NULL COMMENT '币种编码',
  `exchange_rate` DECIMAL(18,8) DEFAULT 1 COMMENT '汇率',
  `create_time` int(11) DEFAULT 0 COMMENT '时间',
  PRIMARY KEY (`id`),
  KEY `currency` (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_unit`;
CREATE TABLE `sa_unit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(10) DEFAULT NULL COMMENT '单位名称',
  `description` varchar(50) DEFAULT NULL COMMENT '单位说明',
  `weight_rate` DECIMAL(18,8) DEFAULT 0 COMMENT '重量转换率',
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
  `price_type` TINYINT(4) DEFAULT '0',
  `unit` VARCHAR(5) DEFAULT '斤',
  `image` VARCHAR(150) DEFAULT '',
  `description` VARCHAR(500) DEFAULT '',
  `delete_time` INT(11) DEFAULT '0',
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

DROP TABLE IF EXISTS `sa_storage_inventory`;
CREATE TABLE `sa_storage_inventory` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `storage_id` INT(4) NOT NULL,
  `order_no` VARCHAR(30) NOT NULL,
  `status` TINYINT(4) NOT NULL,
  `inventory_time` INT(11) DEFAULT '0',
  `delete_time` INT(11) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `storage_id` (`storage_id`) ,
  UNIQUE KEY `order_no` (`order_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_storage_inventory_goods`;
CREATE TABLE `sa_storage_inventory_goods` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `inventory_id` INT(11) NOT NULL,
  `goods_id` INT(11) NOT NULL,
  `count` DECIMAL(14,2) DEFAULT '0',
  `new_count` DECIMAL(14,2) DEFAULT '0',
  `delete_time` INT(11) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `goods_id` (`goods_id`),
  KEY `inventory_id` (`inventory_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_trans_order`;
CREATE TABLE `sa_trans_order` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `from_storage_id` INT(11) NOT NULL,
  `storage_id` INT(4) NOT NULL,
  `order_no` VARCHAR(30) NOT NULL,
  `status` TINYINT(4) NOT NULL,
  `delete_time` INT(11) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `from_storage_id` (`from_storage_id`) ,
  KEY `storage_id` (`storage_id`) ,
  UNIQUE KEY `order_no` (`order_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_trans_order_goods`;
CREATE TABLE `sa_trans_order_goods` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `trans_order_id` INT(11) NOT NULL,
  `goods_id` INT(11) NOT NULL,
  `goods_title` VARCHAR(50) NOT NULL,
  `goods_no` VARCHAR(30) DEFAULT '',
  `goods_unit` VARCHAR(5) DEFAULT '斤',
  `count` DECIMAL(14,2) DEFAULT '0',
  `delete_time` INT(11) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `goods_id` (`goods_id`),
  KEY `trans_order_id` (`trans_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_supplier`;
CREATE TABLE `sa_supplier` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `short` VARCHAR(50) NOT NULL,
  `spell` VARCHAR(100) NOT NULL,
  `province` VARCHAR(50) DEFAULT '',
  `city` VARCHAR(30) DEFAULT '',
  `area` VARCHAR(50) DEFAULT '',
  `address` VARCHAR(200) DEFAULT '',
  `phone` varchar(20) NULL,
	`website` varchar(100) NULL,
	`email` varchar(150) NULL,
	`fax` varchar(20) NULL,
  `status` TINYINT(4) DEFAULT '1',
  `delete_time` INT(11) DEFAULT '0',
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
  `storage_id` INT(11) NOT NULL,
  `order_no` VARCHAR(30) NOT NULL,
  `parent_order_id` INT(11) NOT NULL,
  `supplier_order_no` VARCHAR(30) NOT NULL,
  `status` TINYINT(4) NOT NULL,
  `pay_status` TINYINT(4) DEFAULT '0',
  `diy_price` TINYINT(4) DEFAULT '0',
  `amount` DECIMAL(14,2) DEFAULT '0',
  `payed_amount` DECIMAL(14,2) DEFAULT '0',
  `currency` VARCHAR(10) DEFAULT 'RMB',
  `base_amount` DECIMAL(14,2) DEFAULT '0',
  `freight` DECIMAL(14,2) DEFAULT '0',
  `remark` VARCHAR(100) DEFAULT '',
  `payed_time` INT(11) DEFAULT '0',
  `confirm_time` INT(11) DEFAULT '0',
  `delete_time` INT(11) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `storage_id` (`storage_id`),
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
  `price_type` TINYINT(4) DEFAULT '0',
  `count` DECIMAL(14,2) DEFAULT '0',
  `base_count` DECIMAL(14,2) DEFAULT '0',
  `weight` DECIMAL(14,4) DEFAULT '0',
  `diy_price` TINYINT(4) DEFAULT '0',
  `price` DECIMAL(14,2) DEFAULT '0',
  `base_price` DECIMAL(14,2) DEFAULT '0',
  `amount` DECIMAL(14,2) DEFAULT '0',
  `base_amount` DECIMAL(14,2) DEFAULT '0',
  `remark` VARCHAR(100) DEFAULT '',
  `delete_time` INT(11) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `goods_id` (`goods_id`),
  KEY `purchase_order_id` (`purchase_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sa_customer`;
CREATE TABLE `sa_customer` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `short` VARCHAR(50) NOT NULL,
  `spell` VARCHAR(100) NOT NULL,
  `province` VARCHAR(50) DEFAULT '',
  `city` VARCHAR(30) DEFAULT '',
  `area` VARCHAR(50) DEFAULT '',
  `address` VARCHAR(200) DEFAULT '',
  `phone` varchar(20) NULL,
	`website` varchar(100) NULL,
	`email` varchar(150) NULL,
	`fax` varchar(20) NULL,
  `status` TINYINT(4) DEFAULT '1',
  `delete_time` INT(11) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`) USING BTREE,
  UNIQUE KEY `short` (`short`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_sale_package`;
CREATE TABLE `sa_sale_package` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sort` INT(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_sale_package_item`;
CREATE TABLE `sa_sale_package_item` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `storage_id` INT(11) NOT NULL,
  `package_id` INT(11) NOT NULL,
  `customer_id` INT(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_sale_package_goods`;
CREATE TABLE `sa_sale_package_goods` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `package_id` INT(11) DEFAULT '0',
  `item_id` INT(11) DEFAULT '0',
  `goods_id` INT(11) DEFAULT '0',
  `count` INT(11) DEFAULT '0',
  `unit` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_sale_order`;
CREATE TABLE `sa_sale_order` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `manager_id` INT(11) NOT NULL,
  `customer_id` INT(11) NOT NULL,
  `package_id` INT(11) NOT NULL,
  `storage_id` INT(11) NOT NULL,
  `order_no` VARCHAR(30) NOT NULL,
  `parent_order_id` INT(11) NOT NULL,
  `customer_order_no` VARCHAR(30) NOT NULL,
  `status` TINYINT(4) NOT NULL,
  `pay_status` TINYINT(4) DEFAULT '0',
  `diy_price` TINYINT(4) DEFAULT '0',
  `amount` DECIMAL(14,2) DEFAULT '0',
  `payed_amount` DECIMAL(14,2) DEFAULT '0',
  `currency` VARCHAR(10) DEFAULT 'RMB',
  `base_amount` DECIMAL(14,2) DEFAULT '0',
  `freight` DECIMAL(14,2) DEFAULT '0',
  `remark` VARCHAR(100) DEFAULT '',
  `delete_time` INT(11) DEFAULT '0',
  `payed_time` INT(11) DEFAULT '0',
  `customer_time` INT(11) DEFAULT '0',
  `confirm_time` INT(11) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
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
  `price_type` TINYINT(4) DEFAULT '0',
  `count` DECIMAL(14,2) DEFAULT '0',
  `base_count` DECIMAL(14,2) DEFAULT '0',
  `weight` DECIMAL(14,4) DEFAULT '0',
  `diy_price` TINYINT(4) DEFAULT '0',
  `price` DECIMAL(14,2) DEFAULT '0',
  `base_price` DECIMAL(14,2) DEFAULT '0',
  `amount` DECIMAL(14,2) DEFAULT '0',
  `base_amount` DECIMAL(14,2) DEFAULT '0',
  `remark` VARCHAR(100) DEFAULT '',
  `delete_time` INT(11) DEFAULT '0',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `goods_id` (`goods_id`),
  KEY `sale_order_id` (`sale_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sa_finance_log`;
CREATE TABLE `sa_finance_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(10) DEFAULT NULL COMMENT '日志类型',
  `amount` DECIMAL(14,2) DEFAULT '0',
  `currency` VARCHAR(10) DEFAULT 'RMB',
  `base_amount` DECIMAL(14,2) DEFAULT '0',
  `pay_type` VARCHAR(10) DEFAULT '',
  `order_id` INT(11) DEFAULT '0',
  `customer_id` INT(11) DEFAULT '0',
  `supplier_id` INT(11) DEFAULT '0',
  `remark` VARCHAR(100) DEFAULT '',
  `create_time` INT(11) DEFAULT '0',
  `update_time` INT(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `customer_id` (`customer_id`),
  KEY `supplier_id` (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;