module cryptod.blockcipher.threefish;

import cryptod.blockcipher.blockcipher;

class Threefish : BlockCipher
{
	private:
	immutable ulong[] R4  = [14,16,52,57,23,40,5,37,25,33,46,12,58,22,32,32];
	immutable ulong[] R8  = [46,36,19,37,33,27,14,42,17,49,36,39,44,9,54,56,39,30,34,24,13,50,10,17,25,29,39,43,8,35,56,22];
	immutable ulong[] R16 = [24,13,8,47,8,17,22,37,38,19,10,55,49,18,23,52,33,4,51,13,34,41,59,17,5,20,48,41,47,28,16,25,41,9,37,31,12,47,44,30,16,34,56,51,4,53,42,41,31,44,47,46,19,42,44,25,9,48,35,52,23,31,37,20];
	
	immutable uint[]  pi4 = [0,3,2,1];
	immutable uint[]  pi8 = [2,1,4,7,6,5,0,3];
	immutable uint[]  pi16= [0,9,2,13,6,11,4,15,10,7,12,3,14,5,8,1];
	
	ubyte[] K;
	ubyte[16] T;
	ulong[] k;
	ulong[] t;
	ulong[] ks;
	uint Nw;
	uint Nr;
	
	
	
	pure uint pi(uint i)
	{
		if (Nw == 4)
			return pi4[i];
		else if (Nw == 8)
			return pi8[i];
		else
			return pi16[i];
	}
	
	pure ulong[2] MIX(uint d, uint j, ulong x0, ulong x1)
	{
		ulong y0 = x0+x1;
		ulong y1 = ROTL(x1,R(d%8,j))^y0;
	
		return [y0,y1];
	}
	
	pure ulong[2] INVMIX(uint d, uint j, ulong y0, ulong y1)
	{
		ulong x1 = ROTR(y1^y0,R(d%8,j));
		ulong x0 = y0-x1;
	
		return [x0,x1];
	}
	
	pure ulong ROTL(ulong x, ulong n)
	{
		return (x << n) | (x >> (64-n));
	}
	
	pure ulong ROTR(ulong x, ulong n)
	{
		return (x >> n) | (x << (64-n));
	}
	
	pure ulong R(uint d, uint j)
	{
		if(Nw == 4)
			return R4[2*d+j];
		else if (Nw == 8)
			return R8[4*d+j];
		else
			return R16[8*d+j];
	}
	
	pure ulong[] BytesToWords(ubyte[] Z)
	{
		uint numWords = Z.length/8;
		
		ulong[] words = new ulong[numWords];
			
		for(uint i = 0; i < numWords; i++)
		{
			for(uint j = 0; j < 8; j++)
			{
				words[i] = words[i] << 8;
				words[i] += Z[8*i+j];
			}
		}
			
		return words;
	}
	
	pure ubyte[] WordsToBytes(ulong[] Z)
	{
		uint numBytes = Z.length * 8;
		
		ubyte[] bytes = new ubyte[numBytes];
		
		for(uint i = 0; i < Z.length; i++)
		{
			for(uint j = 0; j < 8; j++)
			{
				bytes[8*i+j] = (Z[i] >>> (8*(7-j))) & 0xFF;
			}
		}
		return bytes;
	}
	
	public:
	
	this(ubyte[] K, ubyte[16] T)
	in
	{
		if((K.length != 32) && (K.length != 64) && (K.length != 128))
		{
			throw new BadBlockSizeException("Threefish key size must be 32, 64, or 128 bytes.");
		}
	}
	body
	{	
		this.K = K;
		this.T = T;
		
		Nw = K.length/8;
		
		Nr = K.length < 128 ? 72 : 80;
		
		k = BytesToWords(K);
		t = BytesToWords(T);
		
		t ~= t[0] ^ t[1];//t[2]
		
		k ~= 0x1BD11BDAA9FC1A22; //C240
		
		for(uint i = 0; i < Nw; i++)
		{
			k[Nw] ^= k[i];
		}
		
		ks = new ulong[(Nr/4+1) * Nw];
		
		for(uint s = 0; s <= Nr/4; s++)
		{
			for(uint i = 0; i < Nw; i++)
			{
				if(i < Nw-3)
					ks[s*Nw+i] = k[(s+i)%(Nw+1)];
				else if (i == Nw-3)
					ks[s*Nw+i] = k[(s+i)%(Nw+1)] + t[s%3];
				else if (i == Nw-2)
					ks[s*Nw+i] = k[(s+i)%(Nw+1)] + t[(s+1)%3];
				else if (i == Nw-1)
					ks[s*Nw+i] = k[(s+i)%(Nw+1)] + s;
			}
		}
	}

	ubyte[] Cipher(ubyte[] P)
	in
	{
		if(K.length != P.length)
		{
			throw new BadBlockSizeException("Threefish key size must match the plaintext size.");
		}
	}
	body
	{
		ulong[] p = BytesToWords(P);
		
		ulong[] v = new ulong[Nw];
		ulong[] e = new ulong[Nw];
		ulong[] f = new ulong[Nw];
		ulong[] c = new ulong[Nw];
		
		for(uint i = 0; i < Nw; i++)
		{
			v[i] = p[i];
		}
		
		for (uint d = 0; d < Nr; d++)
		{
			for(uint i = 0; i < Nw; i++)
				e[i] = (d % 4 == 0) ? (v[i] + ks[(d/4 * Nw) + i]) : v[i];
			for(uint j = 0; j < Nw/2; j++)
			{
				ulong[2] ft = MIX(d,j,e[2*j],e[2*j+1]);
				f[2*j] = ft[0];
				f[2*j+1] = ft[1];
			}
			for(uint i = 0; i < Nw; i++)
				v[i] = f[pi(i)];
		}

		for (uint i = 0; i < Nw; i++)
		{
			c[i] = v[i]+ks[Nr/4 * Nw + i];
		}
		return WordsToBytes(c);
	}
	
	ubyte[] InvCipher(ubyte[] C)
	in
	{
		if(K.length != C.length)
		{
			throw new BadBlockSizeException("Threefish key size must match the plaintext size.");
		}
	}
	body
	{
		ulong[] c = BytesToWords(C);
		
		ulong[] v = new ulong[Nw];
		ulong[] e = new ulong[Nw];
		ulong[] f = new ulong[Nw];
		ulong[] p = new ulong[Nw];
		
		for(uint i = 0; i < Nw; i++)
		{
			v[i] = c[i] - ks[Nr/4 * Nw + i];
		}
		
		for (int d = Nr - 1; d >= 0; d--)
		{
			for(uint i = 0; i < Nw; i++)
				f[pi(i)] = v[i];
			for(uint j = 0; j < Nw/2; j++)
			{
				ulong[2] et = INVMIX(d,j,f[2*j],f[2*j+1]);
				e[2*j] = et[0];
				e[2*j+1] = et[1];
			}
			for(uint i = 0; i < Nw; i++)
				v[i] = (d % 4 == 0) ? (e[i] - ks[(d/4 * Nw) + i]) : e[i];
		}
		
		for(uint i = 0; i < Nw; i++)
		{
			p[i] = v[i];
		}
		
		return WordsToBytes(p);
	}
	
	
	
	unittest
	{
		ubyte[]   K = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
		ubyte[16] T = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
		ubyte[]   P = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
		
		auto tf1 = new Threefish(K,T);
		
		auto tf1_res = tf1.Cipher(P);
		
		assert(tf1_res == [0x94,0xEE,0xEA,0x8B,0x1F,0x2A,0xDA,0x84,0xAD,0xF1,0x03,0x31,0x3E,0xAE,0x66,0x70,0x95,0x24,0x19,0xA1,0xF4,0xB1,0x6D,0x53,0xD8,0x3F,0x13,0xE6,0x3C,0x9F,0x6B,0x11]);
	}
}
