<div class="panel panel-default">
    <div class="panel-body">
        <table class="table">
            <tbody>
            <tr>
                <td>订单号</td>
                <td>{$model.order_no}</td>
                <td>供应商</td>
                <td>[{$supplier.id}]{$supplier.title}</td>
            </tr>
            <tr>
                <td>下单日期</td>
                <td>{$model.create_time|showdate}</td>
                <td>订单状态</td>
                <td>{$model.status|purchase_order_status|raw}</td>
            </tr>
            </tbody>
        </table>
        <table class="table table-bordered">
            <thead>
            <tr>
                <th>品名</th>
                <th>数量</th>
                <th>单位</th>
                <th>单价</th>
                <th>总价</th>
                <th>仓库</th>
            </tr>
            </thead>
            <tbody>
                <volist name="goods" id="p">
                    <tr>
                        <td><span class="badge badge-success">{$p.goods_no}</span> {$p.goods_title}</td>
                        <td>{$p.count}</td>
                        <td>{$p.unit}</td>
                        <td>{$p.price}</td>
                        <td>{$p.total_price}</td>
                        <td>{$p.storage_title}</td>
                    </tr>
                </volist>
            </tbody>
        </table>
        <table class="table">
            <tbody>
            <if condition="$model['remark']">
                <tr>
                    <th >订单备注</th>
                </tr>
                <tr>
                    <td colspan="3">
                        {$model.remark}
                    </td>
                </tr>
            </if>
            <tr>
                <th >订单金额</th>
                <td>
                    <span class="badge badge-info">{$model.currency}</span> {$model.amount}
                </td>
                <th>已付款</th>
                <td colspan="3">
                    <span class="badge badge-info">{$model.currency}</span> {$model.payed_amount}
                </td>
            </tr>
            </tbody>
        </table>
    </div>
    <div class="panel-body">
        <table class="table table-bordered">
            <thead>
            <tr>
                <th colspan="4">付款记录</th>
            </tr>
            </thead>
            <tbody>
            <volist name="paylog" id="pl">
                <tr>
                    <td><span class="badge badge-info">{$pl.currency}</span> {$pl.amount}</td>
                    <td>{$pl.pay_type|finance_type|raw}</td>
                    <td>{$pl.create_time|showdate}</td>
                    <td>{$pl.remark}</td>
                </tr>
            </volist>
            </tbody>
        </table>
    </div>
</div>