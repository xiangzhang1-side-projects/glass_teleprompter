# Polishing

# SlideNote Format

1. CardScrollView.   
	Pro: Takes care of sliding.  
	Con1: How to implement timer?  
	Con2: How to invoke sliding from voice-recog?

# Java timer

Not a trivial task. WTF.

Chronometer. COuntdowntimer. [This][1] 2.

# Update Footer with time

If you have a card, `setContentView` after changing.
```js
myCard.setText("First text");
View cardView = myCard.getView();
setContentView(cardView);
```

If you have a scroll, `notifyDataSetChanged` after changing.
```js
mCardList.get(arg2).setText("changed");
//must have this next line to see change reflected in glass
mCardScrollAdapter.notifyDataSetChanged();
```

Which requires manual re-drawing.
Both `Timer` and `Stopwatch` uses manual layout. Probably too intensive.

# XML-based card

## Design

Just change text. 

WAIT. That feels off.


# Timer

In accordance with “don’t stare at timer all the time”, and in sacrifice for good scrolling, 
we update timer foot every time a new card is shown.

# Bluetooth-based connection?

Hacky / long /buggy As Fuck.

[1]:	https://stackoverflow.com/questions/14814714/update-textview-every-second