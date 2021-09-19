{extend name="public:base" /}
{block name="header"}
    <style type="text/css">
        html{overflow-y:scroll;}
    </style>
{/block}
{block name="body"}

    {include file="public/bread" menu="supplier_index" title="供应商统计" /}

    <div id="page-wrapper">
        <div class="list-header">
            <form class="noajax" action="{:url('supplier/statics',['supplier_id'=>$supplier_id])}" method="post">
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
                        <input type="hidden" name="supplier_id" value="{$supplier.id}"/>
                        <input type="submit" class="btn btn-primary btn-sm btn-submit ml-2" value="确定"/>
                    </div>
                    <div class="form-group mr-3">
                        <a href="{:url('staticsExport',['supplier_id'=>$supplier['id'],'start_date'=>$start_date,'end_date'=>$end_date])}" class="btn btn-info btn-sm" target="_blank"><i class="ion-md-download"></i> 导出</a>
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
        <div class="chart-box">
            <canvas id="myChart" width="800" height="400"></canvas>
        </div>
        <div class="table-box d-none">
            <table class="table table-hover table-striped">
                <thead>
                <tr>
                    <th>日期</th>
                    <th>订单数</th>
                    <th>总金额</th>
                    <th>单均金额</th>
                </tr>
                </thead>
                <tbody>
                {empty name="statics"}{:list_empty(4)}{/empty}
                {volist name="statics" id="v" }
                    <tr>
                        <td>{$v.awdate}</td>
                        <td>{$v.order_count}</td>
                        <td>
                            {$v.order_amount}
                        </td>
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
        window.page_title="[{$supplier['title']}]统计";
        var ctx = document.getElementById("myChart");
        var bgColors=[
            'rgba(255, 99, 132, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 159, 64, 0.2)'
        ];
        var bdColors=[
            'rgba(255,99,132,1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 206, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)',
            'rgba(255, 159, 64, 1)'
        ];
        var myChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: JSON.parse('{:json_encode(array_column($statics,"awdate"))}'),
                datasets: [
                    {
                        label: '订单数量',
                        data: JSON.parse('{:json_encode(array_column($statics,"order_count"))}'),
                        backgroundColor:bgColors[2],
                        borderColor: bdColors[2],
                        borderWidth: 1
                    },
                    {
                        label: '订单总金额',
                        data: JSON.parse('{:json_encode(array_column($statics,"order_amount"))}'),
                        backgroundColor:bgColors[3],
                        borderColor: bdColors[3],
                        borderWidth: 1
                    }
                ]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero:true
                        }
                    }]
                }
            }
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