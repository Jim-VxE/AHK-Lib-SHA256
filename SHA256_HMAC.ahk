SHA256_HMAC( byref key, keyLen, byref message, messageLen ) {
	Static ptr, hex := "123456789abcdef"

	If !ptr
		ptr := A_PtrSize = 8 ? "Ptr" : "UInt"

	VarSetCapacity( keyPad, 64, 0 )

	If ( keyLen > 64 )
	{
		buffer := SHA256( key, keyLen )
		keyLen := StrLen( buffer ) / 2
		Loop %keyLen%
			NumPut( "0x" SubStr( buffer, A_Index * 2 - 1, 2 ), keyPad, A_Index - 1, "UChar" )
	}
	Else If ( keyLen > 0 )
		DllCall("RtlMoveMemory", ptr, &keyPad, ptr, &key, "UInt", keyLen )

	VarSetCapacity( buffer, messageLen + 64, 54 )

	If ( messageLen > 0 )
		DllCall("RtlMoveMemory", ptr, &buffer + 64, ptr, &message, "UInt", messageLen )

	Loop %keyLen%
		NumPut( NumGet( keyPad, A_Index - 1, "UChar" ) ^ 54, buffer, A_Index - 1, "UChar" )

	m := SHA256( buffer, 64 + messageLen )

	VarSetCapacity( buffer, 96, 92 )

	Loop %keyLen%
		NumPut( NumGet( keyPad, A_Index - 1, "UChar" ) ^ 92, buffer, A_Index - 1, "UChar" )

	Loop % StrLen( m ) / 2
		NumPut( "0x" SubStr( m, A_Index * 2 - 1, 2 ), buffer, A_Index + 63, "UChar" )

	Return SHA256( buffer, 96 )

}
