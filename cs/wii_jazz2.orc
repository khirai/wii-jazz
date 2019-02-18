sr = 48000
kr = 240
ksmps = 200
nchnls = 2

#define TAB_MEAS # 5 #
#define TAB_SCALE # 6 #
#define TAB_RHY   # 22 #

gar init 0
gal init 0
gkclock init 0

#define WIIINIT(MOTE)
#
gklatch_$MOTE init 0.
gkpch_off_$MOTE init 0
gkbutAinc_$MOTE init 0
gkmeasure_$MOTE init 0
;gilen_meas_$MOTE tableng $TAB_MEAS
gilen_meas_$MOTE init 12
gkpch_$MOTE init 0
gkskipcnt_$MOTE init 0
gkfifth_$MOTE init 0
#

#define WIIINSTR(MOTE)
#
   kleft_$MOTE     wiidata      9, 0
   kright_$MOTE    wiidata     10, 0
   kpitch_$MOTE    wiidata     20, 0  
   kroll_$MOTE     wiidata     21, 0  
   kbutB_$MOTE     wiidata    203, 0  
   kbutA_$MOTE     wiidata     04, 0

   knunZ_$MOTE    wiidata     33, 0
   knunC_$MOTE    wiidata     34, 0

   knunroll_$MOTE  wiidata     31, 0
   knunpitch_$MOTE wiidata     30, 0

   ksustain_$MOTE =  abs(knunpitch_$MOTE/180.0)*4
   kroll_$MOTE    =  abs( kroll_$MOTE/180.0+0.5)
   kpitch_$MOTE   =  abs( kpitch_$MOTE/180.0+0.5)
 
   ; ----smoothing and release for butB

   gklatch_$MOTE=gklatch_$MOTE+(kbutB_$MOTE-gklatch_$MOTE)*0.5

   ; ----harmonic motion keys

      
   gkfifth_$MOTE   = (gkfifth_$MOTE+5*kleft_$MOTE-5*kright_$MOTE+12)%12 \
                      * (1-kbutA_$MOTE)   
   kamp_$MOTE      = (4096*(kroll_$MOTE-1)+4096)*gklatch_$MOTE  
   gkmeasure_$MOTE = (gkmeasure_$MOTE - knunC_$MOTE +knunZ_$MOTE \
                      + gilen_meas_$MOTE) % gilen_meas_$MOTE \
                      *  (1-kbutA_$MOTE)
   kchord_beg_$MOTE  tab  gkmeasure_$MOTE, $TAB_MEAS
   kchord_end_$MOTE  tab  gkmeasure_$MOTE+1, $TAB_MEAS
   kpch_old_$MOTE  = gkpch_$MOTE
   gkpch_$MOTE       tab  kchord_beg_$MOTE+(kchord_end_$MOTE-kchord_beg_$MOTE)\
                          * kpitch_$MOTE, $TAB_SCALE 
   kpch_out_$MOTE  = cpsmidinn(gkpch_$MOTE+gkfifth_$MOTE)

   ; ---- beat quantitization generation

   kskipidx_$MOTE    = int((knunroll_$MOTE+90)/180*24)
;   printk2 kskipidx_$MOTE
   kskip_$MOTE tab kskipidx_$MOTE, $TAB_RHY

   gkskipcnt_$MOTE = (gkskipcnt_$MOTE+1)

   ; event generation

   if gkskipcnt_$MOTE%kskip_$MOTE != 0  kgoto end_evgen
     gkskipcnt_$MOTE = 0
     if kbutB_$MOTE == 0 kgoto end_evgen   
       event "i", 44 ,0 , ksustain_$MOTE, kpch_out_$MOTE, kamp_$MOTE
   end_evgen:

#

$WIIINIT(0)

;;; metronome instrument
instr 9
   
   gkclock = gkclock + 1
   if  gkclock % 196 != 0 kgoto PULSE_END
      event "i", 44, 0 , 0.2 , 440, 8196
   PULSE_END:
endin


instr 10
   ires wiiconnect 2, 1
   al=0
   ar=0

$WIIINSTR(0)

   outs al, ar 

endin

instr 11
al=0
   outs al,al 
endin 

instr  44
   kenv line 1, p3, 0
    aout oscil kenv*p5, p4 ,1
    gal=aout+gal
    gar=aout+gar
    outs aout, aout
endin

instr 99 

       fout "wii_jazz_rec.wav", 14 , gal, gar 
     gal=0
     gar=0

endin

;   kdown_$MOTE     wiidata     11, 0
;   kup_$MOTE       wiidata     12, 0
;   kminus_$MOTE    wiidata      5, 0
;   kplus_$MOTE     wiidata      6, 0
;   kforce_$MOTE    wiidata     26, 0

