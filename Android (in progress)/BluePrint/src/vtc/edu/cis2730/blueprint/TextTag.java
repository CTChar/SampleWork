package vtc.edu.cis2730.blueprint;

import android.content.Context;
import android.graphics.Color;
import android.view.MotionEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;

public class TextTag extends EditText implements View.OnTouchListener
{

	public TextTag(Context context, FrameLayout mainLayout) 
	{
		super(context);
		_context = context;
		_mainLayout = mainLayout;
		_isPaletteText = true;
		setClickable(true);
		setOnTouchListener(this);
		setTextColor(Color.WHITE);
		setText("Tag");
		setTextSize(10);
	}

	@Override
	public boolean onTouch(View view, MotionEvent event)
	{
		FrameLayout.LayoutParams params = (android.widget.FrameLayout.LayoutParams) view.getLayoutParams();
		switch(event.getAction())
	    {
		    case MotionEvent.ACTION_MOVE:
		    	_x2 = event.getX();
		    	_y2 = event.getY();
		        float deltax = (int)((_x - _x2) + .5);
		        float deltay = (int)((_y - _y2) + .5);
		        int oldLeftMargin = params.leftMargin;
		        int oldRightMargin = params.rightMargin;
		        int oldTopMargin= params.topMargin;
		        int oldBottomMargin = params.bottomMargin;
		        params.leftMargin = oldLeftMargin - (int) deltax;
		        params.rightMargin = oldRightMargin + (int) deltax;
		        params.topMargin = oldTopMargin - (int) deltay;
		        params.bottomMargin = oldBottomMargin + (int) deltay;
		        view.setLayoutParams(params);
		        break;
		    case MotionEvent.ACTION_UP:
		    	_x = event.getX();
		    	_y = event.getY();
		        break;
		    case MotionEvent.ACTION_DOWN:
		    	if(_isPaletteText)
		    	{
	    			FrameLayout.LayoutParams paramsTag = new FrameLayout.LayoutParams(25, 30);
		    		paramsTag.topMargin = 1000;
		    		paramsTag.leftMargin = 400;
		    		TextTag newPalette = new TextTag(_context, _mainLayout);
		    		_mainLayout.addView(newPalette, paramsTag);
		    		_isPaletteText = false;
		    	}
		        _x = event.getX();
		        _y = event.getY();
		        break;
	    }
	    return false;
	}

	protected void onMeasure(int widthSpec, int heightSpec)
	{
		setMeasuredDimension(100, 60);
	}
	
	protected int getSuggestedMinimumWidth()
	{
		return 10;
	}
	
	protected int getSuggestedMinimumHeight()
	{
		return 10;
	}
	
	Context _context;
	FrameLayout _mainLayout;
	private float _x;
	private float _x2;
	private float _y;
	private float _y2;
	boolean _isPaletteText;
}
