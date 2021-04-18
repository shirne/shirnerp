<?php
return array(
    'goodscategory'=>array(
        'title'=>'产品分类',
        'items'=>array(
            'index'=>'内容分类查看',
            'add'=>'内容分类添加',
            'edit'=>'内容分类修改',
            'delete'=>'内容分类删除'
        )
    ),
    'goods'=>array(
        'title'=>'商品管理',
        'items'=>array(
            'index'=>'商品查看',
            'importorder'=>'订单导入转换',
            'add'=>'商品添加',
            'batch'=>'批量添加',
            'import'=>'导入商品资料',
            'edit'=>'商品修改',
            'delete'=>'商品删除',
            'rank'=>'商品统计',
            'rankexport'=>'统计导出',
            'statics'=>'单品统计',
            'staticsexport'=>'单品统计导出'
        )
    ),
    'storage'=>array(
        'title'=>'仓库管理',
        'items'=>array(
            'index'=>'仓库查看',
            'getstorage'=>'商品库存查询接口',
            'add'=>'仓库添加',
            'edit'=>'仓库修改',
            'delete'=>'仓库删除',
            'createinventory'=>'创建盘点',
            'inventory'=>'盘点单列表',
            'inventorydetail'=>'盘点单详情',
            'deleteinventory'=>'删除盘点',
            'goods'=>'仓库商品',
            'prints'=>'打印商品库存',
            'export'=>'导出商品库存'
        )
    ),
    'transorder'=>array(
        'title'=>'转库管理',
        'items'=>array(
            'index'=>'订单查看',
            'create'=>'转库下单',
            'delete'=>'订单删除',
            'status'=>'订单状态',
        )
    ),
    'supplier'=>array(
        'title'=>'供应商管理',
        'items'=>array(
            'index'=>'供应商查看',
            'add'=>'供应商添加',
            'import'=>'导入供应商',
            'edit'=>'供应商修改',
            'delete'=>'供应商删除',
            'rank'=>'供应商排行',
            'rankexport'=>'排行导出',
            'statics'=>'供应商统计',
            'staticsexport'=>'统计导出',
        )
    ),
    'purchaseorder'=>array(
        'title'=>'采购管理',
        'items'=>array(
            'index'=>'订单查看',
            'create'=>'采购下单',
            'back'=>'采购退货',
            'export'=>'导出订单列表',
            'exportone'=>'导出订单',
            'detail'=>'订单查看/编辑',
            'delete'=>'订单删除',
            'status'=>'订单状态',
            'log'=>'操作日志',
            'statics'=>'订单统计',
        )
    ),
    'customer'=>array(
        'title'=>'客户管理',
        'items'=>array(
            'index'=>'客户查看',
            'add'=>'客户添加',
            'import'=>'导入客户',
            'edit'=>'客户修改',
            'delete'=>'客户删除',
            'rank'=>'客户排行',
            'rankexport'=>'排行导出',
            'statics'=>'客户统计',
            'staticsexport'=>'统计导出',
        )
    ),
    'saleorder'=>array(
        'title'=>'销售管理',
        'items'=>array(
            'index'=>'订单查看',
            'create'=>'销售下单',
            'back'=>'销售退货',
            'export'=>'导出订单列表',
            'exportone'=>'导出订单',
            'detail'=>'订单查看/编辑',
            'prints'=>'打印标签',
            'delete'=>'订单删除',
            'status'=>'订单状态',
            'log'=>'操作日志',
            'statics'=>'订单统计',
        )
    ),
    'finance'=>array(
        'title'=>'财务管理',
        'items'=>array(
            'index'=>'财务总览',
            'receive'=>'收款管理',
            'receivelog'=>'收款录入',
            'receivedetail'=>'收款详情',
            'payable'=>'付款管理',
            'payablelog'=>'付款录入',
            'payabledetail'=>'付款详情',
            'logs'=>'财务明细',
        )
    ),
    'data'=>array(
        'title'=>'基础数据',
        'items'=>array(
            'index'=>'基础数据管理',
            'edit_unit'=>'编辑/添加单位',
            'unit_delete'=>'单位删除',
            'edit_currency'=>'编辑/添加货币',
            'currency_delete'=>'货币删除',
            'setbasecurrency'=>'设置基准货币',
            'setcurrencyrate'=>'更新货币汇率'
        )
    ),
    'setting'=>array(
        'title'=>'系统配置',
        'items'=>array(
            'index'=>'系统配置',
            'import'=>'配置导入',
            'export'=>'配置导出',
            'advance'=>'配置管理',
            'add'=>'配置添加',
            'edit'=>'配置修改',
            'delete'=>'配置删除'
        )
    ),
    'manager'=>array(
        'title'=>'管理员',
        'items'=>array(
            'index'=>'管理员查看',
            'add'=>'管理员添加',
            'edit'=>'管理员修改',
            'permision'=>'管理员权限',
            'log'=>'操作日志',
            'delete'=>'管理员删除'
        )
    ),
);
//end