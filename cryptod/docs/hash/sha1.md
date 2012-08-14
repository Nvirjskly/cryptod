<h1>cryptod.hash.sha1</h1>

<b>Authors:</b><br>
Andrey A. Popov, andrey.anat.popov@gmail.com<br><br>

<dl><dt><big>ubyte[] <u>SHA1s</u>(string <i>s</i>);
</big></dt>
<dd>SHA1 function that uses the SHA1 context and takes a simple string argument.<br><br>

</dd>
<dt><big>ubyte[] <u>SHA1ub</u>(ubyte[] <i>s</i>);
</big></dt>
<dd>SHA1 function that uses the SHA1 context and takes a simple ubyte[] argument.<br><br>

</dd>
<dt><big>class <u>SHA1Context</u>: cryptod.hash.hash.HashContext;
</big></dt>
<dd>The SHA1 hash according to specification;
 Takes a byte array and converts it into a 128-bit hash.
 It does not yet support streaming hashes of extremely long messages.<br><br>

</dd>
</dl>