<script lang="ts">
  import { t } from 'svelte-i18n';
  import Toast from '$lib/components/ui/Toast.svelte';
  let toastMsg = '';
  let toastType = 'info';
  let showToast = false;
  function showToastMsg(msg: string, type: string = 'info') {
    toastMsg = msg;
    toastType = type;
    showToast = true;
  }
</script>

<h1 class="text-2xl font-bold mb-4">{ $t('scraper') }</h1>
<p class="text-gray-500">Page en construction…</p>
<Toast message={toastMsg} type={toastType} on:close={() => showToast = false} duration={2500} />
