<extend name="public:print" />

<block name="body">
    <div class="page-wrapper container ml-auto mr-auto mb-3 d-print-none">
        <div class="row">
            <h2 class="col-md-6">订单打印</h2>
            <div class="col-md-6 text-right ">
                <a href="javascript:" class="btn btn-primary print-btn">打印</a>
            </div>
        </div>
    </div>
    <div id="page-wrapper" class="container m-auto">
        <h3 class="text-center">{:getSetting('site-name')}</h3>
        <h4 class="text-center">{$model['parent_order_id']?'采购退货':'采购入库'}清单({$supplier['title']})</h4>
        <div class="row">
            <div class="col text-left">下单日期：{$model['create_time']|showdate}</div>
            <div class="col text-right"></div>
        </div>
        <table class="table table-bordered">
            <thead>
            <tr>
                <th>品种</th>
                <th>数量</th>
                <th>单位</th>
                <th>重量</th>
                <th>单价</th>
                <th>总价</th>
                <th>出库仓</th>
                <th>备注</th>
            </tr>
            </thead>
            <tbody>
            <volist name="goods" id="good">
                <tr>
                    <td>{$good.goods_title}</td>
                    <td>{$good.count}</td>
                    <td>{$good.goods_unit}</td>
                    <td>{$good.weight}</td>
                    <td>{$good.price}</td>
                    <td>{$good.amount}</td>
                    <td>{$good.storage_title}</td>
                    <td>{$good.remark}</td>
                </tr>
            </volist>
            </tbody>
            <tfoot>
                <if condition="!empty($model['remark'])">
                    <tr>
                        <th>备注</th>
                        <td colspan="7">{$model.remark}</td>
                    </tr>
                </if>
                <tr>
                    <th>运费</th>
                    <td colspan="3">{$model.freight}</td>
                    <th>合计</th>
                    <td colspan="3">[{$model.currency}]&nbsp;{$model.amount}</td>
                </tr>
            </tfoot>
        </table>
        <table class="table mt-2">
            <thead>
            <tr>
                <th scope="col">#</th>
                <th scope="col">操作员</th>
                <th scope="col">操作</th>
                <th scope="col">日期</th>
            </tr>
            </thead>
            <tbody>
            <volist name="logs" id="log">
            <tr>
                <th>{$log.id}</th>
                <td>{$log.username}</td>
                <td>{$log.remark}</td>
                <td>{$log.datetime}</td>
            </tr>
            </volist>
            </tbody>
        </table>
    </div>
</block>
<block name="script">
    <script type="text/javascript">
        jQuery(function ($) {
            window.print();
            $('.print-btn').click(function () {
                window.print();
            })
        })
    </script>
</block>