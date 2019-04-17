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
                <th>货币</th>
                <th>应收</th>
                <th>已收</th>
                <th>未收</th>
                <th>账期</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <php>$empty=list_empty(8);</php>
            <volist name="lists" id="v" empty="$empty">
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.customer_title}</td>
                    <td>{$v.currency}</td>
                    <td>{$v.amount}</td>
                    <td>{$v.payed_amount}</td>
                    <td>{$v['amount'] - $v['payed_amount']}</td>
                    <td>{$v.create_time|showdate}</td>
                    <td class="operations">
                        <a href="javascript:" title="入账" data-id="{$v.id}" data-amount="{$v['amount'] - $v['payed_amount']}" class="btn btn-outline-primary finance-btn"><i class="ion-md-list-box"></i> </a>
                        <a class="btn btn-outline-primary" rel="ajax" title="明细" href="{:url('SaleOrder/detail',array('id'=>$v['id']))}"><i class="ion-md-document"></i> </a>
                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
    </div>

</block>
<block name="script">
    <script type="text/html" id="financeLog">
        <div class="row" style="margin:0 10%;">
            <div class="col-12 form-group">
                <div class="input-group">
                    <div class="input-group-prepend"><span class="input-group-text">方式</span> </div>
                    <select name="pay_type" class="form-control">
                        <foreach name="paytypes" key="key" id="ptype">
                            <option value="{$key}">{$ptype}</option>
                        </foreach>
                    </select>
                </div>
            </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">金额</span> </div><input type="text" name="amount" class="form-control" placeholder="请填写入账金额"/> </div></div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">备注</span> </div><input type="text" name="reson" class="form-control" /> </div> </div>
        </div>
    </script>
    <script type="text/javascript">
        jQuery(function ($) {
            var tpl=$('#financeLog').text();
            $('.finance-btn').click(function() {
                var id=$(this).data('id');
                var release=$(this).data('amount');
                var dlg=new Dialog({
                    onshown:function(body){
                        if(release)body.find('[name=amount]').val(release);
                        else body.find('[name=amount]').val('');
                    },
                    onsure:function(body){
                        var amountField=body.find('[name=amount]');
                        var amount=amountField.val();
                        if(!amount){
                            dialog.warning('请填写金额');
                            amountField.focus();
                            return false;
                        }
                        if(amount!=parseFloat(amount)){
                            dialog.warning('请填写两位尾数以内的金额');
                            amountField.focus();
                            return false;
                        }
                        if(amount>release){

                        }
                        var pay_type = body.find('[name=pay_type]').val();
                        $.ajax({
                            url:'{:url("receiveLog")}',
                            type:'POST',
                            data:{
                                id:id,
                                amount:amount,
                                pay_type:pay_type,
                                reson:body.find('input[name=reson]').val()
                            },
                            dataType:'JSON',
                            success:function(j){
                                if(j.code==1) {
                                    dlg.hide();
                                    dialog.alert(j.msg,function() {
                                        location.reload();
                                    })
                                }else{
                                    dialog.warning(j.msg);
                                }
                            }
                        })
                    }
                }).show(tpl,'收款入账');
            });
        })
    </script>
</block>