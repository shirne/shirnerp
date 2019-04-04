<extend name="public:print" />

<block name="body">
    <div id="page-wrapper">

        <div class="row list-header d-print-none">
            <div class="col-md-6">标签打印
            </div>
            <div class="col-md-6 text-right ">
                <a href="javascript:" class="btn btn-primary print-btn">打印</a>
            </div>
        </div>
        <volist name="orders" id="order">
            <volist name="goods" id="good">
                <div class="print-page">

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