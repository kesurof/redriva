<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  export let columns: string[] = [];
  export let rows: any[] = [];
  export let onDelete: (id: string) => void = () => {};
  const dispatch = createEventDispatcher();
</script>

<table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
  <thead>
    <tr>
      {#each columns as col}
        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">{col}</th>
      {/each}
      <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
    </tr>
  </thead>
  <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
    {#each rows as row}
      <tr class="hover:bg-gray-100 dark:hover:bg-gray-800 cursor-pointer" on:click={() => dispatch('rowClick', row.id)}>
        {#each columns as col}
          <td class="px-4 py-2 text-sm text-gray-700 dark:text-gray-200">{row[col]}</td>
        {/each}
        <td class="px-4 py-2" on:click|stopPropagation={() => onDelete(row.id)}>
          <button class="bg-red-600 text-white px-2 py-1 rounded text-xs">{'{$t ? $t("delete") : "Supprimer"}'}</button>
        </td>
      </tr>
    {/each}
  </tbody>
</table>
