module cryptod.hash.hash;

interface HashContext
{
	void AddToContext(ubyte[]);
	void End();
	ubyte[] AsBytes();
	string AsString();
}