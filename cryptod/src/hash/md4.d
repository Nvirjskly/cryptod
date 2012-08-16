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

module cryptod.hash.md4;

import std.string, std.format, std.array;

import cryptod.hash.hash;

class MD4Context
{
	private:
	ubyte[] M;
	uint[16] X;
	ulong messageLength;
	uint A, AA;
	uint B, BB;
	uint C, CC;
	uint D, DD;
	
	@safe pure uint ROTL(uint x, uint n)
	{ return ( x << n ) | ( x >> ( 32-n ) ); }
	
	@safe pure uint F(uint x, uint y, uint z)
	{
		return ( ( x & y ) | ( ( ~x ) & z ) );
	}

	@safe pure uint G(uint x, uint y, uint z)
	{
		return ( ( x & y ) | ( x & z ) | ( y & z ) );
	}
	
	@safe pure uint H(uint x, uint y, uint z)
	{
		return ( x ^ y ^ z );
	}
	
	void round1(ref uint a, uint b, uint c, uint d, uint x, uint s)
	{
		a += F(b,c,d) + X[x];
		a = ROTL(a,s);
	}
	
	void round2(ref uint a, uint b, uint c, uint d, uint x, uint s)
	{
		a += G(b,c,d) + X[x] + 0x5a827999;
		a = ROTL(a,s);
	}
	
	void round3(ref uint a, uint b, uint c, uint d, uint x, uint s)
	{
		a += H(b,c,d) + X[x] + 0x6ed9eba1;
		a = ROTL(a,s);
	}
	
	void PadMessage()
	{
		M ~= 0b10000000;
		while(M.length % 64 != 56)
		{
			M ~= 0;
		}
		PadLength();
	}
	//Pads the message with the message length as too spec. Lowest order bits first.
	void PadLength()
	{
		messageLength *= 8; //converts byte length to bits. I'm not sure that supporting bit adding to digests is a good idea performance-wise.
		M ~= [messageLength & 0xff, (messageLength >> 8) & 0xff, (messageLength >> 16) & 0xff,
		(messageLength >> 24) & 0xff, (messageLength >> 32) & 0xff, (messageLength >> 40) & 0xff,
		(messageLength >> 48) & 0xff, (messageLength >> 56) & 0xff];
	}
	
	public:
	this()
	{
		M = [];
		messageLength = 0;
		A = 0x67452301;//Magic constants voodoo
		B = 0xefcdab89;//This one calls Cthulu
		C = 0x98badcfe;//This one is the One Ring
		D = 0x10325476;//This one is literally Hitler
	}
	
	ubyte[] naiveTest(ubyte[] m)
	{
		M = m;
		messageLength += m.length;
		PadMessage();
		for(uint i = 0; i < M.length/64; i++)
		{
			for(uint j = 0; j < 16; j++)
			{
				ubyte[4] w = M[i*64+4*j..i*64+4*j+4];
				X[j] = w[0] + (w[1]<<8)+(w[2]<<16)+(w[3]<<24);
			}
			
			AA = A;
			BB = B;
			CC = C;
			DD = D;
			
			round1(A, B, C, D,  0,  3);  round1(D, A, B, C,  1,  7);  round1(C, D, A, B,  2, 11);  round1(B, C, D, A,  3, 19);
			round1(A, B, C, D,  4,  3);  round1(D, A, B, C,  5,  7);  round1(C, D, A, B,  6, 11);  round1(B, C, D, A,  7, 19);
			round1(A, B, C, D,  8,  3);  round1(D, A, B, C,  9,  7);  round1(C, D, A, B, 10, 11);  round1(B, C, D, A, 11, 19);
			round1(A, B, C, D, 12,  3);  round1(D, A, B, C, 13,  7);  round1(C, D, A, B, 14, 11);  round1(B, C, D, A, 15, 19);
			
			round2(A, B, C, D,  0,  3);  round2(D, A, B, C,  4,  5);  round2(C, D, A, B,  8,  9);  round2(B, C, D, A, 12, 13);
			round2(A, B, C, D,  1,  3);  round2(D, A, B, C,  5,  5);  round2(C, D, A, B,  9,  9);  round2(B, C, D, A, 13, 13);
			round2(A, B, C, D,  2,  3);  round2(D, A, B, C,  6,  5);  round2(C, D, A, B, 10,  9);  round2(B, C, D, A, 14, 13);
			round2(A, B, C, D,  3,  3);  round2(D, A, B, C,  7,  5);  round2(C, D, A, B, 11,  9);  round2(B, C, D, A, 15, 13);
			
			round3(A, B, C, D,  0,  3);  round3(D, A, B, C,  8,  9);  round3(C, D, A, B,  4, 11);  round3(B, C, D, A, 12, 15);
			round3(A, B, C, D,  2,  3);  round3(D, A, B, C, 10,  9);  round3(C, D, A, B,  6, 11);  round3(B, C, D, A, 14, 15);
			round3(A, B, C, D,  1,  3);  round3(D, A, B, C,  9,  9);  round3(C, D, A, B,  5, 11);  round3(B, C, D, A, 13, 15);
			round3(A, B, C, D,  3,  3);  round3(D, A, B, C, 11,  9);  round3(C, D, A, B,  7, 11);  round3(B, C, D, A, 15, 15);
			
			A += AA;
			B += BB;
			C += CC;
			D += DD;
		}
		
		return [(A)&0xff, (A>>8)&0xff, (A>>16)&0xff, (A>>24)&0xff,
		(B)&0xff, (B>>8)&0xff, (B>>16)&0xff, (B>>24)&0xff,
		(C)&0xff, (C>>8)&0xff, (C>>16)&0xff, (C>>24)&0xff,
		(D)&0xff, (D>>8)&0xff, (D>>16)&0xff, (D>>24)&0xff];
	}
}

unittest
{
	import std.stdio;
	auto md4 = new MD4Context();
	writefln("%(%02x%)",md4.naiveTest(cast(ubyte[])""));
}