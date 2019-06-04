<extend name="public:print" />

<block name="body">
    <div class="page-wrapper container ml-auto mr-auto mb-3 d-print-none">
        <div class="row">
            <h2 class="col-md-3">订单打印</h2>
            <div class="col text-right ">
                <label><input type="checkbox" name="showlog"/> 打印操作日志</label>
                <label><input type="checkbox" name="showstorage"/> 显示出库仓</label>
                <a href="javascript:" class="btn btn-primary print-btn">打印</a>
            </div>
        </div>
    </div>
    <div id="page-wrapper" class="container m-auto">
        <h3 class="text-center mt-3 mb-3">{:getSetting('site-name')}</h3>
        <h4 class="text-center mb-3">{$model['parent_order_id']?'采购退货':'采购入库'}清单({$supplier['title']})</h4>
        <div class="row mb-2">
            <div class="col text-left">下单日期：{$model['create_time']|showdate}</div>
            <div class="col text-right"></div>
        </div>
        <table class="table table-bordered">
            <thead>
            <tr>
                <th>品种</th>
                <th>数量</th>
                <th>单位</th>
                <th>重量</th>
                <th>单价</th>
                <th>总价</th>
                <th class="storage-col d-none">出库仓</th>
                <th>备注</th>
            </tr>
            </thead>
            <tbody>
            <volist name="goods" id="good">
                <tr>
                    <td>{$good.goods_title}</td>
                    <td>{$good.count}</td>
                    <td>{$good.goods_unit}</td>
                    <td>{$good.weight}</td>
                    <td>{$good.price}/{$good['price_type']?getSetting('weight_unit'):$good['goods_unit']}</td>
                    <td>{$good.amount}</td>
                    <td class="storage-col d-none">{$good.storage_title}</td>
                    <td>{$good.remark}</td>
                </tr>
            </volist>
            </tbody>
            <tfoot>
                <if condition="!empty($model['remark'])">
                    <tr>
                        <th>备注</th>
                        <td colspan="7">{$model.remark}</td>
                    </tr>
                </if>
                <tr>
                    <th>运费</th>
                    <td colspan="3">{$model.freight}</td>
                    <th>合计</th>
                    <td colspan="3">[{$model.currency}]&nbsp;{$model.amount}</td>
                </tr>
            </tfoot>
        </table>
        <table class="table mt-2 log-table d-none">
            <thead>
            <tr>
                <th scope="col">#</th>
                <th scope="col">操作员</th>
                <th scope="col">操作</th>
                <th scope="col">日期</th>
            </tr>
            </thead>
            <tbody>
            <volist name="logs" id="log">
            <tr>
                <th>{$log.id}</th>
                <td>{$log.username}</td>
                <td>{$log.remark}</td>
                <td>{$log.datetime}</td>
            </tr>
            </volist>
            </tbody>
        </table>
    </div>
</block>
<block name="script">
    <script type="text/javascript">
        jQuery(function ($) {
            //window.print();
            $('.print-btn').click(function () {
                window.print();
            });

            $('[name=showlog]').change(function () {
                if(this.checked){
                    $('.log-table').removeClass('d-none');
                }else{
                    $('.log-table').addClass('d-none');
                }
            });

            $('[name=showstorage]').change(function () {
                if(this.checked){
                    $('.storage-col').removeClass('d-none');
                }else{
                    $('.storage-col').addClass('d-none');
                }
            });
        })
    </script>
</block>