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
                        <a class="nav-item nav-link" href="{:url('finance/customer')}"><i class="ion-md-stats-bars"></i> 财务统计 </a>
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
                        <a class="nav-item nav-link" href="{:url('finance/supplier')}"><i class="ion-md-add"></i> 财务统计 </a>
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


    <div class="row">
        <div class="col-md-6 mb-3">
            <div class="card border-default">
                <div class="card-header">
                    <h5 class="panel-title"><i class="ion-md-stats"></i> 销售</h5>
                </div>
                <table class="table table-striped">
                    <tr>
                        <th width="80">总会员</th>
                        <td>{$mem.total}</td>
                    </tr>
                    <tr>
                        <th width="80">正常会员</th>
                        <td>{$mem.avail}</td>
                    </tr>
                    <tr>
                        <th width="80">总代理数</th>
                        <td>{$mem.agent}</td>
                    </tr>
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
                        <th width="80">会员充值</th>
                        <td>{$money.total_charge|showmoney}</td>
                        <th width="80">后台充值</th>
                        <td>{$money.system_charge|showmoney}</td>
                    </tr>
                    <tr>
                        <th width="80">总奖励</th>
                        <td>{$money.total_award|showmoney}</td>
                        <th width="80">已提现</th>
                        <td>{$money.total_cash|showmoney}</td>
                    </tr>
                    <tr>
                        <th width="80">账户余额</th>
                        <td>{$money.total_money|showmoney}</td>
                        <th width="80">奖励余额</th>
                        <td>{$money.total_credit|showmoney}</td>
                    </tr>
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
                        <th width="80">会员充值</th>
                        <td>{$money.total_charge|showmoney}</td>
                        <th width="80">后台充值</th>
                        <td>{$money.system_charge|showmoney}</td>
                    </tr>
                    <tr>
                        <th width="80">总奖励</th>
                        <td>{$money.total_award|showmoney}</td>
                        <th width="80">已提现</th>
                        <td>{$money.total_cash|showmoney}</td>
                    </tr>
                    <tr>
                        <th width="80">账户余额</th>
                        <td>{$money.total_money|showmoney}</td>
                        <th width="80">奖励余额</th>
                        <td>{$money.total_credit|showmoney}</td>
                    </tr>
                </table>
            </div>
        </div>
        <div class="col-md-6 mb-3">
            <div class="card border-default">
                <div class="card-header">
                    <h5 class="panel-title"><i class="ion-md-cart"></i> 采购</h5>
                </div>
                <table class="table table-striped">
                    <tr>
                        <th width="80">会员充值</th>
                        <td>{$money.total_charge|showmoney}</td>
                        <th width="80">后台充值</th>
                        <td>{$money.system_charge|showmoney}</td>
                    </tr>
                    <tr>
                        <th width="80">总奖励</th>
                        <td>{$money.total_award|showmoney}</td>
                        <th width="80">已提现</th>
                        <td>{$money.total_cash|showmoney}</td>
                    </tr>
                    <tr>
                        <th width="80">账户余额</th>
                        <td>{$money.total_money|showmoney}</td>
                        <th width="80">奖励余额</th>
                        <td>{$money.total_credit|showmoney}</td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

</div>

</block>