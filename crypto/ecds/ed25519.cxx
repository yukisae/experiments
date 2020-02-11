#include <iostream>
#include <iomanip>
#include <vector>
#include <stdexcept>
#include <openssl/evp.h>

int main() {
    EVP_PKEY *key = nullptr;
    EVP_PKEY_CTX *pctx = EVP_PKEY_CTX_new_id(EVP_PKEY_ED25519, NULL);
    EVP_PKEY_keygen_init(pctx);
    EVP_PKEY_keygen(pctx, &key);

    const std::string data = "Hello World";
    std::vector<unsigned char> sig;
    size_t siglen;

    EVP_MD_CTX *mdctx = NULL;
    if (!(mdctx = EVP_MD_CTX_create()))
        throw std::runtime_error("EVP_MD_CTX_create");
    if (1 != EVP_DigestSignInit(mdctx, nullptr, nullptr, nullptr, key))
        throw std::runtime_error("EVP_DigestSignInit");
    if (1 != EVP_DigestSign(mdctx, nullptr, &siglen, nullptr, 0))
        throw std::runtime_error("EVP_DigestSign#0");
    sig.resize(siglen);
    std::cerr << "Sign Buffer Length: " << siglen << std::endl;
    if (1 != EVP_DigestSign(mdctx, (unsigned char*)sig.data(), &siglen, (const unsigned char*)data.data(), data.size()))
        throw std::runtime_error("EVP_DigestSign#1");
    sig.resize(siglen);
    std::cerr << "Sign Length: " << siglen << std::endl;
#if BIN
    for (auto c : sig)
        std::cout << c;
#else
    for (auto c : sig)
        std::cout << std::hex << std::setfill('0') << std::setw(2) << (int)c;
    std::cout << std::endl;
#endif

    EVP_MD_CTX_destroy(mdctx);
    EVP_PKEY_CTX_free(pctx);
}
