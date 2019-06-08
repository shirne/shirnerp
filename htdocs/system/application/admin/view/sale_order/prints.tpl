<extend name="public:print" />
<block name="header">
    <style >
        @page {
            size: 10cm 10cm;
            margin:0;
        }
        #page-wrapper{

        }
        .print-page{
            width :8cm;
            padding:0;
            height:6cm;
            margin-top:1em;
            position: relative;
            border-radius:5px;
            box-shadow: 1px 2px 5px rgba(0,0,0,.2);
        }
        .print-page .btn-circle{
            position: absolute;
            color:red;
            right:10px;
            top:10px;
        }
        .print-page table{
            height:100%;
        }
        .print-page td{
            border-top:0;
            vertical-align: middle;
        }
        .orderwrapper{
            padding:10px;
            border-bottom:1px #ddd solid;
            display:flex;
        }
        .goodsbox{
            flex:1;
        }
        .labelbox{
            width:8cm;
            flex:0 0 auto;
        }
        @media print {
            .orderwrapper{
                padding:0;
                border:0;
            }
        }
    </style>
</block>
<block name="body">
    <div class="page-wrapper container ml-auto mr-auto mb-3 d-print-none">
        <div class="row">
            <h2 class="col-md-6">标签打印</h2>
            <div class="col-md-6 text-right ">
                <a href="javascript:" class="btn btn-info print-btn">保存</a>
                <a href="javascript:" class="btn btn-primary print-btn">打印</a>
            </div>
        </div>
    </div>
    <div id="page-wrapper" class="container m-auto">
        <div class="orderwrapper" v-for="order in orders">
            <div class="goodsbox d-print-none">
                <a href="javascript:" v-for="good in orderGoods[order.id]" class="btn btn-secondary">
                    {{good.goods_title}} <span class="badge badge-light">{{good.count}} {{good.goods_unit}}</span>
                </a>
            </div>

            <div class="labelbox">
                <div class="print-page" v-for="pkg in packages[order.id]">
                    <a class="btn btn-circle d-print-none" title="删除标签" href="javascript:"><i class="ion-md-close"></i> </a>
                    <table class="table">

                        <thead class="text-center"><tr><td><h1>{{order.customer_title}}</h1></td></tr></thead>
                        <tr v-for="good in goods">
                            <td>
                                <div class="row">
                                    <h1 class="col-4 text-right bigger">品名：</h1>
                                    <h1 class="col text-left bigger">{{good.goods_title}}</h1>
                                </div>
                                <div class="row">
                                    <h1 class="col-4 text-right bigger">数量：</h1>
                                    <h1 class="col text-left bigger">{{good.count}} {{good.goods_unit}}</h1>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
                <a  href="javascript:" class="btn btn-outline-primary mt-3 d-print-none" @click="addLabel(order.id)">增加标签</a>
            </div>
        </div>
    </div>
</block>
<block name="script">
    <script type="text/javascript" src="__STATIC__/js/vue-2.6.min.js"></script>
    <script type="text/javascript">
        jQuery(function ($) {
            //window.print();
            $('.print-btn').click(function () {
                window.print();
            })
        })
        var app = new Vue({
            el: '#page-wrapper',
            data: {
                orders:[],
                orderGoods:[],
                packages:[],
                storage_ids:[]
            },
            watch: {

            },
            mounted: function () {
                this.initData();
            },
            methods: {
                initData:function () {
                    var self=this;
                    $.ajax({
                        url:'',
                        method:'POST',
                        data:{
                            test:1
                        },
                        success:function (json) {
                            console.log(json)
                            if(json.code===1) {
                                var data = json.data;
                                self.orders = data.orders;
                                self.orderGoods = data.orderGoods;
                                self.packages = data.packages;
                                self.packageGoods = data.packageGoods;
                            }
                        }
                    });
                },
                addLabel:function (order_id) {
                    this.packages[order_id].push({
                        package_id:0
                    });
                }
            }
        });
    </script>
</block>