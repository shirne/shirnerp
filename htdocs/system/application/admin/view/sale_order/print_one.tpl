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
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th rowspan="7">{:getSetting('site-name')}</th>
                </tr>
                <tr>
                    <th rowspan="7">出货清单({$customer['title']})</th>
                </tr>
                <tr><th rowspan="4">下单日期：{$model['create_time']|showdate}</th><th></th></tr>
                <tr>
                    <th>品种</th>
                    <th>件数</th>
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
                        <td></td>
                        <td>{$good.price}</td>
                        <td>{$good.amount}</td>
                        <td>{$good.storage_title}</td>
                        <td>&nbsp;</td>
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