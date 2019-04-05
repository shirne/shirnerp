<extend name="public:base" />

<block name="body">

<include file="public/bread" menu="Board" section="主面板" title=""/>
<div id="page-wrapper">
    <foreach name="notices" item="notice">
        <div class="alert alert-{$notice.type|default='warning'} alert-dismissible fade show" role="alert">
            {$notice.message|raw}
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    </foreach>
    <div class="row">
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="card border-info">
                <div class="card-body">
                    <div class="row">
                        <div class="col-6">
                            <i class="ion-md-apps ion-5x"></i>
                        </div>
                        <div class="col-6 text-right">
                            <p class="announcement-heading">{$stat.goods}</p>
                            <p class="announcement-text">商品</p>
                        </div>
                    </div>
                </div>
                <div class="card-footer announcement-bottom">
                    <nav class="nav nav-fill">
                        <a class="nav-item nav-link" href="{:url('goods/index')}"><i class="ion-md-navicon"></i> 管理商品 </a>
                        <a class="nav-item nav-link" href="{:url('storage/index')}"><i class="ion-md-stats-bars"></i> 管理库存 </a>
                    </nav>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="card border-info">
                <div class="card-body">
                    <div class="row">
                        <div class="col-6">
                            <i class="ion-md-people ion-5x"></i>
                        </div>
                        <div class="col-6 text-right">
                            <p class="announcement-heading">{$stat.customer}</p>
                            <p class="announcement-text">客户</p>
                        </div>
                    </div>
                </div>
                <div class="card-footer announcement-bottom">
                    <nav class="nav nav-fill">
                        <a class="nav-item nav-link" href="{:url('customer/index')}"><i class="ion-md-navicon"></i> 管理客户 </a>
                        <a class="nav-item nav-link" href="{:url('finance/receive')}"><i class="ion-md-add"></i> 应收款 </a>
                    </nav>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="card border-info">
                <div class="card-body">
                    <div class="row">
                        <div class="col-6">
                            <i class="ion-md-contacts ion-5x"></i>
                        </div>
                        <div class="col-6 text-right">
                            <p class="announcement-heading">{$stat.supplier}</p>
                            <p class="announcement-text">供应商</p>
                        </div>
                    </div>
                </div>
                <div class="card-footer announcement-bottom">
                    <nav class="nav nav-fill">
                        <a class="nav-item nav-link" href="{:url('supplier/index')}"><i class="ion-md-navicon"></i> 管理供应商 </a>
                        <a class="nav-item nav-link" href="{:url('finance/payable')}"><i class="ion-md-remove"></i> 应付款 </a>
                    </nav>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="card border-info">
                <div class="card-body">
                    <div class="row">
                        <div class="col-6">
                            <i class="ion-md-analytics ion-5x"></i>
                        </div>
                        <div class="col-6 text-right">
                            <p class="announcement-heading">{$stat.sale_order}</p>
                            <p class="announcement-text">销售</p>
                        </div>
                    </div>
                </div>
                <div class="card-footer announcement-bottom">
                    <nav class="nav nav-fill">
                        <a class="nav-item nav-link" href="{:url('saleOrder/index')}"><i class="ion-md-navicon"></i> 管理销售单 </a>
                        <a class="nav-item nav-link" href="{:url('saleOrder/statics')}"><i class="ion-md-stats-bars"></i> 订单统计 </a>
                    </nav>
                </div>
            </div>
        </div>
    </div>

    <php>$empty=list_empty(3);</php>
    <div class="row">
        <div class="col-md-6 mb-3">
            <div class="card border-default">
                <div class="card-header">
                    <a href="{:url('saleOrder/create')}" class="float-right">销售开单</a>
                    <h5 class="panel-title"><i class="ion-md-stats"></i> 销售</h5>
                </div>
                <table class="table table-striped">
                    <tr>
                        <th>日期</th>
                        <th>销售单数</th>
                        <th>销售金额</th>
                    </tr>
                    <volist name="saleOrders" id="order" empty="$empty">
                        <tr>
                            <td>{$order.awdate}</td>
                            <td>{$order.order_count}</td>
                            <td>{$order.order_amount}</td>
                        </tr>
                    </volist>
                </table>
            </div>
        </div>
        <div class="col-md-6 mb-3">
            <div class="card border-default">
                <div class="card-header">
                    <h5 class="panel-title"><i class="ion-md-filing"></i> 库存</h5>
                </div>
                <table class="table table-striped">
                    <tr>
                        <th>仓库</th>
                        <th>品种数</th>
                        <th>品种量</th>
                    </tr>
                    <volist name="storages" id="storage" empty="$empty">
                        <tr>
                            <td>{$storage.title}</td>
                            <td>{$storage.goods_count}</td>
                            <td>{$storage.goods_total}</td>
                        </tr>
                    </volist>
                </table>
            </div>
        </div>
        <div class="col-md-6 mb-3">
            <div class="card border-default">
                <div class="card-header">
                    <h5 class="panel-title"><i class="ion-md-swap"></i> 资金</h5>
                </div>
                <table class="table table-striped">
                    <tr>
                        <th>款项</th>
                        <th>总额</th>
                        <th>账龄30天内</th>
                        <th>账龄90天内</th>
                        <th>账龄90天以上</th>
                    </tr>
                    <tr>
                        <td>应收账款</td>
                        <td> {$finance.sales.total} </td>
                        <td> {$finance.sales.in30days} </td>
                        <td> {$finance.sales.in90days} </td>
                        <td> {$finance.sales.out90days} </td>
                    </tr>
                    <tr>
                        <td>应付账款</td>
                        <td> {$finance.purchases.total} </td>
                        <td> {$finance.purchases.in30days} </td>
                        <td> {$finance.purchases.in90days} </td>
                        <td> {$finance.purchases.out90days} </td>
                    </tr>
                </table>
            </div>
        </div>
        <div class="col-md-6 mb-3">
            <div class="card border-default">
                <div class="card-header">
                    <a href="{:url('purchaseOrder/create')}" class="float-right">采购入库</a>
                    <h5 class="panel-title"><i class="ion-md-cart"></i> 采购</h5>
                </div>
                <table class="table table-striped">
                    <tr>
                        <th>日期</th>
                        <th>采购单数</th>
                        <th>采购金额</th>
                    </tr>
                    <volist name="purchaseOrders" id="order" empty="$empty">
                        <tr>
                            <td>{$order.awdate}</td>
                            <td>{$order.order_count}</td>
                            <td>{$order.order_amount}</td>
                        </tr>
                    </volist>
                </table>
            </div>
        </div>
    </div>

</div>

</block>