// Written in the D programming language

//This is a copy of the code written in C++ by Austin Appleby

module cryptod.hash.murmurhash3;
private:
@safe pure static uint ROTL32 (uint x, ubyte n)
{
	return (x << n) | (x >> (32 - n));
}

@safe pure static ulong ROTL64 ( ulong x, uint r )
{
  return (x << r) | (x >> (64 - r));
}

@safe pure uint fmix32(uint h)
{
	h ^= h >> 16;
	h *= 0x85ebca6b;
	h ^= h >> 13;
	h *= 0xc2b2ae35;
	h ^= h >> 16;

  return h;
}

@safe pure ulong fmix64 ( ulong k )
{
  k ^= k >> 33;
  k *= 0xff51afd7ed558ccd;
  k ^= k >> 33;
  k *= 0xc4ceb9fe1a85ec53;
  k ^= k >> 33;

  return k;
}

public:

//So far this is taken verbatim from murmurhash3.cpp
//D specific niceness (Templates and all) will come later.

pure uint murmurhash3_x86_32(string key, uint seed)
{
	return murmurhash3_x86_32(cast(ubyte[])key, seed);
}

pure uint murmurhash3_x86_32(ubyte[] key, uint seed)
{
	uint len = key.length;
	const ubyte * data = key.ptr;
	const int nblocks = len / 4;

	uint h1 = seed;
	
	uint c1 = 0xcc9e2d51;
	uint c2 = 0x1b873593;
	
	const uint * blocks = cast(uint *)(data + nblocks*4);

	for(int i = -nblocks; i; i++)
	{
		uint k1 = blocks[i];

		k1 *= c1;
		k1 = ROTL32(k1,15);
		k1 *= c2;
    
		h1 ^= k1;
		h1 = ROTL32(h1,13); 
		h1 = h1*5+0xe6546b64;
	}
	
	const ubyte * tail = cast(ubyte*)(data + nblocks*4);

	uint k1 = 0;

	switch(len & 3)
	{
		default:
		case 3: k1 ^= tail[2] << 16;
		case 2: k1 ^= tail[1] << 8;
		case 1: k1 ^= tail[0];
			k1 *= c1; k1 = ROTL32(k1,15); k1 *= c2; h1 ^= k1;
	};


	h1 ^= len;

	h1 = fmix32(h1);

	return h1;
} 

pure uint[4] murmurhash3_x86_128(string key, uint seed)
{
	return murmurhash3_x86_128(cast(ubyte[])key, seed);
}

pure uint[4] murmurhash3_x86_128(ubyte[] key, uint seed)
{
	uint len = key.length;
	const ubyte * data = key.ptr;
	const int nblocks = len / 16;
	int i;

	uint h1 = seed;
	uint h2 = seed;
	uint h3 = seed;
	uint h4 = seed;

	uint c1 = 0x239b961b; 
	uint c2 = 0xab0e9789;
	uint c3 = 0x38b34ae5; 
	uint c4 = 0xa1e38b93;

	const uint * blocks = cast(uint*)(data + nblocks*16);

	for(i = -nblocks; i; i++)
	{
		uint k1 = blocks[i*4+0];
		uint k2 = blocks[i*4+1];
		uint k3 = blocks[i*4+2];
		uint k4 = blocks[i*4+3];

		k1 *= c1; k1	= ROTL32(k1,15); k1 *= c2; h1 ^= k1;

		h1 = ROTL32(h1,19); h1 += h2; h1 = h1*5+0x561ccd1b;

		k2 *= c2; k2	= ROTL32(k2,16); k2 *= c3; h2 ^= k2;

		h2 = ROTL32(h2,17); h2 += h3; h2 = h2*5+0x0bcaa747;

		k3 *= c3; k3	= ROTL32(k3,17); k3 *= c4; h3 ^= k3;

		h3 = ROTL32(h3,15); h3 += h4; h3 = h3*5+0x96cd1c35;

		k4 *= c4; k4	= ROTL32(k4,18); k4 *= c1; h4 ^= k4;

		h4 = ROTL32(h4,13); h4 += h1; h4 = h4*5+0x32ac3b17;
	}

	const ubyte * tail = cast(ubyte*)(data + nblocks*16);

	uint k1 = 0;
	uint k2 = 0;
	uint k3 = 0;
	uint k4 = 0;

	switch(len & 15)
	{
		default:
		case 15: k4 ^= tail[14] << 16;
		case 14: k4 ^= tail[13] << 8;
		case 13: k4 ^= tail[12] << 0;
						 k4 *= c4; k4	= ROTL32(k4,18); k4 *= c1; h4 ^= k4;
	
		case 12: k3 ^= tail[11] << 24;
		case 11: k3 ^= tail[10] << 16;
		case 10: k3 ^= tail[ 9] << 8;
		case	9: k3 ^= tail[ 8] << 0;
						 k3 *= c3; k3	= ROTL32(k3,17); k3 *= c4; h3 ^= k3;
	
		case	8: k2 ^= tail[ 7] << 24;
		case	7: k2 ^= tail[ 6] << 16;
		case	6: k2 ^= tail[ 5] << 8;
		case	5: k2 ^= tail[ 4] << 0;
						 k2 *= c2; k2	= ROTL32(k2,16); k2 *= c3; h2 ^= k2;
	
		case	4: k1 ^= tail[ 3] << 24;
		case	3: k1 ^= tail[ 2] << 16;
		case	2: k1 ^= tail[ 1] << 8;
		case	1: k1 ^= tail[ 0] << 0;
						 k1 *= c1; k1	= ROTL32(k1,15); k1 *= c2; h1 ^= k1;
	};

	h1 ^= len; h2 ^= len; h3 ^= len; h4 ^= len;

	h1 += h2; h1 += h3; h1 += h4;
	h2 += h1; h3 += h1; h4 += h1;

	h1 = fmix32(h1);
	h2 = fmix32(h2);
	h3 = fmix32(h3);
	h4 = fmix32(h4);

	h1 += h2; h1 += h3; h1 += h4;
	h2 += h1; h3 += h1; h4 += h1;

	return [h1,h2,h3,h4];
}

pure ulong[2] murmurhash3_x64_128(string key, uint seed)
{
	return murmurhash3_x64_128(cast(ubyte[])key, seed);
}

pure ulong[2] murmurhash3_x64_128 (ubyte[] key, uint seed)
{
	uint len = key.length;
	const ubyte * data = cast(ubyte*)key;
	const int nblocks = len / 16;
	int i;

	ulong h1 = seed;
	ulong h2 = seed;

	ulong c1 = 0x87c37b91114253d5;
	ulong c2 = 0x4cf5ad432745937f;

	//----------
	// body

	const ulong * blocks = cast(ulong*)(data);

	for(i = 0; i < nblocks; i++)
	{
		ulong k1 = blocks[i*2+0];
		ulong k2 = blocks[i*2+1];

		k1 *= c1; k1	= ROTL64(k1,31); k1 *= c2; h1 ^= k1;

		h1 = ROTL64(h1,27); h1 += h2; h1 = h1*5+0x52dce729;

		k2 *= c2; k2	= ROTL64(k2,33); k2 *= c1; h2 ^= k2;

		h2 = ROTL64(h2,31); h2 += h1; h2 = h2*5+0x38495ab5;
	}

	//----------
	// tail

	const ubyte * tail = cast(ubyte*)(data + nblocks*16);

	ulong k1 = 0;
	ulong k2 = 0;

	switch(len & 15)
	{
		default:
		case 15: k2 ^= cast(ulong)(tail[14]) << 48;
		case 14: k2 ^= cast(ulong)(tail[13]) << 40;
		case 13: k2 ^= cast(ulong)(tail[12]) << 32;
		case 12: k2 ^= cast(ulong)(tail[11]) << 24;
		case 11: k2 ^= cast(ulong)(tail[10]) << 16;
		case 10: k2 ^= cast(ulong)(tail[ 9]) << 8;
		case	9: k2 ^= cast(ulong)(tail[ 8]) << 0;
						 k2 *= c2; k2	= ROTL64(k2,33); k2 *= c1; h2 ^= k2;
	
		case	8: k1 ^= cast(ulong)(tail[ 7]) << 56;
		case	7: k1 ^= cast(ulong)(tail[ 6]) << 48;
		case	6: k1 ^= cast(ulong)(tail[ 5]) << 40;
		case	5: k1 ^= cast(ulong)(tail[ 4]) << 32;
		case	4: k1 ^= cast(ulong)(tail[ 3]) << 24;
		case	3: k1 ^= cast(ulong)(tail[ 2]) << 16;
		case	2: k1 ^= cast(ulong)(tail[ 1]) << 8;
		case	1: k1 ^= cast(ulong)(tail[ 0]) << 0;
						 k1 *= c1; k1	= ROTL64(k1,31); k1 *= c2; h1 ^= k1;
	};

	h1 ^= len; h2 ^= len;

	h1 += h2;
	h2 += h1;

	h1 = fmix64(h1);
	h2 = fmix64(h2);

	h1 += h2;
	h2 += h1;

	return [h1,h2];
}

//Taken from official implementation
unittest
{
	assert(murmurhash3_x86_32("abcde",42)==2933533680u);
	assert(murmurhash3_x86_128("abcde",42)==[1480429215u,166782523u,3736068775u,3736068775u]);
	assert(murmurhash3_x64_128("abcde",42)==[11577333987734259462u, 6620454430658148401u]);
}