ShirneERP
===============

基于[ThinkPHP5.1](https://github.com/top-think/think/tree/5.1)+[bootstrap4.x](https://v4.bootcss.com/docs/4.0/getting-started/introduction/)开发的进存销系统

> 运行环境要求PHP7.1.3以上，Mysql5.5以上<br />
> PHP扩展：gd,mysql,pdo,cURL,OpenSSL,SimpleXML,fileinfo,cli。

## 功能说明
* 商品管理,商品单位
* 销售,退货, 客户管理, 标签打印
* 采购,退货, 供应商管理
* 生产流程, 生产单, 生产统计
* 各种订单统计及导出功能
* 币种
* 财务

## 计划中
* 生产单 生产流程，生产开单，结单，损耗
* 支出项
* 销售单与人员关联统计

## 注意事项
* ThinkPHP 升级
> 由于目录与默认ThinkPHP项目的差异，升级ThinkPHP时需要修改Loader.php
```php
  // 获取应用根目录
  public static function getRootPath()
  {
      if(defined('APP_PATH')){
          return dirname(APP_PATH). DIRECTORY_SEPARATOR;
      }else {
          //...  原方法代码
      }
  }
```

## 前端库引用

[twbs/bootstrap 4.x](https://v4.bootcss.com/docs/4.0/getting-started/introduction/)<br />
[components/jquery 3.3.1](http://api.jquery.com/)<br />
[eonasdan/bootstrap-datetimepicker](https://github.com/Eonasdan/bootstrap-datetimepicker/blob/master/docs/Options.md) 针对bootstrap4.x修改<br />
[driftyco/ionicons](http://ionicons.com/)<br />
[chartjs/Chart.js 2.7.2](https://chartjs.bootcss.com/docs/)<br />
[swiper](http://www.swiper.com.cn/)

## 后端库引用
[EasyWechat](https://www.easywechat.com/docs/3.x/zh-CN/index)<br />
[phpoffice/phpspreadsheet](https://phpspreadsheet.readthedocs.io/en/develop/)<br />
[phpmailer](https://github.com/PHPMailer/PHPMailer)<br />
[endroid/qr-code](https://github.com/endroid/qr-code)

## 开发说明

PHP库引用[Composer](https://getcomposer.org/download/)

>cd htdocs<br />
>composer install

Javascript/CSS构建[Gulp](https://www.gulpjs.com.cn/)

>cd htdocs/resource<br />
cnpm install<br />
构建并监视文件：gulp<br />
清理dest目录: gulp clean<br />
只监视文件: gulp watch

数据库

>scripts/struct.sql 数据表结构<br />
scripts/init.sql 初始数据<br />
scripts/update_shop.sql 商城模块<br />
scripts/update_wechat.sql 微信模块

项目目录

>htdocs 项目根目录<br />
htdocs/public 网站根目录

安装方法

> 修改数据库配置文件 config/database.php<br />
> 手动安装数据库脚本 或者 通过命令行(php think install)或网页安装(/task/util/install)


## 模板说明

分离模板目录配置 template.independence

标签库 [product](TAGLIB.md#product),[article](TAGLIB.md#article) 和 [extendtag](TAGLIB.md#extendtag)

弹出框组件说明 [Dialog](DIALOG.md)

导航配置 navigator.php
