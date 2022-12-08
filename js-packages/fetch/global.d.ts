export type HttpMethod =
  | "GET"
  | "POST"
  | "PUT"
  | "PATCH"
  | "DELETE"
  | "OPTIONS";

export interface HttpBody {
  toString(): string;
}

export interface HttpRequest {
  url: string;
  method: HttpMethod;
  requestHeaders: Record<string, string>;
  body?: HttpBody;
  callback: (response: HttpResponse) => void;
}

export interface HttpResponse {
  errorMessage: string;
  status: number;
  reponseHeaders: Record<string, string>;
  body: HttpBody;
}

declare global {
  export declare const rehax = {
    fetch: {
      request(request: HttpRequest): void;,
    },
  };
}

export {};
