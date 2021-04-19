{extend name="public:base" /}
{block name="header"}
    <style type="text/css">
        html{overflow-y:scroll;}
    </style>
{/block}
{block name="body"}

    {include file="public/bread" menu="supplier_index" title="供应商排行" /}

    <div id="page-wrapper">
        <div class="list-header">
            <form class="noajax" action="{:url('supplier/rank')}" method="post">
                <div class="form-row">
                    <div class="form-group col input-group input-group-sm date-range">
                        <div class="input-group-prepend">
                            <span class="input-group-text">统计时间</span>
                        </div>
                        <input type="text" class="form-control fromdate" name="start_date" placeholder="选择开始日期" value="{$start_date}">
                        <div class="input-group-middle"><span class="input-group-text">-</span></div>
                        <input type="text" class="form-control todate" name="end_date" placeholder="选择结束日期" value="{$end_date}">
                    </div>
                    <div class="form-group col">
                        <input type="submit" class="btn btn-primary btn-sm btn-submit ml-2" value="确定"/>
                    </div>
                    <div class="form-group mr-3">
                        <a href="{:url('rankExport',['start_date'=>$start_date,'end_date'=>$end_date])}" class="btn btn-info btn-sm" target="_blank"><i class="ion-md-download"></i> 导出</a>
                    </div>
                    <div class="btn-group btn-group-sm btn-group-toggle" data-toggle="buttons">
                        <label class="btn btn-outline-primary active">
                            <input type="radio" name="viewmode" value="chars" autocomplete="off" checked> 图表
                        </label>
                        <label class="btn btn-outline-primary">
                            <input type="radio" name="viewmode" value="table" autocomplete="off"> 表格
                        </label>
                    </div>
                </div>
            </form>
        </div>
        <div class="row chart-box">
            <div class="col"><canvas id="countChart" width="400" height="400"></canvas></div>
            <div class="col"><canvas id="amountChart" width="400" height="400"></canvas></div>
        </div>
        <div class="table-box d-none">
            <table class="table table-hover table-striped">
                <thead>
                <tr>
                    <th>#</th>
                    <th>客户</th>
                    <th>采购量</th>
                    <th>采购金额</th>
                    <th>平均金额</th>
                </tr>
                </thead>
                <tbody>
                <empty name="statics">{:list_empty(5)}</empty>
                {volist name="statics" id="v" }
                    <tr>
                        <td>{$v.supplier_id}</td>
                        <td>{$v.supplier} </td>
                        <td>
                            {$v.order_count}
                        </td>
                        <td>{$v.order_amount}</td>
                        <td>
                            {if $v['order_count'] > 0}
                                {:round($v['order_amount']/$v['order_count'],2)}
                                {else/}
                                -
                            {/if}
                        </td>
                    </tr>
                {/volist}
                </tbody>
            </table>
        </div>
    </div>

{/block}
{block name="script"}
    <script type="text/javascript" src="__STATIC__/chart/Chart.bundle.min.js"></script>
    <script type="text/javascript">
        var cchart = document.getElementById("countChart");
        var achart = document.getElementById("amountChart");
        var bgColors = [
            'rgba(255, 99, 132, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 159, 64, 0.2)'
        ];
        var bdColors=[];
        var options={

        };
        var countChart = new Chart(cchart, {
            type: 'pie',
            data: {
                labels: JSON.parse('{:json_encode(array_column($statics,"supplier"))}'),
                datasets: [{
                    label: '采购订单数',
                    data: JSON.parse('{:json_encode(array_column($statics,"order_count"))}'),
                    backgroundColor: bgColors,
                    borderColor: bdColors,
                    borderWidth: 1
                }]
            },
            options: options
        });
        var amountChart = new Chart(achart, {
            type: 'pie',
            data: {
                labels: JSON.parse('{:json_encode(array_column($statics,"supplier"))}'),
                datasets: [
                {
                    label: '采购金额',
                    data: JSON.parse('{:json_encode(array_column($statics,"order_amount"))}'),
                    backgroundColor: bgColors,
                    borderColor: bdColors,
                    borderWidth: 1
                }]
            },
            options: options
        });
        
        jQuery(function ($) {
            $('[name=viewmode]').change(function (e) {
                if(!this.checked) return;
                var val=$(this).val();
                if(val == 'table'){
                    $('.chart-box').addClass('d-none');
                    $('.table-box').removeClass('d-none');
                }else{
                    $('.table-box').addClass('d-none');
                    $('.chart-box').removeClass('d-none');
                }
            })
        })

    </script>
{/block}