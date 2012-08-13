Cryptod
=======

This is a simple Cryptography library written in D.

Ciphers
-------

Block Ciphers:
 * AES
 * Blowfish
 * Threefish
 * (BROKEN) DES
 
Stream Ciphers:
 * PRNG xor cipher (takes any deterministic prng as input.)
 
Planned:
 * Assymetric Crypto
 * Twofish
 * Serpent
 * Stream Ciphers
 
Hashes
------

Context Hashes:
 * SHA1
 * (BROKEN) Tiger
 
'Fast' Hashes: (these hashes are not suitable for cryptographic purposes.)
 * murmurhash3
 
Planned:
 * SHA2 Family
 * All SHA3 finalists (Skein &al)
 * More fast hashes

Pseudo Random Number Generators
-------------------------------
 * Mersenne Twister
 * BlumBlumShub (Note: the design of the algorithms is suppossed to be slow and is great for heavy-duty crypto)
 * Counter Mode Block Cipher PRNG (takes any block cipher as input.)
 

 
Key Derivation Functions
------------------------
 * PBKDF1 (might be broken, not sure, but that might be an obscure case of sha1)
 
More to come.

Benchmarks
----------

Tons of stuff is way too slow right now.
<pre>
	65536 murmurhash3_x86_32 in 304 milliseconds: 210.526 MB/s
	65536 murmurhash3_x86_128 in 324 milliseconds: 197.531 MB/s
	65536 murmurhash3_x64_128 in 291 milliseconds: 219.931 MB/s
	4096 sha1 in 641 milliseconds: 6.24025 MB/s
	16777216 ints generated by mersenne twister in 593 milliseconds: 107.926 MB/s
	256 ints generated by BlumBlumShub in 536 milliseconds: 0.00182194 MB/s
	1048576 texts blowfish encrypted in 568 milliseconds: 14.0845 MB/s
	65536 texts threefish encrypted in 1731 milliseconds: 1.1554 MB/s
	131072 texts aes128 encrypted in 977 milliseconds: 2.04708 MB/s
</pre>