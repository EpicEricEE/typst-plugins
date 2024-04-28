#import "/src/lib.typ": shorthands

#set page(width: 4cm, height: auto, margin: 1em)
#show: shorthands.with(
  ($|<-$,   $arrow.l.stop$),
  ($!<-$,   $arrow.l.not$),
  ($<-|$,   $arrow.l.bar$),
  ($<=|$,   $arrow.l.double.bar$),
  ($!->$,   $arrow.not$),
  ($!=>$,   $arrow.double.not$),
  ($!<=>$,  $arrow.double.l.r.not$),
  ($!<==>$, $cancel(length: #35%, angle: #20deg, <==>)$),

  ($!|-$,   $tack.not$),
  ($!|=$,   $tack.double.not$),
  ($|-$,    $tack$),
  ($|=$,    $tack.double$),
  ($-|$,    $tack.l$),
  ($=|$,    $tack.l.double$),

  ($!>$,    $gt.not$),
  ($!>=$,   $gt.not.eq$),
  ($!<$,    $lt.not$),
  ($!<=$,   $lt.not.eq$),
  ($-:$,    $dash.colon$),

  ($!!$,    $excl.double$),
  ($??$,    $quest.double$),
  ($?!$,    $quest.excl$),
  ($!?$,    $excl.quest$)
)

// Arrows
$
  a |<- b \
  a !<- b \
  a <-| b \
  a <=| b \
  a !-> b \
  a !=> b \
  a !<=> b \
  a !<==> b
$

// Relations
$
  a !|- b \
  a !|= b \
  a |- b \
  a |= b \
  a -| b \
  a =| b \

  a !> b \
  a !>= b \
  a !< b \
  a !<= b \
  a -: b
$

// Punctuation
$
  c !! \
  c ?? \
  c ?! \
  c !? \
$
