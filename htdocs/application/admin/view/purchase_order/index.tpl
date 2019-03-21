<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="purchase_order_index" title="销售单列表" />

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">
                <a href="{:url('purchaseOrder/add')}" class="btn btn-outline-primary btn-sm"><i class="ion-md-add"></i> 添加入库单</a>
            </div>
            <div class="col-6">
                <form action="{:url('purchaseOrder/index')}" method="post">
                    <div class="input-group input-group-sm">
                        <input type="text" class="form-control" name="key" placeholder="输入链接标题或者地址关键词搜索">
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
                <th>地址</th>
                <th>排序</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <volist name="lists" id="v" empty="$empty">
                <tr>
                    <td>{$v.id}</td>
                    <td>
                        <if condition="!empty($v['logo'])">
                            <figure class="figure img-view" data-img="{$v.logo}" >
                                <img src="{$v.logo}?w=100" class="figure-img img-fluid rounded" alt="image">
                            </figure>
                            <else/>
                            -
                        </if>
                    </td>
                    <td>{$v.title}</td>
                    <td><a href="{$v.url}" target="_blank">{$v.url}</a> </td>
                    <td>{$v.sort}</td>
                    <td class="operations">
                        <a class="btn btn-outline-primary" title="编辑" href="{:url('purchaseOrder/edit',array('id'=>$v['id']))}"><i class="ion-md-create"></i> </a>
                        <a class="btn btn-outline-danger link-confirm" title="删除" data-configm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('purchaseOrder/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
        {$page|raw}
    </div>
</block>