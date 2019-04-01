<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="finance_receive" title="应收款" />

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">

            </div>
            <div class="col-6">
                <form action="{:url('finance/receive')}" method="post">
                    <div class="input-group input-group-sm">
                        <input type="text" class="form-control" name="key" placeholder="输入邮箱或者关键词搜索">
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary" type="submit"><i class="ion-md-search"></i></button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <table class="table table-hover table-striped">
            <thead>
            <tr>
                <th width="50">编号</th>
                <th>客户</th>
                <th>应收</th>
                <th>已收</th>
                <th>未收</th>
                <th>账期</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <php>$empty=list_empty(7);</php>
            <volist name="lists" id="v" empty="$empty">
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.customer_title}</td>
                    <td>{$v.amount}</td>
                    <td>{$v.payed_amount}</td>
                    <td>{$v['amount'] - $v['payed_amount']}</td>
                    <td>{$v.create_time|showdate}</td>
                    <td class="operations">
                        <a href="javascript:" title="入账" class="btn btn-outline-primary finance-btn"><i class="ion-md-list-box"></i> </a>
                        <a class="btn btn-outline-primary" title="明细" href="{:url('finance/receiveDetail',array('id'=>$v['id']))}"><i class="ion-md-document"></i> </a>
                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
    </div>

</block>
<block name="script">
    <script type="text/javascript">
        jQuery(function ($) {
            
        })
    </script>
</block>