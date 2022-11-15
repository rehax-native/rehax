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

function fetch(
  urlOrRequest: string | FetchRequest,
  requestOptions?: FetchRequest
): Promise<FetchResponse> {
  const options = {
    ...(requestOptions ??
      (typeof urlOrRequest !== "string" ? urlOrRequest : {})),
  };
  const url =
    typeof urlOrRequest === "string" ? (urlOrRequest as string) : options.url;

  if (!url) {
    throw new Error("url is required");
  }

  if (!options.method) {
    options.method = "GET";
  }

  return new Promise((resolve, reject) => {
    rehax.fetch.request({
      ...options,
      method: options.method!,
      url,
      requestHeaders: options.headers ?? {},
      callback: (response) => {
        if (response.errorMessage) {
          return reject({
            message: response.errorMessage,
            status: response.status,
          });
        }
        resolve({
          headers: response.reponseHeaders,
          ok: response.status >= 200 && response.status < 300,
          status: response.status,
          json: () => JSON.parse(response.body.toString()),
          text: async () => response.body.toString(),
        });
      },
    });
  });
}

export default fetch;
