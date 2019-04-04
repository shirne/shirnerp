<extend name="public:print" />

<block name="body">
    <div class="page-wrapper container ml-auto mr-auto mb-3 d-print-none">
        <div class="row">
            <h2 class="col-md-6">标签打印</h2>
            <div class="col-md-6 text-right ">
                <a href="javascript:" class="btn btn-primary print-btn">打印</a>
            </div>
        </div>
    </div>
    <div id="page-wrapper" class="container m-auto">
        <volist name="orders" id="order">
            <volist name="orderGoods[$order['id']]" id="good">
                <div class="print-page align-items-center">
                    <div class="row">
                        <h1 class="col-4 text-right bigger">客户：</h1>
                        <h1 class="col text-left bigger">{$order.customer_title}</h1>
                    </div>
                    <div class="row">
                        <h1 class="col-4 text-right bigger">品名：</h1>
                        <h1 class="col text-left bigger">{$good.goods_title}</h1>
                    </div>
                    <div class="row">
                        <h1 class="col-4 text-right bigger">数量：</h1>
                        <h1 class="col text-left bigger">{$good.count} {$good.goods_unit}</h1>
                    </div>
                </div>
            </volist>
        </volist>
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