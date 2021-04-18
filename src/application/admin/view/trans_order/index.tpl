<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="trans_order_index" title="商品调度" />

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">
                <a href="{:url('transOrder/create')}" data-tab="timestamp" class="btn btn-outline-primary btn-sm"><i class="ion-md-add"></i> 商品转库</a>
            </div>
            <div class="col-6">
                <form action="{:url('transOrder/index')}" method="post">
                    <div class="input-group input-group-sm">
                        <input type="text" class="form-control" name="key" placeholder="输入单号或仓库名称搜索">
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
                <th>出库仓</th>
                <th>入库仓</th>
                <th>日期</th>
                <th>状态</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <php>$empty=list_empty(7);</php>
            <volist name="lists" id="v" empty="$empty">
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.order_no}</td>
                    <td>{$v.from_storage_title}</td>
                    <td>{$v.storage_title}</td>
                    <td>{$v.create_time|showdate}</td>
                    <td>
                        <if condition="$v['status'] EQ 1">
                            <span class="badge badge-success">已转库</span>
                            <else/>
                            <span class="badge badge-warning">未转库</span>
                        </if>
                    </td>
                    <td class="operations">
                        <if condition="$v['status'] EQ 0">
                            <a class="btn btn-outline-primary link-confirm" title="转库" data-confirm="请确认商品已转库，操作不可撤销!" href="{:url('transOrder/status',array('id'=>$v['id'],'status'=>1))}" ><i class="ion-md-swap"></i> </a>
                            <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('transOrder/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                            <else/>
                            <a class="btn btn-outline-primary link-detail" title="详情" href="{:url('transOrder/detail',array('id'=>$v['id']))}" ><i class="ion-md-document"></i> </a>
                        </if>
                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
        <div class="clearfix"></div>
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
                }).show('<p class="loading">'+lang('loading...')+'</p>','调度详情');
            })
        })
    </script>
</block>