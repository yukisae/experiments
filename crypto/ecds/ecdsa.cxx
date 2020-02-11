#include <iostream>
#include <iomanip>
#include <vector>
#include <stdexcept>
#include <openssl/evp.h>
#include <openssl/ec.h>

int main() {
    EVP_PKEY *key = nullptr;
    EVP_PKEY_CTX *pctx = nullptr;
    if (false) {
        pctx = EVP_PKEY_CTX_new_id(EVP_PKEY_ED25519, NULL);
    } else {
        pctx = EVP_PKEY_CTX_new_id(EVP_PKEY_EC, NULL);
        if (1 != EVP_PKEY_paramgen_init(pctx))
            throw std::runtime_error("EVP_PKEY_paramgen_init");
        if (1 != EVP_PKEY_CTX_set_ec_paramgen_curve_nid(pctx, NID_X9_62_prime256v1))
            throw std::runtime_error("EVP_PKEY_CTX_set_ec_paramgen_curve_nid");
    }
    if (1 != EVP_PKEY_keygen_init(pctx))
        throw std::runtime_error("EVP_PKEY_keygen_init");
    if (1 != EVP_PKEY_keygen(pctx, &key))
        throw std::runtime_error("EVP_PKEY_keygen");

    const std::string data = "Hello World";
    std::vector<unsigned char> sig;
    size_t siglen;

    EVP_MD_CTX *mdctx = NULL;
    if (!(mdctx = EVP_MD_CTX_new()))
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

    if (1 != EVP_MD_CTX_reset(mdctx))
        throw std::runtime_error("EVP_MD_CTX_reset");
    if (1 != EVP_DigestVerifyInit(mdctx, nullptr, nullptr, nullptr, key))
        throw std::runtime_error("EVP_DigestVerifyInit");
    int verify = EVP_DigestVerify(mdctx, (const unsigned char*)sig.data(), sig.size(),
                                  (const unsigned char*)data.data(), data.size());
    std::cerr << "verify: ";
    if (verify == 1) {
        std::cerr << "ok";
    } else {
        std::cerr << "ng (ret=" << verify << ")";
    }
    std::cerr << std::endl;

    EVP_MD_CTX_free(mdctx);
    EVP_PKEY_CTX_free(pctx);
}
