<script>
	import '@evidence-dev/tailwind/fonts.css';
	import '../app.css';
	import './custom.css';
	import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
	import { showQueries } from '@evidence-dev/component-utilities/stores';
	export let data;

	// Force the query-showing store to always be false (disables dev mode query code view)
	$: $showQueries = false;
</script>

<EvidenceDefaultLayout {data} neverShowQueries={true}>
	<slot slot="content" />
</EvidenceDefaultLayout>
