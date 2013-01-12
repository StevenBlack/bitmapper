

IF TYPE("x")= "O"
	TRY
		x.Release()
	CATCH
	ENDTRY
ENDIF
RELEASE x
PUBLIC x

ACTIVATE WINDOW "Debug Output"
SET PROCEDURE TO Bitmapper ADDITIVE

_Screen.AddObject( "x", "My", 132, 255 )
x= _Screen.x
x.top= 30
x.left= 10
x.visible=.t.

***************************
DEFINE CLASS My AS CtrBit
***************************


*=================
FUNCTION Change()
*=================
DODEFAULT()
IF This.isInitialized
	DEBUGOUT This.iValue
ENDIF
RETURN

ENDDEFINE