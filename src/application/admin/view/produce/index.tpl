<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="produce_index" title="生产流程" />

    <div id="page-wrapper">
        <div class="row list-header">
            <div class="col-6">
                <div class="btn-toolbar list-toolbar" role="toolbar" aria-label="Toolbar with button groups">
                    <div class="btn-group btn-group-sm mr-2" role="group" aria-label="check action group">
                        <a href="javascript:" class="btn btn-outline-secondary checkall-btn" data-toggle="button" aria-pressed="false">全选</a>
                        <a href="javascript:" class="btn btn-outline-secondary checkreverse-btn">反选</a>
                    </div>
                    <div class="btn-group btn-group-sm mr-2" role="group" aria-label="action button group">
                        <a href="javascript:" class="btn btn-outline-secondary action-btn" data-action="export">导出</a>
                    </div>
                    <a href="{:url('produce/create')}" data-tab="timestamp" class="btn btn-outline-primary btn-sm"><i class="ion-md-add"></i> 添加生产流程</a>
                </div>
            </div>
            <div class="col-6">
                <form action="{:url('produce/index')}" method="post">
                    <div class="input-group input-group-sm">
                        <input type="text" class="form-control" name="key" placeholder="输入单号或客户名称搜索">
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
                <th>名称</th>
                <th>成品</th>
                <th>物料</th>
                <th>日期</th>
                <th>备注</th>
                <th width="200">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <php>$empty=list_empty(7);</php>
            <volist name="lists" id="v" empty="$empty">
                <tr>
                    <td><input type="checkbox" name="id" value="{$v.id}" /></td>
                    <td>{$v.title}</td>
                    <td>{$v.goods_title}</td>
                    <td>{:count($v['goods'])}类<if condition="$v['package_count'] GT 0">, {$v['package_count']}件 </if></td>
                    <td>{$v.create_time|showdate}</td>
                    <td>{$v.remark}</td>
                    <td class="operations">
                        <a class="btn btn-outline-primary" target="_blank" title="导出" href="{:url('produce/exportOne',array('id'=>$v['id']))}" ><i class="ion-md-download"></i> </a>
                        <a class="btn btn-outline-primary" target="_blank" title="打印" href="{:url('produce/detail',array('id'=>$v['id'],'mode'=>1))}" ><i class="ion-md-print"></i> </a>
                        <a class="btn btn-outline-primary link-log" title="操作记录" href="{:url('produce/log',array('id'=>$v['id']))}" ><i class="ion-md-list"></i> </a>
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
        (function(w,$){
            w.actionPrints=function(ids){
                var url="{:url('produce/prints',['order_ids'=>'__ORDER_IDS__','storage_ids'=>'__STORAGE_IDS__'])}".replace('__ORDER_IDS__',ids).replace('__STORAGE_IDS__','');
                window.open(url);
            };
        })(window,jQuery);
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
        });
    </script>
</block>