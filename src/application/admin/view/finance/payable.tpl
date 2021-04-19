{extend name="public:base" /}

{block name="body"}

    {include file="public/bread" menu="finance_payable" title="应付款" /}

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">
                <h4>应付款</h4>
            </div>
            <div class="col-4">
                <form action="{:url('finance/payable')}" method="post">
                    <div class="input-group input-group-sm">
                        <input type="text" class="form-control" name="key" placeholder="输入邮箱或者关键词搜索">
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary" type="submit"><i class="ion-md-search"></i></button>
                        </div>
                    </div>
                </form>
            </div>
            <div class="col-2">
                <a href="{:url('payableFix')}" class="btn btn-sm btn-outline-secondary">修复状态</a>
            </div>
        </div>
        <table class="table table-hover table-striped">
            <thead>
            <tr>
                <th width="50">编号</th>
                <th>单号</th>
                <th>供应商</th>
                <th>货币</th>
                <th>应付</th>
                <th>已付</th>
                <th>未付</th>
                <th>账期</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            {php}$empty=list_empty(9);{/php}
            {volist name="lists" id="v" empty="$empty"}
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.order_no}{if !empty($v['parent_order_id'])}<span class="badge badge-warning">退货</span> {/if}</td>
                    <td>{$v.supplier_title}</td>
                    <td>{$v.currency}</td>
                    <td>{$v.amount}</td>
                    <td>{$v.payed_amount}</td>
                    <td>{$v['amount'] - $v['payed_amount']}</td>
                    <td>{$v.create_time|showdate}</td>
                    <td class="operations">
                        <a href="javascript:" title="入账" data-id="{$v.id}" data-amount="{$v['amount'] - $v['payed_amount']}" data-currency="{$v.currency}" data-isback="{$v['parent_order_id']}" class="btn btn-outline-primary finance-btn"><i class="ion-md-list-box"></i> </a>
                        <a class="btn btn-outline-primary" rel="ajax" title="明细" href="{:url('PurchaseOrder/detail',array('id'=>$v['id']))}"><i class="ion-md-document"></i> </a>
                    </td>
                </tr>
            {/volist}
            </tbody>
        </table>

    </div>

{/block}
{block name="script"}
    <script type="text/html" id="financeLog">
        <div class="row" style="margin:0 10%;">
            <div class="col-12 form-group">
                <div class="input-group">
                    <div class="input-group-prepend"><span class="input-group-text">方式</span> </div>
                    <select name="pay_type" class="form-control">
                        {foreach $paytypes as $key=>$ptype}
                            <option value="{$key}">{$ptype}</option>
                        {/foreach}
                    </select>
                </div>
            </div>
            <div class="col-12 form-group">
                <div class="input-group">
                    <div class="input-group-prepend"><span class="input-group-text">金额</span> </div>
                    <input type="text" name="amount" class="form-control" placeholder="请填写付款金额"/>
                    <div class="input-group-append"><span class="input-group-text">{@currency}</span> </div>
                </div>
            </div>
            <div class="col-12 form-group"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">备注</span> </div><input type="text" name="reson" class="form-control" /> </div> </div>
        </div>
    </script>
    <script type="text/javascript">
        jQuery(function ($) {
            var tpl=$('#financeLog').text();
            $('.finance-btn').click(function() {
                var id=$(this).data('id');
                var release=$(this).data('amount');
                var currency=$(this).data('currency');
                var isback = $(this).data('isback')=='0';
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
                        var pay_type_text = body.find('[name=pay_type]')[0].selectedOptions[0].innerText;
                        var reson = body.find('[name=reson]').val();

                        dialog.confirm('<div>请仔细核对您填写的数据</div><br /><div>' + [
                            '<b>付款方式</b>: ' + pay_type_text,
                            '<b>金额('+currency+')</b>: ' + amount + ' ('+(amount>=release? '已结清':('剩余:'+(Math.abs(release) - Math.abs(amount))))+')',
                            '<b>备注</b>: <span class="text-muted" >' + reson + '</span>'
                        ].join('</div><div>') + '</div>',function () {
                            $.ajax({
                                url:'{:url("payableLog")}',
                                type:'POST',
                                data:{
                                    id:id,
                                    amount:amount,
                                    pay_type:pay_type,
                                    reson:reson
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
                        },3);
                        return false;
                    }
                }).show(tpl.compile({
                    'currency' : currency
                }),isback?'退货收款':'付款入账');
            });
        })
    </script>
{/block}