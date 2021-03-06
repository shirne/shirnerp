{extend name="public:base" /}

{block name="body"}
    {include file="public/bread" menu="sale_order_index" title="订单详情" /}
    <div id="page-wrapper">
        <div class="page-header">销售单详情</div>
        <div class="page-content">
            <table class="table">
            <tbody>
            <tr>
                <td>订单号</td>
                <td>{$model.order_no}{if $model['parent_order_id']}<span class="badge badge-warning">退货</span> {/if}</td>
                <td>客户</td>
                <td>[{$customer.id}]{$customer.title}</td>
            </tr>
            <tr>
                <td>下单日期</td>
                <td>{$model.create_time|showdate}</td>
                <td>订单状态</td>
                <td>{$model.status|sale_order_status|raw}</td>
            </tr>
            </tbody>
        </table>
        <table class="table table-bordered">
            <thead>
            <tr>
                <th>品名</th>
                <th>数量</th>
                <th>单位</th>
                <th>重量</th>
                <th>单价</th>
                <th>总价</th>
                <th>仓库</th>
                <th>备注</th>
            </tr>
            </thead>
            <tbody>
                {volist name="goods" id="p"}
                    <tr>
                        <td><span class="badge badge-success">{$p.goods_no}</span> {$p.goods_title}</td>
                        <td>{$p.count}</td>
                        <td>{$p.goods_unit}</td>
                        <td>{$p.weight}</td>
                        <td>{$p.price}/{$p['price_type']?getSetting('weight_unit'):$p['goods_unit']}</td>
                        <td>{$p.amount}{if $p['diy_price']}<span class="badge badge-secondary">已改价</span>{/if}
                        </td>
                        <td>{$p.storage_title}</td>
                        <td>{$p.remark}</td>
                    </tr>
                {/volist}
            </tbody>
        </table>

        <table class="table">
            <tbody>
            <tr>
                <th>运费</th>
                <td colspan="3">{$model.freight}</td>
            </tr>
            {if $model['remark']}
                <tr>
                    <th>订单备注</th>
                    <td colspan="3">
                        {$model.remark}
                    </td>
                </tr>
            {/if}
            <tr>
                <th >订单金额</th>
                <td>
                    <span class="badge badge-info">{$model.currency}</span> {$model.amount}
                    {if $model['diy_price']}<span class="badge badge-secondary">已改价</span>{/if}
                </td>
                <th>已付款</th>
                <td>
                    <span class="badge badge-info">{$model.currency}</span> {$model.payed_amount}
                </td>
            </tr>
            </tbody>
        </table>

        <table class="table table-bordered mt-3">
            <thead>
            <tr>
                <th colspan="4">收款记录</th>
            </tr>
            </thead>
            <tbody>
            {volist name="paylog" id="pl"}
                <tr>
                    <td><span class="badge badge-info">{$pl.currency}</span> {$pl.amount}</td>
                    <td>{$pl.pay_type|finance_type|raw}</td>
                    <td>{$pl.create_time|showdate}</td>
                    <td>{$pl.remark}</td>
                </tr>
            {/volist}
            </tbody>
        </table>
    </div>
</div>
{/block}
{block name="script"}
    <script type="text/javascript">
        window.page_title="销售单[{$customer.title}]"
    </script>
{/block}