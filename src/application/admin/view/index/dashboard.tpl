{extend name="public:base" /}

{block name="body"}

{include file="public/bread" menu="Board" section="主面板" title=""/}
<div id="page-wrapper">
    {foreach $notices as $notice}
        <div class="alert alert-{$notice.type|default='warning'} alert-dismissible fade show" role="alert">
            {$notice.message|raw}
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    {/foreach}
    <div class="row">
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="card border-info">
                <div class="card-body">
                    <div class="row">
                        <div class="col-4">
                            <i class="ion-md-apps ion-5x"></i>
                        </div>
                        <div class="col text-right">
                            <p class="announcement-heading">{$stat.goods}</p>
                            <p class="announcement-text">商品</p>
                        </div>
                    </div>
                </div>
                <div class="card-footer announcement-bottom">
                    <nav class="nav nav-fill">
                        <a class="nav-item nav-link" data-nav="goods_index" href="{:url('goods/index')}"><i class="ion-md-navicon"></i> 管理商品 </a>
                        <a class="nav-item nav-link" data-nav="storage_index" href="{:url('storage/index')}"><i class="ion-md-stats-bars"></i> 管理库存 </a>
                    </nav>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="card border-info">
                <div class="card-body">
                    <div class="row">
                        <div class="col-4">
                            <i class="ion-md-people ion-5x"></i>
                        </div>
                        <div class="col text-right">
                            <p class="announcement-heading">{$stat.customer}</p>
                            <p class="announcement-text">客户</p>
                        </div>
                    </div>
                </div>
                <div class="card-footer announcement-bottom">
                    <nav class="nav nav-fill">
                        <a class="nav-item nav-link" data-nav="customer_index" href="{:url('customer/index')}"><i class="ion-md-navicon"></i> 管理客户 </a>
                        <a class="nav-item nav-link" data-nav="finance_receive" href="{:url('finance/receive')}"><i class="ion-md-add"></i> 应收款 </a>
                    </nav>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="card border-info">
                <div class="card-body">
                    <div class="row">
                        <div class="col-4">
                            <i class="ion-md-contacts ion-5x"></i>
                        </div>
                        <div class="col text-right">
                            <p class="announcement-heading">{$stat.supplier}</p>
                            <p class="announcement-text">供应商</p>
                        </div>
                    </div>
                </div>
                <div class="card-footer announcement-bottom">
                    <nav class="nav nav-fill">
                        <a class="nav-item nav-link" data-nav="supplier_index" href="{:url('supplier/index')}"><i class="ion-md-navicon"></i> 管理供应商 </a>
                        <a class="nav-item nav-link" data-nav="finance_payable" href="{:url('finance/payable')}"><i class="ion-md-remove"></i> 应付款 </a>
                    </nav>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="card border-info">
                <div class="card-body">
                    <div class="row">
                        <div class="col-4">
                            <i class="ion-md-analytics ion-5x"></i>
                        </div>
                        <div class="col text-right">
                            <p class="announcement-heading">{$stat.sale_order}</p>
                            <p class="announcement-text">销售</p>
                        </div>
                    </div>
                </div>
                <div class="card-footer announcement-bottom">
                    <nav class="nav nav-fill">
                        <a class="nav-item nav-link" data-nav="sale_order_index" href="{:url('saleOrder/index')}"><i class="ion-md-navicon"></i> 管理销售单 </a>
                        <a class="nav-item nav-link" target="_blank" href="{:url('index/printLabel')}"><i class="ion-md-document"></i> 打印标签 </a>
                    </nav>
                </div>
            </div>
        </div>
    </div>

    {php}$empty=list_empty(3);{/php}
    <div class="row">
        <div class="col-md-6 mb-3">
            <div class="card border-default">
                <div class="card-header">
                    <a href="{:url('saleOrder/create')}" data-tab="timestamp" class="float-right">销售开单</a>
                    <h5 class="panel-title"><i class="ion-md-stats"></i> 销售 <span class="text-muted">7日统计</span> </h5>
                </div>
                <table class="table table-striped">
                    <tr>
                        <th>日期</th>
                        <th>销售单数</th>
                        <th>销售金额</th>
                    </tr>
                    {volist name="saleOrders" id="order" empty="$empty"}
                        <tr>
                            <td>{$order.awdate}</td>
                            <td>{$order.order_count}</td>
                            <td>{$order.order_amount}</td>
                        </tr>
                    {/volist}
                </table>
            </div>
        </div>
        <div class="col-md-6 mb-3">
            <div class="card border-default">
                <div class="card-header">
                    <a href="{:url('purchaseOrder/create')}" data-tab="timestamp" class="float-right">采购入库</a>
                    <h5 class="panel-title"><i class="ion-md-cart"></i> 采购 <span class="text-muted">7日统计</span> </h5>
                </div>
                <table class="table table-striped">
                    <tr>
                        <th>日期</th>
                        <th>采购单数</th>
                        <th>采购金额</th>
                    </tr>
                    {volist name="purchaseOrders" id="order" empty="$empty"}
                        <tr>
                            <td>{$order.awdate}</td>
                            <td>{$order.order_count}</td>
                            <td>{$order.order_amount}</td>
                        </tr>
                    {/volist}
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
                    {volist name="storages" id="storage" empty="$empty"}
                        <tr>
                            <td>{$storage.title}</td>
                            <td>{$storage.goods_count}</td>
                            <td>{$storage.goods_total}</td>
                        </tr>
                    {/volist}
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
                        <td> {$finance.sales.total|show_finance|raw} </td>
                        <td> {$finance.sales.in30days|show_finance|raw} </td>
                        <td> {$finance.sales.in90days|show_finance|raw} </td>
                        <td> {$finance.sales.out90days|show_finance|raw} </td>
                    </tr>
                    {if !empty($finance['sales_back']['total'])}
                        <tr>
                            <td>销售退货</td>
                            <td> {$finance.sales_back.total|show_finance|raw} </td>
                            <td> {$finance.sales_back.in30days|show_finance|raw} </td>
                            <td> {$finance.sales_back.in90days|show_finance|raw} </td>
                            <td> {$finance.sales_back.out90days|show_finance|raw} </td>
                        </tr>
                    {/if}
                    <tr>
                        <td>应付账款</td>
                        <td> {$finance.purchases.total|show_finance|raw} </td>
                        <td> {$finance.purchases.in30days|show_finance|raw} </td>
                        <td> {$finance.purchases.in90days|show_finance|raw} </td>
                        <td> {$finance.purchases.out90days|show_finance|raw} </td>
                    </tr>
                    {if !empty($finance['purchases_back']['total'])}
                        <tr>
                            <td>采购退货</td>
                            <td> {$finance.purchases_back.total|show_finance|raw} </td>
                            <td> {$finance.purchases_back.in30days|show_finance|raw} </td>
                            <td> {$finance.purchases_back.in90days|show_finance|raw} </td>
                            <td> {$finance.purchases_back.out90days|show_finance|raw} </td>
                        </tr>
                    {/if}
                </table>
            </div>
        </div>

    </div>

</div>

{/block}