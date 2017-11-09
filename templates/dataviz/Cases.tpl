{crmTitle string="Case Overview"}
<div class="caseoverview">
    <div id="case-manager" class="clear">
        <strong>Case Manager</strong>
        <a class="reset" href="javascript:typeRow.filterAll();dc.redrawAll();" style="display: none;">reset</a>
        <div class="clearfix"></div>
    </div>
    <div class="clear"></div>
    <div id="pie-group">
        <div id="type">
            <strong>Case Type</strong>
            <a class="reset" href="javascript:typePie.filterAll();dc.redrawAll();" style="display: none;">reset</a>
            <div class="clearfix"></div>
        </div>
        <div id="status">
            <strong>Case Status</strong>
            <a class="reset" href="javascript:statusPie.filterAll();dc.redrawAll();" style="display: none;">reset</a>
            <div class="clearfix"></div>
        </div>
    </div>
    <div class="clear"></div>
    <table id="dc-data-table">
        <thead>
            <tr class="header">
                <th>Contact Name</th>
                <th>Case ID</th>
                <th>Subject</th>
                <th>Status</th>
                <th>Type</th>
                <th>Start Date</th>
                <th>End Date</th>
            </tr>
        </thead>
    </table>
    <div class="clear"></div>
</div>

<script>
  'use strict';
   var data             = {crmSQL file="cases"};
   var statusOptionVal  = {crmAPI entity="OptionValue" option_group_id="case_status"};
   var caseURL          = "{crmURL p='civicrm/contact/view/case?reset=1&id=xx&cid=yy&action=view&context=dashboard&selectedChild=case'}";
   var contactURL       = "{crmURL p='civicrm/contact/view?reset=1&cid=xx'}";

   {literal}
    if(!data.is_error){
        var typeRow, typePie, statusPie, dataTable;
        cj(function($) {
            var statusLabel = {};
            statusOptionVal.values.forEach (function(d) {
                statusLabel[d.value] = d.label;
            });
            statusOptionVal=null;

            data.values.forEach(function(d){
                d.case_status = statusLabel[d.status_id];
            });

            var ndx                 = crossfilter(data.values);
            var caseTypeDim         = ndx.dimension(function(d) {return d.case_type;});
            var caseTypeTotal       = caseTypeDim.group().reduceSum(function(d) {return d.total;});
            var caseStatusDim		= ndx.dimension(function(d) {return d.case_status;});
            var caseStatusTotal     = caseStatusDim.group().reduceSum(function(d) {return d.total;});
            var caseManagerDim		= ndx.dimension(function(d) {return d.contact_sort_name;});
            var caseManagerTotal	= caseManagerDim.group().reduceSum(function(d){return d.total;});

            // Case Manager
            typeRow = dc.rowChart('#case-manager');
            typeRow
                .height(200)
                .margins({top: 20, left: 10, right: 10, bottom: 20})
                .dimension(caseManagerDim)
                .cap(5)
                .ordering (function(d) {return d.total;})
                .colors(d3.scale.category10())
                .group(caseManagerTotal)
                .elasticX(true);

            // Case Type
            typePie = dc.pieChart("#type");
            typePie
                .innerRadius(10)
                .radius(120)
                .width(300)
                .height(300)
                .colors(d3.scale.category10())
                .dimension(caseTypeDim)
                .group(caseTypeTotal);

            // Case Status
            statusPie = dc.pieChart("#status");
            statusPie
                .innerRadius(10)
                .radius(120)
                .width(300)
                .height(300)
                .colors(d3.scale.category10())
                .dimension(caseStatusDim)
                .group(caseStatusTotal);

            // List of Cases
            dataTable = dc.dataTable("#dc-data-table");
            dataTable
                .dimension(caseTypeDim)
                .group(function(d) {return d.year;})
                .columns([
                    function(d) {return "<a href='"+contactURL.replace('xx',d.id)+"'>"+d.contact_sort_name+"</a>";},
                    function(d) {return "<a href='"+caseURL.replace('xx',d.id).replace('yy',d.contact_id)+"'>"+d.id+"</a>";},
                    function(d) {return d.subject;},
                    function(d) {return d.case_status;},
                    function(d) {return d.case_type;},
                    function(d) {return d.start_date;},
                    function(d) {return d.end_date;}
                ]);

            dc.renderAll();
        });
    }
    else {
        cj('.caseoverview').html('<div style="color:red; font-size:18px;">Civisualize Error. Please contact Admin.'+data.error+'</div>')
    }
   {/literal}
</script>
<div class="clear"></div>