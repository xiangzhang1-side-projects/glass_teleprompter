# GDK Dev Textbook

# Use CardBuilder to layout

To use CardBuilder:
1. Create an instance of `CardBuilder`, giving it your desired layout from `CardBuilder.Layout`.
2. Set properties of the card, such as the text, footnote, and timestamp.
3. Call `CardBuilder.getView()` to convert the card to an Android View, or CardBuilder.getRemoteViews() to convert it to a RemoteViews object.
4. Use the View in your activities, layouts, or in a CardScrollView, or use the RemoteViews in a LiveCard.

```js
View view = new CardBuilder(context, CardBuilder.Layout.TEXT) 	// resizeable. alt: TEXT_FIXED
	.setText("A stack indicator can be added to the corner of a card...") 
	.setFootnote("This is the footnote") 						// bottom-left
	.setTimestamp("just now") 									// bottom-right
	.setAttributionIcon(R.drawable.ic_smile) 					// bottom-right r
	.showStackIndicator(true) 									// top-right
	.addImage(R.drawable.image1) 								// background image
	.getView();
```

```js
public class MyActivity extends Activity {

	@Override
	protected void onCreate(Bundle bundle) {
		setContentView(new CardBuilder...);
	}
}
```

# Use CardScrollView to layout

To use CardScrollView:
1. Implement a `CardScrollAdapter` to supply cards to the CardScrollView. 
2. Create a `CardScrollView` that uses the CardScrollAdapter as the supplier for cards.
3. Set your activity's content view to be the CardScrollView or display the CardScrollView in a layout.

```js
public class CardScrollActivity extends Activity {

	// global declare
	private List<CardBuilder> mCards;
	private CardScrollView mCardScrollView;
	private ExampleCardScrollAdapter mAdapter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		mCards = new ArrayList<CardBuilder>();
		mCards.add(new CardBuilder(this, CardBuilder.Layout.TEXT)
				.setText("This card has a footer.")
				.setFootnote("I'm the footer!"));

		mAdapter = new ExampleCardScrollAdapter();

		mCardScrollView = new CardScrollView(this);
		mCardScrollView.setAdapter(mAdapter);
		mCardScrollView.activate();
		setContentView(mCardScrollView);
	}

	private class ExampleCardScrollAdapter extends CardScrollAdapter {

		@Override
		public int getPosition(Object item) {
			return mCards.indexOf(item);
		}

		@Override
		public int getCount() {
			return mCards.size();
		}

		@Override
		public Object getItem(int position) {
			return mCards.get(position);
		}

		@Override
		public int getViewTypeCount() {
			return CardBuilder.getViewTypeCount();
		}

		@Override
		public int getItemViewType(int position){
			return mCards.get(position).getItemViewType();
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			return mCards.get(position).getView(convertView, parent);
		}
	}
}
```

# Start Glassware using Voice Command

1. Add resource to `res/xml/my_voice_trigger.xml`: 
```js
<trigger command="POST_AN_UPDATE">
	<constraints
		microphone="true"
		network="true" />
</trigger>
```
2. In `Android.manifest`/Activity|Service to start, add these
```
	<activity android:icon="@drawable/my_icon">
		<intent-filter>
			<action android:name= "com.google.android.glass.action.VOICE_TRIGGER" />
		</intent-filter>
		<meta-data 
			android:name="com.google.android.glass.VoiceTrigger"
			android:resource="@xml/my_voice_trigger" />
	</activity>
```

Version code must be updated for new-version apk install.

# Immersion Layout

Add `android:immersive="true"` to `<activity>`

---- 

# Skip

Touch Gesture
Live Card (altogether)

# android:onclick 

not a good tutorial

```js
public class AlertDialog extends Dialog {

	private final DialogInterface.OnClickListener mOnClickListener =
		new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int button) {
					// Open WiFi Settings
					startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
				}
		};

	private final GestureDetector.BaseListener mBaseListener =
		new GestureDetector.BaseListener() {
			@Override
			public boolean onGesture(Gesture gesture) {
				if (gesture == Gesture.TAP) {
					mAudioManager.playSoundEffect(Sounds.TAP);
					// Since Glass dialogs do not have buttons, the index passed to onClick is always 0.
					mOnClickListener.onClick(AlertDialog.this, 0);
					return true;
				}
				return false;
			}
		};

	__init__(Context context) {
		
		mAudioManager = 
			(AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
		mGestureDetector =
			new GestureDetector(context).setBaseListener(mBaseListener);
	}

	/** Overridden to let the gesture detector handle a possible tap event. */
	@Override
	public boolean onGenericMotionEvent(MotionEvent event) {
		return mGestureDetector.onMotionEvent(event)
			|| super.onGenericMotionEvent(event);
	}
}
```

---- 

# New Activity

# Invoke New Activity by Intent(thisView, newActivity.class); putExtra; startActivity

# Receive Invocation by getIntent

# Get and set content on page

