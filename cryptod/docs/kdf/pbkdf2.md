<h1>cryptod.kdf.pbkdf2</h1>

<b>Authors:</b><br>
Andrey A. Popov, andrey.anat.popov@gmail.com<br><br>

<dl><dt><big>ubyte[] <u>PBKDF2</u>(ubyte[] function(ubyte[], ubyte[]) <i>PRF</i>, string <i>P</i>, ubyte[] <i>S</i>, uint <i>c</i>, uint <i>dkLen</i>);
</big></dt>
<dd><b>Example:</b><br>
<pre class="d_code"> <font color=blue>import</font> cryptod.prf.hmac;
 <font color=blue>import</font> cryptod.hash.sha1;
 <font color=blue>import</font> std.stdio;

 <font color=blue>alias</font> hmac!(SHA1ub) HMAC_SHA1;

 <font color=blue>ubyte</font>[] key = <u>PBKDF2</u>(&amp;HMAC_SHA1, <font color=red>"password"</font>, [0x78,0x57,0x8E,0x5A,0x5D,0x63,0xCB,0x06], 1000, 16);

 writefln(<font color=red>"%(%02x%)"</font>,key);
</pre>
<br><br>

</dd>
</dl>