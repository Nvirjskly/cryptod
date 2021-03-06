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

module cryptod.hash.ripemd160;

import std.format, std.array;

import cryptod.hash.hash;

private string makeR1 ()
{
	import std.conv;
	//string ret = "static immutable uint[80] r1 = ";
	uint[] r0 = [7, 4, 13, 1, 10, 6, 15, 3, 12, 0, 9, 5, 2, 14, 11, 8];
	string ret;
	ret ~= "static immutable uint[80] r1 = [";
	for(uint j = 0; j < 80; j++)
	{
		if (j < 16)
			ret ~= text(j);
		else if (j < 32)
			ret ~= text(r0[j%16]);
		else if (j < 48)
			ret ~= text(r0[r0[j%16]]);
		else if (j < 64)
			ret ~= text(r0[r0[r0[j%16]]]);
		else
			ret ~= text(r0[r0[r0[r0[j%16]]]]);
		if (j != 79)
			ret ~= ",";
		else
			ret ~= "];";
	}
	return ret;
}

private string makeR2 ()
{
	import std.conv;
	uint[] r0 = [7, 4, 13, 1, 10, 6, 15, 3, 12, 0, 9, 5, 2, 14, 11, 8];
	string ret;
	ret ~= "static immutable uint[80] r2 = [";
	uint pi(uint i) { return (9*i+5)%16; } 
	for(uint j = 0; j < 80; j++)
	{
		if (j < 16)
			ret ~= text(pi(j));
		else if (j < 32)
			ret ~= text(r0[pi(j%16)]);
		else if (j < 48)
			ret ~= text(r0[r0[pi(j%16)]]);
		else if (j < 64)
			ret ~= text(r0[r0[r0[pi(j%16)]]]);
		else
			ret ~= text(r0[r0[r0[r0[pi(j%16)]]]]);
		if (j != 79)
			ret ~= ",";
		else
			ret ~= "];";
	}
	return ret;
}

ubyte[] RIPEMD160s(string s)
{
	return RIPEMD160ub(cast(ubyte[]) s);
}
ubyte[] RIPEMD160ub(ubyte[] s)
{
	auto ct = new RIPEMD160Context();
	ct.AddToContext(s);
	ct.End();
	ubyte[] ret = ct.AsBytes();
	return ret;
}

class RIPEMD160Context : HashContext
{
	private:
	
	union words { ubyte[16*4] b; uint[16] i; }
	
	mixin(makeR1()); //compile time array initialisation;
	mixin(makeR2());
	
	static immutable uint K1[5] = [0x00000000, 0x5a827999, 0x6ed9eba1, 0x8f1bbcdc, 0xa953fd4e];
	
	static immutable uint K2[5] = [0x50a28be6, 0x5c4dd124, 0x6d703ef3, 0x7a6d76e9, 0x00000000];

	static immutable uint[80] S1 = [11,14,15,12,5,8,7,9,11,13,14,15,6,7,9,8,
	7,6,8,13,11,9,7,15,7,12,15,9,11,7,13,12,
	11,13,6,7,14,9,13,15,14,8,13,6,5,12,7,5,
	11,12,14,15,14,15,9,8,9,14,5,6,8,6,5,12,
	9,15,5,11,6,8,13,12,5,12,13,14,11,8,5,6];

	static immutable uint[80] S2 = [8,9,9,11,13,15,15,5,7,7,8,11,14,14,12,6,
	9,13,15,7,12,8,9,11,7,7,12,7,6,15,13,11,
	9,7,15,11,8,6,6,14,12,13,5,14,13,13,7,5,
	15,5,8,11,14,14,6,14,6,9,12,9,12,5,15,8,
	8,5,12,9,12,5,14,6,8,13,6,5,15,13,11,11];
	
	uint f(uint j, uint x, uint y, uint z)  @safe pure nothrow 
	{
		if(j < 16)
			return f1(x,y,z);
		else if (j < 32)
			return f2(x,y,z);
		else if (j < 48)
			return f3(x,y,z);
		else if (j < 64)
			return f4(x,y,z);
		else
			return f5(x,y,z);
	}
	
	uint f1(uint x, uint y, uint z) @safe pure nothrow
	{
		return x ^ y ^ z;
	}
	
	uint f2(uint x, uint y, uint z) @safe pure nothrow
	{
		return ( x & y ) | ( ~x & z );
	}
	
	uint f3(uint x, uint y, uint z) @safe pure nothrow
	{
		return ( x | ~y ) ^ z;
	}
	
	uint f4(uint x, uint y, uint z) @safe pure nothrow
	{
		return ( x & z ) | ( y & ~z );
	}
	
	uint f5(uint x, uint y, uint z) @safe pure nothrow
	{
		return x ^ ( y | ~z );
	}
	
	@safe pure uint ROTL(uint x, uint n) @safe pure nothrow
	{ return ( x << n ) | ( x >> ( 32-n ) ); }
	
	
	uint[5] H = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0];
	ubyte[] M;
	ulong messageLength;
	uint[16] X;
	words Xw;
	
	void PadMessage()
	{
		M ~= 0b10000000;

		M ~= new ubyte[(M.length>56)?(64-M.length+56):(56-(M.length % 64))];//more D-like
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
	
	void AddToHash(ubyte[] F)
	{
		for(uint i = 0; i < F.length/64; i++)
		{
			uint A1 = H[0]; uint B1 = H[1]; uint C1 = H[2]; uint D1 = H[3]; uint E1 = H[4];
			uint A2 = H[0]; uint B2 = H[1]; uint C2 = H[2]; uint D2 = H[3]; uint E2 = H[4];
			
			Xw.b = F[i*64..i*64+4*16]; //This is much faster :)
			X[] = Xw.i;
			
			uint T;
			for(uint j = 0; j < 80; j++) // might get improvements if I spread out the rounds
			{
				T = ROTL( A1 + f(j,B1,C1,D1) + X[r1[j]] + K1[j/16], S1[j] ) + E1;
				A1 = E1; E1 = D1; D1 = ROTL(C1, 10); C1 = B1; B1 = T;
				T = ROTL( A2 + f(79-j,B2,C2,D2) + X[r2[j]] + K2[j/16], S2[j] ) + E2;
				A2 = E2; E2 = D2; D2 = ROTL(C2, 10); C2 = B2; B2 = T;
			}
			T = H[1] + C1 + D2; H[1] = H[2] + D1 + E2; H[2] = H[3] + E1 + A2;
			H[3] = H[4] + A1 + B2; H[4] = H[0] + B1 + C2; H[0] = T;
		}
	}
	
	public:
	
	this()
	{
		messageLength = 0;
		M = [];
	}
	
	void AddToContext(string s)
	{
		AddToContext(cast(ubyte[])s);
	}
	
	void AddToContext(ubyte[] m)
	{
		messageLength += m.length;
		ubyte[] Z = M ~ m;
		ubyte[] F = Z[0..($-($%64))];
		M = Z[$-($%64)..$];
		
		if(F.length > 0)
			AddToHash(F);
	}
	
	void End()
	{
		PadMessage();
		AddToHash(M);
	}

	ubyte[] AsBytes()
	{
		return [(H[0])&0xff, (H[0]>>8)&0xff, (H[0]>>16)&0xff, (H[0]>>24)&0xff,
		(H[1])&0xff, (H[1]>>8)&0xff, (H[1]>>16)&0xff, (H[1]>>24)&0xff,
		(H[2])&0xff, (H[2]>>8)&0xff, (H[2]>>16)&0xff, (H[2]>>24)&0xff,
		(H[3])&0xff, (H[3]>>8)&0xff, (H[3]>>16)&0xff, (H[3]>>24)&0xff,
		(H[4])&0xff, (H[4]>>8)&0xff, (H[4]>>16)&0xff, (H[4]>>24)&0xff];
	}
	
	string AsString()
	{
		auto writer = appender!string();
		formattedWrite(writer, "%(%02x%)",AsBytes());
		return writer.data;
	}
}

unittest
{
	import std.stdio, std.format;
	
	string ths(ubyte[] h)
	{
		auto writer = appender!string();
		formattedWrite(writer, "%(%02x%)",h);
		return writer.data;
	}
	
	assert(ths(RIPEMD160s("")) == "9c1185a5c5e9fc54612808977ee8f548b2258d31");
	assert(ths(RIPEMD160s("a")) == "0bdc9d2d256b3ee9daae347be6f4dc835a467ffe");
	assert(ths(RIPEMD160s("abc")) == "8eb208f7e05d987a9b044a8e98c6b087f15a0bfc");
	assert(ths(RIPEMD160s("message digest")) == "5d0689ef49d2fae572b881b123a85ffa21595f36");
	assert(ths(RIPEMD160s("abcdefghijklmnopqrstuvwxyz")) == "f71c27109c692c1b56bbdceb5b9d2865b3708dbc");
	assert(ths(RIPEMD160s("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq")) == "12a053384a9c0c88e405a06c27dcf49ada62eb2b");
	assert(ths(RIPEMD160s("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")) == "b0e20b6e3116640286ed3a87a5713079b21f5189");
	
	auto rd0 = new RIPEMD160Context();
	for(uint i = 0; i < 8; i++)
		rd0.AddToContext("1234567890");
	rd0.End();
	assert(rd0.AsString() == "9b752e45573d4b39f4dbd3323cab82bf63326bfb");
	
	auto rd1 = new RIPEMD160Context();
	for(uint i = 0; i < 1_000_000; i++)
		rd1.AddToContext("a");
	rd1.End();
	assert(rd1.AsString() == "52783243c1697bdbe16d37f97f68f08325dc1528");
	
	string oneMilA = "";
	for(uint i = 0; i < 1_000_000; i++)
		oneMilA ~= "a";
	assert(ths(RIPEMD160s(oneMilA)) == "52783243c1697bdbe16d37f97f68f08325dc1528");
		
	writeln("RIPEMD160 unittest passed.");	
}