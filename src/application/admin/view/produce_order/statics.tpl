{extend name="public:base" /}
{block name="header"}
    <style type="text/css">
        html{overflow-y:scroll;}
    </style>
{/block}
{block name="body"}

    {include file="public/bread" menu="sale_order_statics" title="生产统计" /}

    <div id="page-wrapper">
        <div class="list-header">
            <form class="noajax" action="{:url('produceOrder/statics')}" method="post">
                <div class="form-row">
                    <div class="form-group col input-group input-group-sm date-range">
                        <div class="input-group-prepend">
                            <span class="input-group-text">生产时间</span>
                        </div>
                        <input type="text" class="form-control fromdate" name="start_date" placeholder="选择开始日期" value="{$start_date}">
                        <div class="input-group-middle"><span class="input-group-text">-</span></div>
                        <input type="text" class="form-control todate" name="end_date" placeholder="选择结束日期" value="{$end_date}">
                    </div>
                    <div class="form-group col">
                        <div class="btn-group btn-group-sm btn-group-toggle" data-toggle="buttons">
                            <label class="btn btn-outline-secondary {$static_type=='date'?'active':''}">
                                <input type="radio" name="type" id="option1" value="date" autocomplete="off" checked> 按日
                            </label>
                            <label class="btn btn-outline-secondary {$static_type=='month'?'active':''}">
                                <input type="radio" name="type" id="option2" value="month" autocomplete="off"> 按月
                            </label>
                            <label class="btn btn-outline-secondary {$static_type=='year'?'active':''}">
                                <input type="radio" name="type" id="option3" value="year" autocomplete="off"> 按年
                            </label>
                        </div>
                        <input type="submit" class="btn btn-primary btn-sm btn-submit ml-2" value="确定"/>
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
                    <th>生产数量</th>
                    <th>生产金额</th>
                </tr>
                </thead>
                <tbody>
                <empty name="statics">{:list_empty(3)}</empty>
                {volist name="statics" id="v" }
                    <tr>
                        <td>{$v.awdate}</td>
                        <td>{$v.order_count}</td>
                        <td>
                            {$v.order_amount}
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
        var ctx = document.getElementById("myChart");
        var myChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: JSON.parse('{:json_encode(array_column($statics,"awdate"))}'),
                datasets: [
                    {
                        label: '销售单数量',
                        data: JSON.parse('{:json_encode(array_column($statics,"order_count"))}'),
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.2)',
                        ],
                        borderColor: [
                            'rgba(255,99,132,1)',
                        ],
                        borderWidth: 1
                    },
                    {
                        label: '销售单金额',
                        data: JSON.parse('{:json_encode(array_column($statics,"order_amount"))}'),
                        backgroundColor: [
                            'rgba(54, 162, 235, 0.2)',
                        ],
                        borderColor: [
                            'rgba(54, 162, 235, 1)',
                        ],
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