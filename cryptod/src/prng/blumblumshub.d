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


/// The type of bit output to use.
enum BIT_TYPE { EVEN, ODD , LEAST };

/**
 * The BlumBlumShub Pseudo random number generator.
 * 
 */
class BlumBlumShub : PRNG
{
	private:
	BIT_TYPE T;
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
	
	uint getBit()
	{
		if(T == BIT_TYPE.LEAST)
			return (xn % two).toInt();
		else if(T == BIT_TYPE.ODD)
		{
			
		}	
		assert(0);	
	}
	
	public:
	
	/**
	 * Sets p to rfc2412p1536, q to rfc5114p2048
	 * and the initial seed to rfc2412p768.
	 */
	this()
	{
		M = rfc2412p1536 * rfc5114p2048;
		xn = rfc2412p768;
		T = BIT_TYPE.LEAST;
	}
	
	/**
	 * Takes two BigInt prime numbers, p and q as input such that p = q = 3 mod 4
	 * and takes a BigInt initial seed.
	 */
	
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
		T = BIT_TYPE.LEAST;
	}
	
	/**
	 * Sets the bit type to use.
	 * BIT_TYPE.ODD is the odd bit parity
	 * BIT_TYPE.EVEN is the even bit parity
	 * BIT_TYPE.LEAST is the least significant bit and is default.
	 * NOT IMPLEMENTED YET.
	 */
	void setBitType(BIT_TYPE T)
	{
		this.T = T;
	}
	
	/**
	 * Gets the next integer from the computation 
	 * (note: each integer needs to run 32 rounds of the function
	 * making it exteremly computationaly expensive.)
	 */
	uint getNextInt()
	{
		uint r = 0;
		for(uint i = 0; i < 32; i++)
		{
			r <<= 1;
			r += getBit();
			nextxn();
		}
		return r;
	}
}	