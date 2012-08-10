// Written in the D programming language

//This is a copy of the code written in C++ by Austin Appleby

module cryptod.hash.murmurhash3;

@safe pure uint ROTL32 (uint x, ubyte n)
{
	return (x << n) | (x >> (32 - n));
}

@safe pure uint fmix(uint h)
{
	h ^= h >> 16;
	h *= 0x85ebca6b;
	h ^= h >> 13;
	h *= 0xc2b2ae35;
	h ^= h >> 16;

  return h;
}

//Taken from official implementation
unittest
{
	
}

//So far this is taken verbatim from murmurhash3.cpp
//D specific niceness (Templates and all) will come later.

uint murmurhash3_32(ubyte[] key, uint seed)
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

	h1 = fmix(h1);

	return h1;
} 
ulong murmurhash3_64(ubyte[] key, uint seed)
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

	h1 = fmix(h1);

	return h1;
} 