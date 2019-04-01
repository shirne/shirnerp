TRUNCATE TABLE `sa_permission`;

INSERT INTO `sa_permission` (`id`, `parent_id`,`name`, `url`,`key`, `icon`, `sort_id`, `disable`)
VALUES
  (1,0,'主面板','Index/index','Board','ion-md-speedometer',0,0),
  (2,0,'商品','','Content','ion-md-apps',1,0),
  (3,0,'采购','','Purchase','ion-md-cart',1,0),
  (4,0,'销售','','Sale','ion-md-analytics',1,0),
  (5,0,'财务','','Finance','ion-md-calculator',1,0),
  (7,0,'其它','','Other','ion-md-cube',7,1),
  (8,0,'会员','','Member','ion-md-person',8,1),
  (9,0,'系统','','System','ion-md-cog',9,0),
  (11,2,'分类管理','GoodsCategory/index','goods_category_index','ion-md-medical',0,0),
  (12,2,'商品管理','Goods/index','goods_index','ion-md-paper',0,0),
  (14,2,'仓库管理','Storage/index','storage_index','ion-md-filing',0,0),
  (13,2,'单页管理','Page/index','page_index','ion-md-document',0,1),
  (15,2,'商品调度','TransOrder/index','trans_order_index','ion-md-swap',0,0),
  (31,3,'供应商管理','Supplier/index','supplier_index','ion-md-contacts',0,0),
  (32,3,'入库单管理','PurchaseOrder/index','purchase_order_index','ion-md-paper',0,0),
  (41,4,'客户管理','Customer/index','customer_index','ion-md-contacts',0,0),
  (42,4,'销售单管理','SaleOrder/index','sale_order_index','ion-md-paper',0,0),
  (50,5,'财务总览','finance/index','finance_index','ion-md-easel',0,0),
  (51,5,'应收款','finance/receive','finance_receive','ion-md-arrow-round-forward',0,0),
  (52,5,'应付款','finance/payable','finance_payable','ion-md-arrow-round-back',0,0),
  (53,5,'收支明细','finance/logs','finance_logs','ion-md-paper',0,0),
  (70,7,'公告管理','Notice/index','notice_index','ion-md-megaphone',0,1),
  (71,7,'广告管理','Adv/index','adv_index','ion-md-aperture',0,1),
  (72,7,'链接管理','Links/index','links_index','ion-md-link',0,1),
  (73,7,'留言管理','Feedback/index','feedback_index','ion-md-chatbubbles',0,1),
  (80,8,'客户管理','Customer/index','customer_index','ion-md-person',0,0),
  (81,8,'邀请码','Invite/index','invite_index','ion-md-pricetags',0,1),
  (82,8,'会员组','MemberLevel/index','member_level_index','ion-md-people',0,0),
  (83,8,'余额明细','Member/money_log','member_money_log','ion-md-paper',0,0),
  (86,8,'操作日志','Member/log','member_log','ion-md-clipboard',0,0),
  (91,9,'配置管理','Setting/index','setting_index','ion-md-options',0,0),
  (92,9,'基础数据','Data/index','data_index','ion-md-grid',0,0),
  (93,9,'管理员','Manager/index','manager_index','ion-md-person',0,0),
  (94,9,'菜单管理','Permission/index','permission_index','ion-md-code-working',0,0),
  (95,9,'导航管理','Navigator/index','navigator_index','ion-md-reorder',0,1),
  (96,9,'操作日志','Manager/log','manager_log','ion-md-clipboard',0,0);


TRUNCATE TABLE `sa_manager`;

INSERT INTO `sa_manager` (`id`, `username`,`realname`, `email`, `password`, `salt`, `avatar`, `create_time`, `update_time`, `login_ip`, `status`, `type`)
VALUES
  (1,'admin','','79099818@qq.com','60271966bbad6ead5faa991772a9277f', 'z5La7s0P',NULL,'1436679338','1436935104','0.0.0.0',1,1);


TRUNCATE TABLE `sa_setting`;

INSERT INTO `sa_setting` ( `key`,`title`,`type`,`group`,`sort`,`is_sys`, `value`, `description`,`data`)
VALUES
  ('site-webname','站点名','text','common',0,1,'ShirneCMS','站点名',''),
  ('site-keywords','关键词','text','common',0,1,'关键词1,关键词2','关键词',''),
  ('site-description','站点描述','text','common',0,1,'站点描述信息','站点描述',''),
  ('site-weblogo','站点logo','image','common',0,1,'','站点logo',''),
  ('site-tongji','统计代码','textarea','common',0,1,'','统计代码',''),
  ('site-icp','ICP备案号','text','common',0,1,'123456','ICP备案号',''),
  ('site-url','站点网址','text','common',0,1,'http://www.shirne.cn','站点地址',''),
  ('site-name','公司名','text','common',0,1,'ShirneCMS','公司名',''),
  ('site-address','公司地址','text','common',0,1,'','公司地址',''),
  ('site-location','公司位置','location','common',0,1,'','location',''),
  ( 'wechat_autologin', '微信自动登录', 'radio', 'third', '0',1, '0', '必须在配置了服务号的情况下能有效', '1:开启\r\n2:关闭'),
  ( 'mail_host', '邮箱主机', 'text', 'advance', '0',1, '', '', ''),
  ( 'mail_port', '邮箱端口', 'text', 'advance', '0',1, '', '', ''),
  ( 'mail_user', '邮箱账户', 'text', 'advance', '0',1, '', '', ''),
  ( 'mail_pass', '邮箱密码', 'text', 'advance', '0',1, '', '', ''),
  ( 'sms_code', '短信验证', 'radio', 'third', '0',1, '0', '', '1:开启\r\n2:关闭'),
  ( 'sms_spcode', '企业编号', 'text', 'third', '0',1, '', '', ''),
  ( 'sms_loginname', '登录名称', 'text', 'third', '0',1, '', '', ''),
  ( 'sms_password', '登录密码', 'text', 'third', '0',1, '', '', ''),
  ( 'kd_userid', '快递鸟用户ID', 'text', 'third', '0',1, '', '', ''),
  ( 'kd_apikey', '快递鸟API Key', 'text', 'third', '0',1, '', '', ''),
  ( 'mapkey_baidu', '百度地图密钥', 'text', 'third', '0',1, 'rO9tOdEWFfvyGgDkiWqFjxK6', '', ''),
  ( 'mapkey_google', '谷哥地图密钥y', 'text', 'third', '0',1, 'AIzaSyB8lorvl6EtqIWz67bjWBruOhm9NYS1e24', '', ''),
  ( 'mapkey_tencent', '腾讯地图密钥', 'text', 'third', '0',1, '7I5BZ-QUE6R-JXLWV-WTVAA-CJMYF-7PBBI', '', ''),
  ( 'mapkey_gaode', '高德地图密钥', 'text', 'third', '0',1, '3ec311b5db0d597e79422eeb9a6d4449', '', ''),
  ( 'captcha_mode', '验证码模式', 'radio', 'third', '0',1, '0', '', '0:图形验证\r\n1:极验验证'),
  ( 'captcha_geeid', '极验ID', 'text', 'third', '0',1, '', '', ''),
  ( 'captcha_geekey', '极验密钥', 'text', 'third', '0',1, '', '', ''),
  ( 'kd_apikey', '快递鸟API Key', 'text', 'third', '0',1, '', '', ''),
  ( 'm_invite', '邀请注册', 'radio', 'member', '0',1, '1', '', '0:关闭\r\n1:启用\r\n2:强制'),
  ( 'm_register', '强制注册', 'radio', 'member', '0',1, '1', '', '0:关闭\r\n1:启用'),
  ( 'm_checkcode', '验证码', 'radio', 'member', '0',1, '1', '', '0:关闭\r\n1:启用');


TRUNCATE TABLE `sa_member_level`;

INSERT INTO `sa_member_level`(`level_id`,`level_name`,`short_name`,`is_default`,`level_price`,`sort`,`commission_layer`,`commission_percent`) VALUES (1,'普通会员','普',1,0.00,0,3,'[\"0\",\"0\",\"0\"]');


TRUNCATE TABLE `sa_category`;

INSERT INTO `sa_category`(`id`,`pid`,`title`,`short`,`name`,`icon`,`image`,`sort`,`keywords`,`description`)VALUES
(1,0,'新闻动态','新闻','news','','',0,'','');
