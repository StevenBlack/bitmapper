**********************************************************************
* Program....: BITMAPPER.PRG
* Version....:
* Author.....: Steven Black
* Date.......: 17 December 2012, 16:07:47
* Notice.....: Copyright © 2012-2013, Steven Black Consulting
*              MIT License http://stevenblack.com/MIT-License
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

* The table where the bits, labels and Sequences are kept
lLoadFromBitTable= .F.
cBitTable= "bit"
cCaptionCase= "proper"

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

IF EMPTY( this.cBitTable ) OR ( NOT FILE( FORCEEXT( this.cBitTable, "dbf" )) AND NOT USED( this.cBitTable ) )
	This.lLoadFromBitTable= .F.
ENDIF

*? For now...
This.aCaptions="caption undefined"

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
FUNCTION Empty()
*==========================
LOCAL lni
FOR lni= This.Objects.Count TO 1 STEP -1
	IF LOWER( This.Objects( lni ).Class ) = LOWER( This.cControlClass )
		This.Objects( lni ).Release()
	ENDIF
ENDFOR
RETURN


*==========================
FUNCTION iWorkBits_Assign( tiPassed )
*==========================
This.iWorkBits= tiPassed
This.SelfConfig()
RETURN

*==========================
FUNCTION SelfConfig( tiWorkBits )
*==========================
LOCAL liWorkBits, lcName, loObj, llObjExists

IF VARTYPE( tiBorkbits ) = "N"
	liWorkBits= tiWorkBits
ELSE
	liWorkBits= This.iWorkBits
ENDIF

DO CASE
CASE LOWER( This.cCaptionCase )= "upper"
	lcLabelexpr= "ALLTRIM( UPPER( cLabel ) )"
CASE LOWER( This.cCaptionCase )= "lower"
	lcLabelexpr= "ALLTRIM( LOWER( cLabel ) )"
OTHERWISE
	lcLabelexpr= "ALLTRIM( PROPER( cLabel ) )"
ENDCASE

IF This.lLoadFromBitTable

	SELECT iBit, &lcLabelexpr AS cLabelstr, iSeq ;
	  FROM ( This.cBitTable ) ;
	 WHERE BITTEST( liWorkBits, iBit ) AND ;
	       cType= "state" AND ;
	       ! EMPTY( cLabel ) ;
	 ORDER BY iSeq ;
	  INTO CURSOR curCtrls

	IF _TALLY > 0
		This.Empty()

		SELECT curCtrls
		SCAN
			IF BITTEST( liWorkBits, iBit )
				lcName= "chk"+ TRANSFORM( iBit )
				This.AddObject( lcName, This.cControlClass, lni, ALLTRIM( cLabel ) )
				loObj= This.&lcName
				loObj.iBindBit= iBit
				loObj.Visible= .T.
				This.Width= MAX( this.Width, loObj.width )
			ENDIF
		ENDSCAN
	ENDIF

ELSE

	FOR lni= 0 TO 31
		lcName= "chk"+ TRANSFORM( lni )
		llObjExists= TYPE( "This."+ lcName ) = "O"
		IF BITTEST( liWorkBits, lni )
			IF ! llObjExists
				This.AddObject( lcName, This.cControlClass, lni, this.aCaptions[ lni+ 1 ] )
				loObj= This.&lcName
				loObj.iBindBit= lni
				loObj.Visible= .T.
				This.Width= MAX( this.Width, loObj.width )
			ENDIF
		ELSE
			IF llObjExists
				This.RemoveObject( lcName )
			ENDIF
		ENDIF
	ENDFOR
	
ENDIF
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
FUNCTION Change
*==========================

ENDDEFINE



*=======================================
DEFINE CLASS chkBit AS Checkbox
*=======================================
iBindBit= -1   && In operation, between 0 and 31
FontSize= 12
Backstyle= 0
Autosize= .T.

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