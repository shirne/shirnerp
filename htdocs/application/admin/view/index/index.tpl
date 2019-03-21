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
        <div class="col-md-6 mt-3">
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
        <div class="col-md-6 mt-3">
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
        <div class="col-md-6 mt-3">
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
        <div class="col-md-6 mt-3">
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