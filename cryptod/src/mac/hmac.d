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

module cryptod.mac.hmac;

import cryptod.hash.sha1;
import cryptod.hash.md5;

//This constructs an hmac out of a sha1 function.
alias hmac!(SHA1ub) HMAC_SHA1; 
alias hmac!(MD5ub) HMAC_MD5;

/**
 * HMAC
 */
ubyte[] hmac(alias hash)(ubyte[] key, ubyte[] message)
{
	uint blocksize = hash([]).length;
	if(key.length > blocksize)
		key = hash(key);
	if(key.length < blocksize)
		key ~= new ubyte[blocksize - key.length];
			
	ubyte[] o_key_pad = new ubyte[key.length];
	ubyte[] i_key_pad = new ubyte[key.length];
	
	o_key_pad[] = 0x5c ^ key[];
	i_key_pad[] = 0x36 ^ key[];
	
	return hash(o_key_pad ~ hash(i_key_pad ~ message));
}