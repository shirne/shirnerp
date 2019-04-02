<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="purchase_order_index" title="销售单列表" />

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">
                <a href="{:url('purchaseOrder/create')}" class="btn btn-outline-primary btn-sm"><i class="ion-md-add"></i> 添加入库单</a>
            </div>
            <div class="col-6">
                <form action="{:url('purchaseOrder/index')}" method="post">
                    <div class="input-group input-group-sm">
                        <input type="text" class="form-control" name="key" placeholder="输入单号或供应商名称搜索">
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary" type="submit"><i class="ion-md-search"></i></button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <table class="table table-hover table-striped">
            <thead>
            <tr>
                <th width="50">编号</th>
                <th>单号</th>
                <th>供应商</th>
                <th>日期</th>
                <th>金额</th>
                <th>状态</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <php>$empty=list_empty(8);</php>
            <volist name="lists" id="v" empty="$empty">
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.order_no}</td>
                    <td>{$v.supplier_title}</td>
                    <td>{$v.create_time|showdate}</td>
                    <td>{$v.amount}</td>
                    <td>
                        <if condition="$v['status'] EQ 1">
                            <span class="badge badge-success">已入库</span>
                            <else/>
                            <span class="badge badge-warning">未入库</span>
                        </if>
                    </td>
                    <td class="operations">

                        <if condition="$v['status'] EQ 0">
                            <a class="btn btn-outline-primary link-confirm" title="入库" data-confirm="请确认商品已入库，操作不可撤销!" href="{:url('purchaseOrder/status',array('id'=>$v['id'],'status'=>1))}" ><i class="ion-md-filing"></i> </a>
                            <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('purchaseOrder/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                            <else/>
                            <a class="btn btn-outline-primary link-detail" data-id="{$v.id}" title="详情" href="{:url('purchaseOrder/detail',array('id'=>$v['id']))}" ><i class="ion-md-document"></i> </a>
                        </if>
                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
        {$page|raw}
    </div>
</block>
<block name="script">
    <script type="text/javascript">
        jQuery(function ($) {
            $('.link-detail').click(function (e) {
                e.preventDefault();
                var self=$(this);
                var dlg = new Dialog({
                    btns: ['确定'],
                    onshow: function (body) {
                        $.ajax({
                            url: self.attr('href'),
                            beforeSend: function(request) {
                                request.setRequestHeader("X-Requested-With","htmlhttp");
                            },
                            success: function (text) {
                                body.html(text);
                            }
                        });
                    }
                }).show('<p class="loading">'+lang('loading...')+'</p>','订单详情');
            })
        })
    </script>
</block>