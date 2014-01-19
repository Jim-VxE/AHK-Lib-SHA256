SHA256( byref data, bytes ) {
	Static ptr, m32 := 0xffffffff, k

	If !ptr
	{	; Do once: fill the k-constants static variable.
		ptr := A_PtrSize = "" ? "UInt" : "Ptr"
		block := "
		( ltrim join
			982f8a4291443771cffbc0b5a5dbb5e95bc25639f111f159a4823f92d55e1cab
			98aa07d8015b8312be853124c37d0c55745dbe72feb1de80a706dc9b74f19bc1
			c1699be48647beefc69dc10fcca10c246f2ce92daa84744adca9b05cda88f976
			52513e986dc631a8c82703b0c77f59bff30be0c64791a7d55163ca0667292914
			850ab72738211b2efc6d2c4d130d385354730a65bb0a6a762ec9c281852c7292
			a1e8bfa24b661aa8708b4bc2a3516cc719e892d1240699d685350ef470a06a10
			16c1a419086c371e4c774827b5bcb034b30c1c394aaad84e4fca9c5bf36f2e68
			ee828f746f63a5781478c8840802c78cfaffbe90eb6c50a4f7a3f9bef27871c6
		)"
		VarSetCapacity( k, 256, 0 )
		Loop 256
			NumPut( "0x" SubStr( block, A_Index * 2 - 1, 2 ), k, A_Index - 1, "UChar" )
	}

	_a := 0x6a09e667, _b := 0xbb67ae85, _c := 0x3c6ef372, _d := 0xa54ff53a
	_e := 0x510e527f, _f := 0x9b05688c, _g := 0x1f83d9ab, _h := 0x5be0cd19

	Loop % ( bytes + 72 ) // 64
	{
		i := A_Index * 64 - 64
		VarSetCapacity( block, 256, 0 )
		a := _a, b := _b, c := _c, d := _d, e := _e, f := _f, g := _g, h := _h
		
		If ( bytes < i + 64 )
		{
			If ( i < bytes )
				DllCall("RtlMoveMemory", ptr, &block, ptr, &data + i, "UInt", bytes - i )

			If ( i <= bytes )
				NumPut( 128, block, bytes - i, "UChar" )

			If ( bytes < i + 56 )
				Loop 8
					NumPut( (( bytes * 8 ) >> ( 64 - A_Index * 8 )) & 255, block, 55 + A_Index, "UChar" )
		}
		Else
			DllCall("RtlMoveMemory", ptr, &block, ptr, &data + i, "UInt", 64 )

		Loop 64
		{
			j := A_Index * 4 - 4

			If ( j < 64 )
			{
				w := NumGet( block, j, "UInt" )
				w := (( w >> 24 ) & 255 ) | (( w >> 8 ) & 65280 )
					| (( w & 65280 ) << 8 ) | (( w & 255 ) << 24 )
			}
			Else
			{
				sig1 := NumGet( block, j - 60, "UInt" )
				sig2 := NumGet( block, j - 8, "UInt" )
				sig1 := (( sig1 >> 7 ) | ( ( sig1 & 0x7f ) << 25 ))
					^ (( sig1 >> 18 ) | ( ( sig1 & 0x3ffff ) << 14 ))
					^ ( sig1 >> 3 )
				sig2 := (( sig2 >> 17 ) | ( ( sig2 & 0x1ffff ) << 15 ))
					^ (( sig2 >> 19 ) | ( ( sig2 & 0x7ffff ) << 13 ))
					^ ( sig2 >> 10 )
				sig3 := NumGet( block, j - 28, "UInt" ) + NumGet( block, j - 64, "UInt" )
				w := ( sig1 + sig2 + sig3 ) & m32
			}

			NumPut( w, block, j, "UInt" )
			j := NumGet( k, j, "Uint" )

			t2 := (((( a >> 2 ) | ( ( a & 0x3 ) << 30 ))
				^ (( a >> 13 ) | ( ( a & 0x1fff ) << 19 ))
				^ (( a >> 22 ) | ( ( a & 0x3fffff ) << 10 )) )
				+ ( ( a & b ) ^ ( a & c ) ^ ( b & c ) ) ) & m32

			t1 := (((( e >> 6 ) | ( ( e & 0x3f ) << 26 ))
				^ (( e >> 11 ) | ( ( e & 0x7ff ) << 21 ))
				^ (( e >> 25 ) | ( ( e & 0x1ffffff ) << 7 )) )
				+ ( ( e & f ) ^ ( (~e) & g ) ) + h + j + w ) & m32

			h := g, g := f, f := e, e := d + t1 & m32
			d := c, c := b, b := a, a := t1 + t2 & m32
		}

		_a := _a + a & m32, _b := _b + b & m32, _c := _c + c & m32, _d := _d + d & m32
		_e := _e + e & m32, _f := _f + f & m32, _g := _g + g & m32, _h := _h + h & m32
	}

	VarSetCapacity( block, 256, 0 )
	Loop 8
	{
		i := Chr( 96 + A_Index )
		Loop 8
		{
			j := ( _%i% >> ( 32 - A_Index * 4 ) ) & 15
			block .= Chr( ( j > 9 ? 87 : 48 ) + j )
		}
	}
	Return block
}
