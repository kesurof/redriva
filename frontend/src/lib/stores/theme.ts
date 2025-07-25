import { writable } from 'svelte/store';
import { persisted } from 'svelte-persisted-store';

export interface ThemeSettings {
  mode: 'light' | 'dark';
  primaryColor: string;
  compact: boolean;
}

const defaultTheme: ThemeSettings = {
  mode: 'light',
  primaryColor: '#3B82F6',
  compact: false
};

export const themeStore = persisted('theme', defaultTheme);

export const toggleDarkMode = () => {
  themeStore.update(theme => ({
    ...theme,
    mode: theme.mode === 'light' ? 'dark' : 'light'
  }));
};

export const setPrimaryColor = (color: string) => {
  themeStore.update(theme => ({
    ...theme,
    primaryColor: color
  }));
};

export const toggleCompact = () => {
  themeStore.update(theme => ({
    ...theme,
    compact: !theme.compact
  }));
};
