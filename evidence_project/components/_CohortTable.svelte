<script>
    import { DataTable, Column } from "@evidence-dev/core-components";
    export let data;
    export let periodTitle="Cohort Period";
    export let sizeFmt="num0";
    export let valueFmt="pct0";

    // find all columns that end with _pct
    $: cols = data && data.length > 0 ? Object.keys(data[0]) : [];
    $: periodCols = cols.filter(c => c.endsWith('_pct')).sort();
</script>

<div class="text-black ml-[36vw] sm:ml-[15vw] pl-10 text-[10pt] font-bold pt-0 pb-0 -mb-4 mt-0">{periodTitle}</div>
<p class="text-xs text-gray-500 mb-2">Debug: Found {periodCols.length} period columns.</p>
<DataTable data={data} rows=all>
    <Column id="cohort_month" title="Cohort Month" fmt="mmm yyyy"/>
    <Column id="cohort_size" title="Cohort Size" align=center fmt={sizeFmt}/>
    {#each periodCols as col, i}
        <Column id={col} title={i+""} fmt={valueFmt} contentType="colorscale" colorMax=1 colorMin=0 colorScale={['#eff6ff', '#1d4ed8']}/>
    {/each}
</DataTable>
