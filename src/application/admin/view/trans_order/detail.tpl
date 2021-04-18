<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">调度信息</h3>
    </div>
    <div class="panel-body">
        <table class="table">
            <tbody>
            <tr>
                <td>订单号</td>
                <td>{$model.order_no}</td>
                <td>仓库</td>
                <td>[{$from_storage.storage_no}]{$from_storage.title} -> [{$storage.storage_no}]{$storage.title}</td>
            </tr>
            <tr>
                <td>调度日期</td>
                <td>{$model.create_time|showdate}</td>
                <td>调度状态</td>
                <td>{$model.status|order_status|raw}</td>
            </tr>
            <tr>
                <th colspan="4">转库商品</th>
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
                    <th colspan="4">备注</th>
                </tr>
                <tr>
                    <td>
                        {$model.remark}
                    </td>
                </tr>
            </if>
            </tbody>
        </table>
    </div>
</div>