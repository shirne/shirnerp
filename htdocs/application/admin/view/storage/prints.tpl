<extend name="public:print" />

<block name="body">
    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-md-6">仓库：{$storage.title}
            </div>
            <div class="col-md-6 text-right ">
                <a href="javascript:" class="btn btn-primary d-print-none">打印</a>
            </div>
        </div>
        <table class="table table-bordered">
            <thead>
            <tr>
                <th width="50">#</th>
                <th>品名</th>
                <th>库存</th>
                <th>单位</th>
                <th>盘点</th>
                <th>备注</th>
            </tr>
            </thead>
            <tbody>
            <empty name="lists">{:list_empty(7)}</empty>
            <volist name="lists" id="v" >
                <tr>
                    <td>{$v.id}</td>
                    <td><span class="badge badge-info">{$v.goods_no}</span> {$v.title}</td>
                    <td>&nbsp;</td>
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
        })
    </script>
</block>