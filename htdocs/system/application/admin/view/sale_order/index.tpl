<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="sale_order_index" title="销售单列表" />

    <div id="page-wrapper">

        <div class="row list-header">
            <div class="col-6">
                <a href="{:url('saleOrder/create')}" class="btn btn-outline-primary btn-sm"><i class="ion-md-add"></i> 添加销售单</a>
            </div>
            <div class="col-6">
                <form action="{:url('saleOrder/index')}" method="post">
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
                <th>单号</th>
                <th>客户</th>
                <th>日期</th>
                <th>金额</th>
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
                    <td>{$v.customer_title}</td>
                    <td>{$v.create_time|showdate}</td>
                    <td><span class="badge badge-info">{$v.currency}</span> {$v.amount}</td>
                    <td>
                        <if condition="$v['status'] EQ 1">
                            <span class="badge badge-success">已出库</span>
                            <else/>
                            <span class="badge badge-warning">未出库</span>
                        </if>
                    </td>
                    <td class="operations">
                        <if condition="$v['status'] EQ 0">
                            <a class="btn btn-outline-primary link-confirm" title="出库" data-confirm="请确认商品已出库，操作不可撤销!" href="{:url('saleOrder/status',array('id'=>$v['id'],'status'=>1))}" ><i class="ion-md-filing"></i> </a>
                        <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('saleOrder/delete',array('id'=>$v['id']))}" ><i class="ion-md-trash"></i> </a>
                        </if>
                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
        {$page|raw}
    </div>
</block>