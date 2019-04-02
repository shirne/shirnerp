<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">订单信息</h3>
    </div>
    <div class="panel-body">
        <table class="table">
            <tbody>
            <tr>
                <td>订单号</td>
                <td>{$model.order_no}</td>
                <td>客户</td>
                <td>[{$customer.id}]{$customer.title}</td>
            </tr>
            <tr>
                <td>下单日期</td>
                <td>{$model.create_time|showdate}</td>
                <td>订单状态</td>
                <td>{$model.status|order_status|raw}</td>
            </tr>
            <tr>
                <th colspan="4">订单商品</th>
            </tr>
            <tr>
                <td colspan="4">
                    <table class="table">
                        <tbody>
                        <volist name="goods" id="p">
                            <tr>
                                <td><span class="badge badge-success">{$p.goods_no}</span> {$p.goods_title}</td>
                                <td>{$p.count}</td>
                                <td>{$p.unit}</td>
                                <td>{$p.price}</td>
                                <td>{$p.total_price}</td>
                            </tr>
                        </volist>
                        </tbody>
                    </table>
                </td>
            </tr>
            <if condition="$model['remark']">
                <tr>
                    <th colspan="4">订单备注</th>
                </tr>
                <tr>
                    <td>
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
</div>
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">付款信息</h3>
    </div>
    <div class="panel-body">
        <table class="table">
            <tbody>
            <volist name="paylog" id="pl">
                <tr>
                    <td><span class="badge badge-info">{$pl.currency}</span> {$pl.amount}</td>
                    <td>{$pl.pay_type}</td>
                    <td>{$pl.create_time|showdate}</td>
                    <td>{$pl.remark}</td>
                </tr>
            </volist>
            </tbody>
        </table>
    </div>
</div>