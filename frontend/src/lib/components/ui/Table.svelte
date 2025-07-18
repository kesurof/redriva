<script lang="ts">
  export let columns: string[] = [];
  export let rows: any[] = [];
</script>

<table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
  <thead>
    <tr>
      {#each columns as col}
        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">{col}</th>
      {/each}
    </tr>
  </thead>
  <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
    {#each rows as row}
      <tr class="hover:bg-gray-100 dark:hover:bg-gray-800 cursor-pointer">
        {#each columns as col}
          <td class="px-4 py-2 text-sm text-gray-700 dark:text-gray-200">{row[col]}</td>
        {/each}
      </tr>
    {/each}
  </tbody>
</table>
