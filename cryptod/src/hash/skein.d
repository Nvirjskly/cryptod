module cryptod.hash.skein;

import cryptod.hash.hash;

/**
 * The Skein Hash Family or is it the whole one...
 *
 */
class SkeinContext : HashContext
{	
	const ubyte treelevelbits = 0x7f;
	const ubyte bitpadbit     = 0x80;
	const ubyte typebits      = 0x3f;
	const ubyte firstbit      = 0x40;
	const ubyte finalbit      = 0x80;
	

	void UBI(ubyte[] G, ubyte[] M, ubyte[16] Ts)
	{
		/**
		 * Ts description:
		 * first 12 bytes are the position
		 * next two bytes are reserved MUST BE ZERO
		 * next bit contains the treelevel and the pitpad
		 * final bit is the type,firstbit, and lastbit.
		 */ 
		 
		ubyte treelevel = Ts[14] & treelevelbits;
		bool  pad       = (Ts[14] & bitpadbit) > 0;
		ubyte type      = Ts[15] & typebits;
		bool  firstSet  = (Ts[15] & firstbit) > 0;
		bool  finalSet  = (Ts[15] & finalbit) > 0;	
		
		ulong Nb = G.length;
		ulong Nm = M.length;
		
		ulong p = (Nm == 0) ? Nb : Nb - (Nm % Nb);
		
		for (ulong i = 0; i < p; i++)
			M ~= 0x00;
			
		ubyte[] Mb;
		 
		
		
		//ulong pmax = 
		
	}


	this()
	{
	
	}
	void AddToContext(ubyte[] m)
	{
		
	}
	void End()
	{
	
	}
	ubyte[] AsBytes()
	{
		return [];
	}
	string AsString()
	{
		return "";
	}
}
