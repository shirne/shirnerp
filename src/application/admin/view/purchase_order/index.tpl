<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="purchase_order_index" title="采购单列表" />

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">
                <a href="{:url('purchaseOrder/create')}" data-tab="timestamp" class="btn btn-outline-primary btn-sm"><i class="ion-md-add"></i> 添加采购单</a>
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
                <th>仓库</th>
                <th>供应商</th>
                <th>品类</th>
                <th>日期</th>
                <th>金额</th>
                <th>状态</th>
                <th width="200">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <php>$empty=list_empty(9);</php>
            <volist name="lists" id="v" empty="$empty">
                <tr>
                    <td>{$v.id}</td>
                    <td>{$v.order_no}<if condition="$v['parent_order_id']"><span class="badge badge-warning">退货</span> </if></td>
                    <td>{$v.storage_title}</td>
                    <td>{$v.supplier_title}</td>
                    <td>{:count($v['goods'])}类</td>
                    <td>{$v.create_time|showdate}</td>
                    <td><span class="badge badge-info">{$v.currency}</span> {$v.amount}</td>
                    <td>
                        <if condition="$v['parent_order_id']">
                            <if condition="$v['status'] EQ 1">
                                <span class="badge badge-success">已出库</span>
                                <else/>
                                <span class="badge badge-warning">未出库</span>
                            </if>
                            <else/>
                        <if condition="$v['status'] EQ 1">
                            <span class="badge badge-success">已入库</span>
                            <else/>
                            <span class="badge badge-warning">未入库</span>
                        </if>
                        </if>
                    </td>
                    <td class="operations">
                        <a class="btn btn-outline-primary" target="_blank" title="导出" href="{:url('purchaseOrder/exportOne',array('id'=>$v['id']))}" ><i class="ion-md-download"></i> </a>
                        <a class="btn btn-outline-primary" target="_blank" title="打印" href="{:url('purchaseOrder/detail',array('id'=>$v['id'],'mode'=>1))}" ><i class="ion-md-print"></i> </a>
                        <a class="btn btn-outline-primary link-log" title="操作记录" href="{:url('purchaseOrder/log',array('id'=>$v['id']))}" ><i class="ion-md-list"></i> </a>
                        <if condition="$v['status'] EQ 0">
                            <if condition="$v['parent_order_id']">
                                <a class="btn btn-outline-success link-confirm" title="出库" data-confirm="请确认商品已出库，操作不可撤销!" href="{:url('purchaseOrder/status',array('id'=>$v['id'],'status'=>1))}" ><i class="ion-md-filing"></i> </a>
                                <else/>
                            <a class="btn btn-outline-success link-confirm" title="入库" data-confirm="请确认商品已入库，操作不可撤销!" href="{:url('purchaseOrder/status',array('id'=>$v['id'],'status'=>1))}" ><i class="ion-md-filing"></i> </a>
                            </if>
                            <a class="btn btn-outline-primary" data-tab="edit-{$v.id}" title="编辑" href="{:url('purchaseOrder/detail',array('id'=>$v['id'],'mode'=>2))}" ><i class="ion-md-create"></i> </a>
                            <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('purchaseOrder/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                            <else/>
                            <if condition="$v['parent_order_id'] EQ 0">
                            <a class="btn btn-outline-warning" data-tab="timestamp" title="退货" href="{:url('purchaseOrder/back',array('id'=>$v['id']))}" ><i class="ion-md-undo"></i> </a>
                            </if>
                            <a class="btn btn-outline-primary" data-tab="detail-{$v.id}" title="详情" href="{:url('purchaseOrder/detail',array('id'=>$v['id']))}" ><i class="ion-md-document"></i> </a>
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
            var linkTpl='<tr>\n' +
                '      <th scope="row">{@id}</th>\n' +
                '      <td>{@username}</td>\n' +
                '      <td>{@remark}</td>\n' +
                '      <td>{@datetime}</td>\n' +
                '    </tr>';
            var tplBox = '<table class="table">\n' +
                '  <thead>\n' +
                '    <tr>\n' +
                '      <th scope="col">#</th>\n' +
                '      <th scope="col">操作员</th>\n' +
                '      <th scope="col">操作</th>\n' +
                '      <th scope="col">日期</th>\n' +
                '    </tr>\n' +
                '  </thead>\n' +
                '  <tbody>\n' +
                '    {@list}\n' +
                '  </tbody>\n' +
                '</table>';
            $('.link-log').click(function (e) {
                e.preventDefault();
                var self=$(this);
                var dlg = new Dialog({
                    btns: ['确定'],
                    onshow: function (body) {
                        $.ajax({
                            url: self.attr('href'),
                            success: function (json) {
                                body.html(tplBox.compile({
                                    list:linkTpl.compile(json.data,true)
                                }));
                            }
                        });
                    }
                }).show('<p class="loading">'+lang('loading...')+'</p>','订单操作记录');
            });
        })
    </script>
</block>