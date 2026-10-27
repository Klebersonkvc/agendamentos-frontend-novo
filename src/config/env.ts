/**
 * Ponto único de leitura das variáveis de ambiente.
 * Para trocar a URL da API, altere apenas VITE_API_URL no arquivo .env.
 */
const rawApiUrl = import.meta.env.VITE_API_URL;

if (!rawApiUrl) {
  console.warn('[config] VITE_API_URL não definida no .env — usando http://localhost:3000');
}

export const env = {
  apiUrl: (rawApiUrl || 'http://localhost:3000').replace(/\/+$/, ''),
};
