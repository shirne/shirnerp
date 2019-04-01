<extend name="public:print" />

<block name="body">
    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-md-6">仓库：{$storage.title}
            </div>
            <div class="col-md-6 text-right ">
                <a href="javascript:" class="btn btn-primary print-btn d-print-none">打印</a>
            </div>
        </div>
        <table class="table table-bordered">
            <thead>
            <tr>
                <th width="50">#</th>
                <td>编码</td>
                <th>品名</th>
                <th>库存</th>
                <th>单位</th>
                <th>盘点</th>
                <th>备注</th>
            </tr>
            </thead>
            <tbody>
            <empty name="goods">{:list_empty(7)}</empty>
            <volist name="goods" id="v" >
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.goods_no}</td>
                    <td>{$v.title}</td>
                    <td>{$v.count}</td>
                    <td>{$v.unit}</td>
                    <td>&nbsp;</td>
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