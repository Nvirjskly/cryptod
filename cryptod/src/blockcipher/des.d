//NOT FINISHED

module cryptod.blockcipher.des;

import cryptod.blockcipher.blockcipher;

class DES : BlockCipher
{
	private:
	
	immutable ubyte[] IPTABLE = 	[58,50,42,34,26,18,10,2,
									60,52,44,36,28,20,12,4,
									62,54,46,38,30,22,14,6,
									64,56,48,40,32,24,16,8,
									57,49,41,33,25,17,9,1,
									59,51,43,35,27,19,11,3,
									61,53,45,37,29,21,13,5,
									63,55,47,39,31,23,15,7];
								
	immutable ubyte[] INVIPTABLE = 	[40,8,48,16,56,24,64,32,
									39,7,47,15,55,23,63,31,
									38,6,46,14,54,22,62,30,
									37,5,45,13,53,21,61,29,
									36,4,44,12,52,20,60,28,
									35,3,43,11,51,19,59,27,
									34,2,42,10,50,18,58,26,
									33,1,41,9,49,17,57,25];						
	
	immutable ubyte[] EXPTABLE = 	[32,1,2,3,4,5,
									4,5,6,7,8,9,
									8,9,10,11,12,13,
									12,13,14,15,16,17,
									16,17,18,19,20,21,
									20,21,22,23,24,25,
									24,25,26,27,28,29,
									28,29,30,31,32,1];
	
	ubyte[8] Key;
	ulong[16] K;
	
	pure ulong IP(ulong B)
	{
		ulong C = 0;
		
		for(uint i = 0; i < 64; i++)
			C+=((B>>(IPTABLE[i]-1))&0x1)<<(IPTABLE[i]-1);
		
		return C;
	}
	
	pure ulong INVIP(ulong C)
	{
		ulong B = 0;
		
		for(uint i = 0; i < 64; i++)
			B+=((C>>(INVIPTABLE[i]-1))&0x1)<<(INVIPTABLE[i]-1);
		
		return B;
	}
	
	pure ulong E(uint H)
	{
		ulong G = 0;
		
		for(uint i = 0; i < 48; i++)
			G+=((H>>(EXPTABLE[i]-1))&0x1)<<(EXPTABLE[i]-1);
		
		return G;
	}
	
	pure ulong KS(uint n, ubyte[] Key)
	{
		
		
		return 1;
	}
	
	public:
	
	this(ubyte[] Key)
	in
	{
		if(Key.length != 7)
			throw new BadBlockSizeException("");
	}
	body
	{
		this.Key = Key;
	}
	
	ubyte[] Cipher(ubyte[] P)
	in
	{
		if(P.length != 8)
			throw new BadBlockSizeException("The input to DES must be 8 bytes long.");
	}
	body
	{
		ulong I = IP(cast(ulong)P);
		uint L = I & 0xffff;
		uint R = I >> 32 & 0xffff;
		
		//uint Lp = 
		
		return P;
	}
	ubyte[] InvCipher(ubyte[] C)
	{
		return C;
	}
	
	
}