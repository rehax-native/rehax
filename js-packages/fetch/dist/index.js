var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
function fetch(urlOrRequest, requestOptions) {
    const options = Object.assign({}, (requestOptions !== null && requestOptions !== void 0 ? requestOptions : (typeof urlOrRequest !== "string" ? urlOrRequest : {})));
    const url = typeof urlOrRequest === "string" ? urlOrRequest : options.url;
    if (!url) {
        throw new Error("url is required");
    }
    if (!options.method) {
        options.method = "GET";
    }
    return new Promise((resolve, reject) => {
        var _a;
        rehax.fetch.request(Object.assign(Object.assign({}, options), { method: options.method, url, requestHeaders: (_a = options.headers) !== null && _a !== void 0 ? _a : {}, callback: (response) => {
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
                    text: () => __awaiter(this, void 0, void 0, function* () { return response.body.toString(); }),
                });
            } }));
    });
}
export default fetch;
