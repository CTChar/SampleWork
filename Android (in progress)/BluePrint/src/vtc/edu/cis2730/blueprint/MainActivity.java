package vtc.edu.cis2730.blueprint;

import android.os.Bundle;
import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Activity;
import android.graphics.Color;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

@SuppressLint("NewApi")
public class MainActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		_blueFrame = (FrameLayout)findViewById(R.id.bluePrintFrame);
		_mainLayout = (FrameLayout)findViewById(R.id.mainLayout);
		_paletteFrame = (FrameLayout)findViewById(R.id.paletteLayout);
		_actionBar = getActionBar();
		_actionBar.show();
		buildPalette();
	}

	private void buildPalette() 
	{
		FrameLayout.LayoutParams paramsWallVert = new FrameLayout.LayoutParams(25, 30);
		paramsWallVert.topMargin = 950;
		paramsWallVert.leftMargin = 50;
		FrameLayout.LayoutParams paramsWallhor = new FrameLayout.LayoutParams(25, 30);
		paramsWallhor.topMargin = 950;
		paramsWallhor.leftMargin = 150;
		Wall paletteWallHor = new Wall(true, this, _mainLayout);
		Wall paletteWallVer = new Wall(false, this, _mainLayout);
		_mainLayout.addView(paletteWallHor, paramsWallhor);
		_mainLayout.addView(paletteWallVer, paramsWallVert);
		FrameLayout.LayoutParams paramsTagActual = new FrameLayout.LayoutParams(25, 90); 
		TextTag paletteTag = new TextTag(this, _mainLayout);
		paramsTagActual.leftMargin = 400;
		paramsTagActual.topMargin = 1000;
		_mainLayout.addView(paletteTag, paramsTagActual);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) 
	{
		MenuInflater inflater = getMenuInflater();
	    inflater.inflate(R.menu.floormenu, menu);
	    return true;
	}
	
	  public boolean onOptionsItemSelected(MenuItem item) 
	  {
		  if(_blueprint != null)
		  {
		    switch (item.getItemId()) 
		    {
		    	case R.id.floorOne:
		    		_blueprint.switchFloor(1, _blueFrame);
		    	break;
		    	case R.id.floorTwo:
		    		_blueprint.switchFloor(2, _blueFrame);
		    	break;
		    	case R.id.floorThree:
		    		_blueprint.switchFloor(3, _blueFrame);
		    	break;
		    }
		  }
		  return true;
	  } 
	
	public void startNew(View v)
	{
		FrameLayout newFrame = (FrameLayout)findViewById(R.id.newFrame);
		newFrame.setVisibility(0);
	}

	@SuppressLint("NewApi")
	public void confirmNew(View v)
	{
		FrameLayout newFrame = (FrameLayout)findViewById(R.id.newFrame);
		EditText length = (EditText)findViewById(R.id.lengthText);
		EditText width = (EditText)findViewById(R.id.widthText);
		EditText floors = (EditText)findViewById(R.id.floorsText);
		String lenString = String.valueOf(length.getText());
		String widString = String.valueOf(width.getText());
		String floorString = String.valueOf(floors.getText());
		boolean init = false;
		int len = 0;
		int wid = 0;
		int floor = 0;
		
		if((lenString.equals("")) || (widString.equals("")))
		{
			CharSequence text = "Enter Length and Width as integers in feet";
			Toast toast = Toast.makeText(this, text, Toast.LENGTH_SHORT);
			toast.show();
		}
		else
		{
			len = Integer.valueOf(lenString);
			wid = Integer.valueOf(widString);
			if(len > 500)
			{
				len = 500;
			}
			if(wid > 700)
			{
				wid = 700;
			}
			if(floorString.equals(""))
			{
				floor = 1;
			}
			else
			{
				floor = Integer.valueOf(floorString);
			}
			init = true;
			newFrame.setVisibility(4);
		}
		if (init)
		{
			_blueprint = new BluePrint(wid, len, floor, this);
	        _blueFrame.addView(_blueprint);
		}
	}
	BluePrint _blueprint;
	private FrameLayout _blueFrame;
	private FrameLayout _mainLayout;
	private FrameLayout _paletteFrame;
	private ActionBar _actionBar;
}
