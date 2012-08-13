// Written in the D programming language

/*	Copyright Andrey A Popov 2012
 * 
 *	Permission is hereby granted, free of charge, to any person or organization
 *	obtaining a copy of the software and accompanying documentation covered by
 *	this license (the "Software") to use, reproduce, display, distribute,
 *	execute, and transmit the Software, and to prepare derivative works of the
 *	Software, and to permit third-parties to whom the Software is furnished to
 *	do so, all subject to the following:
 *	
 *	The copyright notices in the Software and this entire statement, including
 *	the above license grant, this restriction and the following disclaimer,
 *	must be included in all copies of the Software, in whole or in part, and
 *	all derivative works of the Software, unless such copies or derivative
 *	works are solely in the form of machine-executable object code generated by
 *	a source language processor.
 *	
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 *	SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 *	FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 *	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *	DEALINGS IN THE SOFTWARE.
 */


/**
 * Authors: Andrey A. Popov, andrey.anat.popov@gmail.com
 */

//NOT FINISHED

//DOES NOT WORK AS OF YET, STILL SOME BUGS TO FIX

module cryptod.blockcipher.des;

import cryptod.blockcipher.blockcipher;

import std.stdio;

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
	
	immutable ubyte[] ETABLE = 		[32,1,2,3,4,5,
									4,5,6,7,8,9,
									8,9,10,11,12,13,
									12,13,14,15,16,17,
									16,17,18,19,20,21,
									20,21,22,23,24,25,
									24,25,26,27,28,29,
									28,29,30,31,32,1];
									
	immutable ubyte[] PTABLE = 		[16,7,20,21,29,12,28,17,
									1,15,23,26,5,18,31,10,
									2,8,24,14,32,27,3,9,
									19,13,30,6,22,11,4,25];
									
	immutable ubyte[] PC1LTABLE =	[57,49,41,33,25,17,9,
									1,58,50,42,34,26,18,
									10,2,59,51,43,35,27,
									19,11,3,60,52,44,36];
	
	immutable ubyte[] PC1RTABLE =	[63,55,47,39,31,23,15,
									7,62,54,46,38,30,22,
									14,6,61,53,45,37,29,
									21,13,5,28,20,12,4];
	
	immutable ubyte[] PC2TABLE =	[14,17,11,24,1,5,3,28,
									15,6,21,10,23,19,12,4,
									26,8,16,7,27,20,13,2,
									41,52,31,37,47,55,30,40,
									51,45,33,48,44,49,39,56,
									34,53,46,42,50,36,29,32];
									
	immutable ubyte[] S1 =			[14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7,
									0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8,
									4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0,
									15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13];
	
	immutable ubyte[] S2 =			[15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10,
									3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5,
									0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15,
									13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9];
									
	immutable ubyte[] S3 =			[10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8,
									13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1,
									13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7,
									1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12];
	
	immutable ubyte[] S4 =			[7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15,
									1,13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9,
									10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4,
									3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14];
	
	immutable ubyte[] S5 =			[2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9,
									14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6,
									4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14,
									11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3];

	immutable ubyte[] S6 =			[12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11,
									10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8,
									9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6,
									4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13];

	immutable ubyte[] S7 =			[4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1,
									13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6,
									1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2,
									6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12];
	
	immutable ubyte[] S8 =			[13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7,
									1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2,
									7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8,
									2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11];
	
	immutable ubyte[][] SBOX = [S1,S2,S3,S4,S5,S6,S7,S8];
	
	
	ubyte[8] Key;
	ulong[16] K;
	
	pure ulong IP(ulong B)
	{
		ulong C = 0;
		
		for(uint i = 0; i < IPTABLE.length; i++)
			C+=((B>>(IPTABLE[i]-1))&0x1)<<i;
		
		return C;
	}
	
	pure ulong INVIP(ulong C)
	{
		ulong B = 0;
		
		for(uint i = 0; i < INVIPTABLE.length; i++)
			B+=((C>>(INVIPTABLE[i]-1))&0x1)<<i;
		
		return B;
	}
	
	pure ulong E(uint H)
	{
		ulong G = 0;
		
		for(uint i = 0; i < ETABLE.length; i++)
			G+=((H>>(ETABLE[i]-1))&0x1)<<i;
		
		return G;
	}
	
	pure uint P(ulong H)
	{
		uint G = 0;
		
		for(uint i = 0; i < PTABLE.length; i++)
			G+=((H>>(PTABLE[i]-1))&0x1)<<i;
		
		return G;
	}
	
	pure uint PC1L(uint H)
	{
		uint G = 0;
		
		for(uint i = 0; i < PC1LTABLE.length; i++)
			G+=((H>>(PC1LTABLE[i]-1))&0x1)<<i;
		
		return G;
	}
	
	pure uint PC1R(uint H)
	{
		uint G = 0;
		
		for(uint i = 0; i < PC1RTABLE.length; i++)
			G+=((H>>(PC1RTABLE[i]-1))&0x1)<<i;
		
		return G;
	}
	
	
	pure uint PC2(ulong H)
	{
		uint G = 0;
		
		for(uint i = 0; i < PC2TABLE.length; i++)
			G+=((H>>(PC2TABLE[i]-1))&0x1)<<i;
		
		return G;
	}
	
	pure ulong ROTL(ulong a, uint n)
	{
		return 1;
	}
	
	
	void KS(ubyte[] Key)
	{
		//uint C = PC1L(cast(ulong)Key);
		//uint D = PC1R(cast(ulong)Key);
		uint C = PC1L(cast(uint)(Key[0])+cast(uint)(Key[1])<<8+cast(uint)(Key[2])<<16+cast(uint)(Key[3])<<24);
		uint D = PC1R(cast(uint)(Key[4])+cast(uint)(Key[5])<<8+cast(uint)(Key[6])<<16+cast(uint)(Key[7])<<24);
		
		for(uint i = 0; i < 16; i++)
		{
			//writeln(C);
			uint n = (i == 0 || i == 1 || i == 8 || i == 15) ? 1 : 2;
			C = leftShift(C,n);
			D = leftShift(D,n);
			ulong Kt = 0;
			Kt = C;
			Kt = Kt << 28;
			Kt+= D;
			K[i] = PC2(Kt);
			//writeln(K[i]);
		}
	}
	
	pure uint leftShift(uint x, uint n)
	{
		return ((x <<  n) | (x >> (28-n))) &0x0fffffff;//& 0b0000111111111111111111111111;

	}
	
	uint f(uint R, uint n)
	{
		ulong B = K[n] ^ E(R);
		uint S = 0;
		for(uint i = 0; i < 8; i++)
		{
			//row is ((B>>(6*i+4))&2)+((B>>6*i)&1)
			//column is ((B>>(6*i+1))&0b1111)
			//so it's row * 16 + column
			S+=SBOX[i][(((B>>(6*i+4))&0b10)+((B>>(6*i))&0b1))*16+((B>>(6*i+1))&0b1111)]<<(4*i);
		}
		//writeln(P(S));
		return P(S);
	}
	
	public:
	
	this(ubyte[] Key)
	in
	{
		if(Key.length != 8)
			throw new BadBlockSizeException("");	
	}
	body
	{
		this.Key = Key;
		KS(Key);
		
		writeln("got here");
	}
	
	@property uint blockSize()
	{
		return 8;
	}
	
	ubyte[] Cipher(ubyte[] T)
	in
	{
		if(T.length != 8)
			throw new BadBlockSizeException("The input to DES must be 8 bytes long.");
	}
	body
	{
		//(cast(ulong)T[7])<<56;
		ulong Ia = (cast(ulong)T[4])<<32+(cast(ulong)T[5])<<40+(cast(ulong)T[6])<<48+(cast(ulong)T[7])<<56;
		ulong I = IP(T[0]+T[1]<<8+T[2]<<16+T[3]<<24+Ia);
		writefln("I%x", I);
		uint L = I & 0xffff;
		uint R = I >> 32 & 0xffff;
		
		for(uint i = 0; i < 16; i++)
		{
			uint temp = R;
			R = L ^ f(R,i);
			L = temp;
		}
		ulong RL = R;
		RL = RL << 32;
		RL += L;
		
		RL = INVIP(RL);
		
		writeln("got here");
		//writefln("%x",RL);
		writefln("%x",INVIP(RL));
		//ubyte[8] ret = ((cast(ubyte*)&RL)[0..8]);
		//return ((cast(ubyte[])RL)[0..8]);
		ubyte[] ret;
		for(uint i = 0; i < 8; i++)
			ret ~= (RL>>(i*8))&0xFF;
		
		return ret;
	}
	ubyte[] InvCipher(ubyte[] T)
	{
		ulong Ia = (cast(ulong)T[4])<<32+(cast(ulong)T[5])<<40+(cast(ulong)T[6])<<48+(cast(ulong)T[7])<<56;
		ulong I = INVIP(T[0]+T[1]<<8+T[2]<<16+T[3]<<24+Ia);
		writefln("I%x", I);
		uint L = I & 0xffff;
		uint R = I >> 32 & 0xffff;
		
		for(uint i = 15; i != 0; i--)
		{
			uint temp = L;
			L = L ^ f(R,i);
			R = temp;
		}
		ulong LR = L;
		LR = LR << 32;
		LR += R;
		
		LR = IP(LR);
		
		ubyte[] ret;
		for(uint i = 0; i < 8; i++)
			ret ~= (LR>>(i*8))&0xFF;
		
		return ret;
	}
	
	
}