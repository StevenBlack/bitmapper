**********************************************************************
* Program....: BITMAPPER.PRG
* Version....:
* Author.....: Steven Black
* Date.......: 17 December 2012, 16:07:47
* Notice.....: Copyright © 2012, Steven Black Consulting
*              All Rights Reserved.
* Compiler...: Visual FoxPro 09.00.0000.7423 for Windows
* Abstract...:
* Parameters.:
* Called by..:
* Purpose....: Bitmap logic and display classes
**********************************************************************

*=======================================
DEFINE CLASS ctrBit AS Container
*=======================================
* Characteristics of all containers
BorderWidth = 0
Backstyle   = 0

* The controlclass to use to display/chage bits
cControlClass= "chkBit"

* Properties for the numeric state of the mapper
* The current aggregate state value
iValue      = 0

* Integer, which bits we're supporting
iWorkBits   = -1

*  Properties for the display of controls
*-- Optional object that will do layouts
oLayoutMgr= .NULL.

*-- Line height
nLineHeight = 20

*-- Captions on controls
DIMENSION aCaptions[32]

*-- Are we done init?
isInitialized= .f.

*==========================
FUNCTION Init( tiVal, tiDomain )
*==========================

*? For now...
This.aCaptions="Foo"

IF VARTYPE( tiDomain )= "N"
	This.iWorkBits= tiDomain
ENDIF
IF VARTYPE( tiVal )= "N"
	This.SetValue( tiVal )
ENDIF

RETURN

*==========================
FUNCTION SetValue( tiPassed )
*==========================
This.iValue= tiPassed
LOCAL loChk
FOR EACH loChk IN This.Objects
	IF loChk.BaseClass= "Checkbox"
		loChk.Value= BITTEST( tiPassed, loChk.iBindBit )
	ENDIF
ENDFOR
This.isInitialized= .T.

RETURN

*==========================
FUNCTION SelfConfig()
*==========================
LOCAL liWorkBits, lcName, loObj, llObjExists
liWorkBits= This.iWorkBits
FOR lni= 0 TO 31
	lcName= "chk"+ TRANSFORM( lni )
	llObjExists= TYPE( "This."+ lcName ) = "O"
	IF BITTEST( liWorkBits, lni )
		IF ! llObjExists
			This.AddObject( lcName, This.cControlClass, lni, this.aCaptions[ lni+ 1 ] )
			loObj= This.&lcName
			loObj.iBindBit= lni
			loObj.Visible= .T.
		ENDIF
	ELSE
		IF llObjExists
			This.RemoveObject( lcName )
		ENDIF
	ENDIF
ENDFOR
This.Layout()
RETURN

*==========================
FUNCTION Layout()
*==========================
IF ! ISNULL( This.oLayoutMgr )
	*? Implement
ELSE
	*-- Simple layout for now
	LOCAL lnHits, lnNewHeight
	lnHits= 0
	FOR EACH lo IN This.controls
		IF lo.baseClass= "Checkbox"
			lo.Top= lnHits* This.nLineHeight
			lo.Left= 0
			lnHits = lnHits + 1
		ENDIF
	ENDFOR
	This.height= MAX( This.height, (lnHits + 1) * this.nLineHeight )
ENDIF
RETURN

*==========================
FUNCTION Release()
*==========================
RELEASE This
RETURN

*==========================
FUNCTION iWorkBits_Assign( tiPassed )
*==========================
This.iWorkBits= tiPassed
This.SelfConfig()
RETURN

*==========================
FUNCTION Change
*==========================

ENDDEFINE



*=======================================
DEFINE CLASS chkBit AS Checkbox
*=======================================
iBindBit= -1   && In operation, between 0 and 31
FontSize= 12
Backstyle= 0

*==========================
FUNCTION Init( tnBit, tcCaption )
*==========================
IF VARTYPE( tnBit ) = "N"
	This.iBindBit= tnBit
ENDIF
IF VARTYPE( tcCaption ) = "C"
	This.Caption= tcCaption
ENDIF 
RETURN

*==========================
FUNCTION InteractiveChange()
*==========================
This.Change()
RETURN

*==========================
FUNCTION ProgrammaticChange()
*==========================
This.Change()
RETURN

*==========================
FUNCTION Change()
*==========================
IF !EMPTY( This.Value )
	This.Parent.iValue= BITSET( This.Parent.iValue, This.iBindBit )
ELSE
	This.Parent.iValue= BITCLEAR( This.Parent.iValue, This.iBindBit )
ENDIF
This.Refresh()
This.Parent.change()
RETURN

*==========================
FUNCTION Release()
*==========================
RELEASE This
RETURN

ENDDEFINE