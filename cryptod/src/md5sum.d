/*import cryptod.hash.md5;
import std.file, std.array, std.stdio, std.parallelism, core.cpuid, std.regex, std.path, std.conv, std.datetime;

bool[string] flags;

struct file
{
	string baseDir;
	string name;
	this(string a, string b)
	{baseDir=a;name=b;}
}

void main(string[] args)
{
	args.popFront();
	//read args
	while(args.length != 0 && args.front().front()=='-')
	{
		args.front().popFront();
		flags[args.front()] = true;
		
		
		args.popFront();
	}
	//writeln(flags);
	file[] files;
	uint maxLength = 0;
	void addDirToFiles(string dir)
	{
		foreach (string name; dirEntries(dir, SpanMode.breadth))
		{
			if(name.isFile())
			{
				if(name.length > maxLength)
					maxLength = name.length;
				files ~= file(dir,name[dir.length..name.length]);
			}
		}
	}
	if(("r" in flags) !is null)
	{
		foreach(arg; args)
		{
			addDirToFiles(arg);
		}
		if(args.length==0)
		{
			addDirToFiles(".");
		}
	} //else
		//files = args;
	auto timer = StopWatch(AutoStart.yes);
	ulong numbytes = 0;
	//foreach(arg; taskPool.parallel(files, files.length/2))
	foreach(arg; files)
	{
			//writeln(arg.baseDir~arg.name);
			auto f = File(arg.baseDir~arg.name, "r");
			auto md5 = new MD5Context();
			foreach (ubyte[] buffer; f.byChunk(0xffff))
			{
				md5.AddToContext(buffer);
				numbytes+=buffer.length;
			}
			md5.End();
			if(to!string(arg.name.front())==dirSeparator)
				arg.name.popFront();
			string print = "";	
			print ~= arg.name~" ";
			for(uint i = 0; i < maxLength-(arg.baseDir.length+arg.name.length);i++)
				print~=" ";
			print~=md5.AsString();
			writeln(print);
			try{
			f.close();}catch(Exception e){}
	}
	ulong time = timer.peek.msecs;
	writefln("%sMB/s",(numbytes/(1024.0*1024))/(time/1000.0));
}*/