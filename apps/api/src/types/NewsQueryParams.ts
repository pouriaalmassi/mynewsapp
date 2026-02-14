export interface NewsQueryParams {
  country?: string;
  category?: string;
  q?: string;
  pageSize?: number;
  page?: number;
  fetchFullContent?: boolean;
}