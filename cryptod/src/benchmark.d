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

import cryptod.blockcipher.blowfish;

import cryptod.blockcipher.threefish;

import cryptod.blockcipher.aes;

import cryptod.hash.murmurhash3;

import cryptod.hash.sha1;

import cryptod.hash.md2;

import cryptod.prng.mersennetwister;

import cryptod.prng.blumblumshub;

import cryptod.primes.primes;

import std.datetime, std.stdio, std.random, std.conv, std.bigint;


void benchmark_murmur3()
{
	string input = "";
	
	uint numtimes = 0x10000;
	
	uint strLen = 1024;
	
	for(uint i = 0; i < strLen; i++)
		input ~= text(uniform(0,0xf));
	
	auto timer = StopWatch(AutoStart.yes);
	
	
	
	for(uint i = 0; i < numtimes; i++)
	{
		//murmurhash3_x86_32((cast(ubyte*)&i)[0..4],i);
		murmurhash3_x86_32(input,i);
	}
	writefln("%s murmurhash3_x86_32 in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((strLen*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
	
	
	timer.reset();
	
	for(uint i = 0; i < numtimes; i++)
	{
		//murmurhash3_x86_128((cast(ubyte*)&i)[0..4],i);
		murmurhash3_x86_128(input,i);
	}
	writefln("%s murmurhash3_x86_128 in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((strLen*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
	
	timer.reset();
	
	for(uint i = 0; i < numtimes; i++)
	{
		//murmurhash3_x64_128((cast(ubyte*)&i)[0..4],i);
		murmurhash3_x64_128(input,i);
	}
	writefln("%s murmurhash3_x64_128 in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((strLen*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
}

void benchmark_sha1()
{
	SHA1Context shc = new SHA1Context();
	
	string input = "";
	
	uint numtimes = 0x1000;
	
	uint strLen = 1024;
	
	for(uint i = 0; i < strLen; i++)
		input ~= text(uniform(0,0xf));
	
	auto timer = StopWatch(AutoStart.yes);
	
	for(uint i = 0; i<numtimes; i++)
	{
		shc.AddToContext(input);
	}	
	shc.End();
	
	writefln("%s sha1 in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((strLen*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
}

void benchmark_md2()
{
	auto md2 = new MD2Context();
	
	string input = "";
	
	uint numtimes = 0x1000;
	
	uint strLen = 1024;
	
	for(uint i = 0; i < strLen; i++)
		input ~= text(uniform(0,0xf));
	
	auto timer = StopWatch(AutoStart.yes);
	
	for(uint i = 0; i<numtimes; i++)
	{
		md2.AddToContext(input);
	}	
	md2.End();
	
	writefln("%s md2 in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((strLen*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
}

void benchmark_mersenne()
{
	uint numtimes = 0x1000000;
	
	MersenneTwister mt = new MersenneTwister([0x123, 0x234, 0x345, 0x456]);
	
	auto timer = StopWatch(AutoStart.yes);
	
	for(uint i = 0; i<numtimes; i++)
		mt.getNextInt();
		
	writefln("%s ints generated by mersenne twister in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((4*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
}

void benchmark_bbs()
{
	uint numtimes = 0x100;
	
	string seedString = "";
	
	for(uint i = 0; i < 1024; i++)
		seedString ~= uniform(0,0xf);
	
	BlumBlumShub bbs = new BlumBlumShub(rfc2412p1536,rfc5114p2048,BigInt(seedString));
	
	auto timer = StopWatch(AutoStart.yes);
	
	for(uint i = 0; i<numtimes; i++)
		bbs.getNextInt();
		
	writefln("%s ints generated by BlumBlumShub in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((4*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
}

void benchmark_blowfish()
{
	Blowfish blow = new Blowfish([0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8]);
	
	uint numtimes = 0x100000;
	
	auto timer = StopWatch(AutoStart.yes);
	
	for(uint i = 0; i<numtimes; i++)
		blow.Cipher([i,i+1]);
	
	writefln("%s texts blowfish encrypted in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((8*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
}

void benchmark_threefish()
{
	ubyte[32] key = [0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0x10,0x11,0x12,0x13,0x14,0x15,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8];
	ubyte[16] T = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	Threefish three = new Threefish(key,T);
	
	uint numtimes = 0x10000;
	
	auto timer = StopWatch(AutoStart.yes);
	
	for(uint i = 0; i<numtimes; i++)
		three.Cipher([i&0xff,(i>>1)&0xff,(i>>2)&0xff,(i>>3)&0xff,(i>>4)&0xff,(i>>5)&0xff,(i>>6)&0xff,(i>>7)&0xff,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u,0u]);
	
	writefln("%s texts threefish encrypted in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((32*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
}

void benchmark_aes()
{
	AES a = new AES([0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0x10,0x11,0x12,0x13,0x14,0x15]);
	
	uint numtimes = 0x20000;
	
	auto timer = StopWatch(AutoStart.yes);
	
	for(uint i = 0; i<numtimes; i++)
		a.Cipher([i&0xff,(i>>1)&0xff,(i>>2)&0xff,(i>>3)&0xff,(i>>4)&0xff,(i>>5)&0xff,(i>>6)&0xff,(i>>7)&0xff]~[0u,0u,0u,0u,0u,0u,0u,0u]);
	
	writefln("%s texts aes128 encrypted in %s milliseconds: %s MB/s", numtimes,timer.peek.msecs,((16*cast(float)numtimes)/(1024 * 1024))/((cast(float)timer.peek.msecs)/1000));
}

void main()
{
	import cryptod.blockcipher.aes;
	import cryptod.prf.hmac;
	import cryptod.hash.sha1;
	import cryptod.kdf.pbkdf2;
	import cryptod.prng.mersennetwister;
	import std.datetime;
	
	ulong t = Clock.currTime().stdTime();
	
	//makes a seed from the current time
	uint[] seed = [(t&0xffff),(t>>1)&0xffff,(t>>2)&0xffff,(t>>3)&0xffff,(t>>4)&0xffff,(t>>5)&0xffff,(t>>6)&0xffff,(t>>7)&0xffff
	,(t>>8)&0xffff,(t>>9)&0xffff,(t>>10)&0xffff,(t>>11)&0xffff,(t>>12)&0xffff,(t>>13)&0xffff,(t>>14)&0xffff,(t>>15)&0xffff];
	
	//seeds a MersenneTwister
	MersenneTwister mt = new MersenneTwister(seed);
	
	//Generates a random salt (ideally this would be stored in a database after generating.
	ubyte[] salt = [(mt.getNextInt()&0xff),(mt.getNextInt())&0xff,(mt.getNextInt())&0xff,(mt.getNextInt())&0xff,
	(mt.getNextInt())&0xff,(mt.getNextInt())&0xff,(mt.getNextInt())&0xff,(mt.getNextInt())&0xff,(mt.getNextInt())&0xff];
	
	//This constructs an hmac out of a sha1 function.
	alias hmac!(SHA1ub) HMAC_SHA1; 
	
	//This generates a 128-bit key from the password "password" using a 10,000 iteration PBKDF2 function.
	ubyte[] key = PBKDF2(&HMAC_SHA1, "password", salt, 10000, 16); 
	
	//Creates a new AES context for the generated key.
	AES aes = new AES(key);
	
	//converts a 16 byte input to a ubyte array
	ubyte[] input = cast(ubyte[])"A 16-byte input.";
	
	//Enciphers the input
	ubyte[] enciphered = aes.Cipher(input);
	
	//Deciphers the enciphered output
	ubyte[] deciphered = aes.InvCipher(enciphered);
	
	assert(input == deciphered);
	
	benchmark_murmur3();
	benchmark_md2();
	benchmark_sha1();
	benchmark_mersenne();
	benchmark_bbs();
	benchmark_blowfish();
	benchmark_threefish();
	benchmark_aes();
}