import { writable } from 'svelte/store';
import { persisted } from 'svelte-persisted-store';

export interface AuthState {
  isAuthenticated: boolean;
  token: string | null;
  user: any | null;
}

const initialState: AuthState = {
  isAuthenticated: false,
  token: null,
  user: null
};

export const authStore = persisted('auth', initialState);

export const login = (token: string, user: any) => {
  authStore.update(state => ({
    ...state,
    isAuthenticated: true,
    token,
    user
  }));
};

export const logout = () => {
  authStore.update(state => ({
    ...initialState
  }));
};

export const updateUser = (user: any) => {
  authStore.update(state => ({
    ...state,
    user
  }));
};
