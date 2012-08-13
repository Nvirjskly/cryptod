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

module cryptod.prng.blumblumshub;

import cryptod.primes.primes;

import cryptod.prng.prng;

import std.bigint; //Might want to implement a home-grown bigint class in order to not rely on std and maybe be faster.

/**
 * BBS input must be primes p, q and a number seed such that
 * p = q = 3 mod 4 and p, q, and seed are coprime.
 */

class BlumBlumShub : PRNG
{
	private:
	BigInt M;
	BigInt xn;
	BigInt one = BigInt(1);
	BigInt two = BigInt(2);
	BigInt modPow(BigInt x, BigInt e, BigInt m)
	{
		BigInt r = 1;
		
		while (e > 0)
		{
			if(e % two == one)
			{
				r = (r*x)%m;
			}
			e = e>>1;
			x = (x*x)%m;
		}
		return r;
	}
	void nextxn()
	{
		xn = modPow(xn,two,M);
	}
	
	public:
	
	this()
	{
		M = rfc2412p1536 * rfc5114p2048;
		xn = rfc2412p768;
	}
	
	this(BigInt p, BigInt q, BigInt seed)
	in
	{
		if(p % 4 != 3 || q % 4 != 3)
		{
			throw new Exception("p and q must be congruent to 3 mod 4");
		}
		if(seed % p == 0 || seed % q == 0)
		{
			throw new Exception("the seed must be coprime with p and q");
		}
	}
	body
	{
		M = p*q;
		xn = seed;
	}
	
	uint getNextInt()
	{
		uint r = 0;
		for(uint i = 0; i < 32; i++)
		{
			r <<= 1;
			r += (xn % two).toInt();
			nextxn();
		}
		return r;
	}
	
}	