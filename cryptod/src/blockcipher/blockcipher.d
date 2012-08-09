module cryptod.blockcipher.blockcipher;

class BadBlockSizeException : Exception
{
	this(string msg)
	{
		super(msg);
	}
}

interface BlockCipher
{
	public:
	
	ubyte[] Cipher(ubyte[] P);
	ubyte[] InvCipher(ubyte[] C);
}