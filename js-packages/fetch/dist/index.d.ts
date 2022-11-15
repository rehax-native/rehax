import { HttpMethod } from "./global";
export interface FetchRequest {
    url?: string;
    method?: HttpMethod;
    headers?: Record<string, string>;
    body?: string;
}
export interface FetchResponse {
    headers?: Record<string, string>;
    ok: boolean;
    status: number;
    json<T = any>(): Promise<T>;
    text(): Promise<string>;
}
declare function fetch(urlOrRequest: string | FetchRequest, requestOptions?: FetchRequest): Promise<FetchResponse>;
export default fetch;
